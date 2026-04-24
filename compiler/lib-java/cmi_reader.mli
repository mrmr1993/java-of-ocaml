(** Minimal [.cmi] reader for the Java-facade feature
    (see [docs/JAVA_FACADE.md]).

    Reads a compiled OCaml interface via [compiler-libs.Cmi_format]
    and classifies each [Sig_value] binding into a simplified
    {!facade_kind}. Other signature items (types, class types,
    module types, ...) are tracked only for their effect on the
    module-struct field layout: they contribute to the field index
    we compute for downstream value bindings.

    This is step 2 of the sequencing in [docs/JAVA_FACADE.md §8];
    the classifier deliberately covers only a small, tractable
    subset of OCaml types for the first landing. Unknown shapes
    return {!K_other} rather than erroring, so the emission pass
    can degrade gracefully (skip, warn, or fall back to an
    [Object]-typed signature). *)

(** Classification of a single value binding's type, expressed at
    the granularity the emission pass cares about.

    The classifier is conservative: only shapes it fully
    understands produce non-[K_other] results. In particular a
    function type must be first-order in every component for it
    to surface as [K_fun]. *)
type facade_kind =
  | K_int
  | K_long    (** [int64] — emits as JVM [long]. *)
  | K_string
  | K_float
  | K_bool
  | K_unit
  | K_fun of facade_kind list * facade_kind
        (** Fully-flattened first-order function. Arity is [List.length
            args]; labels are not preserved. *)
  | K_other   (** Abstract, polymorphic, tuple, record, variant,
                  higher-order, or anything else the first landing
                  doesn't handle. Surfaces as a JVM [Object] in
                  the emitted facade. *)

type binding =
  { name : string         (** Source-level binding name, as it
                              appears in the [.mli] / [.ml]. *)
  ; field_index : int     (** Offset into the module block that
                              backs this module at runtime. *)
  ; kind : facade_kind
  }

type t =
  { modname : string
  ; bindings : binding list   (** In source / signature order. *)
  }

val read : search_paths:string list -> modname:string -> t
(** [read ~search_paths ~modname] locates [<modname>.cmi] under the
    given paths (case-insensitive match on the module name, as
    [ocamlfind] does — [Foo.cmi] and [foo.cmi] are both accepted)
    and returns its extracted bindings. Raises [Failure] if the
    file is not found or is not a well-formed [.cmi]. *)
