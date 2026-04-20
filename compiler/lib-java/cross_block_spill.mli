(** Pre-split pass that collapses wide cross-block forwarding chains
    into a shared carrier block.

    Identifies "logical variables" — equivalence classes of [Var.t]
    linked by edge-arg / block-param bindings across the CFG — that
    forward through many blocks with few true uses. Allocates a
    single [alloc_block] carrier in the program's entry block,
    threads it through every other block as an additional param, and
    replaces each logical var with:

    - [Set_field(carrier, slot, v)] at the class's defining [Let],
    - [Let(fresh, Field(carrier, slot))] immediately before each
      non-edge-arg use (with the use substituted).

    Members of the class are then purged from [block.params] lists
    and from their corresponding positions in every branch-cont
    args list. For Method_split, the N previously-forwarded vars
    per cut collapse into one threaded carrier — helper method
    arities drop accordingly.

    Runs after [Block_preallocation] / [Eval] / [Deadcode] /
    [Spill_long_lived] and before [Method_split]. *)

type stats =
  { spilled_classes : int
  ; carrier_size : int
  }

val run : Code.program -> Code.program * stats
val f : Code.program -> Code.program
