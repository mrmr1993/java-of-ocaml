(** Per-function control-flow graph.

    Partitions an [Instr.instr array] slice into basic blocks:
    maximal straight-line sequences of instructions whose only
    entry is the first instruction and whose only exit is the
    last. Used by the emitter to normalise state at every
    cross-block edge — see the plan in
    [/home/mathew/.claude/plans/we-need-to-create-glistening-turing.md].

    Block boundaries follow
    [js_of_ocaml/compiler/lib/parse_bytecode.ml:345-443]:
    - a new block starts at every branch target;
    - a new block starts at the instruction immediately after an
      unconditional terminator (BRANCH / RETURN / APPTERM* / RAISE
      family / STOP);
    - PUSHTRAP's handler PC is already a branch target and thus a
      block start.
*)

type block =
  { id : int
  ; start_idx : int
        (** Index into the instruction array of the block's first
            instruction. *)
  ; end_idx : int
        (** Index into the instruction array of the block's last
            instruction (the terminator for the block). *)
  ; start_pc : int
  ; mutable incoming : int list
        (** Block ids that transfer control into this block. A block
            with [incoming = []] is unreachable (or the entry block).
            A block with [List.length incoming > 1] is a "join" — it
            needs block-param locals in Phase 2. *)
  ; mutable outgoing : int list
        (** Block ids this block can transfer control to. Ordered
            as: jump targets first, then fall-through last. Empty
            for blocks whose terminator is RETURN / APPTERM / RAISE
            / STOP. *)
  }

type t =
  { blocks : block array
  ; by_start_pc : (int, int) Hashtbl.t
        (** pc of a block's first instruction → its block id. *)
  }

val build : Instr.instr array -> body_start:int -> body_end:int -> t
(** [build arr ~body_start ~body_end] carves the instruction range
    [[body_start .. body_end]] into blocks. Single forward pass; no
    fixpoint. The result has [blocks] ordered by [start_idx]. *)

val entry_block_id : t -> int
(** Block id of the entry block — always the block containing
    [body_start]. By construction this is id 0. *)

val is_join : t -> int -> bool
(** [is_join cfg id] iff block [id] has more than one incoming
    edge. Join blocks need block-param locals (Phase 2). *)
