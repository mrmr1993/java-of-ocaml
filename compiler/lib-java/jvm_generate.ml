(* IR-to-JVM emitter. Phase 2 scope: int arith / comparisons /
   constants / Assign / Branch / Cond / Return / Stop. Every other
   expr or terminator raises [Unsupported]. Callers in [compile.ml]
   can catch and fall back to the legacy per-opcode emitter during
   the transition. *)

exception Unsupported of string

type ctx =
  { code : Jvm.Code.t
  ; typing : Jvm_typing.t
  ; var_local : (int, int) Hashtbl.t
  ; labels : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
  ; name_of_body : int -> string
  ; prim_name : int -> string
  ; enclosing : (Function_info.function_info * Code.Var.t) option
  ; mutable next_local : int
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
   | _ ->
     (* K_obj / reference kinds — no conversion needed at JVM level. *)
     ());
  let l = local_of ctx v in
  Kind.emit_store_for_kind ctx.code l k

(* Emit an [Int] constant onto the stack as a JVM [int]. *)
let emit_int_const ctx n = Jvm.Code.ldc_int ctx.code n

let emit_constant ctx (c : Code.constant) : Kind.kind =
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
  | Block _ -> raise (Unsupported "Constant Block")

(* Load a prim_arg onto the stack and return its Kind. *)
let emit_prim_arg ctx (pa : Code.prim_arg) : Kind.kind =
  match pa with
  | Pv v ->
    emit_load ctx v;
    kind_of ctx v
  | Pc c -> emit_constant ctx c

(* Ensure top of stack is [K_int]. *)
let ensure_int ctx k =
  match k with
  | Kind.K_int -> ()
  | Kind.K_obj ->
    Jvm.Code.checkcast ctx.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | _ -> raise (Unsupported "ensure_int: unexpected kind")

(* Emit a C primitive call by name. Args have already been parsed
   into [prim_arg list]; they're all Pv or Pc. The handler dispatches
   on known primitive names and emits specialised bytecode.
   Unknown names raise [Unsupported]. *)
let emit_ccall ctx name args =
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
      Jvm.Code.checkcast ctx.code "java/lang/Integer";
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"java/lang/Integer"
        ~method_:"intValue"
        ~descriptor:"()I"
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
    (match args with
     | [ Pv b ] ->
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"length"
         ~descriptor:"()I";
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
       as_bytes b;
       as_int i;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"get"
         ~descriptor:"(I)I";
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
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"asString"
         ~descriptor:"()Ljava/lang/String;";
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
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_int bi;
       as_string s;
       as_int si;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitString"
         ~descriptor:"(ILjava/lang/String;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_string arity"))
  | "caml_blit_bytes" ->
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_int bi;
       as_bytes s;
       as_int si;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitBytes"
         ~descriptor:"(ILBytes;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_bytes arity"))
  | "caml_format_int" ->
    (match args with
     | [ Pv _fmt; Pv n ] ->
       (* Ignore format string; use Integer.toString for now. *)
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"toString"
         ~descriptor:"(I)Ljava/lang/String;";
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
  | "caml_ml_close_channel" ->
    (match args with
     | [ Pv _ch ] ->
       (* No-op; JVM GC handles cleanup. *)
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_close_channel arity"))
  | "caml_obj_tag" ->
    (* Arg 0: Block. Return: tag (int). *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"tag"
         ~descriptor:"I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_obj_tag arity"))
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
  | "caml_fresh_oo_id" ->
    (* OCaml runtime counter; increment and return. We use a static
       counter on Main for simplicity. *)
    raise (Unsupported "caml_fresh_oo_id (needs Main counter)")
  | _ -> raise (Unsupported ("C primitive " ^ name))

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
    (* Materialise as 0/1. Use ifeq/ifne over a compare: load a, load
       b, if_icmp<op> Ltrue; iconst_0; goto Lend; Ltrue: iconst_1;
       Lend. *)
    let l_true = Jvm.Code.fresh_label ctx.code in
    let l_end = Jvm.Code.fresh_label ctx.code in
    let ka = emit_prim_arg ctx a in
    ensure_int ctx ka;
    let kb = emit_prim_arg ctx b in
    ensure_int ctx kb;
    (match p with
     | Eq -> Jvm.Code.if_icmpeq ctx.code l_true
     | Neq -> Jvm.Code.if_icmpne ctx.code l_true
     | Lt | Ult -> Jvm.Code.if_icmplt ctx.code l_true
     | Le -> Jvm.Code.if_icmple ctx.code l_true
     | Gt -> Jvm.Code.if_icmpgt ctx.code l_true
     | Ge | Uge -> Jvm.Code.if_icmpge ctx.code l_true
     | _ -> assert false);
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.goto ctx.code l_end;
    Jvm.Code.mark_label ctx.code l_true;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.mark_label ctx.code l_end;
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
    (* Read a byte from a Bytes/String at an int index. *)
    let ka = emit_prim_arg ctx a in
    (match ka with
     | K_string -> ()
     | _ ->
       (* fall-back: checkcast Bytes and invoke get(int) *)
       Jvm.Code.checkcast ctx.code "Bytes");
    let kb = emit_prim_arg ctx b in
    ensure_int ctx kb;
    (match ka with
     | K_string ->
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"charAt"
         ~descriptor:"(I)C"
     | _ ->
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"get"
         ~descriptor:"(I)I");
    K_int
  | Extern "getmethod", [ Pv meth; Pv obj ] ->
    (* Methods are looked up via the class-dispatch table. For now
       defer to a runtime helper (to be added). *)
    let _ = meth in
    let _ = obj in
    raise (Unsupported "getmethod (needs runtime helper)")
  | Extern "getpubmet", [ Pv _a; Pc (Int _tag) ] ->
    raise (Unsupported "getpubmet (needs runtime helper)")
  | Extern "getdynmet", [ Pv _a; Pv _obj ] ->
    raise (Unsupported "getdynmet (needs runtime helper)")
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

let apply_descriptor_for_nargs = Emit_apply.apply_descriptor_for_nargs

let emit_expr ctx (e : Code.expr) : Kind.kind =
  match e with
  | Constant c -> emit_constant ctx c
  | Prim (p, args) -> emit_prim ctx p args
  | Apply { f; args; exact = _ } ->
    let nargs = List.length args in
    if nargs < 1 || nargs > 7
    then raise (Unsupported (Printf.sprintf "Apply arity %d" nargs));
    emit_load ctx f;
    (match kind_of ctx f with
     | K_closure _ -> ()
     | _ -> Jvm.Code.checkcast ctx.code "Closure");
    List.iter (fun a -> emit_load_as_obj ctx a) args;
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"Closure"
      ~method_:(Printf.sprintf "apply%d" nargs)
      ~descriptor:(apply_descriptor_for_nargs nargs);
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
    Jvm.Code.new_ ctx.code class_name;
    Jvm.Code.dup ctx.code;
    List.iter (fun v -> emit_load_as_obj ctx v) captures;
    let cap_desc =
      String.concat "" (List.map (fun _ -> "Ljava/lang/Object;") captures)
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
  | Assign (x, y) ->
    emit_load ctx y;
    emit_store ctx x ~from:(kind_of ctx y)
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
  Jvm.Code.goto ctx.code target_label

(* Find the param list of a target block. *)
let params_of_block (prog : Code.program) addr =
  match Code.Addr.Map.find_opt addr prog.blocks with
  | Some b -> b.params
  | None -> raise (Unsupported (Printf.sprintf "missing block %d" addr))

let emit_cont ctx prog (addr, args) =
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
    emit_load ctx v;
    (match kind_of ctx v with
     | K_int -> ()
     | _ ->
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I");
    let l_else = Jvm.Code.fresh_label ctx.code in
    Jvm.Code.ifeq ctx.code l_else;
    emit_cont ctx prog c_then;
    Jvm.Code.mark_label ctx.code l_else;
    emit_cont ctx prog c_else
  | Switch (v, cases) ->
    let n = Array.length cases in
    if n = 0 then raise (Unsupported "empty Switch");
    let kv = kind_of ctx v in
    let load_selector () =
      emit_load ctx v;
      match kv with
      | K_int -> ()
      | _ ->
        Jvm.Code.checkcast ctx.code "java/lang/Integer";
        Jvm.Code.invokevirtual
          ctx.code
          ~class_:"java/lang/Integer"
          ~method_:"intValue"
          ~descriptor:"()I"
    in
    let case_labels =
      Array.init n (fun _ -> Jvm.Code.fresh_label ctx.code)
    in
    for i = 0 to n - 2 do
      load_selector ();
      Jvm.Code.ldc_int ctx.code i;
      Jvm.Code.if_icmpeq ctx.code case_labels.(i)
    done;
    Jvm.Code.goto ctx.code case_labels.(n - 1);
    Array.iteri
      (fun i c ->
        Jvm.Code.mark_label ctx.code case_labels.(i);
        emit_cont ctx prog c)
      cases
  | Pushtrap (body_c, exn_var, handler_c) ->
    let start_lbl = Jvm.Code.fresh_label ctx.code in
    let end_lbl = Jvm.Code.fresh_label ctx.code in
    let handler_lbl = Jvm.Code.fresh_label ctx.code in
    Jvm.Code.add_exception_handler
      ctx.code
      ~start_lbl
      ~end_lbl
      ~handler_lbl
      ~catch_class:(Some "CamlException");
    Jvm.Code.mark_label ctx.code start_lbl;
    emit_cont ctx prog body_c;
    Jvm.Code.mark_label ctx.code end_lbl;
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

let emit_block ctx prog addr (b : Code.block) =
  (* Ensure each param has a local allocated. *)
  List.iter (fun v -> ignore (local_of ctx v)) b.params;
  Jvm.Code.mark_label ctx.code (label_of ctx addr);
  List.iter (fun i -> emit_instr ctx i) b.body;
  emit_last ctx prog b.branch

let emit_program
    ~code ~typing ~name_of_body ~prim_name ?(arg_vars = []) ?enclosing
    (prog : Code.program)
  =
  let ctx =
    { code
    ; typing
    ; var_local = Hashtbl.create 64
    ; labels = Hashtbl.create 32
    ; name_of_body
    ; prim_name
    ; enclosing
    ; next_local = 1
    }
  in
  (* Apply-method locals 1..N are the formal args by JVM calling
     convention. Pin each arg Var to its local before block emission
     so [emit_load arg_i] reads from the right slot. Args are all
     [K_obj] in the apply signature; we coerce to arg_vars' typed
     kinds on first use via the normal emit_load path. *)
  List.iteri
    (fun i v ->
      Hashtbl.replace ctx.var_local (Code.Var.idx v) (i + 1);
      if ctx.next_local <= i + 1 then ctx.next_local <- i + 2)
    arg_vars;
  Jvm.Code.set_min_locals ctx.code ctx.next_local;
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
    prog.blocks
