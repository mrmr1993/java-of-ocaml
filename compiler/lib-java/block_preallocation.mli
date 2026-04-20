(** Rewrite wide [Block (tag, fields)] expressions into an
    [alloc_block] allocation placed near the first field's defining
    [Let] plus per-field [Set_field] stores at each field's
    definition site. Collapses the simultaneous live-var peak at
    module-init MAKEBLOCK sites without changing observable
    semantics.

    Operates block-by-block on a [Code.program]. The rewrite is
    SSA-safe: the original MAKEBLOCK's carrier [Var.t] is re-bound
    by the inserted [alloc_block] Let; no new carriers are
    introduced downstream. *)

type stats =
  { blocks_rewritten : int
  ; fields_streamed : int
  }

val run : Code.program -> Code.program * stats
val f : Code.program -> Code.program
