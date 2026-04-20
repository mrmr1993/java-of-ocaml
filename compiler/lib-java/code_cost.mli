(** Conservative JVM byte-cost estimate for a [Code.program].

    Mirrors what [Jvm_generate] eventually emits, at the coarse level
    needed to decide whether a program will fit in a single 65535-byte
    [Code] attribute. The estimator is tuned to *slightly over-estimate*
    — splitting triggers before the emitter actually overflows, and
    never triggers spuriously far from the limit.

    Used by [Method_split] both to decide whether a split is needed
    and, when it is, to score candidate cuts by head byte count. *)

val extern_cost : string -> int
(** Body-byte cost of a specific extern primitive — the [Extern name]
    arm of [prim_cost]. Exposed so the per-primitive test can walk
    a curated list and assert this table stays in sync with what
    [Jvm_generate] actually emits. *)

val instr : Code.instr -> int
(** Byte estimate for a single instruction. Exposed so the intra-block
    splitter in [Method_split] can walk a [body : instr array] and
    pick the cost-midpoint index without duplicating the table. *)

val max_instr_cost : int
(** Conservative upper bound on per-instruction bytes. Use with
    [Array.length b.body] for an O(1) upper bound on block cost —
    the splitter uses it to skip expensive analysis on blocks that
    trivially can't approach the method-size limit. *)

val last : Code.last -> int
(** Byte estimate for a block terminator. Exposed for the same reason
    as [instr]: the intra-block splitter sums per-position
    cost-from-end including the terminator. *)

val block : Code.block -> int
(** Byte estimate for a single block, summed over its body instructions
    and terminator. *)

val program : Code.program -> int
(** Byte estimate for the whole program. Includes a small fixed
    overhead for the entry prologue (null-init of params, [aload 0] /
    capture loads). *)

val program_upper_bound : Code.program -> int
(** [Array.length]-only upper bound for [program]: no per-instruction
    walk, just [max_instr_cost * total_instrs + per-block slack]. Use
    as a cheap short-circuit — if the upper bound sits under the
    split limit, the real [program] value does too. *)

val entry_overhead : Code.program -> int
(** The fixed prologue component of [program]: entry null-init +
    [aload 0]. Exposed so callers that already hold a block-cost
    sum (e.g. [Method_split]'s cached splitter) can add the
    overhead without re-walking the blocks. *)

val subset : Code.program -> Code.Addr.Set.t -> int
(** Cost of the sub-program restricted to the given set of block
    addresses, plus the program's fixed entry overhead. *)

