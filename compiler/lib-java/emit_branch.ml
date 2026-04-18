open Kind
open Instr
open State

let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  ensure_kind state K_int;
  Jvm.Code.ldc_int state.code imm;
  (match ins.opcode with
   | 131 -> Jvm.Code.if_icmpeq state.code lbl
   | 132 -> Jvm.Code.if_icmpne state.code lbl
   | 133 -> Jvm.Code.if_icmpgt state.code lbl
   | 134 -> Jvm.Code.if_icmpge state.code lbl
   | 135 -> Jvm.Code.if_icmplt state.code lbl
   | 136 -> Jvm.Code.if_icmple state.code lbl
   | other ->
     failwith
       (Printf.sprintf "java_of_ocaml: unexpected cmp_jump opcode %d" other));
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int

let cmp_of_opcode op =
  if op = Bytecode.Op.eq then Eq
  else if op = Bytecode.Op.neq then Ne
  else if op = Bytecode.Op.ltint then Lt
  else if op = Bytecode.Op.leint then Le
  else if op = Bytecode.Op.gtint then Gt
  else if op = Bytecode.Op.geint then Ge
  else
    failwith
      (Printf.sprintf "java_of_ocaml: cmp_of_opcode on non-comparison %d" op)

let emit_branch_on_val_int_zero state ~target_pc ~branch_if_zero =
  let v_local = allocate_local state in
  let l_not_int = Jvm.Code.fresh_label state.code in
  let l_end = Jvm.Code.fresh_label state.code in
  let target_lbl = label_at state target_pc in
  Jvm.Code.astore state.code v_local;
  Jvm.Code.aload state.code v_local;
  Jvm.Code.instanceof_ state.code "java/lang/Integer";
  Jvm.Code.ifeq state.code l_not_int;
  Jvm.Code.aload state.code v_local;
  Jvm.Code.checkcast state.code "java/lang/Integer";
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/lang/Integer"
    ~method_:"intValue"
    ~descriptor:"()I";
  (if branch_if_zero
   then Jvm.Code.ifeq state.code target_lbl
   else Jvm.Code.ifne state.code target_lbl);
  Jvm.Code.goto state.code l_end;
  Jvm.Code.mark_label state.code l_not_int;
  if not branch_if_zero then Jvm.Code.goto state.code target_lbl;
  Jvm.Code.mark_label state.code l_end

(* Stash the scrutinee into a JVM local, then for each case iload + ldc +
   if_icmpeq. This keeps the JVM stack balanced across the dispatch and
   never leaves a dangling [pop] after a [goto] — the [Jvm.Code]
   max-stack tracker only observes straight-line code, so any such
   dangling pop silently under-declares [max_stack] downstream. *)
let emit_int_case_chain state ~cases ~to_target_pc =
  let v_local = allocate_local state in
  Jvm.Code.istore state.code v_local;
  List.iter
    (fun case_index ->
      let target_pc = to_target_pc case_index in
      Jvm.Code.iload state.code v_local;
      Jvm.Code.ldc_int state.code case_index;
      Jvm.Code.if_icmpeq state.code (label_at state target_pc);
      record_branch_target state target_pc)
    cases

let emit_switch state (ins : instr) =
  let sizes = ins.args.(0) in
  let num_ints = sizes land 0xffff in
  let num_tags = (sizes lsr 16) land 0xffff in
  let int_target i = ins.pc + 2 + ins.args.(1 + i) in
  let tag_target j = ins.pc + 2 + ins.args.(1 + num_ints + j) in
  let int_cases = List.init num_ints (fun i -> i) in
  let tag_cases = List.init num_tags (fun j -> j) in
  (match state.acc_kind with
   | K_int ->
     emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target
   | K_obj ->
     if num_tags = 0
     then (
       Jvm.Code.checkcast state.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         state.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target)
     else if num_ints = 0
     then (
       Jvm.Code.checkcast state.code "Block";
       Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target)
     else (
       let v_local = allocate_local state in
       let l_is_block = Jvm.Code.fresh_label state.code in
       let l_end = Jvm.Code.fresh_label state.code in
       Jvm.Code.astore state.code v_local;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.instanceof_ state.code "Block";
       Jvm.Code.ifne state.code l_is_block;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.checkcast state.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         state.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target;
       Jvm.Code.goto state.code l_end;
       Jvm.Code.mark_label state.code l_is_block;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.checkcast state.code "Block";
       Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target;
       Jvm.Code.mark_label state.code l_end)
   | K_block _ ->
     Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
     emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: SWITCH on unsupported kind %s"
          (jvm_type_of_kind other)));
  state.acc_live <- false;
  state.acc_kind <- K_int

(* Materialise a [pending_cmp] into a concrete 0/1 value in acc. The
   set of comparison bytecodes (EQ/NEQ/LT/LE/GT/GE) normally runs
   fused with a following BRANCHIF(NOT); when the OCaml compiler
   emits a bare comparison followed by any other opcode (e.g. RETURN
   at the tail of an expression whose value is a boolean), we have
   to emit the equivalent "if-then-else 1 else 0" here. *)
let emit_materialize_cmp state ~cmp =
  let slot = top_slot_local ~state in
  let slot_kind = kind_of_slot_from_top ~state 0 in
  ensure_kind state K_int;
  emit_load_for_kind state.code slot slot_kind;
  (match slot_kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: comparison against non-int slot kind %s"
          (jvm_type_of_kind slot_kind)));
  let lbl_true = Jvm.Code.fresh_label state.code in
  let lbl_end = Jvm.Code.fresh_label state.code in
  (match cmp with
   | Eq -> Jvm.Code.if_icmpeq state.code lbl_true
   | Ne -> Jvm.Code.if_icmpne state.code lbl_true
   | Lt -> Jvm.Code.if_icmplt state.code lbl_true
   | Le -> Jvm.Code.if_icmple state.code lbl_true
   | Gt -> Jvm.Code.if_icmpgt state.code lbl_true
   | Ge -> Jvm.Code.if_icmpge state.code lbl_true);
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.goto state.code lbl_end;
  Jvm.Code.mark_label state.code lbl_true;
  Jvm.Code.ldc_int state.code 1;
  Jvm.Code.mark_label state.code lbl_end;
  consume_top state;
  state.acc_live <- true;
  state.acc_kind <- K_int

let flush_pending_cmp state =
  match state.pending_cmp with
  | None -> ()
  | Some cmp ->
    state.pending_cmp <- None;
    emit_materialize_cmp state ~cmp

let emit_fused_branch state ~cmp ~target_pc ~branch_if_true =
  let slot_kind = kind_of_slot_from_top ~state 0 in
  let slot = top_slot_local ~state in
  let is_ref_kind = function
    | K_int | K_obj -> false
    | K_string | K_block _ | K_closure _ -> true
  in
  let lbl = label_at state target_pc in
  let branch_cond =
    if branch_if_true
    then cmp
    else
      match cmp with
      | Eq -> Ne
      | Ne -> Eq
      | Lt -> Ge
      | Le -> Gt
      | Gt -> Le
      | Ge -> Lt
  in
  if is_ref_kind state.acc_kind || is_ref_kind slot_kind
  then (
    emit_load_for_kind state.code slot slot_kind;
    (match branch_cond with
     | Eq -> Jvm.Code.if_acmpeq state.code lbl
     | Ne -> Jvm.Code.if_acmpne state.code lbl
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: ordering comparison on reference kinds \
             (%s vs %s) at pc %d"
            (jvm_type_of_kind state.acc_kind)
            (jvm_type_of_kind slot_kind)
            target_pc)))
  else (
    ensure_kind state K_int;
    emit_load_for_kind state.code slot slot_kind;
    (match slot_kind with
     | K_int -> ()
     | K_obj -> emit_unbox_to_kind state.code K_int
     | other ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: fused branch on non-int slot kind %s"
            (jvm_type_of_kind other)));
    match branch_cond with
    | Eq -> Jvm.Code.if_icmpeq state.code lbl
    | Ne -> Jvm.Code.if_icmpne state.code lbl
    | Lt -> Jvm.Code.if_icmplt state.code lbl
    | Le -> Jvm.Code.if_icmple state.code lbl
    | Gt -> Jvm.Code.if_icmpgt state.code lbl
    | Ge -> Jvm.Code.if_icmpge state.code lbl);
  consume_top state;
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int
