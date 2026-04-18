(** Per-[Var.t] kind inference over the [Code] IR.

    Forward dataflow pass: walks the program's blocks, pinning each
    Var's kind from its defining expression and joining across
    [Assign]s. Block params default to [K_obj] (the universal carrier);
    downstream uses unbox via the emitter's [ensure_kind] at point of
    use.

    Adapted from [js_of_ocaml/compiler/lib-wasm/typing.ml] in shape —
    our lattice is [Kind.kind] from [Kind], not jsoo's WASM typing
    types. *)

open Code

type t

(** [infer program] returns a [t] that maps every Var defined in
    [program] to an inferred [Kind.kind]. Defaults to [K_obj] for any
    Var not otherwise pinned. *)
val infer : program -> t

val kind : t -> Var.t -> Kind.kind
