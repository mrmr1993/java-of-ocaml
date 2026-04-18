(** Elapsed-time measurement for compiler passes.

    Modeled on [js_of_ocaml/compiler/lib/timer.ml]. *)

type t

val make : ?get_time:(unit -> float) -> unit -> t
(** [make ()] starts a timer at the current time. *)

val get : t -> float
(** Elapsed seconds since [make]. *)

val print : Format.formatter -> t -> unit
(** Print as [%.2f] seconds. *)
