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

val compare_class_bytes : unit -> string
(** Static methods for polymorphic structural comparison on the
    runtime-value shapes our compiler emits — used by
    [caml_compare] / [caml_equal] / [caml_lessthan] / etc. *)

val channel_class_bytes : unit -> string
(** See above. *)

val bytes_class_bytes : unit -> string
(** Output channel wrapper. Holds a [java.io.PrintStream] and
    exposes [output] / [outputChar] / [flush] for
    [caml_ml_output] / [caml_ml_output_char] / [caml_ml_flush].
    Static [stdout] / [stderr] fields plus a [forDescriptor]
    helper so [caml_ml_open_descriptor_out] can return the right
    one. *)
