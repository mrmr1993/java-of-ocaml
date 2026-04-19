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

val format_class_bytes : unit -> string
(** [caml_format_int] / [caml_format_float] target. *)

val bytes_class_bytes : unit -> string
(** Output channel wrapper. Holds a [java.io.PrintStream] and
    exposes [output] / [outputChar] / [flush] for
    [caml_ml_output] / [caml_ml_output_char] / [caml_ml_flush].
    Static [stdout] / [stderr] fields plus a [forDescriptor]
    helper so [caml_ml_open_descriptor_out] can return the right
    one. *)

val ephemeron_class_bytes : unit -> string
(** OCaml ephemerons / weak refs. Keys are held as
    [java.lang.ref.WeakReference]s; data slot is cleared when any
    key's referent has been collected. *)

val java_ffi_class_bytes : unit -> string
(** Reflective dispatcher backing [Java.Unsafe]. Static helpers for
    invoking methods / reading fields / allocating objects when the
    target is a runtime-computed name rather than known at compile
    time. Users of the PPX / typed-external path don't need this
    class; it's linked in unconditionally for simplicity. *)

val mutex_class_bytes : unit -> string
(** OCaml [Mutex.t] backed by a [java.util.concurrent.locks.ReentrantLock]. *)

val cond_var_class_bytes : unit -> string
(** OCaml [Condition.t] backed by [java.util.concurrent.locks.Condition]
    (lazily bound to the mutex on first wait). *)

val big_array_class_bytes : unit -> string
(** Minimal OCaml [Bigarray.Genarray.t] backing — boxed uniform
    storage in an [Object[]] with kind + layout + dims recorded. *)
