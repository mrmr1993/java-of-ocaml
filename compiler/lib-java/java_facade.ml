(* See [java_facade.mli]. Step 3 of [docs/JAVA_FACADE.md §8]: first
   emission pass, scoped to int / int64 / string bindings and
   first-order curried functions over them. Anything else skips
   with a warning.

   The generated class is structurally tiny:

       public final class <FQCN> {
         private static volatile boolean $initialised = false;
         private <FQCN>() {}

         public static synchronized void init() {
           if ($initialised) return;
           Main.main(new String[0]);
           $initialised = true;
         }

         // for each exported binding:
         public static <ret> <name>(<args>) {
           init();
           Object mod = Main.GLOBALS[mod_idx];
           Object val = ((Block) mod).fields[field_idx];
           // non-function: unbox and return
           // function:     ((Closure) val).apply<N>(boxed args) -> unbox
         }
       }

   The facade sits on top of the existing Main.GLOBALS / Block /
   Closure machinery. It never mutates module state and owns no
   runtime representation of its own. *)

module K = Cmi_reader

type export =
  { outer : string
  ; sub_path : string list
  ; fqcn : string
  }

let dotted_name exp =
  String.concat "." (exp.outer :: exp.sub_path)

type facade_class =
  { jvm_name : string
  ; bytes : string
  }

(* --- FQCN normalisation -------------------------------------------- *)

let fqcn_to_internal fqcn =
  String.map (fun c -> if c = '.' then '/' else c) fqcn

(* --- Resolve modname -> Main.GLOBALS index ------------------------- *)

(* Walk the full instruction stream for [setglobal] ops. Each one
   fires exactly once, at the end of its owning unit's init code, and
   its argument is the [GLOBALS] slot the module's block is stored
   in. Match up the pc against [parsed.units] to recover the mapping.

   Executables compiled without [-g] have [parsed.units = []]; we
   error out in that case rather than guess. *)
let build_module_index (parsed : Bytecode.t) : (string, int) Hashtbl.t =
  let out = Hashtbl.create 16 in
  if parsed.units = []
  then out
  else
    let unit_arr = Array.of_list parsed.units in
    let unit_of_pc pc =
      let rec loop i =
        if i >= Array.length unit_arr then None
        else
          let u = unit_arr.(i) in
          if pc >= u.start_pc && pc < u.end_pc then Some u
          else loop (i + 1)
      in
      loop 0
    in
    let instrs = Instr.decode_all parsed in
    List.iter
      (fun (ins : Instr.instr) ->
        if ins.opcode = Bytecode.Op.setglobal
        then
          match unit_of_pc ins.pc with
          | None -> ()
          | Some u ->
            (* Multiple setglobals inside one unit is unexpected —
               the OCaml bytecode compiler emits one per unit. If it
               happens we keep the last one, which matches runtime
               observable state. *)
            Hashtbl.replace out u.modname ins.args.(0))
      instrs;
    out

(* --- JVM descriptor helpers ---------------------------------------- *)

let jvm_desc_of_kind = function
  | K.K_int -> "I"
  | K.K_long -> "J"
  | K.K_string -> "Ljava/lang/String;"
  | K.K_float -> "D"
  | K.K_bool -> "Z"
  | K.K_unit -> "V"
  | K.K_other | K.K_fun _ -> "Ljava/lang/Object;"

let method_descriptor ~args ~ret =
  let b = Buffer.create 32 in
  Buffer.add_char b '(';
  List.iter (fun k -> Buffer.add_string b (jvm_desc_of_kind k)) args;
  Buffer.add_char b ')';
  Buffer.add_string b (jvm_desc_of_kind ret);
  Buffer.contents b

(* Whether we have enough support for this binding's kind to generate
   a facade method. Step 3 supports int / long / string, plus first-
   order functions whose arg+return are all supported. *)
let supported_scalar = function
  | K.K_int | K.K_long | K.K_string -> true
  | _ -> false

let supports_binding (b : K.binding) =
  match b.kind with
  | k when supported_scalar k -> true
  | K.K_fun (args, ret) ->
    List.for_all supported_scalar args && supported_scalar ret
  | _ -> false

(* --- Emission helpers ---------------------------------------------- *)

(* JVM local-slot width: long/double occupy two slots, everything
   else one. Needed to lay out method parameters. *)
let slots_of_kind = function
  | K.K_long | K.K_float -> 2
  | _ -> 1

(* Load parameter at a given JVM local index, widened into whatever
   Java type its descriptor declares. Used for loading facade-method
   args before boxing. *)
let load_param code ~kind ~slot =
  let open Jvm.Code in
  match kind with
  | K.K_int | K.K_bool -> iload code slot
  | K.K_long -> lload code slot
  | K.K_float -> dload code slot
  | K.K_string | K.K_other | K.K_fun _ -> aload code slot
  | K.K_unit ->
    (* unit arg — shouldn't happen for a real Java caller but keep
       the load shape uniform by pushing a null. *)
    aconst_null code

(* Box a scalar to the appropriate reference type (Integer / Long /
   ...) so it can be stashed into an Object[] arg array. Leaves the
   boxed value on the stack. String / reference kinds are no-ops. *)
let box_scalar code = function
  | K.K_int ->
    Jvm.Code.invokestatic code ~class_:"java/lang/Integer"
      ~method_:"valueOf" ~descriptor:"(I)Ljava/lang/Integer;"
  | K.K_long ->
    Jvm.Code.invokestatic code ~class_:"java/lang/Long"
      ~method_:"valueOf" ~descriptor:"(J)Ljava/lang/Long;"
  | K.K_float ->
    Jvm.Code.invokestatic code ~class_:"java/lang/Double"
      ~method_:"valueOf" ~descriptor:"(D)Ljava/lang/Double;"
  | K.K_bool ->
    Jvm.Code.invokestatic code ~class_:"java/lang/Boolean"
      ~method_:"valueOf" ~descriptor:"(Z)Ljava/lang/Boolean;"
  | K.K_string | K.K_other | K.K_fun _ | K.K_unit -> ()

(* Coerce an Object on the stack back to the target kind and return
   it. Mirrors [Block.asLong] for long; for int/string we [checkcast]
   and unbox via [intValue] / identity. *)
let unbox_and_return code = function
  | K.K_int ->
    (* OCaml [int]s arrive boxed as either [Integer] or [Long]
       depending on whether the producing path widened to JVM long
       (e.g. constants routed through [Block.asLong]). [Block.asLong]
       coerces both shapes to a primitive long, which [l2i] then
       narrows to the JVM int we return. *)
    Jvm.Code.invokestatic code ~class_:"Block" ~method_:"asLong"
      ~descriptor:"(Ljava/lang/Object;)J";
    Jvm.Code.l2i code;
    Jvm.Code.ireturn code
  | K.K_long ->
    Jvm.Code.invokestatic code ~class_:"Block" ~method_:"asLong"
      ~descriptor:"(Ljava/lang/Object;)J";
    Jvm.Code.lreturn code
  | K.K_string ->
    Jvm.Code.checkcast code "java/lang/String";
    Jvm.Code.areturn code
  | K.K_float ->
    Jvm.Code.checkcast code "java/lang/Double";
    Jvm.Code.invokevirtual code ~class_:"java/lang/Double"
      ~method_:"doubleValue" ~descriptor:"()D";
    Jvm.Code.dreturn code
  | K.K_bool ->
    Jvm.Code.checkcast code "java/lang/Boolean";
    Jvm.Code.invokevirtual code ~class_:"java/lang/Boolean"
      ~method_:"booleanValue" ~descriptor:"()Z";
    Jvm.Code.ireturn code
  | K.K_other | K.K_fun _ -> Jvm.Code.areturn code
  | K.K_unit ->
    Jvm.Code.pop_top code;
    Jvm.Code.return_void code

(* Push [Main.GLOBALS[mod_idx]] onto the stack as an Object. *)
let push_module code ~mod_idx =
  Jvm.Code.getstatic code ~class_:"Main" ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.ldc_int code mod_idx;
  Jvm.Code.aaload code

(* Push the binding's field out of the module-block onto the stack
   as an Object. Assumes module is already on top of stack; consumes
   it and leaves the field value. *)
let push_module_field code ~field_idx =
  Jvm.Code.checkcast code "Block";
  Jvm.Code.getfield code ~class_:"Block" ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.ldc_int code field_idx;
  Jvm.Code.aaload code

(* --- Init method + default constructor ---------------------------- *)

let emit_init_method ~facade_class ~cp =
  let code = Jvm.Code.create cp in
  let open Jvm.Code in
  let return_lbl = fresh_label code in
  (* if ($initialised) return; *)
  getstatic code ~class_:facade_class ~field:"$initialised"
    ~descriptor:"Z";
  ifne code return_lbl;
  (* Main.main(new String[0]); *)
  ldc_int code 0;
  anewarray code "java/lang/String";
  invokestatic code ~class_:"Main" ~method_:"main"
    ~descriptor:"([Ljava/lang/String;)V";
  (* $initialised = true; *)
  ldc_int code 1;
  putstatic code ~class_:facade_class ~field:"$initialised"
    ~descriptor:"Z";
  mark_label code return_lbl;
  return_void code;
  { Jvm.name = "init"
  ; descriptor = "()V"
  ; access_flags = 0x0029   (* public static synchronized *)
  ; code
  }

let emit_private_ctor ~cp =
  let code = Jvm.Code.create cp in
  let open Jvm.Code in
  set_min_locals code 1;
  aload code 0;
  invokespecial code ~class_:"java/lang/Object" ~method_:"<init>"
    ~descriptor:"()V";
  return_void code;
  { Jvm.name = "<init>"
  ; descriptor = "()V"
  ; access_flags = 0x0002   (* private *)
  ; code
  }

(* --- Top-level class assembly ------------------------------------- *)

(* Walk the field-chain from the outer module's block down to the
   target nested module. Emits, for each index [i] in [chain]:
     (Block) .fields[i]
   leaving the nested module's block on top of stack. If [chain] is
   empty, stack is unchanged. *)
let walk_field_chain code chain =
  List.iter
    (fun idx ->
      Jvm.Code.checkcast code "Block";
      Jvm.Code.getfield code ~class_:"Block" ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code idx;
      Jvm.Code.aaload code)
    chain

let emit_one_class ~parsed ~cmi_paths ~(exp : export) ~module_index
    : facade_class option
  =
  let dname = dotted_name exp in
  match Hashtbl.find_opt module_index exp.outer with
  | None ->
    failwith
      (Printf.sprintf
         "java_of_ocaml --export-module %s: outer module %s not found \
          in the linked bytecode (parsed.units has %d entries)"
         dname
         exp.outer
         (List.length parsed.Bytecode.units))
  | Some mod_idx ->
    let cmi =
      match exp.sub_path with
      | [] ->
        Cmi_reader.read ~search_paths:cmi_paths ~modname:exp.outer
      | sub_path ->
        Cmi_reader.read_path ~search_paths:cmi_paths
          ~outer:exp.outer ~sub_path
    in
    let supported, skipped =
      List.partition supports_binding cmi.bindings
    in
    List.iter
      (fun (b : K.binding) ->
        Format.eprintf
          "[java-facade] skipping %s.%s: unsupported kind@."
          dname b.name)
      skipped;
    if supported = []
    then (
      Format.eprintf
        "[java-facade] module %s has no supported bindings; no class \
         emitted@."
        dname;
      None)
    else
      let jvm_name = fqcn_to_internal exp.fqcn in
      let cp = Jvm.Cp.create () in
      let methods = ref [] in
      let add_method m = methods := m :: !methods in
      add_method (emit_private_ctor ~cp);
      add_method (emit_init_method ~facade_class:jvm_name ~cp);
      List.iter
        (fun b ->
          let code = Jvm.Code.create cp in
          let open Jvm.Code in
          invokestatic code ~class_:jvm_name ~method_:"init"
            ~descriptor:"()V";
          push_module code ~mod_idx;
          walk_field_chain code cmi.field_chain;
          push_module_field code ~field_idx:b.K.field_index;
          let arg_kinds, ret_kind =
            match b.kind with
            | K.K_fun (args, ret) -> args, ret
            | k -> [], k
          in
          (match arg_kinds with
           | [] -> unbox_and_return code ret_kind
           | _ ->
             checkcast code "Closure";
             let slot = ref 0 in
             List.iter
               (fun k ->
                 load_param code ~kind:k ~slot:!slot;
                 box_scalar code k;
                 slot := !slot + slots_of_kind k)
               arg_kinds;
             let n = List.length arg_kinds in
             let descriptor =
               let buf = Buffer.create 32 in
               Buffer.add_char buf '(';
               for _ = 1 to n do
                 Buffer.add_string buf "Ljava/lang/Object;"
               done;
               Buffer.add_string buf ")Ljava/lang/Object;";
               Buffer.contents buf
             in
             invokevirtual code ~class_:"Closure"
               ~method_:(Printf.sprintf "apply%d" n) ~descriptor;
             unbox_and_return code ret_kind);
          add_method
            { Jvm.name = b.name
            ; descriptor = method_descriptor ~args:arg_kinds ~ret:ret_kind
            ; access_flags = 0x0009
            ; code
            })
        supported;
      let fields =
        [ { Jvm.name = "$initialised"
          ; descriptor = "Z"
          ; access_flags = 0x004A
          }
        ]
      in
      let bytes =
        Jvm.assemble_class
          ~source_file:("<facade:" ^ dname ^ ">")
          ~class_name:jvm_name
          ~super_name:"java/lang/Object"
          ~cp
          ~fields
          ~methods:(List.rev !methods)
          ~access_flags:0x0031
          ()
      in
      Some { jvm_name; bytes }

let emit ~parsed ~cmi_paths ~exports =
  let module_index = build_module_index parsed in
  List.filter_map
    (fun exp -> emit_one_class ~parsed ~cmi_paths ~exp ~module_index)
    exports
