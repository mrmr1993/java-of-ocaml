(** Emitters for the integer-arithmetic bytecode ops.

    Each op pops the top of the OCaml stack + uses acc, emits the JVM
    [iadd] / [isub] / ... / [irem] and updates the slot tracker. acc
    stays live as a [K_int]. *)

val emit_addint : State.state -> unit
val emit_subint : State.state -> unit
val emit_mulint : State.state -> unit
val emit_divint : State.state -> unit
val emit_modint : State.state -> unit

val emit_offsetint : State.state -> int -> unit
(** [acc <- acc + n], used by both [OFFSETINT] and the increment side
    of [OFFSETREF]. Does not consume a stack slot. *)
