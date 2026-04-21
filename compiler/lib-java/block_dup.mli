(** Subgraph cloning for [Method_split]'s block-duplication cut.

    Given a program and a set of root blocks, clones every block
    forward-reachable from the roots (stopping at [stop] blocks or
    at terminators), allocating fresh [Code.Addr.t] / [Code.Var.t]
    for each. Returns the new blocks plus the substitution maps so
    callers can rewrite their own references to point at the clones.

    The original blocks are unchanged — this is a pure clone. The
    caller is responsible for splicing the clones into a new program
    and adjusting source-side references. *)

type duplicated =
  { new_blocks : Code.block Code.Addr.Map.t
        (** [clone_addr → cloned_block]. Each block has fresh
            params, body, and branch — vars defined inside the
            subgraph are renamed; vars defined outside (closures,
            forwarded args, etc.) are kept as-is. *)
  ; addr_subst : (Code.Addr.t, Code.Addr.t) Hashtbl.t
        (** [original_addr → clone_addr]. Caller uses this to
            rewrite their own branches that should now target a
            clone instead of the original. *)
  ; var_subst : (Code.Var.t, Code.Var.t) Hashtbl.t
        (** [original_var → clone_var]. Mostly for callers that
            want to follow a value through the clone — most
            consumers won't need it. *)
  ; free_pc : Code.Addr.t
        (** Updated [free_pc] after fresh-addr allocation; pass
            into the next program-modifying step. *)
  }

val duplicate_subgraph
  :  Code.program
  -> roots:Code.Addr.t list
  -> stop:Code.Addr.Set.t
  -> free_pc:Code.Addr.t
  -> duplicated
(** Walk forward from [roots] via [Code.successors_of]-style
    enumeration. Stop at blocks in [stop] (those branches keep
    pointing to the original addr — they're caller's territory).
    Stop at terminators (no successors).

    Branches inside cloned blocks that target other cloned blocks
    are rewritten via [addr_subst]; branches targeting [stop]
    blocks keep the original addr; branches targeting any other
    block (e.g. unreachable in the clone walk) keep the original
    too — caller must ensure such targets remain valid in the
    final program. *)
