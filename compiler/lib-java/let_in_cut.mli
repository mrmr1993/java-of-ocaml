(** Identify "Let_in" style cut candidates in a [Code.program]:
    single-entry single-exit subgraphs whose only external exit is a
    branch to a join block carrying a single "result" value.

    These are the natural extractions for [Method_split] when the
    tail-only [Invoke_tail] model is the wrong shape — i.e. when a
    big sub-expression's result flows *into* the rest of the function
    rather than out of it. Think: big match expression producing one
    value, then more code after.

    Commit 5 phase 1: candidate identification only. Actual
    extraction / splitter integration is a separate follow-up. *)

type candidate =
  { join_block : Code.Addr.t
        (** The block receiving the body's result via its first
            block-param. All exits from [body_blocks] to outside the
            subgraph target this block. *)
  ; result_param : Code.Var.t
        (** [join_block.params.(0)] — the result of the extracted
            subgraph, bound at the join. *)
  ; body_entry : Code.Addr.t
        (** Dominator root of the body — single block that every
            edge into [body_blocks] targets. *)
  ; body_blocks : Code.Addr.Set.t
  ; caller : Code.Addr.t
        (** The single block whose terminator is [Branch(body_entry,
            _)]. After extraction, caller's body gains a
            [Let (v', Invoke_helper {...})] and its terminator
            becomes [Branch(join_block, [v'])]. *)
  ; cost : int
        (** Sum of [Code_cost.block] over [body_blocks]. *)
  }

val enumerate : Code.program -> candidate list
(** Enumerate every candidate, no filtering for size. Caller (the
    splitter) applies its own budget / scoring. *)
