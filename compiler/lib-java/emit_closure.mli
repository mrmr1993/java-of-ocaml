(** Emitters for closure-related bytecode ops: CLOSURE, CLOSUREREC,
    OFFSETCLOSURE{0,3,m3,N}, ENVACC / PUSHENVACC. *)

val ctor_descriptor_for_captures : Kind.kind list -> string
(** Build a JVM constructor descriptor for a closure class given the
    kinds of its captures in field order. Exposed for the driver's
    per-function class emission. *)

val emit_offsetclosure0 : State.state -> unit
(** Load [this] as acc. *)

val emit_pushoffsetclosure0 : State.state -> unit

val emit_offsetclosure : State.state -> int -> unit
(** Navigate to a sibling closure within a CLOSUREREC group. Offset is
    counted in OCaml closure words (3 words per sibling). *)

val emit_pushoffsetclosure : State.state -> int -> unit

val emit_envacc : State.state -> int -> unit
(** ENVACC k — read the (k-2)-th capture field of [this]. *)

val emit_pushenvacc : State.state -> int -> unit

val emit_closure : State.state -> Instr.instr -> unit
(** CLOSURE: allocate one function class instance with captures. *)

val emit_closurerec : State.state -> Instr.instr -> unit
(** CLOSUREREC: allocate N function class instances with shared
    captures, then cross-wire their sibling_i fields. *)
