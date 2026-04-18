(** Emitters for the branching family: compare-and-jump, BRANCH(IF/NOT)
    on tagged int/block values, SWITCH, and the fused
    compare-and-branch built on top of a pending [cmp_op]. *)

val cmp_of_opcode : int -> State.cmp_op
(** Map a nullary comparison opcode (EQ / NEQ / LTINT / LEINT / GTINT /
    GEINT) to its [cmp_op]. Raises on anything else. *)

val emit_cmp_jump : State.state -> Instr.instr -> unit
(** BEQ / BNEQ / BLTINT / BLEINT / BGTINT / BGEINT — the fused
    compare-with-immediate-and-branch family. *)

val emit_branch_on_val_int_zero
  :  State.state
  -> target_pc:int
  -> branch_if_zero:bool
  -> unit
(** BRANCHIF / BRANCHIFNOT on a K_obj acc (a variant value that may be
    either a boxed Integer for immediate constructors or a Block for
    data constructors). Assumes acc is already on the JVM operand
    stack. *)

val emit_switch : State.state -> Instr.instr -> unit

val emit_fused_branch
  :  State.state
  -> cmp:State.cmp_op
  -> target_pc:int
  -> branch_if_true:bool
  -> unit
(** Called when [state.pending_cmp] was set by a nullary comparison
    followed immediately by BRANCHIF / BRANCHIFNOT. Emits a single
    fused [if_icmp<cond>] / [if_acmp<cond>] depending on slot kinds. *)
