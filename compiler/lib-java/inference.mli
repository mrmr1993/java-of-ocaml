(** Pre-passes that populate [function_info] fields before code emission.

    These walk the decoded bytecode once each and are pure with respect to
    the bytecode array — they read instructions but do not emit JVM code. *)

open Kind
open Instr
open Function_info

val supported_call_indices
  :  instr array
  -> prim_table:Prim.table
  -> (int * int) option
(** Locate the first and last user-range anchor in [arr]. The walker
    defines user code as "runs from the first to the last seed C_CALL".
    Returns [None] if no seed primitive is called at all. *)

val walk_back_user_start : instr array -> int -> int
(** Extend a user-range start leftwards past every [is_user_op]
    instruction. Used to pick up module-init boilerplate that is still
    legally compilable. *)

val walk_forward_user_end : instr array -> int -> int
(** Extend a user-range end rightwards past every [is_user_op]
    instruction. *)

val find_function_by_body_pc : function_info list -> int -> function_info option

val infer_return_kind : instr array -> function_info list -> function_info -> kind
(** Heuristic: the instruction immediately before each [RETURN] / [APPTERM*]
    pins the return kind. Observations across multiple returns must
    agree; disagreement falls back to [K_obj]. *)

val infer_arg_kinds : instr array -> Prim.table -> function_info -> kind list
(** Scan the body for patterns that constrain argument kinds. Currently
    only detects: [ACC k] directly followed by [C_CALL1 caml_java_print_endline]
    pins arg [k] to [K_string]. Everything else defaults to [K_int]. *)

val kinds_agree : kind -> kind -> bool
(** Conservative equality on outer kind-constructors only (ignores the
    inner shape of [K_block] / [K_closure]). Used by [infer_return_kind]
    to decide whether multiple observed return kinds match. *)
