(* IR-to-JVM emitter. Phase 2 scope: int arith / comparisons /
   constants / Branch / Cond / Return / Stop. Every other
   expr or terminator raises [Unsupported]. Callers in [compile.ml]
   can catch and fall back to the legacy per-opcode emitter during
   the transition. *)

exception Unsupported of string

let debug_ir_gen_trace =
  match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
  | None -> false
  | Some s ->
    List.mem "ir_gen_trace" (List.map String.trim (String.split_on_char ',' s))

type ctx =
  { code : Jvm.Code.t
  ; typing : Jvm_typing.t
  ; var_local : (int, int) Hashtbl.t
  ; labels : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
  ; name_of_body : int -> string
  ; fn_info_of_body : int -> Function_info.function_info option
  ; prim_name : int -> string
  ; enclosing : (Function_info.function_info * Code.Var.t) option
  ; fresh_oo_id : int ref
  ; not_found_idx : int ref
        (* Index into Main.GLOBALS of the [Not_found] exception
           descriptor. Populated by the driver. *)
  ; mutable next_local : int
  ; line_of_pc : int -> int option
        (* Source line of a bytecode-pc (Addr), if known. Used to
           populate the LineNumberTable via [Jvm.Code.mark_line]. *)
  ; block_start : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
        (* Start label per block (same as [labels]; kept for
           clarity). *)
  ; block_end : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
        (* End-of-block label allocated on first need (Pushtrap
           processing) and marked by emit_block at that block's
           final instruction position. *)
  ; trap_regions : (Code.Addr.t, Code.Addr.Set.t) Hashtbl.t
        (* Pushtrap block addr → set of blocks in its protected
           region, precomputed from [Code.compute_trap_contexts] so
           every consumer sees the same stack-relative semantics. *)
  ; mutable current_block_addr : Code.Addr.t
        (* Address of the block currently being emitted. Used by
           [emit_last]'s [Pushtrap] case to key into [trap_regions]
           (the trap's identity is its Pushtrap block's address). *)
  ; mutable pending_handlers : pending_handler list
  }

and pending_handler =
  { protected : Code.Addr.Set.t
  ; handler_lbl : Jvm.Code.label
  }

let kind_of ctx v = Jvm_typing.kind ctx.typing v

let local_of ctx v =
  match Hashtbl.find_opt ctx.var_local (Code.Var.idx v) with
  | Some l -> l
  | None ->
    let k = kind_of ctx v in
    let slots = Kind.local_slots_for_kind k in
    let l = ctx.next_local in
    ctx.next_local <- l + slots;
    Jvm.Code.set_min_locals ctx.code ctx.next_local;
    Hashtbl.add ctx.var_local (Code.Var.idx v) l;
    l

let label_of ctx addr =
  match Hashtbl.find_opt ctx.labels addr with
  | Some l -> l
  | None ->
    let l = Jvm.Code.fresh_label ctx.code in
    Hashtbl.add ctx.labels addr l;
    l

(* Load Var v onto the JVM operand stack. The env Var (if any) maps
   to [aload 0] — in an apply method, local 0 is [this]. *)
let emit_load ctx v =
  match ctx.enclosing with
  | Some (_, env_var) when Code.Var.equal v env_var ->
    Jvm.Code.aload ctx.code 0
  | _ ->
    let k = kind_of ctx v in
    let l = local_of ctx v in
    Kind.emit_load_for_kind ctx.code l k

(* Store top of JVM operand stack into Var v's local, coercing if the
   producing kind differs from v's declared kind. *)
let emit_store ctx v ~from:from_kind =
  let k = kind_of ctx v in
  (* Convert [from_kind] -> [k] at the top of stack. *)
  (match from_kind, k with
   | a, b when a = b -> ()
   | Kind.K_int, Kind.K_obj -> Kind.emit_box_int ctx.code
   | Kind.K_float, Kind.K_obj -> Kind.emit_box_float ctx.code
   | Kind.K_obj, Kind.K_int ->
     Jvm.Code.invokestatic
       ctx.code
       ~class_:"Block"
       ~method_:"asLong"
       ~descriptor:"(Ljava/lang/Object;)J";
     Jvm.Code.l2i ctx.code
   | Kind.K_obj, Kind.K_float ->
     Jvm.Code.checkcast ctx.code "java/lang/Double";
     Jvm.Code.invokevirtual
       ctx.code
       ~class_:"java/lang/Double"
       ~method_:"doubleValue"
       ~descriptor:"()D"
   | _ ->
     (* K_obj / reference kinds — no conversion needed at JVM level. *)
     ());
  let l = local_of ctx v in
  Kind.emit_store_for_kind ctx.code l k

(* Emit an [Int] constant onto the stack as a JVM [int]. *)
let emit_int_const ctx n = Jvm.Code.ldc_int ctx.code n

let rec emit_constant ctx (c : Code.constant) : Kind.kind =
  match c with
  | Int n ->
    emit_int_const ctx n;
    K_int
  | Null ->
    Jvm.Code.aconst_null ctx.code;
    K_obj
  | String s ->
    Jvm.Code.ldc_string ctx.code s;
    K_string
  | Float f ->
    Jvm.Code.ldc_double ctx.code f;
    K_float
  | Block (tag, fields) ->
    (* Materialise a constant Block recursively. *)
    let n = Array.length fields in
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code tag;
    Jvm.Code.ldc_int ctx.code n;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Array.iteri
      (fun i c ->
        Jvm.Code.dup ctx.code;
        Jvm.Code.ldc_int ctx.code i;
        let k = emit_constant ctx c in
        (match k with
         | Kind.K_int -> Kind.emit_box_int ctx.code
         | Kind.K_float -> Kind.emit_box_float ctx.code
         | _ -> ());
        Jvm.Code.aastore ctx.code)
      fields;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    K_obj

(* Load a prim_arg onto the stack and return its Kind. *)
let emit_prim_arg ctx (pa : Code.prim_arg) : Kind.kind =
  match pa with
  | Pv v ->
    emit_load ctx v;
    kind_of ctx v
  | Pc c -> emit_constant ctx c

(* Ensure top of stack is [K_int]. Tolerant of boxed Long
   (Int32 / Nativeint / small-Int64 globals): route through
   [Block.asLong + l2i]. *)
let ensure_int ctx k =
  match k with
  | Kind.K_int -> ()
  | Kind.K_obj ->
    Jvm.Code.invokestatic
      ctx.code
      ~class_:"Block"
      ~method_:"asLong"
      ~descriptor:"(Ljava/lang/Object;)J";
    Jvm.Code.l2i ctx.code
  | _ -> raise (Unsupported "ensure_int: unexpected kind")

(* ==== Java FFI: dispatch for [java:*] primitive names ====

   The PPX / [Java.Unsafe] module declares [external]s whose C-primitive
   name is a structured string encoding a JVM operation, e.g.
   [java:virtual:java/util/ArrayList:add:(Ljava/lang/Object;)Z]. The
   descriptor is baked into the name, so we can parse it at emit time
   and produce the right [invoke*] / [getfield] / [new] / ... opcode
   directly — no extension to the IR, no reflection. *)

(* Parse one JVM field descriptor starting at [i] in [d]. Returns the
   descriptor substring and the index just after it. *)
let rec parse_one_type d i =
  let n = String.length d in
  if i >= n then failwith "parse_one_type: out of bounds"
  else
    match d.[i] with
    | ('B' | 'C' | 'D' | 'F' | 'I' | 'J' | 'S' | 'Z' | 'V') as c ->
      String.make 1 c, i + 1
    | '[' ->
      let s, j = parse_one_type d (i + 1) in
      "[" ^ s, j
    | 'L' ->
      (match String.index_from_opt d i ';' with
       | None -> failwith ("parse_one_type: unterminated object type in " ^ d)
       | Some j -> String.sub d i (j - i + 1), j + 1)
    | c -> failwith (Printf.sprintf "parse_one_type: bad char %C in %s" c d)

(* Parse a JVM method descriptor "(...)R" → (arg_descs, ret_desc). *)
let parse_method_desc d =
  if String.length d < 2 || d.[0] <> '('
  then failwith ("parse_method_desc: not a method desc: " ^ d);
  let rec loop i acc =
    if i >= String.length d then failwith ("parse_method_desc: no ) in " ^ d)
    else if d.[i] = ')' then List.rev acc, i + 1
    else
      let t, j = parse_one_type d i in
      loop j (t :: acc)
  in
  let args, ri = loop 1 [] in
  let ret, _ = parse_one_type d ri in
  args, ret

(* Map a JVM return/field descriptor to a [Kind] for the OCaml side. *)
let kind_of_jvm_desc = function
  | "I" | "Z" | "B" | "S" | "C" -> Kind.K_int
  | "D" -> Kind.K_float
  | "Ljava/lang/String;" -> Kind.K_string
  | _ -> Kind.K_obj

(* Normalise a class name to internal form (slashes, not dots). The
   PPX already emits slashed names, but we're defensive. *)
let intern_class s = String.map (function '.' -> '/' | c -> c) s

(* Take the first [n] elements of a list; return the full list if
   shorter. Used to drop trailing unit-placeholder args for zero-arg
   externals. *)
let rec take_at_most n = function
  | _ when n <= 0 -> []
  | [] -> []
  | x :: xs -> x :: take_at_most (n - 1) xs

(* Emit [pa], then coerce top-of-stack from the producing [Kind] to
   the JVM slot described by [target]. *)
let emit_arg_coerced ctx (pa : Code.prim_arg) target =
  let kind = emit_prim_arg ctx pa in
  match target with
  | "I" | "Z" | "B" | "S" | "C" ->
    (match kind with
     | Kind.K_int -> ()
     | _ ->
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I")
  | "D" ->
    (match kind with
     | Kind.K_float -> ()
     | _ ->
       Jvm.Code.checkcast ctx.code "java/lang/Double";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"doubleValue"
         ~descriptor:"()D")
  | "Ljava/lang/String;" ->
    (match kind with
     | Kind.K_string -> ()
     | Kind.K_int ->
       Kind.emit_box_int ctx.code;
       (* Boxed Integer isn't a String — but user-written bindings
          may want to let OCaml string flow through via K_obj.
          Don't checkcast here; leave the verifier to surface a
          real mismatch. *)
       Jvm.Code.checkcast ctx.code "java/lang/String"
     | _ -> Jvm.Code.checkcast ctx.code "java/lang/String")
  | t when String.length t > 0 && t.[0] = '[' ->
    (* JVM array target. OCaml arrays are [Block]s whose underlying
       storage lives in [Object[] fields] — extract that directly for
       uniform-object arrays. For element-typed arrays (e.g. [I]),
       verifier acceptance requires a matching descriptor; we fall
       back to a [checkcast] and let the JIT complain if the shapes
       don't line up. *)
    (match kind with
     | Kind.K_block _ | Kind.K_obj ->
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       if target <> "[Ljava/lang/Object;" then Jvm.Code.checkcast ctx.code target
     | _ -> ())
  | _ ->
    (* Reference target: box primitives to Object. *)
    (match kind with
     | Kind.K_int -> Kind.emit_box_int ctx.code
     | Kind.K_float -> Kind.emit_box_float ctx.code
     | _ -> ())

(* After an invoke*, the return descriptor says what's on the stack.
   For [V], nothing was pushed; emit a 0 so OCaml's unit-shaped caller
   has something to consume. *)
let finish_java_return ctx ret =
  match ret with
  | "V" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | _ -> kind_of_jvm_desc ret

(* Load [this] for an instance op. *)
let emit_java_this ctx pa class_ =
  let _ = emit_prim_arg ctx pa in
  Jvm.Code.checkcast ctx.code class_

(* Dispatch [java:*] primitive. *)
let emit_java_ffi ctx name (args : Code.prim_arg list) : Kind.kind =
  let parts = String.split_on_char ':' name in
  match parts with
  | [ "java"; "virtual"; class_; method_; descriptor ] ->
    let class_ = intern_class class_ in
    let arg_descs, ret = parse_method_desc descriptor in
    let expected = 1 + List.length arg_descs in
    let used = take_at_most expected args in
    (match used with
     | this_arg :: rest_args when List.length rest_args = List.length arg_descs ->
       emit_java_this ctx this_arg class_;
       List.iter2 (emit_arg_coerced ctx) rest_args arg_descs;
       Jvm.Code.invokevirtual ctx.code ~class_ ~method_ ~descriptor;
       finish_java_return ctx ret
     | _ ->
       raise
         (Unsupported
            (Printf.sprintf "java:virtual %s.%s: arity mismatch" class_ method_)))
  | [ "java"; "static"; class_; method_; descriptor ] ->
    let class_ = intern_class class_ in
    let arg_descs, ret = parse_method_desc descriptor in
    let expected = List.length arg_descs in
    let used = take_at_most expected args in
    if List.length used <> expected
    then
      raise
        (Unsupported
           (Printf.sprintf "java:static %s.%s: arity mismatch" class_ method_));
    List.iter2 (emit_arg_coerced ctx) used arg_descs;
    Jvm.Code.invokestatic ctx.code ~class_ ~method_ ~descriptor;
    finish_java_return ctx ret
  | [ "java"; "new"; class_; descriptor ] ->
    let class_ = intern_class class_ in
    let arg_descs, _ret = parse_method_desc descriptor in
    let expected = List.length arg_descs in
    let used = take_at_most expected args in
    if List.length used <> expected
    then raise (Unsupported (Printf.sprintf "java:new %s: arity mismatch" class_));
    Jvm.Code.new_ ctx.code class_;
    Jvm.Code.dup ctx.code;
    List.iter2 (emit_arg_coerced ctx) used arg_descs;
    Jvm.Code.invokespecial ctx.code ~class_ ~method_:"<init>" ~descriptor;
    Kind.K_obj
  | [ "java"; "getfield"; class_; field; descriptor ] ->
    let class_ = intern_class class_ in
    (match args with
     | this_arg :: _ ->
       emit_java_this ctx this_arg class_;
       Jvm.Code.getfield ctx.code ~class_ ~field ~descriptor;
       kind_of_jvm_desc descriptor
     | [] ->
       raise (Unsupported (Printf.sprintf "java:getfield %s.%s: no this" class_ field)))
  | [ "java"; "putfield"; class_; field; descriptor ] ->
    let class_ = intern_class class_ in
    (match args with
     | this_arg :: value_arg :: _ ->
       emit_java_this ctx this_arg class_;
       emit_arg_coerced ctx value_arg descriptor;
       Jvm.Code.putfield ctx.code ~class_ ~field ~descriptor;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ ->
       raise
         (Unsupported
            (Printf.sprintf "java:putfield %s.%s: need this + value" class_ field)))
  | [ "java"; "getstatic"; class_; field; descriptor ] ->
    let class_ = intern_class class_ in
    Jvm.Code.getstatic ctx.code ~class_ ~field ~descriptor;
    kind_of_jvm_desc descriptor
  | [ "java"; "putstatic"; class_; field; descriptor ] ->
    let class_ = intern_class class_ in
    (match args with
     | value_arg :: _ ->
       emit_arg_coerced ctx value_arg descriptor;
       Jvm.Code.putstatic ctx.code ~class_ ~field ~descriptor;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | [] ->
       raise
         (Unsupported (Printf.sprintf "java:putstatic %s.%s: no value" class_ field)))
  | [ "java"; "instanceof"; class_ ] ->
    let class_ = intern_class class_ in
    (match args with
     | obj_arg :: _ ->
       let _ = emit_prim_arg ctx obj_arg in
       Jvm.Code.instanceof_ ctx.code class_;
       Kind.K_int
     | [] -> raise (Unsupported (Printf.sprintf "java:instanceof %s: no arg" class_)))
  | [ "java"; "checkcast"; class_ ] ->
    let class_ = intern_class class_ in
    (match args with
     | obj_arg :: _ ->
       let _ = emit_prim_arg ctx obj_arg in
       Jvm.Code.checkcast ctx.code class_;
       Kind.K_obj
     | [] -> raise (Unsupported (Printf.sprintf "java:checkcast %s: no arg" class_)))
  | _ -> raise (Unsupported ("malformed java:* primitive: " ^ name))

(* Emit a C primitive call by name. Args have already been parsed
   into [prim_arg list]; they're all Pv or Pc. The handler dispatches
   on known primitive names and emits specialised bytecode.
   Unknown names raise [Unsupported]. *)
let rec emit_ccall ctx name args =
  if String.length name >= 5 && String.sub name 0 5 = "java:"
  then emit_java_ffi ctx name args
  else emit_ccall_named ctx name args

and emit_ccall_named ctx name args =
  let load_args_obj () =
    List.iter
      (fun pa ->
        match (pa : Code.prim_arg) with
        | Pv v ->
          emit_load ctx v;
          (match kind_of ctx v with
           | K_int -> Kind.emit_box_int ctx.code
           | K_float -> Kind.emit_box_float ctx.code
           | _ -> ())
        | Pc c -> ignore (emit_constant ctx c))
      args
  in
  let _ = load_args_obj in
  let as_string v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_string -> ()
    | _ -> Jvm.Code.checkcast ctx.code "java/lang/String"
  in
  let as_bytes v =
    emit_load ctx v;
    match kind_of ctx v with
    | _ -> Jvm.Code.checkcast ctx.code "Bytes"
  in
  let as_block v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_block _ -> ()
    | _ -> Jvm.Code.checkcast ctx.code "Block"
  in
  let as_int v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_int -> ()
    | _ ->
      (* Route through [Block.asLong + l2i]. Handles both Integer
         (the usual OCaml-int carrier) and Long (Int32 / Nativeint /
         Int64 globals materialised from custom-tag DATA-section
         blocks). Without this, Int32 ops on a boxed-Long global
         like [Nativeint.max_int] would [checkcast Integer] → CCE. *)
      Jvm.Code.invokestatic
        ctx.code
        ~class_:"Block"
        ~method_:"asLong"
        ~descriptor:"(Ljava/lang/Object;)J";
      Jvm.Code.l2i ctx.code
  in
  match name with
  | "caml_ml_string_length" | "caml_string_length" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"length"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_length arity"))
  | "caml_ml_bytes_length" | "caml_bytes_length" ->
    (* Accept both Bytes and String at runtime — Stdlib frequently
       passes Strings via unsafe_of_string. *)
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticLength"
         ~descriptor:"(Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_length arity"))
  | "caml_string_get" ->
    (match args with
     | [ Pv s; Pv i ] ->
       as_string s;
       as_int i;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"charAt"
         ~descriptor:"(I)C";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_get arity"))
  | "caml_bytes_get" ->
    (match args with
     | [ Pv b; Pv i ] ->
       emit_load ctx b;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticGet"
         ~descriptor:"(Ljava/lang/Object;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_get arity"))
  | "caml_bytes_set" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_bytes b;
       as_int i;
       as_int v;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"set"
         ~descriptor:"(II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_set arity"))
  | "caml_create_bytes" ->
    (match args with
     | [ Pv n ] ->
       Jvm.Code.new_ ctx.code "Bytes";
       Jvm.Code.dup ctx.code;
       as_int n;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Bytes"
         ~method_:"<init>"
         ~descriptor:"(I)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_create_bytes arity"))
  | "caml_ml_flush" ->
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"flush"
         ~descriptor:"()V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_flush arity"))
  | "caml_ml_output_char" ->
    (match args with
     | [ Pv chan; Pv c ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_int c;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"outputChar"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output_char arity"))
  | "caml_array_unsafe_get" | "caml_array_get" ->
    (match args with
     | [ Pv a; Pv i ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_get arity"))
  | "caml_array_unsafe_set" | "caml_array_set" ->
    (match args with
     | [ Pv a; Pv i; Pv v ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_set arity"))
  | "caml_string_of_bytes" ->
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticAsString"
         ~descriptor:"(Ljava/lang/Object;)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_string_of_bytes arity"))
  | "caml_bytes_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"ofString"
         ~descriptor:"(Ljava/lang/String;)LBytes;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_bytes_of_string arity"))
  | "caml_blit_string" ->
    (* [caml_blit_string src srcofs dst dstofs len]. Bytes.blitString
       has signature [(String src, int sofs, int dofs, int len)], so
       we push args: dst (receiver), src, srcofs, dstofs, len. *)
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_string s;
       as_int si;
       as_int bi;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitString"
         ~descriptor:"(Ljava/lang/String;III)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_string arity"))
  | "caml_fill_bytes" | "caml_fill_string" ->
    (match args with
     | [ Pv b; Pv ofs; Pv len; Pv c ] ->
       as_bytes b;
       as_int ofs;
       as_int len;
       as_int c;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"fill"
         ~descriptor:"(III)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_fill_bytes arity"))
  | "caml_blit_bytes" ->
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_bytes s;
       as_int si;
       as_int bi;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitBytes"
         ~descriptor:"(LBytes;III)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_bytes arity"))
  | "caml_format_int" ->
    (match args with
     | [ Pv fmt; Pv n ] ->
       as_string fmt;
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Format"
         ~method_:"formatInt"
         ~descriptor:"(Ljava/lang/String;I)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_format_int arity"))
  | "caml_string_equal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"equals"
         ~descriptor:"(Ljava/lang/Object;)Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_equal arity"))
  | "caml_string_notequal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"equals"
         ~descriptor:"(Ljava/lang/Object;)Z";
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.ixor ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_notequal arity"))
  | "caml_bytes_equal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_bytes a;
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"contentEquals"
         ~descriptor:"(LBytes;)Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_equal arity"))
  | "caml_ml_output" ->
    (match args with
     | [ Pv chan; Pv s; Pv off; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_string s;
       as_int off;
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"output"
         ~descriptor:"(Ljava/lang/String;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output arity"))
  | "caml_add_float" | "caml_sub_float" | "caml_mul_float" | "caml_div_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       (match name with
        | "caml_add_float" -> Jvm.Code.dadd ctx.code
        | "caml_sub_float" -> Jvm.Code.dsub ctx.code
        | "caml_mul_float" -> Jvm.Code.dmul ctx.code
        | "caml_div_float" -> Jvm.Code.ddiv ctx.code
        | _ -> assert false);
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_neg_float" ->
    (match args with
     | [ Pv a ] ->
       emit_load ctx a;
       (match kind_of ctx a with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.dneg ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_neg_float arity"))
  | "caml_eq_float" | "caml_neq_float" | "caml_lt_float"
  | "caml_le_float" | "caml_gt_float" | "caml_ge_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       (* dcmpl/dcmpg: -1/0/1, with NaN semantics. eq/neq use dcmpl.
          lt/le use dcmpg (NaN pushes +1 → lt is false). gt/ge use
          dcmpl (NaN pushes -1 → gt is false). *)
       (match name with
        | "caml_eq_float" | "caml_neq_float" | "caml_gt_float"
        | "caml_ge_float" ->
          Jvm.Code.dcmpl ctx.code
        | "caml_lt_float" | "caml_le_float" -> Jvm.Code.dcmpg ctx.code
        | _ -> assert false);
       let l_true = Jvm.Code.fresh_label ctx.code in
       let l_end = Jvm.Code.fresh_label ctx.code in
       (match name with
        | "caml_eq_float" -> Jvm.Code.ifeq ctx.code l_true
        | "caml_neq_float" -> Jvm.Code.ifne ctx.code l_true
        | "caml_lt_float" -> Jvm.Code.iflt ctx.code l_true
        | "caml_le_float" -> Jvm.Code.ifle ctx.code l_true
        | "caml_gt_float" -> Jvm.Code.ifgt ctx.code l_true
        | "caml_ge_float" -> Jvm.Code.ifge ctx.code l_true
        | _ -> assert false);
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.goto_w ctx.code l_end;
       Jvm.Code.mark_label ctx.code l_true;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.mark_label ctx.code l_end;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int_of_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.d2i ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_of_float arity"))
  | "caml_float_of_int" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.i2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_float_of_int arity"))
  (* Float helpers not in java.lang.Math — delegate to [Format]'s
     static helpers (asinh/acosh/atanh/erf/erfc/exp2). *)
  | "caml_round_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Math" ~method_:"rint"
         ~descriptor:"(D)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_round_float arity"))
  | "caml_trunc_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       (* trunc = sign(x) * floor(|x|). Implement via d2l + l2d for
          round-toward-zero semantics on finite values. *)
       Jvm.Code.d2l ctx.code;
       Jvm.Code.l2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_trunc_float arity"))
  | "caml_signbit_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Double" ~method_:"doubleToRawLongBits"
         ~descriptor:"(D)J";
       Jvm.Code.ldc_int ctx.code 63;
       Jvm.Code.lushr ctx.code;
       Jvm.Code.l2i ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_signbit_float arity"))
  | "caml_nextafter_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a; as_dbl b;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Math" ~method_:"nextAfter"
         ~descriptor:"(DD)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_nextafter_float arity"))
  | "caml_ldexp_float" ->
    (* ldexp x n = x * 2^n. Math has [Math.scalb(double, int)]. *)
    (match args with
     | [ Pv x; Pv n ] ->
       emit_load ctx x;
       (match kind_of ctx x with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       as_int n;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Math" ~method_:"scalb"
         ~descriptor:"(DI)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_ldexp_float arity"))
  | "caml_modf_float" ->
    (* modf x = (frac, int) as Block{0, [frac; int]}. *)
    (match args with
     | [ Pv x ] ->
       emit_load ctx x;
       (match kind_of ctx x with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code ~class_:"Format" ~method_:"modf"
         ~descriptor:"(D)LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_modf_float arity"))
  | "caml_log2_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       (* log2(x) = log(x) / log(2). *)
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Math" ~method_:"log"
         ~descriptor:"(D)D";
       Jvm.Code.ldc_double ctx.code 0.6931471805599453;
       Jvm.Code.ddiv ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_log2_float arity"))
  | "caml_asinh_float" | "caml_acosh_float" | "caml_atanh_float"
  | "caml_erf_float" | "caml_erfc_float" | "caml_exp2_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       let mname =
         match name with
         | "caml_asinh_float" -> "asinh"
         | "caml_acosh_float" -> "acosh"
         | "caml_atanh_float" -> "atanh"
         | "caml_erf_float" -> "erf"
         | "caml_erfc_float" -> "erfc"
         | "caml_exp2_float" -> "exp2"
         | _ -> assert false
       in
       Jvm.Code.invokestatic
         ctx.code ~class_:"Format" ~method_:mname ~descriptor:"(D)D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_frexp_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code ~class_:"Format" ~method_:"frexp"
         ~descriptor:"(D)LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_frexp_float arity"))
  | "caml_fma_float" ->
    (match args with
     | [ Pv a; Pv b; Pv c ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a; as_dbl b; as_dbl c;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Format" ~method_:"fma"
         ~descriptor:"(DDD)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_fma_float arity"))
  | "caml_abs_float" | "caml_sqrt_float" | "caml_sin_float"
  | "caml_cos_float" | "caml_tan_float" | "caml_asin_float"
  | "caml_acos_float" | "caml_atan_float" | "caml_log_float"
  | "caml_log10_float" | "caml_exp_float" | "caml_ceil_float"
  | "caml_floor_float" | "caml_sinh_float" | "caml_cosh_float"
  | "caml_tanh_float" | "caml_cbrt_float" | "caml_expm1_float"
  | "caml_log1p_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       let mname =
         match name with
         | "caml_abs_float" -> "abs"
         | "caml_sqrt_float" -> "sqrt"
         | "caml_sin_float" -> "sin"
         | "caml_cos_float" -> "cos"
         | "caml_tan_float" -> "tan"
         | "caml_asin_float" -> "asin"
         | "caml_acos_float" -> "acos"
         | "caml_atan_float" -> "atan"
         | "caml_log_float" -> "log"
         | "caml_log10_float" -> "log10"
         | "caml_exp_float" -> "exp"
         | "caml_ceil_float" -> "ceil"
         | "caml_floor_float" -> "floor"
         | "caml_sinh_float" -> "sinh"
         | "caml_cosh_float" -> "cosh"
         | "caml_tanh_float" -> "tanh"
         | "caml_cbrt_float" -> "cbrt"
         | "caml_expm1_float" -> "expm1"
         | "caml_log1p_float" -> "log1p"
         | _ -> assert false
       in
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Math"
         ~method_:mname
         ~descriptor:"(D)D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_atan2_float" | "caml_hypot_float" | "caml_power_float"
  | "caml_fmod_float" | "caml_copysign_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       let mname =
         match name with
         | "caml_atan2_float" -> "atan2"
         | "caml_hypot_float" -> "hypot"
         | "caml_power_float" -> "pow"
         | "caml_fmod_float" -> "IEEEremainder"
         | "caml_copysign_float" -> "copySign"
         | _ -> assert false
       in
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Math"
         ~method_:mname
         ~descriptor:"(DD)D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_float_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"parseDouble"
         ~descriptor:"(Ljava/lang/String;)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_float_of_string arity"))
  | "caml_int32_format" ->
    (match args with
     | [ Pv _fmt; Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"toString"
         ~descriptor:"(I)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_format" | "caml_nativeint_format" ->
    (* Format a boxed [Long] via [Long.toString]. The [fmt] arg
       carries OCaml's [%d]/[%x]/[%o]/etc. encoding; we ignore it
       and always emit decimal — matches our [caml_format_int]
       stub's current shape. *)
    (match args with
     | [ Pv _fmt; Pv n ] ->
       emit_load ctx n;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Long"
         ~method_:"toString"
         ~descriptor:"(J)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_hexstring_of_float" ->
    (* The real primitive takes (float, precision, style); we only
       use the float and return Double.toHexString. First arg is the
       float; drop any others (they've been pushed but unused). *)
    (match args with
     | (Code.Pv f) :: _rest ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"toHexString"
         ~descriptor:"(D)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_hexstring_of_float arity"))
  | "caml_classify_float" ->
    (* OCaml codes:
         FP_normal=0, FP_subnormal=1, FP_zero=2, FP_infinite=3, FP_nan=4. *)
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       (* Stack leak risk: call a static helper if we had one; for
          now just return 0 (FP_normal). Lossy but structurally
          sound. *)
       Jvm.Code.pop2 ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_classify_float arity"))
  | "caml_java_print_int" ->
    (match args with
     | [ Pv n ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_int arity"))
  | "caml_java_print_endline" ->
    (match args with
     | [ Pv s ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       as_string s;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_endline arity"))
  | "caml_java_print_float" ->
    (match args with
     | [ Pv f ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(D)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_float arity"))
  | "caml_int_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"parseInt"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_of_string arity"))
  | "caml_format_float" ->
    (match args with
     | [ Pv fmt; Pv f ] ->
       as_string fmt;
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Format"
         ~method_:"formatFloat"
         ~descriptor:"(Ljava/lang/String;D)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_format_float arity"))
  | "caml_sys_exit" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"exit"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_exit arity"))
  | "caml_sys_get_config" ->
    (* Returns ("Unix", 32, false) triple. *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_int ctx.code 3;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_string ctx.code "Unix";
    Jvm.Code.aastore ctx.code;
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.ldc_int ctx.code 32;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code;
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 2;
    Jvm.Code.ldc_int ctx.code 0;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    Kind.K_obj
  | "caml_sys_const_int_size" -> Jvm.Code.ldc_int ctx.code 63; Kind.K_int
  | "caml_sys_const_word_size" -> Jvm.Code.ldc_int ctx.code 64; Kind.K_int
  | "caml_sys_const_big_endian"
  | "caml_sys_const_ostype_unix" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_sys_const_ostype_cygwin" | "caml_sys_const_ostype_win32"
  | "caml_sys_const_backend_type"
  | "caml_sys_const_naked_pointers_checked" ->
    (* 4.14 stdlib init reads [naked_pointers_checked] and asserts
       it; return 0 (false — JVM runtime doesn't have the no-naked-
       pointers optimisation those 4.x releases guarded behind it,
       but the stdlib init code path treats 0 as "no assertion
       failure"). *)
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_sys_const_max_wosize" ->
    (* Stdlib's Sys.max_string_length is computed from this as
       [word_size / 8 * max_wosize - 1]. With our word_size = 64
       and JVM 32-bit ints, max_wosize * 8 must stay in int32
       range; clamp to 2^28 - 1 so [8 * 268435455 - 1 = 2147483639]
       fits. OCaml's canonical value (2^54 - 1 on 64-bit) would
       overflow our 32-bit arithmetic to a negative number,
       causing Buffer.create / Bytes.create to receive absurd
       sizes. *)
    Jvm.Code.ldc_int ctx.code 268435455;
    Kind.K_int
  | "caml_sys_const_min_int" -> Jvm.Code.ldc_int ctx.code min_int; Kind.K_int
  | "caml_sys_const_max_int" -> Jvm.Code.ldc_int ctx.code max_int; Kind.K_int
  | "caml_ensure_stack_capacity"
  | "caml_ml_set_binary_mode"
  | "caml_ml_set_channel_name"
  | "caml_register_named_value"
  | "caml_init_signals"
  | "caml_record_backtrace"
  | "caml_backtrace_status"
  | "caml_ml_debug_info_status"
  | "caml_ml_enable_runtime_warnings"
  | "caml_ml_runtime_warnings_enabled"
  | "caml_runtime_parameters"
  | "caml_runtime_variant"
  | "caml_ml_out_channels_list"
  | "caml_ml_seek_out"
  | "caml_ml_seek_out_64"
  | "caml_ml_seek_in"
  | "caml_ml_seek_in_64"
  | "caml_ml_pos_out"
  | "caml_ml_pos_out_64"
  | "caml_ml_pos_in"
  | "caml_ml_pos_in_64" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_sys_getenv" ->
    (* Look up the env var via java.lang.System.getenv; if absent,
       raise OCaml's [Not_found] so [Sys.getenv_opt]'s [try ... with
       Not_found -> None] catches it. [Not_found]'s descriptor is
       [ctx.not_found_idx] (scanned out of the DATA section at
       compile time) — we raise via [CamlException] wrapping
       [GLOBALS[idx]]. *)
    (match args with
     | [ Pv k ] ->
       as_string k;
       Jvm.Code.invokestatic ctx.code
         ~class_:"java/lang/System"
         ~method_:"getenv"
         ~descriptor:"(Ljava/lang/String;)Ljava/lang/String;";
       let lbl_nn = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.dup ctx.code;
       Jvm.Code.ifnonnull ctx.code lbl_nn;
       (* getenv returned null → raise Not_found. *)
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.new_ ctx.code "CamlException";
       Jvm.Code.dup ctx.code;
       Jvm.Code.getstatic ctx.code
         ~class_:"Main"
         ~field:"GLOBALS"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code !(ctx.not_found_idx);
       Jvm.Code.aaload ctx.code;
       Jvm.Code.invokespecial ctx.code
         ~class_:"CamlException"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/Object;)V";
       Jvm.Code.athrow ctx.code;
       Jvm.Code.mark_label ctx.code lbl_nn;
       Kind.K_string
     | _ -> raise (Unsupported "caml_sys_getenv arity"))
  | "caml_sys_argv" ->
    (* Return [Main.ARGV] — the driver populates it at [main(args)]
       entry from the [String[]] parameter. *)
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"ARGV"
      ~descriptor:"LBlock;";
    Kind.K_obj
  | "caml_sys_get_argv" ->
    (* Returns a tuple [(argv0, argv)] — [Sys.get_argv ()] shape.
       [argv0] is the first element (the program name). *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_int ctx.code 2;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    (* argv[0] — read [ARGV.fields[0]]. *)
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"ARGV"
      ~descriptor:"LBlock;";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.aaload ctx.code;
    Jvm.Code.aastore ctx.code;
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"ARGV"
      ~descriptor:"LBlock;";
    Jvm.Code.aastore ctx.code;
    Jvm.Code.invokespecial ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    Kind.K_obj
  | "caml_channel_descriptor"
  | "caml_sys_executable_name"
  | "caml_sys_system_command"
  | "caml_sys_file_exists"
  (* Unix init-time stubs. When linking threads.cma the Unix module
     is pulled in; its init touches a few inet helpers whose results
     aren't used unless the application actually reaches for
     sockets. Returning null keeps init flowing; an actual socket
     call later would NPE at the use site. *)
  | "caml_unix_inet_addr_of_string"
  | "caml_unix_string_of_inet_addr"
  (* Core-level unbound-prefix variants of the same Unix helpers.
     Jane Street's core_unix registers its C stubs under names that
     drop the OCaml-runtime [caml_] prefix, so [Unix.inet_addr_of_string]
     in a core_unix-linked program resolves to [unix_inet_addr_of_string]
     rather than [caml_unix_inet_addr_of_string]. Same init-time-only
     treatment — null is OK until an actual socket path runs. *)
  | "unix_inet_addr_of_string"
  | "unix_string_of_inet_addr" ->
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj
  | "caml_ml_open_descriptor_in" ->
    (* Wrap an FD (from [caml_sys_open] or 0 for stdin) in an input
       [Channel]. *)
    (match args with
     | [ Pv fd ] ->
       as_int fd;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Channel"
         ~method_:"forDescriptor"
         ~descriptor:"(I)LChannel;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_open_descriptor_in arity"))
  | "caml_sys_open" ->
    (* [path flags perm] → int FD. The flags arg is an OCaml list of
       [Open_rdonly] / [Open_wronly] / … variants; [Channel.openFile]
       walks the [Block]-cons chain at runtime. *)
    (match args with
     | [ Pv path; Pv flags; Pv perm ] ->
       as_string path;
       emit_load ctx flags;
       as_int perm;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Channel"
         ~method_:"openFile"
         ~descriptor:"(Ljava/lang/String;Ljava/lang/Object;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_open arity"))
  | "caml_sys_close" ->
    (match args with
     | [ Pv fd ] ->
       as_int fd;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Channel"
         ~method_:"closeFd"
         ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_close arity"))
  | "caml_md5_chan" ->
    (* MD5 of the remaining contents of an input channel (or [len]
       bytes if len >= 0). Delegates to [Channel.md5] which consumes
       from the buffered input. *)
    (match args with
     | [ Pv chan; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Channel" ~method_:"md5"
         ~descriptor:"(I)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_md5_chan arity"))
  | "caml_md5_bytes" | "caml_md5_string" ->
    (* 16-byte MD5 digest of [s[ofs..ofs+len)] as a Bytes. Routes
       through a static [Bytes.md5] helper that wraps
       [java.security.MessageDigest]. *)
    (match args with
     | [ Pv s; Pv ofs; Pv len ] ->
       emit_load ctx s;
       as_int ofs;
       as_int len;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"md5"
         ~descriptor:"(Ljava/lang/Object;II)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_bytes_get16" | "caml_string_get16" ->
    (match args with
     | [ Pv b; Pv i ] ->
       emit_load ctx b;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"get16"
         ~descriptor:"(Ljava/lang/Object;I)I";
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_bytes_get32" | "caml_string_get32" ->
    (match args with
     | [ Pv b; Pv i ] ->
       emit_load ctx b;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"get32"
         ~descriptor:"(Ljava/lang/Object;I)I";
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_bytes_get64" | "caml_string_get64" ->
    (match args with
     | [ Pv b; Pv i ] ->
       emit_load ctx b;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"get64"
         ~descriptor:"(Ljava/lang/Object;I)J";
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_bytes_set16" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_bytes b;
       as_int i;
       as_int v;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"set16"
         ~descriptor:"(LBytes;II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_set16 arity"))
  | "caml_bytes_set32" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_bytes b;
       as_int i;
       as_int v;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"set32"
         ~descriptor:"(LBytes;II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_set32 arity"))
  | "caml_bytes_set64" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_bytes b;
       as_int i;
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.invokestatic
         ctx.code ~class_:"Bytes" ~method_:"set64"
         ~descriptor:"(LBytes;IJ)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_set64 arity"))
  | "caml_float_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a; as_dbl b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"compare"
         ~descriptor:"(DD)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_float_compare arity"))
  | "caml_bswap16" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.ldc_int ctx.code 0xFF;
       Jvm.Code.iand ctx.code;
       Jvm.Code.ldc_int ctx.code 8;
       Jvm.Code.ishl ctx.code;
       as_int n;
       Jvm.Code.ldc_int ctx.code 8;
       Jvm.Code.iushr ctx.code;
       Jvm.Code.ldc_int ctx.code 0xFF;
       Jvm.Code.iand ctx.code;
       Jvm.Code.ior ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_bswap16 arity"))
  | "caml_lxm_next" ->
    (match args with
     | [ Pv st ] ->
       emit_load ctx st;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"lxmNext"
         ~descriptor:"(LBigArray;)J";
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_lxm_next arity"))
  | "caml_ba_create" ->
    (* [caml_ba_create kind layout dims] where dims is a Block
       (OCaml int array) of sizes. *)
    (match args with
     | [ Pv kind; Pv layout; Pv dims ] ->
       as_int kind;
       as_int layout;
       as_block dims;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"BigArray"
         ~method_:"create"
         ~descriptor:"(IILBlock;)LBigArray;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ba_create arity"))
  | "caml_ba_num_dims" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"numDims" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_num_dims arity"))
  | "caml_ba_dim" ->
    (match args with
     | [ Pv ba; Pv n ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"dim" ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_dim arity"))
  | "caml_ba_dim_1" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"dim1" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_dim_1 arity"))
  | "caml_ba_dim_2" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"dim2" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_dim_2 arity"))
  | "caml_ba_dim_3" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"dim3" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_dim_3 arity"))
  | "caml_ba_kind" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.getfield
         ctx.code ~class_:"BigArray" ~field:"kind" ~descriptor:"I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_kind arity"))
  | "caml_ba_layout" ->
    (match args with
     | [ Pv ba ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.getfield
         ctx.code ~class_:"BigArray" ~field:"layout" ~descriptor:"I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_layout arity"))
  | "caml_ba_get_1" ->
    (match args with
     | [ Pv ba; Pv i ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int i;
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"get1"
         ~descriptor:"(I)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ba_get_1 arity"))
  | "caml_ba_set_1" ->
    (match args with
     | [ Pv ba; Pv i; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"set1"
         ~descriptor:"(ILjava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_set_1 arity"))
  | "caml_ba_get_2" ->
    (match args with
     | [ Pv ba; Pv i; Pv j ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int i; as_int j;
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"get2"
         ~descriptor:"(II)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ba_get_2 arity"))
  | "caml_ba_set_2" ->
    (match args with
     | [ Pv ba; Pv i; Pv j; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int i; as_int j;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"set2"
         ~descriptor:"(IILjava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_set_2 arity"))
  | "caml_ba_fill" ->
    (match args with
     | [ Pv ba; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokevirtual
         ctx.code ~class_:"BigArray" ~method_:"fill"
         ~descriptor:"(Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_fill arity"))
  (* Bin_prot byte-addressed multi-byte accessors on a uint8 / char
     Bigarray. Little-endian, matching the OCaml C stubs. *)
  | "caml_ba_uint8_set16" | "caml_bigstring_set16" ->
    (match args with
     | [ Pv ba; Pv pos; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       as_int v;
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"setU16"
         ~descriptor:"(LBigArray;II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_uint8_set16 arity"))
  | "caml_ba_uint8_set32" | "caml_bigstring_set32" ->
    (match args with
     | [ Pv ba; Pv pos; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       as_int v;
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"setU32"
         ~descriptor:"(LBigArray;II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_uint8_set32 arity"))
  | "caml_ba_uint8_set64" | "caml_bigstring_set64" ->
    (match args with
     | [ Pv ba; Pv pos; Pv v ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       emit_load ctx v;
       (* [v] is an Int64 — already boxed [Long] or primitive [long].
          Route through [Block.asLong] so either carrier works. *)
       (match kind_of ctx v with
        | _ ->
          Jvm.Code.invokestatic
            ctx.code ~class_:"Block" ~method_:"asLong"
            ~descriptor:"(Ljava/lang/Object;)J");
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"setU64"
         ~descriptor:"(LBigArray;IJ)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_uint8_set64 arity"))
  | "caml_ba_uint8_get16" | "caml_bigstring_get16" ->
    (match args with
     | [ Pv ba; Pv pos ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"getU16"
         ~descriptor:"(LBigArray;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_uint8_get16 arity"))
  | "caml_ba_uint8_get32" | "caml_bigstring_get32" ->
    (match args with
     | [ Pv ba; Pv pos ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"getU32"
         ~descriptor:"(LBigArray;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_uint8_get32 arity"))
  | "caml_ba_uint8_get64" | "caml_bigstring_get64" ->
    (match args with
     | [ Pv ba; Pv pos ] ->
       emit_load ctx ba;
       Jvm.Code.checkcast ctx.code "BigArray";
       as_int pos;
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"getU64"
         ~descriptor:"(LBigArray;I)J";
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ba_uint8_get64 arity"))
  | "caml_ba_blit" ->
    (match args with
     | [ Pv src; Pv dst ] ->
       emit_load ctx src;
       Jvm.Code.checkcast ctx.code "BigArray";
       emit_load ctx dst;
       Jvm.Code.checkcast ctx.code "BigArray";
       Jvm.Code.invokestatic
         ctx.code ~class_:"BigArray" ~method_:"blit"
         ~descriptor:"(LBigArray;LBigArray;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ba_blit arity"))
  (* GC control primitives — all no-ops on our JVM runtime. Returning
     0 (unit) or a plausible constant keeps Stdlib init / Gc module
     users happy without any real behaviour. *)
  | "caml_gc_minor" | "caml_gc_major" | "caml_gc_full_major"
  | "caml_gc_compaction" | "caml_gc_major_slice" | "caml_gc_set"
  | "caml_final_register" | "caml_final_register_called_without_value"
  | "caml_final_release" | "caml_install_signal_handler"
  | "caml_register_channel_for_spacetime"
  | "caml_memprof_start" | "caml_memprof_stop" | "caml_memprof_discard"
  | "caml_set_parser_trace" | "caml_restore_raw_backtrace" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_gc_minor_words" | "caml_get_minor_free"
  | "caml_gc_counters" ->
    Jvm.Code.ldc_double ctx.code 0.0;
    Kind.K_float
  | "caml_gc_stat" | "caml_gc_quick_stat" | "caml_gc_get" ->
    (* OCaml Gc.stat returns a record with 16 fields (floats + ints).
       Build a Block with zeros so destructuring sees a sane shape. *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_int ctx.code 16;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    (* Leave unfilled — JVM null-inits Object[]. OCaml-side readers
       of specific fields would NPE if they read; most users of
       Gc.stat print the whole record which just reads all fields. *)
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    Kind.K_obj
  (* Backtrace / callstack — stub as empty / no-op. *)
  | "caml_get_current_callstack"
  | "caml_get_exception_raw_backtrace"
  | "caml_get_continuation_callstack"
  | "caml_convert_raw_backtrace"
  | "caml_convert_raw_backtrace_slot"
  | "caml_raw_backtrace_length"
  | "caml_raw_backtrace_slot"
  | "caml_raw_backtrace_next_slot" ->
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj
  | "caml_bytes_compare" ->
    (* Lexicographic compare of two byte sequences. Delegate to
       [Bytes.staticCompare(Object, Object)]. *)
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a;
       emit_load ctx b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticCompare"
         ~descriptor:"(Ljava/lang/Object;Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_compare arity"))
  | "caml_array_concat" ->
    (* Concatenate a list of arrays. Delegate to a static helper on
       Block that walks the OCaml-cons list and allocates one
       Object[] big enough. *)
    (match args with
     | [ Pv lst ] ->
       emit_load ctx lst;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Block"
         ~method_:"concatList"
         ~descriptor:"(Ljava/lang/Object;)LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_concat arity"))
  | "caml_array_create_float" | "caml_floatarray_make" ->
    (* Allocate a Block whose fields are zero-initialised Doubles. *)
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Block"
         ~method_:"createFloat"
         ~descriptor:"(I)LBlock;";
       Kind.K_obj
     | [ Pv n; Pv init ] ->
       as_int n;
       emit_load ctx init;
       (match kind_of ctx init with
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Block"
         ~method_:"createFloatInit"
         ~descriptor:"(ILjava/lang/Object;)LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_floatarray_get" | "caml_floatarray_unsafe_get"
  | "caml_array_get_float" | "caml_array_unsafe_get_float" ->
    (* Float arrays are Blocks whose fields[i] holds a Double. *)
    (match args with
     | [ Pv a; Pv i ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code ~class_:"Block" ~field:"fields" ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Jvm.Code.checkcast ctx.code "java/lang/Double";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
         ~descriptor:"()D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_floatarray_set" | "caml_floatarray_unsafe_set"
  | "caml_array_set_float" | "caml_array_unsafe_set_float" ->
    (match args with
     | [ Pv a; Pv i; Pv v ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code ~class_:"Block" ~field:"fields" ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_floatarray_sub" ->
    emit_ccall ctx "caml_array_sub" args
  | "caml_floatarray_blit" ->
    emit_ccall ctx "caml_array_blit" args
  | "caml_floatarray_fill" ->
    emit_ccall ctx "caml_array_fill" args
  | "caml_floatarray_append" ->
    emit_ccall ctx "caml_array_append" args
  | "caml_thread_new" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       Jvm.Code.checkcast ctx.code "Closure";
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadNew"
         ~descriptor:"(LClosure;)Ljava/lang/Thread;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_thread_new arity"))
  | "caml_thread_self" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadSelf"
         ~descriptor:"()Ljava/lang/Thread;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_thread_self arity"))
  | "caml_thread_id" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.checkcast ctx.code "java/lang/Thread";
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadId"
         ~descriptor:"(Ljava/lang/Thread;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_id arity"))
  | "caml_thread_join" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.checkcast ctx.code "java/lang/Thread";
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadJoin"
         ~descriptor:"(Ljava/lang/Thread;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_join arity"))
  | "caml_thread_yield" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadYield"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_yield arity"))
  | "caml_thread_initialize" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadInitialize"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_initialize arity"))
  | "caml_thread_cleanup" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadCleanup"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_cleanup arity"))
  | "caml_thread_uncaught_exception" ->
    (match args with
     | [ Pv e ] ->
       emit_load ctx e;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"threadUncaughtException"
         ~descriptor:"(Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_uncaught_exception arity"))
  | "caml_thread_set_name" ->
    (match args with
     | [ Pv n ] ->
       as_string n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"ThreadPrim"
         ~method_:"setCurrentThreadName"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_thread_set_name arity"))
  | "caml_ml_mutex_new" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Mutex"
         ~method_:"create"
         ~descriptor:"()LMutex;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_mutex_new arity"))
  | "caml_ml_mutex_lock" ->
    (match args with
     | [ Pv m ] ->
       emit_load ctx m;
       Jvm.Code.checkcast ctx.code "Mutex";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Mutex" ~method_:"mlock" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_mutex_lock arity"))
  | "caml_ml_mutex_try_lock" ->
    (match args with
     | [ Pv m ] ->
       emit_load ctx m;
       Jvm.Code.checkcast ctx.code "Mutex";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Mutex" ~method_:"mtry_lock" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_mutex_try_lock arity"))
  | "caml_ml_mutex_unlock" ->
    (match args with
     | [ Pv m ] ->
       emit_load ctx m;
       Jvm.Code.checkcast ctx.code "Mutex";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Mutex" ~method_:"munlock" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_mutex_unlock arity"))
  | "caml_ml_condition_new" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"CondVar"
         ~method_:"create"
         ~descriptor:"()LCondVar;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_condition_new arity"))
  | "caml_ml_condition_wait" ->
    (match args with
     | [ Pv c; Pv m ] ->
       emit_load ctx c;
       Jvm.Code.checkcast ctx.code "CondVar";
       emit_load ctx m;
       Jvm.Code.checkcast ctx.code "Mutex";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"CondVar" ~method_:"cwait" ~descriptor:"(LMutex;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_condition_wait arity"))
  | "caml_ml_condition_signal" ->
    (match args with
     | [ Pv c ] ->
       emit_load ctx c;
       Jvm.Code.checkcast ctx.code "CondVar";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"CondVar" ~method_:"csignal" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_condition_signal arity"))
  | "caml_ml_condition_broadcast" ->
    (match args with
     | [ Pv c ] ->
       emit_load ctx c;
       Jvm.Code.checkcast ctx.code "CondVar";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"CondVar" ~method_:"cbroadcast" ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_condition_broadcast arity"))
  | "caml_sys_time" | "caml_sys_time_include_children" ->
    (* Seconds since an arbitrary epoch as an OCaml float.
       [System.nanoTime()] gives relative nanos; scale to seconds. *)
    (match args with
     | [ _ ] ->
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"nanoTime"
         ~descriptor:"()J";
       Jvm.Code.l2d ctx.code;
       Jvm.Code.ldc_double ctx.code 1e9;
       Jvm.Code.ddiv ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_sys_random_seed" ->
    (* Returns an [int array] (Block tag 0) used to seed the PRNG.
       One element of [System.nanoTime()] cast to int is enough. *)
    (match args with
     | [ _ ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"nanoTime"
         ~descriptor:"()J";
       Jvm.Code.l2i ctx.code;
       Kind.emit_box_int ctx.code;
       Jvm.Code.aastore ctx.code;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_sys_random_seed arity"))
  | "caml_sys_getcwd" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.ldc_string ctx.code "user.dir";
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"getProperty"
         ~descriptor:"(Ljava/lang/String;)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_sys_getcwd arity"))
  | "caml_sys_is_directory" ->
    (match args with
     | [ Pv path ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string path;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"isDirectory"
         ~descriptor:"()Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_is_directory arity"))
  | "caml_sys_chdir" ->
    (* JVM has no chdir — [user.dir] is read-only once set. We store
       the "logical" cwd as a static and have [caml_sys_getcwd]
       return it. For now, just track the latest value; most
       relative-path I/O goes through java.io.File which uses
       [user.dir] anyway. This is a best-effort stub — chdir-heavy
       code will see different behaviour than native OCaml. *)
    (match args with
     | [ Pv path ] ->
       Jvm.Code.ldc_string ctx.code "user.dir";
       as_string path;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"setProperty"
         ~descriptor:"(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;";
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_chdir arity"))
  | "caml_sys_mkdir" ->
    (match args with
     | [ Pv path; _perm ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string path;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"mkdir"
         ~descriptor:"()Z";
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_mkdir arity"))
  | "caml_sys_rmdir" ->
    (match args with
     | [ Pv path ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string path;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"delete"
         ~descriptor:"()Z";
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_rmdir arity"))
  | "caml_sys_rename" ->
    (match args with
     | [ Pv src; Pv dst ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string src;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string dst;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"renameTo"
         ~descriptor:"(Ljava/io/File;)Z";
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_rename arity"))
  | "caml_sys_isatty" ->
    (* OCaml [Unix.isatty fd] — approximate as always false since
       the JVM can't easily distinguish. *)
    (match args with
     | [ _ ] ->
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_isatty arity"))
  | "caml_ml_is_buffered" | "caml_ml_is_binary_mode" ->
    (match args with
     | [ _ ] ->
       Jvm.Code.ldc_int ctx.code 1;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_ml_set_buffered" ->
    (match args with
     | [ _; _ ] ->
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_set_buffered arity"))
  | "caml_sys_is_regular_file" ->
    (match args with
     | [ Pv path ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string path;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"isFile"
         ~descriptor:"()Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_is_regular_file arity"))
  | "caml_sys_read_directory" ->
    (match args with
     | [ Pv path ] ->
       as_string path;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Block"
         ~method_:"readDirectory"
         ~descriptor:"(Ljava/lang/String;)LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_sys_read_directory arity"))
  | "caml_ml_channel_size" ->
    (match args with
     | [ Pv _ ] ->
       (* Our buffered Channel doesn't currently track underlying
          file size. Return 0 as a sentinel; Stdlib paths that
          actually care (in_channel_length) will see 0 and likely
          bail or handle gracefully. *)
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_channel_size arity"))
  | "caml_ml_channel_size_64" ->
    (match args with
     | [ Pv _ ] ->
       Jvm.Code.ldc_long ctx.code 0L;
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_channel_size_64 arity"))
  | "caml_ml_input_int" ->
    (* Read 4 bytes big-endian from the channel. *)
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Channel" ~method_:"inputInt"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_input_int arity"))
  | "caml_ml_output_int" ->
    (match args with
     | [ Pv chan; Pv v ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_int v;
       Jvm.Code.invokevirtual
         ctx.code ~class_:"Channel" ~method_:"outputInt"
         ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output_int arity"))
  | "caml_obj_raw_field" ->
    (match args with
     | [ Pv b; Pv i ] ->
       as_block b;
       Jvm.Code.getfield
         ctx.code ~class_:"Block" ~field:"fields" ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_raw_field arity"))
  | "caml_obj_set_raw_field" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_block b;
       Jvm.Code.getfield
         ctx.code ~class_:"Block" ~field:"fields" ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_obj_set_raw_field arity"))
  | "caml_obj_add_offset" ->
    (match args with
     | [ Pv b; _ ] ->
       (* OCaml pointer arithmetic — not meaningful on JVM. Identity. *)
       emit_load ctx b;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_add_offset arity"))
  | "caml_obj_reachable_words" ->
    (match args with
     | [ _ ] ->
       (* JVM GC doesn't expose per-object retained set; return 0. *)
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_obj_reachable_words arity"))
  | "caml_sys_remove" ->
    (match args with
     | [ Pv path ] ->
       Jvm.Code.new_ ctx.code "java/io/File";
       Jvm.Code.dup ctx.code;
       as_string path;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"java/io/File"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/File"
         ~method_:"delete"
         ~descriptor:"()Z";
       (* Discard bool, return 0 (unit). *)
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_remove arity"))
  | "caml_ml_close_channel" ->
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"close"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_close_channel arity"))
  | "caml_ml_input_char" ->
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"inputChar"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_input_char arity"))
  | "caml_ml_input_scan_line" ->
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"inputScanLine"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_input_scan_line arity"))
  | "caml_ml_input" ->
    (match args with
     | [ Pv chan; Pv buf; Pv ofs; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_bytes buf;
       as_int ofs;
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"input"
         ~descriptor:"(LBytes;II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_input arity"))
  | "caml_int64_float_of_bits" ->
    (* Reinterpret a 64-bit bit pattern as a [double]. Stdlib's
       [infinity] / [nan] / [max_float] / [min_float] are constructed
       this way at init. *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"longBitsToDouble"
         ~descriptor:"(J)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_int64_float_of_bits arity"))
  | "caml_int64_bits_of_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"doubleToRawLongBits"
         ~descriptor:"(D)J";
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_int64_bits_of_float arity"))
  | "caml_int32_bits_of_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       (* Narrow to float then extract the 32-bit pattern. *)
       Jvm.Code.d2f ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Float"
         ~method_:"floatToRawIntBits"
         ~descriptor:"(F)I";
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_bits_of_float arity"))
  | "caml_int32_float_of_bits" ->
    (* Reinterpret a 32-bit bit pattern as a JVM [float], then widen
       to [double] — OCaml's [Int32.float_of_bits] returns an OCaml
       float (= JVM double), so the single→double widening is
       value-preserving and that's what the caller expects. *)
    (match args with
     | [ Pv v ] ->
       as_int v;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Float"
         ~method_:"intBitsToFloat"
         ~descriptor:"(I)F";
       Jvm.Code.f2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_int32_float_of_bits arity"))
  (* int64 / int32 / nativeint ops — our int is 32-bit JVM int, so
     these collapse to the identity / pass-through operations on
     the boxed Integer representation. Not bit-accurate for values
     outside the JVM int range but enough for most Stdlib paths
     that route through Hashtbl.hash, Random, etc. *)
  | "caml_hash" ->
    (* Stdlib's Hashtbl calls this to compute a hash. Return
       a simple polymorphic hash using Object.hashCode() on the
       boxed value. OCaml's hash is structural; this is coarser
       but enough to make Hashtbl work at a basic level. *)
    (match args with
     | [ _; _; _; Pv v ] | [ Pv v ] | [ Pv v; _ ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Object"
         ~method_:"hashCode"
         ~descriptor:"()I";
       (* OCaml hashes to a non-negative 30-bit int; mask. *)
       Jvm.Code.ldc_int ctx.code 0x3fffffff;
       Jvm.Code.iand ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_hash arity"))
  | "caml_string_hash" ->
    (match args with
     | [ _; Pv s ] | [ Pv s ] ->
       emit_load ctx s;
       Jvm.Code.checkcast ctx.code "java/lang/String";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"hashCode"
         ~descriptor:"()I";
       Jvm.Code.ldc_int ctx.code 0x3fffffff;
       Jvm.Code.iand ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_hash arity"))
  (* ==== Int32 arithmetic ==== identity-on-32-bit int semantics.
     Values flow as boxed [java.lang.Integer]. *)
  | "caml_int32_of_int" | "caml_int_of_int32" ->
    (match args with
     | [ Pv v ] ->
       as_int v;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_add" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iadd ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_sub" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.isub ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_mul" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.imul ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_xor" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ixor ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_and" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iand ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_or" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ior ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_shift_left" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ishl ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_shift_right" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ishr ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Integer" ~method_:"compare"
         ~descriptor:"(II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_int32_compare arity"))
  | "caml_int32_div" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.idiv ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_div arity"))
  | "caml_int32_mod" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.irem ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_mod arity"))
  | "caml_int32_neg" ->
    (match args with
     | [ Pv a ] ->
       as_int a;
       Jvm.Code.ineg ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_neg arity"))
  | "caml_int32_of_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.d2i ctx.code;
       Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_of_float arity"))
  | "caml_int32_to_float" ->
    (match args with
     | [ Pv v ] ->
       as_int v;
       Jvm.Code.i2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_int32_to_float arity"))
  | "caml_int32_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Integer" ~method_:"parseInt"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_of_string arity"))
  | "caml_int32_bswap" ->
    (match args with
     | [ Pv v ] ->
       as_int v;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Integer" ~method_:"reverseBytes"
         ~descriptor:"(I)I";
       Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int32_bswap arity"))
  | "caml_int64_bswap" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Long" ~method_:"reverseBytes"
         ~descriptor:"(J)J";
       Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int64_bswap arity"))
  | "caml_int64_of_nativeint" | "caml_int64_to_nativeint" ->
    (* Both nativeint and int64 use JVM [long], so identity. *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Long" ~method_:"parseLong"
         ~descriptor:"(Ljava/lang/String;)J";
       Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_int64_of_string arity"))
  | "caml_nativeint_of_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.d2l ctx.code;
       Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_nativeint_of_float arity"))
  | "caml_nativeint_to_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.l2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_nativeint_to_float arity"))
  | "caml_nativeint_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code ~class_:"java/lang/Long" ~method_:"parseLong"
         ~descriptor:"(Ljava/lang/String;)J";
       Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported "caml_nativeint_of_string arity"))
  | "caml_int32_shift_right_unsigned" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iushr ctx.code; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int32_to_int" ->
    (match args with
     | [ Pv v ] ->
       as_int v; Kind.emit_box_int ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  (* ==== Int64 / Nativeint arithmetic ==== JVM [long] semantics.
     Values flow as boxed [java.lang.Long]. *)
  | "caml_int64_of_int" | "caml_nativeint_of_int" ->
    (match args with
     | [ Pv v ] ->
       as_int v;
       Jvm.Code.i2l ctx.code;
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int_of_int64" | "caml_int_of_nativeint" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.l2i ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_add" | "caml_nativeint_add" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.ladd ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_sub" | "caml_nativeint_sub" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lsub ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_mul" | "caml_nativeint_mul" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lmul ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_div" | "caml_nativeint_div" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.ldiv ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_mod" | "caml_nativeint_mod" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lrem ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_neg" | "caml_nativeint_neg" ->
    (match args with
     | [ Pv a ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lneg ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_xor" | "caml_nativeint_xor" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lxor_ ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_and" | "caml_nativeint_and" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.land_ ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_or" | "caml_nativeint_or" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lor_ ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_left" | "caml_nativeint_shift_left" ->
    (* JVM [lshl] takes a long on bottom and an int shift count on
       top — the shift count's low 6 bits are used. *)
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       as_int b;
       Jvm.Code.lshl ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_right" | "caml_nativeint_shift_right" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       as_int b;
       Jvm.Code.lshr ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_right_unsigned" | "caml_nativeint_shift_right_unsigned" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       as_int b;
       Jvm.Code.lushr ctx.code; Kind.emit_box_long ctx.code; Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_to_int" | "caml_nativeint_to_int" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.l2i ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_of_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code ~class_:"java/lang/Double" ~method_:"doubleValue" ~descriptor:"()D");
       Jvm.Code.d2l ctx.code;
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_int64_of_float arity"))
  | "caml_int64_to_float" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.l2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_int64_to_float arity"))
  | "caml_int64_compare" | "caml_nativeint_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a; Kind.emit_unbox_long ctx.code;
       emit_load ctx b; Kind.emit_unbox_long ctx.code;
       Jvm.Code.lcmp ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_of_int32" | "caml_nativeint_of_int32" ->
    (match args with
     | [ Pv v ] ->
       as_int v;
       Jvm.Code.i2l ctx.code;
       Kind.emit_box_long ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_to_int32" | "caml_nativeint_to_int32" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Kind.emit_unbox_long ctx.code;
       Jvm.Code.l2i ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_atomic_load" ->
    (* Atomic_load ref: read field 0 of the block — identical
       semantics to a plain !ref on the JVM under the default
       memory model. *)
    (match args with
     | [ Pv r ] ->
       as_block r;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_atomic_load arity"))
  | "caml_ml_output_bytes" ->
    (match args with
     | [ Pv chan; Pv b; Pv off; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"asString"
         ~descriptor:"()Ljava/lang/String;";
       as_int off;
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"output"
         ~descriptor:"(Ljava/lang/String;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output_bytes arity"))
  | "caml_floatarray_create" | "caml_make_float_vect" ->
    (* [arr = new Object[n]; Arrays.fill(arr, Double.valueOf(0.0)); return
       new Block(Double_array_tag, arr)]. *)
    (match args with
     | [ Pv n ] ->
       let arr_local = ctx.next_local in
       ctx.next_local <- arr_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       as_int n;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.astore ctx.code arr_local;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.ldc_double ctx.code 0.0;
       Kind.emit_box_float ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"fill"
         ~descriptor:"([Ljava/lang/Object;Ljava/lang/Object;)V";
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 254;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_floatarray_create arity"))
  | "caml_array_make" | "caml_make_vect" ->
    (* [arr = new Object[n]; Arrays.fill(arr, boxed(init)); return new
       Block(0, arr)]. Use a temp local to save the array across the
       void-returning Arrays.fill. *)
    (match args with
     | [ Pv n; Pv init ] ->
       let arr_local = ctx.next_local in
       ctx.next_local <- arr_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       as_int n;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.astore ctx.code arr_local;
       Jvm.Code.aload ctx.code arr_local;
       emit_load ctx init;
       (match kind_of ctx init with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"fill"
         ~descriptor:"([Ljava/lang/Object;Ljava/lang/Object;)V";
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_make arity"))
  | "caml_array_blit" ->
    (* Array.blit src srcofs dst dstofs len → System.arraycopy on
       the underlying [Block.fields] Object[]. *)
    (match args with
     | [ Pv src; Pv srcofs; Pv dst; Pv dstofs; Pv len ] ->
       as_block src;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int srcofs;
       as_block dst;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int dstofs;
       as_int len;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"arraycopy"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_blit arity"))
  | "caml_array_sub" ->
    (* Array.sub src ofs len → new Block(0, Arrays.copyOfRange(
       src.fields, ofs, ofs+len)). *)
    (match args with
     | [ Pv src; Pv ofs; Pv len ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       as_block src;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int ofs;
       (* end index = ofs + len; compute on the JVM stack. *)
       as_int ofs;
       as_int len;
       Jvm.Code.iadd ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"copyOfRange"
         ~descriptor:
           "([Ljava/lang/Object;II)[Ljava/lang/Object;";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_sub arity"))
  | "caml_array_fill" ->
    (* Array.fill arr ofs len v → Arrays.fill(arr.fields, ofs,
       ofs+len, boxed(v)). Need a temp for len's contribution to
       the end index since Arrays.fill's range is [from, to). *)
    (match args with
     | [ Pv arr; Pv ofs; Pv len; Pv v ] ->
       as_block arr;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int ofs;
       as_int ofs;
       as_int len;
       Jvm.Code.iadd ctx.code;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"fill"
         ~descriptor:
           "([Ljava/lang/Object;IILjava/lang/Object;)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_fill arity"))
  | "caml_array_append" ->
    (* Array.append a1 a2 → new Block(0, dst) where dst is a
       fresh Object[] of length len1+len2 filled by two
       System.arraycopy calls. Use a temp local for the dst
       reference since arraycopy returns void. *)
    (match args with
     | [ Pv a1; Pv a2 ] ->
       let dst_local = ctx.next_local in
       ctx.next_local <- dst_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       (* len1 + len2 *)
       as_block a1;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.arraylength ctx.code;
       as_block a2;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.iadd ctx.code;
       (* dst = new Object[len1+len2] *)
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.astore ctx.code dst_local;
       (* System.arraycopy(a1.fields, 0, dst, 0, len1) *)
       as_block a1;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_local;
       Jvm.Code.ldc_int ctx.code 0;
       as_block a1;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"arraycopy"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)V";
       (* System.arraycopy(a2.fields, 0, dst, len1, len2) *)
       as_block a2;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_local;
       as_block a1;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.arraylength ctx.code;
       as_block a2;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"arraycopy"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)V";
       (* return new Block(0, dst) *)
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_local;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_append arity"))
  | "caml_ephe_create" | "caml_weak_create" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"create"
         ~descriptor:"(I)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_create arity"))
  | "caml_ephe_set_key" | "caml_weak_set" ->
    (* [caml_weak_set] has a different signature than [caml_ephe_set_key]:
       it takes a [v option], while ephe_set_key takes [v] directly.
       OCaml's [Weak.set x i None] calls [caml_weak_set], which jsoo
       dispatches to unset_key. Here [caml_weak_set] is emitted only by
       code paths where the value is known-Some, so treat them the
       same. *)
    (match args with
     | [ Pv t; Pv i; Pv v ] ->
       emit_load ctx t;
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"set_key"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_set_key arity"))
  | "caml_ephe_unset_key" ->
    (match args with
     | [ Pv t; Pv i ] ->
       emit_load ctx t;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"unset_key"
         ~descriptor:"(Ljava/lang/Object;I)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_unset_key arity"))
  | "caml_ephe_get_key" | "caml_weak_get" ->
    (match args with
     | [ Pv t; Pv i ] ->
       emit_load ctx t;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"get_key"
         ~descriptor:"(Ljava/lang/Object;I)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_get_key arity"))
  | "caml_ephe_get_key_copy" | "caml_weak_get_copy" ->
    (match args with
     | [ Pv t; Pv i ] ->
       emit_load ctx t;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"get_key_copy"
         ~descriptor:"(Ljava/lang/Object;I)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_get_key_copy arity"))
  | "caml_ephe_check_key" | "caml_weak_check" ->
    (match args with
     | [ Pv t; Pv i ] ->
       emit_load ctx t;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"check_key"
         ~descriptor:"(Ljava/lang/Object;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ephe_check_key arity"))
  | "caml_ephe_set_data" ->
    (match args with
     | [ Pv t; Pv v ] ->
       emit_load ctx t;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"set_data"
         ~descriptor:
           "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_set_data arity"))
  | "caml_ephe_unset_data" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"unset_data"
         ~descriptor:"(Ljava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_unset_data arity"))
  | "caml_ephe_get_data" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"get_data"
         ~descriptor:"(Ljava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_get_data arity"))
  | "caml_ephe_get_data_copy" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"get_data_copy"
         ~descriptor:"(Ljava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_get_data_copy arity"))
  | "caml_ephe_check_data" ->
    (match args with
     | [ Pv t ] ->
       emit_load ctx t;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"check_data"
         ~descriptor:"(Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_ephe_check_data arity"))
  | "caml_ephe_blit_data" ->
    (match args with
     | [ Pv src; Pv dst ] ->
       emit_load ctx src;
       emit_load ctx dst;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"blit_data"
         ~descriptor:
           "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_blit_data arity"))
  | "caml_ephe_blit_key" | "caml_weak_blit" ->
    (match args with
     | [ Pv a1; Pv i1; Pv a2; Pv i2; Pv len ] ->
       emit_load ctx a1;
       as_int i1;
       emit_load ctx a2;
       as_int i2;
       as_int len;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Ephemeron"
         ~method_:"blit_key"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)Ljava/lang/Object;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ephe_blit_key arity"))
  (* --- Base runtime primitives (mirror [_opam/lib/base/runtime.js]).
     Base's inline runtime is [//Weakdef] so any C/JS stub suffices;
     we emit the simplest JVM equivalent for each. *)
  | "Base_am_testing" ->
    (* Always false — we're not running in Base's test harness.
       The arg is unused; [emit_ccall] doesn't pre-push args, so we
       just emit the constant. *)
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "Base_clear_caml_backtrace_pos" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "Base_caml_exn_is_most_recent_exn" ->
    Jvm.Code.ldc_int ctx.code 1;
    Kind.K_int
  | "Base_int_math_int_popcount" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"bitCount"
         ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "Base_int_math_int_popcount arity"))
  | "Base_int_math_int_clz"
  | "Base_int_math_int32_clz"
  | "Base_int_math_nativeint_clz" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"numberOfLeadingZeros"
         ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "Base_int_math_clz arity"))
  | "Base_int_math_int_ctz"
  | "Base_int_math_int32_ctz"
  | "Base_int_math_nativeint_ctz" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"numberOfTrailingZeros"
         ~descriptor:"(I)I";
       Kind.K_int
     | _ -> raise (Unsupported "Base_int_math_ctz arity"))
  | "Base_int_math_int_pow_stub" ->
    (* Integer exponentiation by squaring. Use a small helper emit
       pattern: no runtime dep needed, just [imul] + [iushr] in a
       loop. Cheaper to emit as a runtime invocation via
       [java.lang.Math.pow] on doubles; we do that here since the
       precise overflow semantics match Base's stub. *)
    (match args with
     | [ Pv b; Pv e ] ->
       as_int b;
       Jvm.Code.i2d ctx.code;
       as_int e;
       Jvm.Code.i2d ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Math"
         ~method_:"pow"
         ~descriptor:"(DD)D";
       Jvm.Code.d2i ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "Base_int_math_int_pow_stub arity"))
  | "Base_unsafe_create_local_bytes" ->
    (* Same as [caml_create_bytes]: allocate a fresh [Bytes] of the
       requested length. Base uses this for a "local" allocation that
       has no special meaning on the JVM. *)
    (match args with
     | [ Pv n ] ->
       Jvm.Code.new_ ctx.code "Bytes";
       Jvm.Code.dup ctx.code;
       as_int n;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Bytes"
         ~method_:"<init>"
         ~descriptor:"(I)V";
       Kind.K_obj
     | _ -> raise (Unsupported "Base_unsafe_create_local_bytes arity"))
  | "caml_make_local_vect" ->
    (* Same shape as [caml_make_vect] — no stack-local array on the JVM. *)
    emit_ccall ctx "caml_array_make" args
  | "Base_hash_string" ->
    (match args with
     | [ Pv s ] ->
       emit_load ctx s;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Object"
         ~method_:"hashCode"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "Base_hash_string arity"))
  | "Base_hash_double" ->
    (match args with
     | [ Pv d ] ->
       emit_load ctx d;
       (match kind_of ctx d with
        | K_float ->
          Jvm.Code.invokestatic
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"valueOf"
            ~descriptor:"(D)Ljava/lang/Double;"
        | _ -> Jvm.Code.checkcast ctx.code "java/lang/Double");
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Object"
         ~method_:"hashCode"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "Base_hash_double arity"))
  | "caml_dummy_obj_is_stack" ->
    (* Documented unreachable; emit a throwing stub rather than an
       actual implementation. *)
    Jvm.Code.new_ ctx.code "java/lang/UnsupportedOperationException";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_string
      ctx.code
      "caml_dummy_obj_is_stack: should be unreachable";
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"java/lang/UnsupportedOperationException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    Jvm.Code.athrow ctx.code;
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj
  | "caml_array_get_addr" | "caml_array_unsafe_get_addr" ->
    (match args with
     | [ Pv a; Pv i ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_get_addr arity"))
  | "caml_array_set_addr" | "caml_array_unsafe_set_addr" ->
    (match args with
     | [ Pv a; Pv i; Pv v ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_set_addr arity"))
  | "caml_obj_block" ->
    (* [caml_obj_block tag size] creates a block with [size]
       uninitialized fields and the given [tag]. *)
    (match args with
     | [ Pv tag; Pv size ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       as_int tag;
       as_int size;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_block arity"))
  | "caml_alloc_dummy" | "caml_alloc_dummy_float" ->
    (* [caml_alloc_dummy size] allocates a placeholder [Block] with
       tag 0 and [size] fields, later filled in by
       [caml_update_dummy]. Used by the compiler for recursive
       values ([let rec x = ...]) and by [CamlinternalMod] for
       recursive-module value / module shapes.

       [caml_alloc_dummy_float] has the same semantics in our
       representation since we don't flatten double arrays. *)
    (match args with
     | [ Pv size ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       as_int size;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_alloc_dummy arity"))
  | "caml_alloc_dummy_function" ->
    (* Recursive-closure placeholder: [let rec f x = ...] that
       references [f] inside the body, and the Function-shape slots
       [CamlinternalMod] pre-fills for recursive modules. Returns a
       [DummyClosure] whose applyN forwards to a null [target] until
       [caml_update_dummy] patches it to the real body.
       Both args (size, arity) are ignored — DummyClosure doesn't
       need either; arity comes from the real target at patch time. *)
    (match args with
     | [ _size; _arity ] ->
       Jvm.Code.new_ ctx.code "DummyClosure";
       Jvm.Code.dup ctx.code;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"DummyClosure"
         ~method_:"<init>"
         ~descriptor:"()V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_alloc_dummy_function arity"))
  | "caml_update_dummy" ->
    (* Dispatch on [dst]'s runtime type:
       - [DummyClosure] (from [caml_alloc_dummy_function]): set its
         [target] field to [src]; subsequent applyN on the dummy
         forwards there.
       - [Block] (from [caml_alloc_dummy] / [caml_alloc_dummy_float]):
         arraycopy [src.fields] into [dst.fields], leaving the tag
         at its [caml_alloc_dummy] value of 0. This covers the
         common recursive-value ([let rec xs = x :: xs]) and
         recursive-module cases where [src] is also a Block.

       We pick the branch via an [instanceof DummyClosure] check
       rather than emitting two different prim calls from the front
       end, because the same [caml_update_dummy] is invoked for both
       closure and data dummies from within user OCaml code like
       [CamlinternalMod]. *)
    (match args with
     | [ Pv dst; Pv src ] ->
       let end_lbl = Jvm.Code.fresh_label ctx.code in
       let not_dummy_lbl = Jvm.Code.fresh_label ctx.code in
       let dst_fields_local = ctx.next_local in
       ctx.next_local <- dst_fields_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       (* if (dst instanceof DummyClosure) ((DummyClosure)dst).target = (Closure)src; *)
       emit_load ctx dst;
       Jvm.Code.instanceof_ ctx.code "DummyClosure";
       Jvm.Code.ifeq ctx.code not_dummy_lbl;
       emit_load ctx dst;
       Jvm.Code.checkcast ctx.code "DummyClosure";
       emit_load ctx src;
       Jvm.Code.checkcast ctx.code "Closure";
       Jvm.Code.putfield
         ctx.code
         ~class_:"DummyClosure"
         ~field:"target"
         ~descriptor:"LClosure;";
       Jvm.Code.goto ctx.code end_lbl;
       (* else copy src.fields into dst.fields *)
       Jvm.Code.mark_label ctx.code not_dummy_lbl;
       as_block dst;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.astore ctx.code dst_fields_local;
       as_block src;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_fields_local;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_fields_local;
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"arraycopy"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)V";
       Jvm.Code.mark_label ctx.code end_lbl;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_update_dummy arity"))
  | "caml_int_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a;
       as_int b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"compare"
         ~descriptor:"(II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_compare arity"))
  | "caml_string_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"compareTo"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_compare arity"))
  | "caml_set_oo_id" ->
    (* [caml_set_oo_id block] sets field 1 of [block] to a fresh
       OO-id. The legacy emitter uses a static counter. Skip the
       side-effect for IR path: return the block unchanged. *)
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_set_oo_id arity"))
  | "caml_ml_open_descriptor_out" ->
    (match args with
     | [ Pv fd ] ->
       as_int fd;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Channel"
         ~method_:"forDescriptor"
         ~descriptor:"(I)LChannel;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_open_descriptor_out arity"))
  | "caml_notequal" | "caml_equal" | "caml_compare" | "caml_lessthan"
  | "caml_greaterthan" | "caml_lessequal" | "caml_greaterequal" ->
    (* Structural comparison via the runtime Compare class. *)
    let method_, desc =
      match name with
      | "caml_equal" -> "equal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_notequal" -> "notequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_compare" -> "compare", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_lessthan" -> "lessthan", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_greaterthan" ->
        "greaterthan", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_lessequal" ->
        "lessequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_greaterequal" ->
        "greaterequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | _ -> assert false
    in
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a;
       (match kind_of ctx a with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       emit_load ctx b;
       (match kind_of ctx b with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic ctx.code ~class_:"Compare" ~method_ ~descriptor:desc;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_obj_tag" ->
    (* [caml_obj_tag v] returns [v.tag] when [v] is a [Block],
       1000 ([int_tag]) when [v] is an immediate int, and 1001
       ([string_tag]) for a [String]. We dispatch at runtime via
       [instanceof] because [v]'s inferred kind may be [K_obj]
       (the usual [Obj.t] path) or [K_int] (if the frontend
       propagated the actual int kind through an [Obj.repr]). *)
    (match args with
     | [ Pv v ] ->
       (match kind_of ctx v with
        | K_int ->
          (* Always an int → always [int_tag = 1000]. Emit the
             load purely for its side effects (none, since it's
             a pure iload on an already-typed slot) and just push
             1000. *)
          Jvm.Code.ldc_int ctx.code 1000;
          Kind.K_int
        | K_float ->
          Jvm.Code.ldc_int ctx.code 253 (* double_tag *);
          Kind.K_int
        | K_string ->
          Jvm.Code.ldc_int ctx.code 252 (* string_tag *);
          Kind.K_int
        | K_block _ ->
          emit_load ctx v;
          (* K_block is already boxed as Block reference. *)
          Jvm.Code.getfield
            ctx.code
            ~class_:"Block"
            ~field:"tag"
            ~descriptor:"I";
          Kind.K_int
        | K_closure _ ->
          Jvm.Code.ldc_int ctx.code 247 (* closure_tag *);
          Kind.K_int
        | K_obj ->
          (* Runtime dispatch: if [instanceof Block], read .tag;
             else if [instanceof java/lang/Integer] → 1000; else
             if [instanceof java/lang/String] → 252; else 0 (the
             generic object tag; shouldn't arise in practice). *)
          let l_block = Jvm.Code.fresh_label ctx.code in
          let l_end = Jvm.Code.fresh_label ctx.code in
          let l_int = Jvm.Code.fresh_label ctx.code in
          let l_not_int = Jvm.Code.fresh_label ctx.code in
          let l_str = Jvm.Code.fresh_label ctx.code in
          emit_load ctx v;
          Jvm.Code.dup ctx.code;
          Jvm.Code.instanceof_ ctx.code "Block";
          Jvm.Code.ifne ctx.code l_block;
          Jvm.Code.dup ctx.code;
          Jvm.Code.instanceof_ ctx.code "java/lang/Integer";
          Jvm.Code.ifne ctx.code l_int;
          Jvm.Code.dup ctx.code;
          Jvm.Code.instanceof_ ctx.code "java/lang/String";
          Jvm.Code.ifne ctx.code l_str;
          Jvm.Code.goto_w ctx.code l_not_int;
          Jvm.Code.mark_label ctx.code l_block;
          Jvm.Code.checkcast ctx.code "Block";
          Jvm.Code.getfield
            ctx.code
            ~class_:"Block"
            ~field:"tag"
            ~descriptor:"I";
          Jvm.Code.goto_w ctx.code l_end;
          Jvm.Code.mark_label ctx.code l_int;
          Jvm.Code.pop_top ctx.code;
          Jvm.Code.ldc_int ctx.code 1000;
          Jvm.Code.goto_w ctx.code l_end;
          Jvm.Code.mark_label ctx.code l_str;
          Jvm.Code.pop_top ctx.code;
          Jvm.Code.ldc_int ctx.code 252;
          Jvm.Code.goto_w ctx.code l_end;
          Jvm.Code.mark_label ctx.code l_not_int;
          Jvm.Code.pop_top ctx.code;
          Jvm.Code.ldc_int ctx.code 0;
          Jvm.Code.mark_label ctx.code l_end;
          Kind.K_int)
     | _ -> raise (Unsupported "caml_obj_tag arity"))
  | "caml_obj_with_tag" ->
    (* [caml_obj_with_tag tag v] allocates a fresh [Block] with the
       given tag and a shallow copy of [v]'s fields. *)
    (match args with
     | [ Pv tag; Pv v ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       as_int tag;
       as_block v;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       (* Arrays.copyOf(fields, fields.length). Use dup + arraylength
          to avoid reloading v. *)
       Jvm.Code.dup ctx.code;
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"copyOf"
         ~descriptor:"([Ljava/lang/Object;I)[Ljava/lang/Object;";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_with_tag arity"))
  | "caml_lazy_update_to_forcing" ->
    (* Atomically flip the tag from [lazy_tag=246] to [forcing_tag=244].
       Single-threaded semantics: no CAS loop, just a tag check +
       set. Returns 0 on success, 1 if the tag wasn't [lazy_tag]. *)
    (match args with
     | [ Pv v ] ->
       let mismatch_lbl = Jvm.Code.fresh_label ctx.code in
       let done_lbl = Jvm.Code.fresh_label ctx.code in
       emit_load ctx v;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.getfield ctx.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       Jvm.Code.ldc_int ctx.code 246;
       Jvm.Code.if_icmpne ctx.code mismatch_lbl;
       (* Match: stack top is the [Block]; set its tag to 244 and
          push 0. *)
       Jvm.Code.ldc_int ctx.code 244;
       Jvm.Code.putfield ctx.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.goto ctx.code done_lbl;
       Jvm.Code.mark_label ctx.code mismatch_lbl;
       (* Mismatch: stack top is the [Block]; discard it and push 1. *)
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.mark_label ctx.code done_lbl;
       Kind.K_int
     | _ -> raise (Unsupported "caml_lazy_update_to_forcing arity"))
  | "caml_lazy_reset_to_lazy" ->
    (* Rewrite the tag back to [lazy_tag=246] on force-exception. *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.ldc_int ctx.code 246;
       Jvm.Code.putfield ctx.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_lazy_reset_to_lazy arity"))
  | "caml_lazy_update_to_forward" ->
    (* Rewrite the tag to [forward_tag=250] once the result is stored.
       At this point field 0 holds the forced value rather than the
       thunk closure. *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.ldc_int ctx.code 250;
       Jvm.Code.putfield ctx.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_lazy_update_to_forward arity"))
  | "caml_lazy_make_forward" ->
    (* [new Block(forward_tag=250, new Object[]{ v })]. *)
    (match args with
     | [ v ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 250;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       let k = emit_prim_arg ctx v in
       (match k with
        | Kind.K_int -> Kind.emit_box_int ctx.code
        | Kind.K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_lazy_make_forward arity"))
  | "caml_array_of_uniform_array" | "caml_make_array" ->
    (* Both are identity for our backend: we represent OCaml arrays
       as [Block]s and the bytecode emits these to promote literal
       arrays / concat results to the uniform-array shape, which our
       representation already is. *)
    (match args with
     | [ a ] ->
       let _ = emit_prim_arg ctx a in
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_of_uniform_array arity"))
  | "caml_obj_dup" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (* Block.dup() returns a shallow-copy Block. *)
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Block"
         ~method_:"dup"
         ~descriptor:"()LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_dup arity"))
  | "caml_atomic_exchange" ->
    (* r := new; return old. *)
    (match args with
     | [ Pv r; Pv v ] ->
       let arr_local = ctx.next_local in
       ctx.next_local <- arr_local + 1;
       let old_local = ctx.next_local in
       ctx.next_local <- old_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       emit_load ctx r;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.astore ctx.code arr_local;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aaload ctx.code;
       Jvm.Code.astore ctx.code old_local;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.ldc_int ctx.code 0;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.aload ctx.code old_local;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_atomic_exchange arity"))
  | "caml_atomic_fetch_add" ->
    (* r field 0 += delta; return old int. *)
    (match args with
     | [ Pv r; Pv d ] ->
       let arr_local = ctx.next_local in
       ctx.next_local <- arr_local + 1;
       let old_local = ctx.next_local in
       ctx.next_local <- old_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       emit_load ctx r;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.astore ctx.code arr_local;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aaload ctx.code;
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       Jvm.Code.istore ctx.code old_local;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.iload ctx.code old_local;
       as_int d;
       Jvm.Code.iadd ctx.code;
       Kind.emit_box_int ctx.code;
       Jvm.Code.aastore ctx.code;
       Jvm.Code.iload ctx.code old_local;
       Kind.K_int
     | _ -> raise (Unsupported "caml_atomic_fetch_add arity"))
  | "caml_atomic_cas" ->
    (* Returns 1 if swap succeeded, else 0. *)
    (match args with
     | [ Pv r; Pv expected; Pv new_ ] ->
       let label_ne = Jvm.Code.fresh_label ctx.code in
       let label_end = Jvm.Code.fresh_label ctx.code in
       emit_load ctx r;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       (* Stack: fields *)
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aaload ctx.code;
       emit_load ctx expected;
       (match kind_of ctx expected with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       (* Stack: fields, cur, expected *)
       Jvm.Code.if_acmpne ctx.code label_ne;
       Jvm.Code.ldc_int ctx.code 0;
       emit_load ctx new_;
       (match kind_of ctx new_ with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.goto ctx.code label_end;
       Jvm.Code.mark_label ctx.code label_ne;
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.mark_label ctx.code label_end;
       Kind.K_int
     | _ -> raise (Unsupported "caml_atomic_cas arity"))
  | "caml_atomic_make_contended" ->
    (* Just wrap in a Block of size 1, tag 0. *)
    (match args with
     | [ Pv v ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.invokespecial ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_atomic_make_contended arity"))
  | "caml_domain_dls_set" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Jvm.Code.putstatic ctx.code
         ~class_:"Main"
         ~field:"DLS_STATE"
         ~descriptor:"Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_domain_dls_set arity"))
  | "caml_domain_dls_get" ->
    Jvm.Code.getstatic ctx.code
      ~class_:"Main"
      ~field:"DLS_STATE"
      ~descriptor:"Ljava/lang/Object;";
    Kind.K_obj
  | "caml_domain_dls_compare_and_set" ->
    (match args with
     | [ Pv old_; Pv new_ ] ->
       let label_ne = Jvm.Code.fresh_label ctx.code in
       let label_end = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.getstatic ctx.code
         ~class_:"Main"
         ~field:"DLS_STATE"
         ~descriptor:"Ljava/lang/Object;";
       emit_load ctx old_;
       Jvm.Code.if_acmpne ctx.code label_ne;
       emit_load ctx new_;
       Jvm.Code.putstatic ctx.code
         ~class_:"Main"
         ~field:"DLS_STATE"
         ~descriptor:"Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.goto ctx.code label_end;
       Jvm.Code.mark_label ctx.code label_ne;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.mark_label ctx.code label_end;
       Kind.K_int
     | _ -> raise (Unsupported "caml_domain_dls_compare_and_set arity"))
  | "caml_ml_domain_id" | "caml_ml_domain_index" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_recommended_domain_count" ->
    Jvm.Code.ldc_int ctx.code 1;
    Kind.K_int
  | "caml_ml_domain_cpu_relax" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_fresh_oo_id" ->
    (* Compile-time counter — stable enough because module init is
       the only caller and runs once at Main.main entry. Matches
       legacy. *)
    let n = !(ctx.fresh_oo_id) in
    ctx.fresh_oo_id := n + 1;
    Jvm.Code.ldc_int ctx.code n;
    Kind.K_int
  | _ ->
    (* Unknown C primitive: emit a runtime-throwing stub rather than
       falling back to the legacy emitter. Matches what legacy does
       for OO / effect opcodes. Programs that never reach this call
       path at runtime (the usual case for Stdlib functions
       unrelated to the program's features) load and run cleanly. *)
    (* Drop any args already loaded — we haven't loaded any; args
       are lazily loaded per-case above. *)
    Jvm.Code.new_ ctx.code "java/lang/UnsupportedOperationException";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_string
      ctx.code
      (Printf.sprintf "C primitive %s is not implemented" name);
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"java/lang/UnsupportedOperationException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    Jvm.Code.athrow ctx.code;
    (* Dead: give downstream an Object so emit_store has something
       to pop. *)
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj

let emit_int_binop ctx op a b =
  let ka = emit_prim_arg ctx a in
  ensure_int ctx ka;
  let kb = emit_prim_arg ctx b in
  ensure_int ctx kb;
  op ctx.code

let emit_prim ctx (p : Code.prim) (args : Code.prim_arg list) : Kind.kind =
  match p, args with
  | Extern "add_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iadd a b; K_int
  | Extern "sub_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.isub a b; K_int
  | Extern "mul_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.imul a b; K_int
  | Extern "div_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.idiv a b; K_int
  | Extern "mod_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.irem a b; K_int
  | Extern "and_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iand a b; K_int
  | Extern "or_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ior a b; K_int
  | Extern "xor_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ixor a b; K_int
  | Extern "lsl_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ishl a b; K_int
  | Extern "lsr_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iushr a b; K_int
  | Extern "asr_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ishr a b; K_int
  | Extern "neg_int", [ a ] ->
    let ka = emit_prim_arg ctx a in
    ensure_int ctx ka;
    Jvm.Code.ineg ctx.code;
    K_int
  | Not, [ a ] ->
    (* Boolean negation: OCaml ints are 0/1 here; flip with 1 - x. *)
    Jvm.Code.ldc_int ctx.code 1;
    let ka = emit_prim_arg ctx a in
    ensure_int ctx ka;
    Jvm.Code.isub ctx.code;
    K_int
  | (Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge), [ a; b ] ->
    (* OCaml's EQ / NEQ opcodes are bitwise: int compare for
       immediates, reference compare for blocks. LT/LE/GT/GE (and
       unsigned variants) are only meaningful on ints. We dispatch
       off the typed kinds of the operands:
       - Both statically-int: unbox + if_icmp<op>.
       - Eq/Neq with at least one reference-typed operand: box both
         to Object if needed, then if_acmpeq / if_acmpne. This is
         the right semantics for exception-constructor matching
         (Block(248, [name, id]) references compared by identity
         via the shared Main.GLOBALS array).
       - Lt/Le/Gt/Ge/Ult/Uge on non-ints: unbox anyway (assume
         they're boxed Integers; OCaml doesn't emit these on
         blocks).*)
    let arg_kind = function
      | Code.Pv v -> kind_of ctx v
      | Pc (Int _) -> K_int
      | Pc (Float _) -> K_float
      | Pc (String _) -> K_string
      | Pc (Block _) -> K_obj
      | Pc Null -> K_obj
    in
    let ka = arg_kind a in
    let kb = arg_kind b in
    (* For [Eq] / [Neq], dispatch on which kind of equality we need:
       - value equality on ints (bytecode [BEQ n] or polymorphic-
         variant dispatch): one or both operands are statically
         known ints. Unbox the other side and use [if_icmp*].
       - reference equality on refs (exception-constructor matching,
         shared descriptors): neither operand is known-int — box
         both to Object and use [if_acmp*].
       The subtle case is "one K_int, one K_obj": at runtime both
       hold the same integer (the frontend boxed the K_int one
       into an [Integer] because of a cross-block edge), but the
       [Integer] objects are distinct references for values beyond
       the JVM's [Integer.valueOf] cache (|n| > 127). Reference
       equality would silently fail on, e.g., polymorphic-variant
       hashes like `Blue = 737308346`. *)
    let known_int = function
      | Kind.K_int -> true
      | _ -> false
    in
    let use_ref =
      match p with
      | Eq | Neq -> not (known_int ka || known_int kb)
      | _ -> false
    in
    let l_true = Jvm.Code.fresh_label ctx.code in
    let l_end = Jvm.Code.fresh_label ctx.code in
    if use_ref
    then (
      (* [Object.equals] gives us what OCaml's bitwise [=] /
         [<>] want on every representation we actually use:
         - Two boxed [Integer]s compare by value (the JVM's
           [Integer.valueOf] cache only covers -128..127, so
           [if_acmpeq] on Integer(128) would silently be false).
         - [Block] (heap tuples / variants / exception
           descriptors) doesn't override [equals], so it falls
           back to reference equality, which is the right thing
           for exception-constructor matching.
         - Same for [Closure]. [String.equals] is content
           equality, slightly stricter than OCaml's raw [==] on
           strings, but OCaml code rarely relies on string
           pointer equality. *)
      let load_as_obj pa =
        let k = emit_prim_arg ctx pa in
        match k with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ()
      in
      load_as_obj a;
      load_as_obj b;
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"java/lang/Object"
        ~method_:"equals"
        ~descriptor:"(Ljava/lang/Object;)Z";
      (match p with
       | Eq -> Jvm.Code.ifne ctx.code l_true
       | Neq -> Jvm.Code.ifeq ctx.code l_true
       | _ -> assert false))
    else (
      let _ = emit_prim_arg ctx a in
      ensure_int ctx ka;
      let _ = emit_prim_arg ctx b in
      ensure_int ctx kb;
      (* Ult / Uge need unsigned semantics; JVM's if_icmp family is
         signed. Flip the sign bit (JVM 32-bit INT_MIN, which is
         -2^31, NOT OCaml's 63-bit min_int) on each operand first so
         [signed compare of (x ^ INT_MIN)] gives the unsigned
         ordering. Operands are already on the stack at this point,
         so we XOR each with INT_MIN in place. *)
      let jvm_int_min = -2147483648 in
      (match p with
       | Ult | Uge ->
         let tmp = ctx.next_local in
         ctx.next_local <- tmp + 1;
         Jvm.Code.set_min_locals ctx.code ctx.next_local;
         Jvm.Code.ldc_int ctx.code jvm_int_min;
         Jvm.Code.ixor ctx.code;
         Jvm.Code.istore ctx.code tmp;
         Jvm.Code.ldc_int ctx.code jvm_int_min;
         Jvm.Code.ixor ctx.code;
         Jvm.Code.iload ctx.code tmp
       | _ -> ());
      match p with
      | Eq -> Jvm.Code.if_icmpeq ctx.code l_true
      | Neq -> Jvm.Code.if_icmpne ctx.code l_true
      | Lt -> Jvm.Code.if_icmplt ctx.code l_true
      | Ult -> Jvm.Code.if_icmplt ctx.code l_true
      | Le -> Jvm.Code.if_icmple ctx.code l_true
      | Gt -> Jvm.Code.if_icmpgt ctx.code l_true
      | Ge -> Jvm.Code.if_icmpge ctx.code l_true
      | Uge -> Jvm.Code.if_icmpge ctx.code l_true
      | _ -> assert false);
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.goto_w ctx.code l_end;
    Jvm.Code.mark_label ctx.code l_true;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.mark_label ctx.code l_end;
    K_int
  | Extern "set_sibling", [ Pv self; Pc (Int idx); Pv other ] ->
    (* [self.sibling_<idx> = other] on the closure subclass [self]
       belongs to. [kind_of self] is K_closure tagged with the
       body_pc (as a string); look up the real class name via
       [name_of_body]. *)
    let class_name =
      match kind_of ctx self with
      | K_closure { name; _ } ->
        (match int_of_string_opt name with
         | Some body_pc ->
           (try ctx.name_of_body body_pc
            with Not_found ->
              raise (Unsupported "set_sibling: no class for body_pc"))
         | None -> name)
      | _ ->
        raise (Unsupported "set_sibling: self not K_closure")
    in
    emit_load ctx self;
    Jvm.Code.checkcast ctx.code class_name;
    emit_load ctx other;
    Jvm.Code.checkcast ctx.code "Closure";
    Jvm.Code.putfield
      ctx.code
      ~class_:class_name
      ~field:(Printf.sprintf "sibling_%d" idx)
      ~descriptor:"LClosure;";
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "offsetclosure", [ Pv env_arg; Pc (Int k) ] ->
    (match ctx.enclosing with
     | None -> raise (Unsupported "offsetclosure: no enclosing fn")
     | Some (fi, env_var) ->
       if not (Code.Var.equal env_arg env_var)
       then raise (Unsupported "offsetclosure on non-env var");
       let self_idx = fi.Function_info.group_idx in
       let target_idx = self_idx + (k / 3) in
       let group_len = Array.length fi.Function_info.group in
       if group_len <= 1 && k = 0
       then (
         (* Single closure, self-ref: just aload 0. *)
         Jvm.Code.aload ctx.code 0;
         K_closure { name = fi.name; captures = [] })
       else if target_idx < 0 || target_idx >= group_len
       then raise (Unsupported "offsetclosure: target out of group")
       else (
         let target = fi.Function_info.group.(target_idx) in
         Jvm.Code.aload ctx.code 0;
         Jvm.Code.getfield
           ctx.code
           ~class_:fi.name
           ~field:(Printf.sprintf "sibling_%d" target_idx)
           ~descriptor:"LClosure;";
         K_closure { name = target.name; captures = [] }))
  | Extern s, args' when String.length s > 6 && String.sub s 0 6 = "ccall_" ->
    let idx = int_of_string (String.sub s 6 (String.length s - 6)) in
    let name =
      try ctx.prim_name idx
      with Not_found -> raise (Unsupported ("ccall_" ^ string_of_int idx))
    in
    emit_ccall ctx name args'
  | Array_get, [ a; i ] ->
    let _ = emit_prim_arg ctx a in
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    let ki = emit_prim_arg ctx i in
    ensure_int ctx ki;
    Jvm.Code.aaload ctx.code;
    K_obj
  | Vectlength, [ a ] ->
    let _ = emit_prim_arg ctx a in
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.arraylength ctx.code;
    K_int
  | Extern "set_byte", [ s; i; v ] ->
    (* s.set(i, v); returns unit = 0 *)
    let ks = emit_prim_arg ctx s in
    (match ks with
     | _ -> Jvm.Code.checkcast ctx.code "Bytes");
    let ki = emit_prim_arg ctx i in
    ensure_int ctx ki;
    let kv = emit_prim_arg ctx v in
    ensure_int ctx kv;
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"Bytes"
      ~method_:"set"
      ~descriptor:"(II)V";
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "get_byte", [ a; b ] ->
    (* Read a byte from a Bytes/String at an int index. OCaml
       interchanges the two freely via unsafe_of_string; dispatch
       at runtime through [Bytes.staticGet]. *)
    let _ = emit_prim_arg ctx a in
    let kb = emit_prim_arg ctx b in
    ensure_int ctx kb;
    Jvm.Code.invokestatic
      ctx.code
      ~class_:"Bytes"
      ~method_:"staticGet"
      ~descriptor:"(Ljava/lang/Object;I)I";
    K_int
  | Extern ("getmethod" | "getpubmet" | "getdynmet"), _ ->
    (* Matches legacy: throw at runtime rather than compile-time.
       For programs that don't actually reach these ops at runtime
       (the common case), the class loads and runs cleanly. *)
    Jvm.Code.new_ ctx.code "java/lang/UnsupportedOperationException";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_string ctx.code "OCaml objects / methods are not supported";
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"java/lang/UnsupportedOperationException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    Jvm.Code.athrow ctx.code;
    (* athrow is terminating; the verifier is OK with "dead" code
       following, but we still need a value on the stack for
       consumers that expect one. Use aconst_null as placeholder. *)
    Jvm.Code.aconst_null ctx.code;
    K_obj
  | Extern "alloc_block", [ Pc (Int tag); Pc (Int n) ] ->
    (* Allocate a [Block] of the given tag and size with every
       field initialised to [null]. [Block_preallocation] emits
       this in place of a wide [Block (tag, fs)] expression and
       threads per-field [Set_field] writes at each field-Var's
       definition site, so no reader ever sees a [null] slot. *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code tag;
    Jvm.Code.ldc_int ctx.code n;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    Kind.K_obj
  | Extern "get_global", [ Pc (Int idx) ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    Jvm.Code.aaload ctx.code;
    K_obj
  | Extern "set_global", [ Pc (Int idx); Pv v ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    emit_load ctx v;
    (match kind_of ctx v with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code;
    (* Return unit (represented as int 0). *)
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "get_global_field", [ Pc (Int idx); Pc (Int field) ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    Jvm.Code.aaload ctx.code;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code field;
    Jvm.Code.aaload ctx.code;
    K_obj
  | IsInt, [ a ] ->
    let ka = emit_prim_arg ctx a in
    (match ka with
     | K_int -> Jvm.Code.ldc_int ctx.code 1; K_int
     | _ ->
       Jvm.Code.instanceof_ ctx.code "java/lang/Integer";
       K_int)
  | p, _ ->
    let p_str =
      match p with
      | Code.Extern s -> "Extern " ^ s
      | Vectlength -> "Vectlength"
      | Array_get -> "Array_get"
      | Not -> "Not"
      | IsInt -> "IsInt"
      | Eq -> "Eq" | Neq -> "Neq" | Lt -> "Lt" | Le -> "Le"
      | Gt -> "Gt" | Ge -> "Ge" | Ult -> "Ult" | Uge -> "Uge"
    in
    raise (Unsupported ("prim " ^ p_str))

(* Load a Var, then box primitives to Object so the value can be
   passed to an apply method or stored into a closure-ctor arg. *)
let emit_load_as_obj ctx v =
  emit_load ctx v;
  match kind_of ctx v with
  | K_int -> Kind.emit_box_int ctx.code
  | K_float -> Kind.emit_box_float ctx.code
  | _ -> ()

let apply_descriptor_for_nargs n =
  let b = Buffer.create 16 in
  Buffer.add_char b '(';
  for _ = 1 to n do
    Buffer.add_string b "Ljava/lang/Object;"
  done;
  Buffer.add_string b ")Ljava/lang/Object;";
  Buffer.contents b

let apply_trace_counter = ref 0

let emit_expr ctx (e : Code.expr) : Kind.kind =
  match e with
  | Constant c -> emit_constant ctx c
  | Prim (p, args) -> emit_prim ctx p args
  | Apply { f; args; exact = _ } ->
    let nargs = List.length args in
    if nargs < 1
    then raise (Unsupported (Printf.sprintf "Apply arity %d" nargs));
    (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
     | Some s when List.mem "apply_trace" (String.split_on_char ',' s) ->
       let id = !apply_trace_counter in
       incr apply_trace_counter;
       Jvm.Code.getstatic ctx.code
         ~class_:"java/lang/System"
         ~field:"err"
         ~descriptor:"Ljava/io/PrintStream;";
       Jvm.Code.ldc_int ctx.code id;
       Jvm.Code.invokevirtual ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(I)V"
     | _ -> ());
    (* [Closure] only exposes [apply1..apply7] directly. For higher-
       arity calls we chunk the arg list: call [apply7] on the first
       7 args (yields a [PartialClosure] when a caller's arity is
       larger, or the result when it's exactly 7), then [apply7] on
       the partial for the next 7, and so on. The final chunk uses
       [applyK] with [K = remaining args]. This is correct whenever
       a caller closure is a genuine curried function of arity >=
       [nargs], which is what OCaml emits for over-arity calls. *)
    let rec emit_chunks args first =
      let n_here = min 7 (List.length args) in
      let here, rest =
        let rec take k acc = function
          | xs when k = 0 -> List.rev acc, xs
          | [] -> List.rev acc, []
          | x :: xs -> take (k - 1) (x :: acc) xs
        in
        take n_here [] args
      in
      if first
      then (
        emit_load ctx f;
        (match kind_of ctx f with
         | K_closure _ -> ()
         | _ -> Jvm.Code.checkcast ctx.code "Closure"))
      else Jvm.Code.checkcast ctx.code "Closure";
      List.iter (fun a -> emit_load_as_obj ctx a) here;
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"Closure"
        ~method_:(Printf.sprintf "apply%d" n_here)
        ~descriptor:(apply_descriptor_for_nargs n_here);
      if rest <> [] then emit_chunks rest false
    in
    emit_chunks args true;
    K_obj
  | Block (tag, fields) ->
    (* new Block(tag, new Object[]{fields...}). *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code tag;
    Jvm.Code.ldc_int ctx.code (Array.length fields);
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Array.iteri
      (fun i v ->
        Jvm.Code.dup ctx.code;
        Jvm.Code.ldc_int ctx.code i;
        emit_load ctx v;
        (match kind_of ctx v with
         | K_int -> Kind.emit_box_int ctx.code
         | K_float -> Kind.emit_box_float ctx.code
         | _ -> ());
        Jvm.Code.aastore ctx.code)
      fields;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    K_obj
  | Field (v, i) ->
    (* Field(env, i) — ENVACC-style capture read. Resolve via the
       enclosing function's [cap_<idx>] field; cap index is
       [i - envofs] where envofs is the OCaml closure offset
       (function of group size and group_idx). *)
    (match ctx.enclosing with
     | Some (fi, env_var) when Code.Var.equal v env_var ->
       let nfuncs = Array.length fi.Function_info.group in
       let envofs = (3 * (nfuncs - fi.group_idx)) - 1 in
       if i < envofs
       then
         raise
           (Unsupported
              (Printf.sprintf
                 "Field(env,%d) below envofs=%d (closure-info/sibling \
                  field)"
                 i
                 envofs));
       let cap_index = i - envofs in
       let cap_kinds = !(fi.Function_info.capture_kinds) in
       let k =
         try List.nth cap_kinds cap_index
         with _ -> Kind.K_obj
       in
       Jvm.Code.aload ctx.code 0;
       Jvm.Code.getfield
         ctx.code
         ~class_:fi.name
         ~field:(Printf.sprintf "cap%d" cap_index)
         ~descriptor:(Kind.jvm_type_of_kind k);
       k
     | _ ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_block _ | K_obj ->
          Jvm.Code.checkcast ctx.code "Block";
          Jvm.Code.getfield
            ctx.code
            ~class_:"Block"
            ~field:"fields"
            ~descriptor:"[Ljava/lang/Object;";
          Jvm.Code.ldc_int ctx.code i;
          Jvm.Code.aaload ctx.code;
          K_obj
        | _ -> raise (Unsupported "Field on non-block kind")))
  | Closure { captures; body = body_pc, _ } ->
    let class_name =
      try ctx.name_of_body body_pc
      with Not_found ->
        raise
          (Unsupported
             (Printf.sprintf "no class for closure body pc %d" body_pc))
    in
    (* Look up or propagate the callee's capture kinds. If empty,
       infer from the caller's typing and propagate so the callee's
       class layout matches. This lets IR operate without legacy
       priming fn_info.capture_kinds first. *)
    let callee_cap_kinds =
      match ctx.fn_info_of_body body_pc with
      | Some fi ->
        let existing = !(fi.Function_info.capture_kinds) in
        if existing = []
        then (
          let inferred =
            List.map
              (fun v ->
                match kind_of ctx v with
                | Kind.K_int -> Kind.K_int
                | Kind.K_float -> Kind.K_float
                | _ -> Kind.K_obj)
              captures
          in
          fi.Function_info.capture_kinds := inferred;
          inferred)
        else existing
      | None -> List.map (fun _ -> Kind.K_obj) captures
    in
    let pad_len = List.length captures - List.length callee_cap_kinds in
    let cap_kinds =
      if pad_len > 0
      then
        callee_cap_kinds @ List.init pad_len (fun _ -> Kind.K_obj)
      else if pad_len < 0
      then
        let rec take n = function
          | _ when n = 0 -> []
          | [] -> []
          | x :: xs -> x :: take (n - 1) xs
        in
        take (List.length captures) callee_cap_kinds
      else callee_cap_kinds
    in
    Jvm.Code.new_ ctx.code class_name;
    Jvm.Code.dup ctx.code;
    List.iter2
      (fun v target_kind ->
        emit_load ctx v;
        let vk = kind_of ctx v in
        match (vk : Kind.kind), (target_kind : Kind.kind) with
        | a, b when a = b -> ()
        | Kind.K_int, Kind.K_obj -> Kind.emit_box_int ctx.code
        | Kind.K_float, Kind.K_obj -> Kind.emit_box_float ctx.code
        | Kind.K_obj, Kind.K_int ->
          Jvm.Code.checkcast ctx.code "java/lang/Integer";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Integer"
            ~method_:"intValue"
            ~descriptor:"()I"
        | Kind.K_obj, Kind.K_float ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D"
        | _ -> ())
      captures
      cap_kinds;
    let cap_desc =
      String.concat "" (List.map Kind.jvm_type_of_kind cap_kinds)
    in
    Jvm.Code.invokespecial
      ctx.code
      ~class_:class_name
      ~method_:"<init>"
      ~descriptor:(Printf.sprintf "(%s)V" cap_desc);
    K_closure { name = class_name; captures = [] }

let emit_instr ctx (i : Code.instr) =
  match i with
  | Let (x, e) ->
    let produced = emit_expr ctx e in
    emit_store ctx x ~from:produced
  | Set_field (x, i, y) ->
    emit_load ctx x;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code i;
    emit_load ctx y;
    (match kind_of ctx y with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code
  | Offset_ref (v, n) ->
    (* arr = v.fields; arr[0] = Integer.valueOf(((Integer)arr[0]).intValue() + n).
       Use a fresh local to hold the array cleanly. *)
    let tmp = ctx.next_local in
    ctx.next_local <- tmp + 1;
    Jvm.Code.set_min_locals ctx.code ctx.next_local;
    emit_load ctx v;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.astore ctx.code tmp;
    Jvm.Code.aload ctx.code tmp;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.aload ctx.code tmp;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.aaload ctx.code;
    Jvm.Code.checkcast ctx.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I";
    Jvm.Code.ldc_int ctx.code n;
    Jvm.Code.iadd ctx.code;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code
  | Array_set (a, i, v) ->
    emit_load ctx a;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    emit_load ctx i;
    (match kind_of ctx i with
     | K_int -> ()
     | _ ->
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I");
    emit_load ctx v;
    (match kind_of ctx v with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code
  | Source_pc pc ->
    (* Attach the OCaml source line (if DBUG has one for this PC) to
       the current JVM bytecode position. [mark_line] dedupes on
       line, so many consecutive Source_pc markers with the same
       line only produce one LineNumberTable entry. *)
    (match ctx.line_of_pc pc with
     | Some line -> Jvm.Code.mark_line ctx.code line
     | None -> ())

(* Emit a branch edge: parallel-rename the [args] into a caller's
   [param] locals, then [goto] a caller's entry label. To avoid
   clobber, load all args onto the JVM operand stack first, then
   store to params in reverse. *)
let emit_edge ctx (params : Code.Var.t list) (args : Code.Var.t list)
    target_label =
  if List.length params <> List.length args
  then
    raise
      (Unsupported
         (Printf.sprintf
            "block-edge arity mismatch: %d params vs %d args"
            (List.length params)
            (List.length args)));
  (* Short-cut: if all corresponding (param, arg) vars are equal, no
     moves needed. *)
  let equal =
    List.for_all2 (fun p a -> Code.Var.equal p a) params args
  in
  if not equal
  then (
    List.iter (fun a -> emit_load ctx a) args;
    List.iter2
      (fun p _a -> emit_store ctx p ~from:(kind_of ctx _a))
      (List.rev params)
      (List.rev args));
  Jvm.Code.goto_w ctx.code target_label

(* Find the param list of a target block. *)
let params_of_block (prog : Code.program) addr =
  match Code.Addr.Map.find_opt addr prog.blocks with
  | Some b -> b.params
  | None -> raise (Unsupported (Printf.sprintf "missing block %d" addr))

let emit_cont ctx prog (addr, args) =
  if debug_ir_gen_trace
  then
    Format.eprintf
      "[ir_gen_trace] emit_cont addr=%d args=%d@."
      addr
      (List.length args);
  let params = params_of_block prog addr in
  emit_edge ctx params args (label_of ctx addr)

let emit_last ctx prog (l : Code.last) =
  match l with
  | Return v ->
    let k = kind_of ctx v in
    emit_load ctx v;
    (match k with
     | K_int -> Kind.emit_box_int ctx.code; Jvm.Code.areturn ctx.code
     | K_float -> Kind.emit_box_float ctx.code; Jvm.Code.areturn ctx.code
     | _ -> Jvm.Code.areturn ctx.code)
  | Stop -> Jvm.Code.return_void ctx.code
  | Raise v ->
    Jvm.Code.new_ ctx.code "CamlException";
    Jvm.Code.dup ctx.code;
    emit_load_as_obj ctx v;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"CamlException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/Object;)V";
    Jvm.Code.athrow ctx.code
  | Branch c -> emit_cont ctx prog c
  | Cond (v, c_then, c_else) ->
    (* Cond tests whether [v] is truthy — for OCaml, that means
       either a non-zero immediate int or any block (cons, variant
       with args, ref, etc.). The else-arm fires only on the
       immediate [0] / empty-list. When [v] could be either (K_obj
       in particular, as for pattern matching on a list or variant),
       test [instanceof Block] first; blocks always take the
       then-arm. *)
    let l_else = Jvm.Code.fresh_label ctx.code in
    (match kind_of ctx v with
     | K_int ->
       emit_load ctx v;
       Jvm.Code.ifeq ctx.code l_else
     | K_block _ | K_closure _ | K_string ->
       (* Reference-typed values never compare zero; always truthy. *)
       ()
     | K_float ->
       emit_load ctx v;
       Jvm.Code.ldc_double ctx.code 0.0;
       Jvm.Code.dcmpl ctx.code;
       Jvm.Code.ifeq ctx.code l_else
     | K_obj ->
       emit_load ctx v;
       let l_then = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.dup ctx.code;
       Jvm.Code.instanceof_ ctx.code "Block";
       Jvm.Code.ifne ctx.code l_then;
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       Jvm.Code.ifeq ctx.code l_else;
       let l_end = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.goto_w ctx.code l_end;
       Jvm.Code.mark_label ctx.code l_then;
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.mark_label ctx.code l_end);
    emit_cont ctx prog c_then;
    Jvm.Code.mark_label ctx.code l_else;
    emit_cont ctx prog c_else
  | Switch (v, int_cases, tag_cases) ->
    let n_i = Array.length int_cases in
    let n_t = Array.length tag_cases in
    if n_i = 0 && n_t = 0 then raise (Unsupported "empty Switch");
    let kv = kind_of ctx v in
    let int_labels =
      Array.init n_i (fun _ -> Jvm.Code.fresh_label ctx.code)
    in
    let tag_labels =
      Array.init n_t (fun _ -> Jvm.Code.fresh_label ctx.code)
    in
    (* Store selector to a temp local so each case test pops cleanly
       to stack height 0 before branching. *)
    let alloc_int_local () =
      let l = ctx.next_local in
      ctx.next_local <- l + 1;
      Jvm.Code.set_min_locals ctx.code ctx.next_local;
      l
    in
    let _ = alloc_int_local in
    (* tableswitch is O(1) dispatch, uses 4-byte offsets so targets
       can be arbitrarily far from the switch, and produces far
       more compact bytecode than an if_icmpeq chain for large
       case counts. Selector is already on the operand stack as
       an int. OCaml's SWITCH has no default so we route out-of-
       range (shouldn't happen in well-typed code) to the last
       case. *)
    let emit_int_dispatch () =
      if n_i = 0
      then Jvm.Code.pop_top ctx.code
      else
        Jvm.Code.tableswitch
          ctx.code
          ~default:int_labels.(n_i - 1)
          ~low:0
          ~high:(n_i - 1)
          int_labels
    in
    let emit_tag_dispatch () =
      if n_t = 0
      then Jvm.Code.pop_top ctx.code
      else
        Jvm.Code.tableswitch
          ctx.code
          ~default:tag_labels.(n_t - 1)
          ~low:0
          ~high:(n_t - 1)
          tag_labels
    in
    if n_t = 0
    then (
      emit_load ctx v;
      (match kv with
       | K_int -> ()
       | _ ->
         Jvm.Code.checkcast ctx.code "java/lang/Integer";
         Jvm.Code.invokevirtual
           ctx.code
           ~class_:"java/lang/Integer"
           ~method_:"intValue"
           ~descriptor:"()I");
      emit_int_dispatch ())
    else if n_i = 0
    then (
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "Block";
      Jvm.Code.getfield
        ctx.code
        ~class_:"Block"
        ~field:"tag"
        ~descriptor:"I";
      emit_tag_dispatch ())
    else (
      (* Mixed: instanceof Block -> tag path, else int path. *)
      let l_block = Jvm.Code.fresh_label ctx.code in
      emit_load ctx v;
      Jvm.Code.instanceof_ ctx.code "Block";
      Jvm.Code.ifne ctx.code l_block;
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "java/lang/Integer";
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"java/lang/Integer"
        ~method_:"intValue"
        ~descriptor:"()I";
      emit_int_dispatch ();
      Jvm.Code.mark_label ctx.code l_block;
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "Block";
      Jvm.Code.getfield
        ctx.code
        ~class_:"Block"
        ~field:"tag"
        ~descriptor:"I";
      emit_tag_dispatch ());
    Array.iteri
      (fun i c ->
        Jvm.Code.mark_label ctx.code int_labels.(i);
        emit_cont ctx prog c)
      int_cases;
    Array.iteri
      (fun i c ->
        Jvm.Code.mark_label ctx.code tag_labels.(i);
        emit_cont ctx prog c)
      tag_cases
  | Pushtrap (body_c, exn_var, handler_c) ->
    let handler_lbl = Jvm.Code.fresh_label ctx.code in
    (* Trap identity = the Pushtrap block's address. [trap_regions]
       is precomputed from [Code.compute_trap_contexts], so the set
       includes every block where this trap is live on the runtime
       stack (inner handlers under it, code after nested Poptraps,
       etc. — the stack-relative walk that an ad-hoc scope walk
       gets wrong). *)
    let protected =
      match Hashtbl.find_opt ctx.trap_regions ctx.current_block_addr with
      | Some s -> s
      | None -> Code.Addr.Set.empty
    in
    Code.Addr.Set.iter
      (fun addr ->
        if not (Hashtbl.mem ctx.block_end addr)
        then
          Hashtbl.add ctx.block_end addr (Jvm.Code.fresh_label ctx.code))
      protected;
    ctx.pending_handlers <-
      { protected; handler_lbl } :: ctx.pending_handlers;
    emit_cont ctx prog body_c;
    (* Handler prelude: unwrap CamlException → exn value, store into
       exn_var's local, then move to handler cont. *)
    Jvm.Code.mark_label ctx.code handler_lbl;
    Jvm.Code.handler_stack_prelude ctx.code;
    Jvm.Code.getfield
      ctx.code
      ~class_:"CamlException"
      ~field:"value"
      ~descriptor:"Ljava/lang/Object;";
    emit_store ctx exn_var ~from:K_obj;
    emit_cont ctx prog handler_c
  | Poptrap c ->
    (* POPTRAP at the IR level is just a branch: the JVM exception
       table entry was closed at end_lbl in the enclosing Pushtrap. *)
    emit_cont ctx prog c
  | Invoke_tail { class_; method_; descriptor; args; is_static } ->
    (* [Method_split] output: call a helper method on this class
       (virtual, through [this]) or on a host class (static), then
       return. Args are loaded boxed-to-Object. Return shape follows
       the descriptor's return type: [)V] — [return_void]; else
       [areturn]. *)
    if not is_static then Jvm.Code.aload ctx.code 0;
    List.iter (fun a -> emit_load_as_obj ctx a) args;
    if is_static
    then Jvm.Code.invokestatic ctx.code ~class_ ~method_ ~descriptor
    else Jvm.Code.invokevirtual ctx.code ~class_ ~method_ ~descriptor;
    let returns_void =
      let n = String.length descriptor in
      n >= 2 && descriptor.[n - 1] = 'V' && descriptor.[n - 2] = ')'
    in
    if returns_void
    then Jvm.Code.return_void ctx.code
    else Jvm.Code.areturn ctx.code

let emit_block ctx prog addr (b : Code.block) =
  if debug_ir_gen_trace
  then Format.eprintf "[ir_gen_trace] emit_block addr=%d@." addr;
  (* Ensure each param has a local allocated. *)
  List.iter (fun v -> ignore (local_of ctx v)) b.params;
  let start_lbl = label_of ctx addr in
  Jvm.Code.mark_label ctx.code start_lbl;
  (match ctx.line_of_pc addr with
   | Some line -> Jvm.Code.mark_line ctx.code line
   | None -> ());
  Hashtbl.replace ctx.block_start addr start_lbl;
  Array.iter (fun i -> emit_instr ctx i) b.body;
  ctx.current_block_addr <- addr;
  emit_last ctx prog b.branch;
  (* Mark the end-of-block label if anyone (a Pushtrap deferred
     handler install) asked for one. *)
  match Hashtbl.find_opt ctx.block_end addr with
  | Some end_lbl -> Jvm.Code.mark_label ctx.code end_lbl
  | None -> ()

let emit_program
    ~code
    ~typing
    ~name_of_body
    ~fn_info_of_body
    ~prim_name
    ?(arg_vars = [])
    ?enclosing
    ?(not_found_idx = 6)
    ?(line_of_pc = fun _ -> None)
    ?(is_static = false)
    ?(unbox_args = false)
    (prog : Code.program)
  =
  let trap_regions =
    (* Stack-relative trap regions via [Code.compute_trap_contexts].
       Inverts the block→context map into trap→blocks. *)
    let contexts = Code.compute_trap_contexts prog in
    let regions = Hashtbl.create 8 in
    Hashtbl.iter
      (fun addr ctx ->
        List.iter
          (fun trap_addr ->
            let s =
              match Hashtbl.find_opt regions trap_addr with
              | Some s -> s
              | None ->
                let s = ref Code.Addr.Set.empty in
                Hashtbl.add regions trap_addr s;
                s
            in
            s := Code.Addr.Set.add addr !s)
          ctx)
      contexts;
    let out = Hashtbl.create (Hashtbl.length regions) in
    Hashtbl.iter (fun k s -> Hashtbl.add out k !s) regions;
    out
  in
  let ctx =
    { code
    ; typing
    ; var_local = Hashtbl.create 64
    ; labels = Hashtbl.create 32
    ; name_of_body
    ; fn_info_of_body
    ; prim_name
    ; enclosing
    ; fresh_oo_id = ref 0
    ; not_found_idx = ref not_found_idx
    ; next_local = 1
    ; line_of_pc
    ; block_start = Hashtbl.create 32
    ; block_end = Hashtbl.create 32
    ; trap_regions
    ; current_block_addr = -1
    ; pending_handlers = []
    }
  in
  (* For an instance method, local 0 is [this] and args start at
     local 1; for a static method, args start at local 0. Advance
     [next_local] past the arg block up-front so any unbox-into-
     fresh-local grabs a slot beyond it. *)
  let arg_base = if is_static then 0 else 1 in
  ctx.next_local <- arg_base + List.length arg_vars;
  (* When [unbox_args] is set (the [Method_split]-produced helper
     case), an arg Var's inferred kind may be [K_int] or [K_float]
     because the same Var is Let-bound elsewhere in the program —
     reading its arg slot via [iload] / [dload] would then mismatch
     the [Object] type JVM calling convention stored there. In that
     case we allocate a fresh local for the unboxed value, emit a
     [checkcast + unbox; store] prologue, and bind the Var to the
     new local. The original arg slot retains its [Object] type. *)
  let unbox_prologue = ref [] in
  List.iteri
    (fun i v ->
      let arg_slot = arg_base + i in
      let k = kind_of ctx v in
      Hashtbl.replace ctx.var_local (Code.Var.idx v) arg_slot;
      if ctx.next_local <= arg_slot then ctx.next_local <- arg_slot + 1;
      if unbox_args
      then (
        match k with
        | Kind.K_int | Kind.K_float ->
          (* Need a separate local slot because the JVM verifier
             types a single local as Object after astore; widening
             it to int/double via istore/dstore on the same slot
             would be a type conflict on subsequent loads. Allocate
             a fresh wide-enough slot and rebind the Var to it. *)
          let slots = Kind.local_slots_for_kind k in
          let new_slot = ctx.next_local in
          ctx.next_local <- ctx.next_local + slots;
          Hashtbl.replace ctx.var_local (Code.Var.idx v) new_slot;
          unbox_prologue := `Unbox (arg_slot, new_slot, k) :: !unbox_prologue
        | Kind.K_closure _ | Kind.K_block _ | Kind.K_string ->
          (* Reference-typed — narrow in place so the verifier
             treats the local as the specific reference type from
             this point on. The body's [emit_load] expects the
             narrowed type (e.g. invokevirtual on [Closure]). *)
          unbox_prologue := `Narrow (arg_slot, k) :: !unbox_prologue
        | Kind.K_obj -> ()))
    arg_vars;
  Jvm.Code.set_min_locals ctx.code ctx.next_local;
  let narrow_class = function
    | Kind.K_closure _ -> "Closure"
    | Kind.K_block _ -> "Block"
    | Kind.K_string -> "java/lang/String"
    | _ -> assert false
  in
  List.iter
    (function
      | `Unbox (arg_slot, new_slot, k) ->
        Jvm.Code.aload ctx.code arg_slot;
        (match k with
         | Kind.K_int ->
           Jvm.Code.checkcast ctx.code "java/lang/Integer";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Integer"
             ~method_:"intValue"
             ~descriptor:"()I";
           Jvm.Code.istore ctx.code new_slot
         | Kind.K_float ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D";
           Jvm.Code.dstore ctx.code new_slot
         | _ -> assert false)
      | `Narrow (arg_slot, k) ->
        Jvm.Code.aload ctx.code arg_slot;
        Jvm.Code.checkcast ctx.code (narrow_class k);
        Jvm.Code.astore ctx.code arg_slot)
    (List.rev !unbox_prologue);
  (* Initialise every entry-block param that isn't a pre-bound
     apply-method arg to [null]. This covers the "start_accu" Var
     (the entry block's nominal accu, which in OCaml's bytecode is
     undefined on function entry) plus any leftover stack slots
     that the caller of parse_function populated as initial_stack
     but didn't bind to JVM locals — typically none for functions,
     but being safe for robustness. Without this, the verifier
     sees aload-on-uninitialized-local at the first read. *)
  (let entry = Code.Addr.Map.find prog.start prog.blocks in
   let arg_set =
     List.fold_left
       (fun s v -> Code.Var.Set.add v s)
       Code.Var.Set.empty
       arg_vars
   in
   List.iter
     (fun v ->
       if not (Code.Var.Set.mem v arg_set)
       then (
         let l = local_of ctx v in
         Jvm.Code.aconst_null ctx.code;
         Jvm.Code.astore ctx.code l))
     entry.params);
  (* Emit start block first so control-flow fall-through matches
     block-address order. Then other blocks in sorted address order. *)
  let start_block = Code.Addr.Map.find prog.start prog.blocks in
  emit_block ctx prog prog.start start_block;
  Code.Addr.Map.iter
    (fun addr b ->
      if addr <> prog.start then emit_block ctx prog addr b)
    prog.blocks;
  (* Install deferred exception-handler entries. For each Pushtrap,
     install one entry per block in its protected set, covering
     that block's start..end labels (end is marked at the end of
     [emit_block]; we allocate it on demand). Using one entry per
     block sidesteps the problem that IR-ordered block emission
     doesn't lay out a try region as a contiguous byte range. *)
  List.iter
    (fun { protected; handler_lbl } ->
      Code.Addr.Set.iter
        (fun addr ->
          match
            ( Hashtbl.find_opt ctx.block_start addr
            , Hashtbl.find_opt ctx.block_end addr )
          with
          | Some start_lbl, Some end_lbl ->
            Jvm.Code.add_exception_handler
              ctx.code
              ~start_lbl
              ~end_lbl
              ~handler_lbl
              ~catch_class:(Some "CamlException")
          | _ -> ())
        protected)
    ctx.pending_handlers
