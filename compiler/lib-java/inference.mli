(** Pre-passes that populate [function_info] fields before code emission.

    These walk the decoded bytecode once each and are pure with respect to
    the bytecode array — they read instructions but do not emit JVM code. *)

open Kind
open Instr
open Function_info

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
