(** Structural IR for the method-splitting stage.

    The splitter historically operated directly on [Code.program] — a
    flat [Addr.t]-keyed block map — and had to rederive every structural
    question (trap regions, loop bodies, SESE sub-graphs) from reachability
    and dataflow. This module is an alternative view: a tree whose nodes
    are valid-by-construction cut candidates.

    The migration happens stepwise; see
    [/home/mathew/.claude/plans/it-seems-like-it-adaptive-duckling.md].

    Construction strategy: recognise patterns ([Seq] chains, if-diamonds,
    trap regions) where they're clean; fall back to [Flat] for anything
    the grammar can't express cleanly. Round-trip identity is preserved
    regardless of how much structure was recovered: [to_program] emits
    every leaf's block with its original branch, so the block graph
    round-trips byte-for-byte. *)

type leaf =
  { entry_addr : Code.Addr.t
  ; params : Code.Var.t list
  ; body : Code.instr array
  ; branch : Code.last
  }

type node =
  | Leaf of leaf
  | Flat of node list
      (** Unordered bag — the fallback when no structural pattern fits. *)
  | Seq of node list
      (** Linear chain: each element's sole successor is the next
          element's entry, and each non-first element has a single
          predecessor (the previous element). Valid cut candidate:
          a suffix of a [Seq] can be lifted into a helper. *)
  | If of
      { cond_leaf : leaf
            (** The [Cond]-terminated block that guards the diamond. *)
      ; t_branch : node
      ; f_branch : node
      ; join : node option
            (** The subtree at the reconvergence block, if both
                branches merge back cleanly. [None] if both branches
                terminate (Return/Raise/Stop/Invoke_tail) or exit via
                other paths. *)
      }
  | Switch of
      { scrut_leaf : leaf
      ; int_cases : node array
      ; tag_cases : node array
      ; join : node option
      }
  | Loop of
      { header_leaf : leaf
            (** The loop entry block; every back-edge in the body
                targets this block. *)
      ; body : node
            (** Blocks reachable from the header along edges inside
                the loop (i.e. within the natural-loop closure of the
                back-edges). *)
      }
  | Try_region of
      { pushtrap : leaf
      ; exn_var : Code.Var.t
      ; handler_addr : Code.Addr.t
      ; poptraps : Code.Addr.Set.t
      ; protected : node
      }

type t =
  { start : Code.Addr.t
  ; free_pc : Code.Addr.t
  ; root : node
  }

val of_program : Code.program -> t
val to_program : t -> Code.program

val iter_leaves : node -> (leaf -> unit) -> unit

val leaf_addrs : t -> Code.Addr.Set.t

val trap_regions
  :  t
  -> (Code.Addr.t * Code.Addr.t * Code.Addr.Set.t * Code.Addr.Set.t) list
