(** Stack-access emitters: pushes, accu-slot reads, constants.

    These are the primitives every other emit_* module uses to move
    values between acc, the OCaml-stack slot list, and the JVM operand
    stack. *)

val emit_int_const : State.state -> int -> unit

val emit_string_const : State.state -> string -> unit

val emit_materialise_value : State.state -> Global_view.global_field_value -> unit
(** Push the given global-field value onto the JVM op stack, building a
    [Block] for nested-block values. Does NOT update [acc_live] /
    [acc_kind]; callers set those. *)

val emit_materialise_block_constant
  :  State.state
  -> int
  -> Global_view.global_field_value list
  -> unit
(** Statically-known [Block(tag, fields)] — used by GETGLOBAL /
    PUSHGETGLOBAL when the global is already a block. *)

val emit_push : State.state -> unit
(** [PUSH] — dup acc, stash into a fresh local, track as a new slot.
    No-op if acc is dead. *)

val emit_acc : State.state -> int -> unit
(** [ACCk] — load slot [k] from top (0-indexed) into acc. *)

val emit_pushacc : State.state -> int -> unit

val emit_int_push : State.state -> int -> unit
(** PUSHCONSTINT / PUSHCONST0..3 — shortcut that pushes a small integer
    and sets acc. *)

val emit_string_push : State.state -> string -> unit
