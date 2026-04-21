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
        (** The block receiving the body's results via its block
            params. All exits from [body_blocks] to outside the
            subgraph target this block. *)
  ; result_params : Code.Var.t list
        (** [join_block.params] — the params bound by the join,
            each receiving a value from every body-edge to the
            join. The helper packs them into a [Block 0 (Object
            array)] return value; the caller unpacks via [Field]
            before branching to [join_block]. *)
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

type applied =
  { helper_entry_params : Code.Var.t list
        (** Params of the helper's entry block. [body_entry.params]
            from the original program, in order, plus freshly
            introduced params for the forwarded vars. [Method_split]
            builds the descriptor from this list. *)
  ; helper_prog : Code.program
  ; head_prog : Code.program
  ; forwarded_args : Code.Var.t list
        (** Vars the caller must pass into the helper call (in the
            same order as the tail of [helper_entry_params]). These
            are the live-in vars at [body_entry] that aren't
            already covered by the original branch args. *)
  }

val apply
  :  Code.program
  -> candidate
  -> class_:string
  -> method_:string
  -> descriptor:string
  -> is_static:bool
  -> applied
(** Apply the candidate as a split. Builds:

    - [helper_prog] — the body_blocks with every edge to
      [join_block] rewritten to [Return] of the single result arg.
      Multi-arm cases (a Cond or Switch where multiple arms target
      the join) get fresh stub blocks so each exit path produces
      its own [Return]. No block in the helper has a
      function-exit terminator (the enumerator rejected those).

    - [head_prog] — the original program with [body_blocks] removed
      and [caller]'s terminator replaced by
      [Let (v', Invoke_helper {...})] followed by
      [Branch (join_block, [v'])]. [join_block]'s params and edges
      are unchanged; the new edge from the caller carries [v'] in
      the result slot.

    Caller's responsibility: provide unique [method_] / [class_] /
    [descriptor] / [is_static]; the descriptor must describe a
    method with |helper_entry_params| Object args returning an
    Object. *)
