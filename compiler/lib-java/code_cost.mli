(** Conservative JVM byte-cost estimate for a [Code.program].

    Mirrors what [Jvm_generate] eventually emits, at the coarse level
    needed to decide whether a program will fit in a single 65535-byte
    [Code] attribute. The estimator is tuned to *slightly over-estimate*
    — splitting triggers before the emitter actually overflows, and
    never triggers spuriously far from the limit.

    Used by [Method_split] both to decide whether a split is needed
    and, when it is, to score candidate cuts by head byte count. *)

val instr : Code.instr -> int
(** Byte estimate for a single instruction. Exposed so the intra-block
    splitter in [Method_split] can walk a [body : instr list] and
    pick the cost-midpoint index without duplicating the table. *)

val block : Code.block -> int
(** Byte estimate for a single block, summed over its body instructions
    and terminator. *)

val program : Code.program -> int
(** Byte estimate for the whole program. Includes a small fixed
    overhead for the entry prologue (null-init of params, [aload 0] /
    capture loads). *)

val entry_overhead : Code.program -> int
(** The fixed prologue component of [program]: entry null-init +
    [aload 0]. Exposed so callers that already hold a block-cost
    sum (e.g. [Method_split]'s cached splitter) can add the
    overhead without re-walking the blocks. *)

val subset : Code.program -> Code.Addr.Set.t -> int
(** Cost of the sub-program restricted to the given set of block
    addresses, plus the program's fixed entry overhead. *)

val heaviest_block : Code.program -> (Code.Addr.t * int) option
(** Address + cost of the single heaviest block in [prog], or [None]
    if [prog] is empty. Used by intra-block splitting to pick the
    block to break up when no structural cut is available. *)
