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
      (* Code.Var.idx → JVM local index. *)
  ; labels : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
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

(* Load Var v onto the JVM operand stack. *)
let emit_load ctx v =
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
  | IsInt, [ a ] ->
    let ka = emit_prim_arg ctx a in
    (match ka with
     | K_int -> Jvm.Code.ldc_int ctx.code 1; K_int
     | _ ->
       Jvm.Code.instanceof_ ctx.code "java/lang/Integer";
       K_int)
  | _ -> raise (Unsupported "prim (unsupported)")

let emit_expr ctx (e : Code.expr) : Kind.kind =
  match e with
  | Constant c -> emit_constant ctx c
  | Prim (p, args) -> emit_prim ctx p args
  | Apply _ -> raise (Unsupported "Apply")
  | Block _ -> raise (Unsupported "Block")
  | Field _ -> raise (Unsupported "Field")
  | Closure _ -> raise (Unsupported "Closure")

let emit_instr ctx (i : Code.instr) =
  match i with
  | Let (x, e) ->
    let produced = emit_expr ctx e in
    emit_store ctx x ~from:produced
  | Assign (x, y) ->
    emit_load ctx y;
    emit_store ctx x ~from:(kind_of ctx y)
  | Set_field _ | Offset_ref _ | Array_set _ ->
    raise (Unsupported "Set_field/Offset_ref/Array_set")

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
  | Raise _ -> raise (Unsupported "Raise")
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
  | Switch _ -> raise (Unsupported "Switch")
  | Pushtrap _ -> raise (Unsupported "Pushtrap")
  | Poptrap _ -> raise (Unsupported "Poptrap")

let emit_block ctx prog addr (b : Code.block) =
  (* Ensure each param has a local allocated. *)
  List.iter (fun v -> ignore (local_of ctx v)) b.params;
  Jvm.Code.mark_label ctx.code (label_of ctx addr);
  List.iter (fun i -> emit_instr ctx i) b.body;
  emit_last ctx prog b.branch

let emit_program ~code ~typing (prog : Code.program) =
  let ctx =
    { code
    ; typing
    ; var_local = Hashtbl.create 64
    ; labels = Hashtbl.create 32
    ; next_local = 1
    }
  in
  (* Emit start block first so control-flow fall-through matches
     block-address order. Then other blocks in sorted address order. *)
  let start_block = Code.Addr.Map.find prog.start prog.blocks in
  emit_block ctx prog prog.start start_block;
  Code.Addr.Map.iter
    (fun addr b ->
      if addr <> prog.start then emit_block ctx prog addr b)
    prog.blocks
