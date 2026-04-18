(** Byte generators for the four runtime support classes. *)

val block_class_bytes : unit -> string
(** Heap blocks. Two public final instance fields ([int tag],
    [Object[] fields]) + a two-argument constructor. *)

val closure_class_bytes : unit -> string
(** Base class for OCaml function closures. Defines [apply1..apply7] that
    dispatch via [arity()] to either the subclass's concrete applyN or to a
    shared [under] fallback that builds a [PartialClosure]. *)

val partial_closure_class_bytes : unit -> string
(** Captures a target closure plus some args. [applyN] combines, and either
    builds a deeper partial or dispatches once saturated. *)

val camlexception_class_bytes : unit -> string
(** [RuntimeException] carrier for the OCaml exception value. Used by
    [raise] / [try ... with] to cross JVM call boundaries. *)
