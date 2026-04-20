(** Structural IR for the method-splitting stage.

    The splitter historically operated directly on [Code.program] — a
    flat [Addr.t]-keyed block map — and had to rederive every structural
    question (trap regions, loop bodies, SESE sub-graphs) from reachability
    and dataflow. This module is an alternative view: a tree whose nodes
    are valid-by-construction cut candidates.

    The migration happens stepwise; see
    [/home/mathew/.claude/plans/it-seems-like-it-adaptive-duckling.md]. *)

type leaf =
  { entry_addr : Code.Addr.t
  ; params : Code.Var.t list
  ; body : Code.instr array
  ; branch : Code.last
  }

type node =
  | Leaf of leaf
  | Flat of node list
      (** Unordered bag of nodes. *)
  | Try_region of
      { pushtrap : leaf
            (** The [Pushtrap]-terminated block itself. Sits in the
                parent level (its context is the parent's), but the
                [Try_region] node pulls it out so the protected subtree
                can be pointed to. *)
      ; exn_var : Code.Var.t
      ; handler_addr : Code.Addr.t
            (** The handler block lives in the *parent* level of the
                tree (its trap context is the parent's). The address
                is recorded here so cut validity can check that
                pushtrap + handler stay co-sided without rewalking the
                CFG. *)
      ; poptraps : Code.Addr.Set.t
            (** Every block in the protected subtree whose terminator
                is a [Poptrap] popping this trap. *)
      ; protected : node
            (** Blocks whose innermost active trap is this one.
                Nested trap regions appear here as further
                [Try_region] nodes. *)
      }

type t =
  { start : Code.Addr.t
  ; free_pc : Code.Addr.t
  ; root : node
  }

val of_program : Code.program -> t
val to_program : t -> Code.program

val iter_leaves : node -> (leaf -> unit) -> unit

val trap_regions
  :  t
  -> (Code.Addr.t * Code.Addr.t * Code.Addr.Set.t * Code.Addr.Set.t) list
(** Same shape as [Method_split.pushtrap_regions]: for each trap, the tuple
    [(pushtrap_addr, handler_addr, poptraps, protected)]. *)
