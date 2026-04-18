(** Decoded bytecode instructions: flat list + classification helpers.

    Each decoded instruction carries its position in the bytecode stream
    ([pc]), its opcode, and its arguments. The rest of this module is
    opcode-level predicates (is_c_call, is_acc, ...) and a pair of helpers
    for branch-target arithmetic used by the function-range finder and the
    emitter. *)

type instr =
  { pc : int
  ; opcode : int
  ; args : int array
  }

val decode_all : Bytecode.t -> instr list
(** Decode the whole CODE section into a flat list, one [instr] per
    opcode. *)

(** {1 Opcode classification} *)

val is_cmp_jump : int -> bool
(** BEQ / BNEQ / BLTINT / BLEINT / BGTINT / BGEINT — the fused
    compare-and-branch family. *)

val is_cmp_nullary : int -> bool
(** EQ / NEQ / LTINT / LEINT / GTINT / GEINT — the nullary comparisons. *)

val is_c_call : int -> bool
(** C_CALL1 .. C_CALL6. *)

val is_acc : int -> bool
(** ACC0 .. ACC7 + ACC. *)

val is_pushacc : int -> bool
(** PUSHACC0 .. PUSHACC7 + PUSHACC. *)

val is_user_op : instr -> bool
(** True iff we recognise the opcode as one we can compile.

    Used by the user-range walker to know when it has overshot Stdlib /
    module-init boilerplate and reached a body of user bytecode. *)

(** {1 Bytecode.Op aliases}

    Frequent targets, aliased here for brevity in callers. *)

val closurerec_op : int
val closure_op : int
val offsetclosure0_op : int
val pushoffsetclosure0_op : int
val offsetclosurem3_op : int
val offsetclosure3_op : int
val offsetclosure_op : int
val pushoffsetclosurem3_op : int
val pushoffsetclosure3_op : int
val pushoffsetclosure_op : int
val apply1_op : int
val apply2_op : int
val apply3_op : int
val apply_op : int
val appterm_op : int
val appterm1_op : int
val appterm2_op : int
val appterm3_op : int
val return_op : int
val restart_op : int
val grab_op : int
val event_op : int
val break_op : int

(** {1 Branch arithmetic} *)

val branch_target : instr -> int option
(** [Some target_pc] for single-target branches (BRANCH, BRANCHIF,
    BRANCHIFNOT, PUSHTRAP, the compare-and-branch family); [None]
    otherwise. *)

val is_terminator : int -> bool
(** True for opcodes that don't fall through to the following PC:
    BRANCH, RETURN, RAISE / RERAISE / RAISE_NOTRACE, STOP, APPTERM*.
    Used to distinguish fall-through vs jump entries at a label. *)

val branch_targets : instr -> int list
(** Every bytecode PC that [ins] might transfer control to. SWITCH
    expands to all of its cases; other branches wrap [branch_target]. *)
