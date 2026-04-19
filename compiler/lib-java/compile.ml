open Instr
open Kind
open Function_info

(* Debug flags. Enable via [JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit]. *)
let debug_times = Debug.find "times"
let debug_primitives = Debug.find "primitives"
let debug_functions = Debug.find "functions"
let debug_ir_emit = Debug.find "ir_emit"


(* Attempt to lower a function body (or the main init range) to the new
   Code IR via [Parse_bytecode]. This is a smoke pass for Phase 1 — the
   legacy forward-walk emitter still runs unconditionally. Failures are
   logged under the [ir] debug flag and otherwise silent; opcodes we
   haven't ported yet (CLOSURE, PUSHTRAP, SWITCH, ENVACC, ...) raise
   [Not_supported], which is expected. *)
let time_phase name f =
  if not (debug_times ())
  then f ()
  else
    let t = Timer.make () in
    let r = f () in
    Format.eprintf "[times] %s: %a s@." name Timer.print t;
    r

(* -------------------------------------------------------------------------- *)
(* Compile-wide driver. *)



(* Emit bytecode that materialises a global-value tree into a live
   [Block]. Used by the globals-init prelude (no State threading
   needed since we target [main]'s [<clinit>]-style setup). Uses
   a fresh JVM local to park the [Object[]] between anewarray and
   the Block ctor call. *)
let rec emit_materialise_value code (v : Global_view.global_field_value) =
  match v with
  | Gv_int n ->
    Jvm.Code.ldc_int code n;
    Kind.emit_box_int code
  | Gv_string s -> Jvm.Code.ldc_string code s
  | Gv_float d ->
    Jvm.Code.ldc_double code d;
    Kind.emit_box_float code
  | Gv_int64 n ->
    (* Truncate to JVM int — most DATA-section int32/int64/nativeint
       constants (Int32.zero, Int64.one, Nativeint.minus_one, etc.)
       fit in 32 bits. Box as Integer so downstream [as_int] unboxes
       via the usual checkcast+intValue. Lossy for 64-bit payloads
       (double-bit-pattern constants, large int64 literals); those
       cases are tracked separately. *)
    Jvm.Code.ldc_int code (Int64.to_int n);
    Kind.emit_box_int code
  | Gv_block (tag, fields) ->
    emit_materialise_block_constant code tag fields
  | Gv_null -> Jvm.Code.aconst_null code

and emit_materialise_block_constant code tag fields =
  let n = List.length fields in
  Jvm.Code.new_ code "Block";
  Jvm.Code.dup code;
  Jvm.Code.ldc_int code tag;
  Jvm.Code.ldc_int code n;
  Jvm.Code.anewarray code "java/lang/Object";
  List.iteri
    (fun i fv ->
      Jvm.Code.dup code;
      Jvm.Code.ldc_int code i;
      emit_materialise_value code fv;
      Jvm.Code.aastore code)
    fields;
  Jvm.Code.invokespecial
    code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"

(* Emit code that populates [Main.GLOBALS] from the bytecode's DATA
   section. Runs first thing in [Main.main] so module init (which
   SETGLOBALs the dynamic module records) sees a pre-populated table
   holding the pre-marshalled values (exception descriptors, atom
   blocks, etc.). Globals whose shape we can't classify statically are
   left [null]; anything that reads them before a SETGLOBAL writes
   them will trip NullPointerException at runtime. *)
let emit_globals_init code globals =
  let n = Array.length globals in
  Jvm.Code.ldc_int code n;
  Jvm.Code.anewarray code "java/lang/Object";
  Jvm.Code.putstatic
    code
    ~class_:"Main"
    ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  for i = 0 to n - 1 do
    match Global_view.inspect_global globals i with
    | G_unsupported -> ()
    | G_int n ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      Jvm.Code.ldc_int code n;
      Kind.emit_box_int code;
      Jvm.Code.aastore code
    | G_string s ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      Jvm.Code.ldc_string code s;
      Jvm.Code.aastore code
    | G_float d ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      Jvm.Code.ldc_double code d;
      emit_box_float code;
      Jvm.Code.aastore code
    | G_int64 n ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      Jvm.Code.ldc_int code (Int64.to_int n);
      Kind.emit_box_int code;
      Jvm.Code.aastore code
    | G_block (tag, fields) ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      emit_materialise_block_constant code tag fields;
      Jvm.Code.aastore code
  done

let compile ~bc ~out_dir =
  let total = if debug_times () then Some (Timer.make ()) else None in
  let parsed = time_phase "parse-bytecode" (fun () -> Bytecode.read_exe bc) in
  let prim_table = Prim.find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int, ...).";
  if debug_primitives ()
  then (
    Format.eprintf "[primitives] resolved %d:@." (Hashtbl.length prim_table);
    Hashtbl.iter
      (fun idx (name, _, seed) ->
        Format.eprintf "  %d -> %s%s@." idx name (if seed then " (seed)" else ""))
      prim_table);
  let instrs = time_phase "decode" (fun () -> decode_all parsed) in
  let arr = Array.of_list instrs in
  let start_idx, end_idx = 0, Array.length arr - 1 in
  if debug_functions ()
  then
    Format.eprintf
      "[functions] whole bytecode: idx %d..%d (pc %d..%d)@."
      start_idx
      end_idx
      arr.(start_idx).pc
      arr.(end_idx).pc;
  (* Pre-scan for every CLOSUREREC / CLOSURE in the whole bytecode. *)
  let functions = Hashtbl.create 64 in
  let func_list = ref [] in
  let fn_body_pcs = Hashtbl.create 64 in
  let fn_count = ref 0 in
  let fn_scan_timer = if debug_times () then Some (Timer.make ()) else None in
  (* First pass: collect every function body_pc up front, so when we
     compute body ranges below we can bound each one by the next
     function's body_pc. Without this bound the range-walker can
     consume sibling bodies whole whenever a forward branch points
     past the natural terminator. *)
  let all_body_pcs = ref [] in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op
    then (
      let nf = ins.args.(0) in
      for k = 0 to nf - 1 do
        all_body_pcs := (ins.pc + 3 + ins.args.(2 + k)) :: !all_body_pcs
      done)
    else if ins.opcode = closure_op
    then all_body_pcs := (ins.pc + ins.args.(1) + 2) :: !all_body_pcs
  done;
  (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
   | Some s when List.mem "setglobals" (String.split_on_char ',' s) ->
     for i = start_idx to end_idx do
       let ins = arr.(i) in
       if ins.opcode = Bytecode.Op.setglobal
       then
         Format.eprintf
           "[setglobal] pc=%d idx=%d@." ins.pc ins.args.(0)
     done
   | _ -> ());
  (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
   | Some s when List.mem "globals" (String.split_on_char ',' s) ->
     let g = parsed.globals in
     for i = 0 to Array.length g - 1 do
       let classified =
         match Global_view.inspect_global g i with
         | G_int n -> Printf.sprintf "G_int %d" n
         | G_string s -> Printf.sprintf "G_string %S" s
         | G_float _ -> "G_float"
         | G_int64 n -> Printf.sprintf "G_int64 %Ld" n
         | G_block _ -> "G_block"
         | G_unsupported -> "G_unsupported"
       in
       Format.eprintf "[global] %d: %s@." i classified
     done
   | _ -> ());
  let sorted_body_pcs =
    List.sort_uniq compare !all_body_pcs |> Array.of_list
  in
  let pc_upper_bound_after pc =
    let n = Array.length sorted_body_pcs in
    let rec find i =
      if i >= n then max_int
      else if sorted_body_pcs.(i) > pc then sorted_body_pcs.(i)
      else find (i + 1)
    in
    find 0
  in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op || ins.opcode = closure_op
    then (
      let recursive = ins.opcode = closurerec_op in
      let nfuncs, nvars, body_pc_of =
        if recursive
        then (
          let nf = ins.args.(0) in
          let nv = ins.args.(1) in
          nf, nv, fun k -> ins.pc + 3 + ins.args.(2 + k))
        else (
          let nv = ins.args.(0) in
          1, nv, fun _ -> ins.pc + ins.args.(1) + 2)
      in
      let group = Array.make nfuncs (Obj.magic () : function_info) in
      for k = 0 to nfuncs - 1 do
        let body_pc = body_pc_of k in
        let pc_upper_bound = pc_upper_bound_after body_pc in
        let body_start_idx, body_end_idx, nargs =
          find_function_body_range arr ~pc_upper_bound body_pc
        in
        let name = Printf.sprintf "ocaml_fn_%d" !fn_count in
        incr fn_count;
        let info =
          { name
          ; closurerec_pc = ins.pc
          ; body_pc
          ; body_start_idx
          ; body_end_idx
          ; nargs
          ; ncaps = nvars
          ; return_kind = ref K_int
          ; arg_kinds = ref (List.init nargs (fun _ -> K_int))
          ; capture_kinds = ref []
          ; recursive
          ; group_idx = k
          ; group = [||]
          }
        in
        group.(k) <- info;
        if k = 0 then Hashtbl.add functions ins.pc info;
        func_list := info :: !func_list;
        let pre_start =
          let rec find i =
            if i >= Array.length arr then i
            else if arr.(i).pc = body_pc then i
            else find (i + 1)
          in
          find 0
        in
        for j = pre_start to body_end_idx do
          Hashtbl.replace fn_body_pcs arr.(j).pc ()
        done
      done;
      Array.iter (fun info -> info.group <- group) group)
  done;
  (match fn_scan_timer with
   | Some t ->
     Format.eprintf
       "[times] function-scan (%d fns): %a s@."
       !fn_count
       Timer.print
       t
   | None -> ());
  let fn_by_name = Hashtbl.create 64 in
  List.iter
    (fun (fi : function_info) -> Hashtbl.add fn_by_name fi.name fi)
    !func_list;
  (* Legacy-only kind inference removed. The IR path uses
     [Jvm_typing.infer] on each function's Code.program instead. *)
  if debug_functions ()
  then
    List.iter
      (fun (fi : function_info) ->
        Format.eprintf
          "[functions] %s: nargs=%d ncaps=%d pc=%d body=[%d..%d] return=%s \
           args=[%s]@."
          fi.name
          fi.nargs
          fi.ncaps
          fi.body_pc
          fi.body_start_idx
          fi.body_end_idx
          (string_of_kind !(fi.return_kind))
          (String.concat "," (List.map string_of_kind !(fi.arg_kinds))))
      !func_list;
  let cp = Jvm.Cp.create () in
  let main_code = Jvm.Code.create cp in
  (* Globals-init prelude is emitted later — after we've decided
     between IR and legacy for the main body, so a failed IR attempt
     doesn't leave half-written globals-init bytes in [main_code]. *)
  let _ = end_idx in
  time_phase "emit-main" (fun () ->
    let body_pc_to_fi = Hashtbl.create 64 in
    List.iter
      (fun (fi : function_info) -> Hashtbl.replace body_pc_to_fi fi.body_pc fi)
      !func_list;
    let name_of_body pc =
      match Hashtbl.find_opt body_pc_to_fi pc with
      | Some fi -> fi.name
      | None -> raise Not_found
    in
    let fn_info_of_body pc = Hashtbl.find_opt body_pc_to_fi pc in
    let prim_name idx =
      if idx < 0 || idx >= Array.length parsed.prims
      then raise Not_found
      else parsed.prims.(idx)
    in
    let try_main_ir () =
        (* Don't filter out fn_body_pcs — the parser's block-boundary
           scan needs the full instruction stream to find successor
           PCs via addr_map. Function bodies aren't reachable via
           fall-through (their entry pc is only ever a caller of
           a CLOSURE/CLOSUREREC body-pc argument, which doesn't
           appear in [Instr.branch_targets]), so they won't get
           processed as blocks. *)
        let instrs = Array.to_list arr in
        match instrs with
        | [] -> None
        | first :: _ ->
          let last = List.nth instrs (List.length instrs - 1) in
          let start_pc = first.pc in
          let end_pc = last.pc + 1 in
          (* Emit into a scratch code so we can discard on IR
             failure without contaminating main_code. *)
          let scratch = Jvm.Code.create cp in
          Jvm.Code.set_min_locals scratch 1;
          (try
             let prog = Parse_bytecode.parse_main instrs ~start_pc ~end_pc in
             let typing = Jvm_typing.infer prog in
             Jvm_generate.emit_program
               ~code:scratch
               ~typing
               ~name_of_body
               ~fn_info_of_body
               ~prim_name
               prog;
             if debug_ir_emit ()
             then Format.eprintf "[ir_emit] <main>: used IR@.";
             Some scratch
           with
           | Parse_bytecode.Not_supported msg ->
             if debug_ir_emit ()
             then
               Format.eprintf "[ir_emit] <main>: legacy (parse: %s)@." msg;
             None
           | Jvm_generate.Unsupported msg ->
             if debug_ir_emit ()
             then
               Format.eprintf "[ir_emit] <main>: legacy (gen: %s)@." msg;
             None)
    in
    (match try_main_ir () with
     | Some _scratch_ir_code ->
       emit_globals_init main_code parsed.globals;
       let instrs = Array.to_list arr in
       let first = List.hd instrs in
       let last = List.nth instrs (List.length instrs - 1) in
       let prog =
         Parse_bytecode.parse_main
           instrs
           ~start_pc:first.pc
           ~end_pc:(last.pc + 1)
       in
       let typing = Jvm_typing.infer prog in
       Jvm_generate.emit_program
         ~code:main_code
         ~typing
         ~name_of_body
         ~fn_info_of_body
         ~prim_name
         prog
     | None ->
       emit_globals_init main_code parsed.globals;
       Jvm.Code.new_ main_code "java/lang/UnsupportedOperationException";
       Jvm.Code.dup main_code;
       Jvm.Code.ldc_string
         main_code
         "IR emitter gave up on main init; legacy retired";
       Jvm.Code.invokespecial
         main_code
         ~class_:"java/lang/UnsupportedOperationException"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.athrow main_code));
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code = main_code
    }
  in
  let globals_field =
    { Jvm.name = "GLOBALS"
    ; descriptor = "[Ljava/lang/Object;"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    }
  in
  let dls_field =
    { Jvm.name = "DLS_STATE"
    ; descriptor = "Ljava/lang/Object;"
    ; access_flags = 0x0009
    }
  in
  let main_class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[ globals_field; dls_field ]
      ~methods:[ main_method ]
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
  in
  let closure_class_files = time_phase "emit-closures" (fun () ->
    List.map
      (fun (fn_info : function_info) ->
        let cap_kinds = !(fn_info.capture_kinds) in
        let ncaps = List.length cap_kinds in
        let fn_cp = Jvm.Cp.create () in
        let ctor_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals ctor_code (1 + ncaps);
        Jvm.Code.aload ctor_code 0;
        Jvm.Code.invokespecial
          ctor_code
          ~class_:"Closure"
          ~method_:"<init>"
          ~descriptor:"()V";
        List.iteri
          (fun i k ->
            Jvm.Code.aload ctor_code 0;
            emit_load_for_kind ctor_code (i + 1) k;
            Jvm.Code.putfield
              ctor_code
              ~class_:fn_info.name
              ~field:(Printf.sprintf "cap%d" i)
              ~descriptor:(jvm_type_of_kind k))
          cap_kinds;
        Jvm.Code.return_void ctor_code;
        let apply_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
        (* Emit the apply body from the IR. On IR failure, write a
           runtime-throwing stub into [apply_code] so the class
           still loads. *)
        let try_ir () =
          let body_pc = arr.(fn_info.body_start_idx).pc in
          let end_pc = arr.(fn_info.body_end_idx).pc in
          try
              let prog, params, env_var =
                Parse_bytecode.parse_function
                  (Array.to_list arr)
                  ~start_pc:body_pc
                  ~end_pc:(end_pc + 1)
                  ~nargs:fn_info.nargs
                  ~ncaps
              in
              let arg_vars =
                let rec take n = function
                  | _ when n = 0 -> []
                  | [] -> []
                  | x :: xs -> x :: take (n - 1) xs
                in
                take fn_info.nargs params
              in
              let ir_code = Jvm.Code.create fn_cp in
              Jvm.Code.set_min_locals ir_code (1 + fn_info.nargs);
              let typing = Jvm_typing.infer prog in
              let body_pc_to_fi = Hashtbl.create 64 in
              Hashtbl.iter
                (fun _name fi ->
                  Hashtbl.replace body_pc_to_fi fi.Function_info.body_pc fi)
                fn_by_name;
              let name_of_body pc =
                match Hashtbl.find_opt body_pc_to_fi pc with
                | Some fi -> fi.Function_info.name
                | None -> raise Not_found
              in
              let fn_info_of_body pc = Hashtbl.find_opt body_pc_to_fi pc in
              let prim_name idx =
                if idx < 0 || idx >= Array.length parsed.prims
                then raise Not_found
                else parsed.prims.(idx)
              in
              Jvm_generate.emit_program
                ~code:ir_code
                ~typing
                ~name_of_body
                ~fn_info_of_body
                ~prim_name
                ~arg_vars
                ~enclosing:(fn_info, env_var)
                prog;
              if debug_ir_emit ()
              then Format.eprintf "[ir_emit] %s: used IR@." fn_info.name;
              Some ir_code
            with
            | Parse_bytecode.Not_supported msg ->
              if debug_ir_emit ()
              then
                Format.eprintf
                  "[ir_emit] %s: legacy (parse: %s)@."
                  fn_info.name
                  msg;
              None
            | Jvm_generate.Unsupported msg ->
              if debug_ir_emit ()
              then
                Format.eprintf
                  "[ir_emit] %s: legacy (gen: %s)@."
                  fn_info.name
                  msg;
              None
        in
        let apply_code =
          match try_ir () with
          | Some ir_code -> ir_code
          | None ->
            (* IR couldn't handle this function. Emit a method body
               that throws at runtime so the class still loads;
               anything that actually invokes it will see a
               descriptive UnsupportedOperationException. Avoids
               needing the legacy forward-walk emitter as a
               fallback. *)
            Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
            Jvm.Code.new_
              apply_code
              "java/lang/UnsupportedOperationException";
            Jvm.Code.dup apply_code;
            Jvm.Code.ldc_string
              apply_code
              (Printf.sprintf
                 "IR emitter gave up on %s; legacy retired"
                 fn_info.name);
            Jvm.Code.invokespecial
              apply_code
              ~class_:"java/lang/UnsupportedOperationException"
              ~method_:"<init>"
              ~descriptor:"(Ljava/lang/String;)V";
            Jvm.Code.athrow apply_code;
            apply_code
        in
        let cap_fields =
          List.mapi
            (fun i k ->
              { Jvm.name = Printf.sprintf "cap%d" i
              ; descriptor = jvm_type_of_kind k
              ; access_flags = 0x0011
              })
            cap_kinds
        in
        let sibling_fields =
          let n = Array.length fn_info.group in
          if n <= 1
          then []
          else
            List.init n (fun i ->
              { Jvm.name = Printf.sprintf "sibling_%d" i
              ; descriptor = "LClosure;"
              ; access_flags = 0x0001
              })
        in
        let fields = cap_fields @ sibling_fields in
        let ctor =
          { Jvm.name = "<init>"
          ; descriptor =
              (let b = Buffer.create 16 in
               Buffer.add_char b '(';
               List.iter
                 (fun k -> Buffer.add_string b (jvm_type_of_kind k))
                 cap_kinds;
               Buffer.add_string b ")V";
               Buffer.contents b)
          ; access_flags = 0x0001
          ; code = ctor_code
          }
        in
        let apply_method =
          { Jvm.name = Printf.sprintf "apply%d" fn_info.nargs
          ; descriptor =
              (let b = Buffer.create 16 in
               Buffer.add_char b '(';
               for _ = 1 to fn_info.nargs do
                 Buffer.add_string b "Ljava/lang/Object;"
               done;
               Buffer.add_string b ")Ljava/lang/Object;";
               Buffer.contents b)
          ; access_flags = 0x0001
          ; code = apply_code
          }
        in
        let arity_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals arity_code 1;
        Jvm.Code.ldc_int arity_code fn_info.nargs;
        Jvm.Code.ireturn arity_code;
        let arity_method =
          { Jvm.name = "arity"
          ; descriptor = "()I"
          ; access_flags = 0x0001
          ; code = arity_code
          }
        in
        let bytes =
          Jvm.assemble_class
            ~class_name:fn_info.name
            ~super_name:"Closure"
            ~cp:fn_cp
            ~fields
            ~methods:[ ctor; arity_method; apply_method ]
            ~access_flags:0x0031
        in
        fn_info.name, bytes)
      !func_list)
  in
  let write_class name bytes =
    let path = Filename.concat out_dir (name ^ ".class") in
    let oc = open_out_bin path in
    output_string oc bytes;
    close_out oc
  in
  time_phase "write-classes" (fun () ->
    write_class "Main" main_class_bytes;
    write_class "Block" (Jvm.block_class_bytes ());
    write_class "Closure" (Jvm.closure_class_bytes ());
    write_class "CamlException" (Jvm.camlexception_class_bytes ());
    write_class "PartialClosure" (Jvm.partial_closure_class_bytes ());
    write_class "Compare" (Jvm.compare_class_bytes ());
    write_class "Channel" (Jvm.channel_class_bytes ());
    write_class "Bytes" (Jvm.bytes_class_bytes ());
    write_class "Format" (Jvm.format_class_bytes ());
    List.iter (fun (name, bytes) -> write_class name bytes) closure_class_files);
  match total with
  | Some t -> Format.eprintf "[times] total: %a s@." Timer.print t
  | None -> ()
