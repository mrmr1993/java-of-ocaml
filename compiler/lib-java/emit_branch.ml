open Kind
open Instr
open State

(* Re-export so [emit_instr] can reach the helper via [Emit_branch]. *)
let normalize_acc_for_branch = State.normalize_acc_for_branch

let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  (* [BEQ] / [BNEQ] / [B{LT,LE,GT,GE}INT] preserve acc per OCaml's
     bytecode semantics. Box acc to [Object] first so every edge
     (taken and fall-through) leaves the same JVM type on the
     operand stack. Then [dup] the Object, [checkcast Integer],
     unbox to int, compare with [imm], branch. The dup keeps the
     Object on the stack across the consumption by [if_icmp]. *)
  normalize_acc_for_branch state;
  emit_edge_spill state target_pc;
  Jvm.Code.dup state.code;
  Jvm.Code.checkcast state.code "java/lang/Integer";
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/lang/Integer"
    ~method_:"intValue"
    ~descriptor:"()I";
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
  record_branch_target state target_pc
  (* acc stays live as [K_obj] on both paths. *)

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

(* BRANCHIF(NOT) on an opaque [K_obj] acc: the value is either a
   boxed [Integer] (for immediate OCaml values) or a reference
   (Block / Closure / String — never [Val_false], which is always an
   Integer(0)). Dispatch on runtime type and branch accordingly.

   Preserves acc on every outgoing edge (both taken and fall-through),
   so a caller label's snapshot and our fall-through walker state
   both leave acc live on the JVM stack. *)
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
  (* Take the branch based on the unboxed int; if taken, restore
     acc onto the stack at a caller. The JVM verifier merges
     stack states across incoming edges to a caller, so every
     [goto target_lbl] below pushes acc first via [aload v_local]. *)
  (if branch_if_zero
   then Jvm.Code.ifne state.code l_end (* ifne: stay when non-zero *)
   else Jvm.Code.ifeq state.code l_end);
  (* Taken path: push acc, spill to target's params if join, then branch. *)
  Jvm.Code.aload state.code v_local;
  emit_edge_spill state target_pc;
  Jvm.Code.goto state.code target_lbl;
  Jvm.Code.mark_label state.code l_not_int;
  (* Non-Integer acc: always takes on BRANCHIF (value is truthy),
     never on BRANCHIFNOT (value is non-zero). *)
  if not branch_if_zero
  then (
    Jvm.Code.aload state.code v_local;
    emit_edge_spill state target_pc;
    Jvm.Code.goto state.code target_lbl);
  Jvm.Code.mark_label state.code l_end;
  (* Fall-through: restore acc on the stack too. *)
  Jvm.Code.aload state.code v_local

(* Dispatch on an int scrutinee, preserving acc on the JVM operand
   stack throughout so every outgoing edge has the same shape as
   acc-preserving branches like BEQ / BULTINT — which the OCaml
   interpreter semantics agree on (SWITCH does NOT consume accu;
   [ocaml/runtime/interp.c] just reads it for the jump-table
   index). The chain:

     - Call site has [acc] on stack as Object (post-normalise). We
       stash it in [v_local] as a reference and separately unbox
       an [int] copy into [v_int] for the comparisons.
     - For each case: [aload v_local; emit_edge_spill; iload v_int;
       ldc case; if_icmpeq target]. The acc goes on stack *for each
       iteration*, is spilled into a caller block's params, and
       sits there for the [if_icmpeq] to fall through without
       consuming it — the whole stack effect of the case block is
       [+1 Object ; if taken, target gets 1 Object; if not,
        next iteration pushes its own copy afresh].
     - Leaving the chain: [aload v_local] once more so fall-through
       state is "acc on stack, K_obj". *)
let emit_int_case_chain state ~cases ~to_target_pc =
  let v_local = allocate_local state in
  let v_int = allocate_local state in
  (* acc is on the operand stack as an int at this point (callers
     either unboxed from Integer or extracted [Block.tag]). Stash
     both a boxed and an unboxed copy. *)
  Jvm.Code.dup state.code;
  Jvm.Code.istore state.code v_int;
  emit_box_int state.code;
  Jvm.Code.astore state.code v_local;
  state.acc_live <- true;
  state.acc_kind <- K_obj;
  List.iter
    (fun case_index ->
      let target_pc = to_target_pc case_index in
      Jvm.Code.aload state.code v_local;
      emit_edge_spill state target_pc;
      Jvm.Code.iload state.code v_int;
      Jvm.Code.ldc_int state.code case_index;
      let taken_lbl = label_at state target_pc in
      let next_lbl = Jvm.Code.fresh_label state.code in
      Jvm.Code.if_icmpne state.code next_lbl;
      Jvm.Code.goto state.code taken_lbl;
      Jvm.Code.mark_label state.code next_lbl;
      (* We left a duplicate acc on stack for the (now-dropped)
         if_icmpeq taken edge; pop it so the next iteration
         starts with the same stack height as the last. *)
      Jvm.Code.pop_top state.code;
      record_branch_target state target_pc)
    cases;
  (* Fall-through after the chain: re-push acc so callers see
     [acc_live=true, acc on stack]. *)
  Jvm.Code.aload state.code v_local

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
  (* Per OCaml interp semantics SWITCH preserves accu, and the
     case-chain leaves acc on the operand stack as K_obj. *)
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* Materialise a [pending_cmp] into a concrete 0/1 value in acc. The
   set of comparison bytecodes (EQ/NEQ/LT/LE/GT/GE) normally runs
   fused with a following BRANCHIF(NOT); when the OCaml compiler
   emits a bare comparison followed by any other opcode (e.g. RETURN
   at the tail of an expression whose value is a boolean), we have
   to emit the equivalent "if-then-else 1 else 0" here. *)
(* A kind that can be compared as a primitive int via [if_icmp*]. *)
let is_int_like = function
  | K_int -> true
  | K_float | K_string | K_block _ | K_closure _ | K_obj -> false

(* A kind whose JVM representation is a reference (one slot of some
   `[L…]` type). *)
let is_definitely_ref = function
  | K_int | K_float -> false
  | K_string | K_block _ | K_closure _ | K_obj -> true

let emit_materialize_cmp state ~cmp =
  let slot = top_slot_local ~state in
  let slot_kind = kind_of_slot_from_top ~state 0 in
  let is_ordering_cmp =
    match cmp with
    | Eq | Ne -> false
    | Lt | Le | Gt | Ge -> true
  in
  (* For ordering comparisons (Lt/Le/Gt/Ge) OCaml expects both
     operands to be ints. Unbox as needed. For equality on mixed
     int / reference kinds, fall back to int compare so an int-on-
     both-sides runtime value compares equal. *)
  let use_acmp =
    (not is_ordering_cmp)
    && is_definitely_ref state.acc_kind
    && is_definitely_ref slot_kind
    && not (is_int_like state.acc_kind)
    && not (is_int_like slot_kind)
  in
  if use_acmp
  then (
    emit_load_for_kind state.code slot slot_kind;
    (* No unbox needed — both operands stay as references. *)
    ())
  else (
    ensure_kind state K_int;
    emit_load_for_kind state.code slot slot_kind;
    match slot_kind with
    | K_int -> ()
    | K_obj -> emit_unbox_to_kind state.code K_int
    | K_float | K_string | K_block _ | K_closure _ ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: integer comparison against non-int slot kind \
            %s (acc=%s, cmp=%s)"
           (jvm_type_of_kind slot_kind)
           (jvm_type_of_kind state.acc_kind)
           (match cmp with
            | Eq -> "eq"
            | Ne -> "ne"
            | Lt -> "lt"
            | Le -> "le"
            | Gt -> "gt"
            | Ge -> "ge")));
  let lbl_true = Jvm.Code.fresh_label state.code in
  let lbl_end = Jvm.Code.fresh_label state.code in
  (if use_acmp
   then (
     match cmp with
     | Eq -> Jvm.Code.if_acmpeq state.code lbl_true
     | Ne -> Jvm.Code.if_acmpne state.code lbl_true
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: ordering comparison on reference kinds \
             (%s vs %s) is not meaningful"
            (jvm_type_of_kind state.acc_kind)
            (jvm_type_of_kind slot_kind)))
   else
     match cmp with
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

(* [emit_fused_branch] has been retired — cmp+branch fusion
   conflicted with acc-preservation discipline. All BRANCHIF /
   BRANCHIFNOT now flow through [flush_pending_cmp] then the
   regular branch arm in [emit_instr]. *)
