(** Per-[Var] def-site and use-site index for a [Code.program].

    Built in a single linear pass over [prog.blocks]. Designed for
    [Method_split]'s upcoming Let_in-style extraction: given a Var,
    know exactly where it's defined and where it's used so we can
    decide whether the producing subgraph can be lifted into a
    helper method and replaced with an [Invoke_helper] call site.

    Not a general dataflow framework — [Flow] (the js_of_ocaml
    constant-propagation module we haven't ported yet) would cover
    that. This is purpose-built and minimal. *)

type def_site =
  | Block_param of Code.Addr.t * int
      (** [Block_param (addr, i)] — the Var is [block.params.(i)] of
          the block at [addr]. *)
  | Let_instr of Code.Addr.t * int
      (** [Let_instr (addr, i)] — [block.body.(i)] is
          [Let (v, _)]. *)
  | Exn_var of Code.Addr.t
      (** The exn_var bound by a [Pushtrap] at [addr]. *)

type use_site =
  | In_body of Code.Addr.t * int
      (** [block.body.(i)] references the var. *)
  | In_branch of Code.Addr.t
      (** The block's terminator references the var (scrutinee,
          Return/Raise value, Invoke_tail arg, etc.). *)
  | In_branch_arg of Code.Addr.t * int
      (** The var appears at position [i] in a [cont] argument list
          in the block's terminator. Multiple edges into the same
          target are not distinguished here — callers who need to
          know which successor use [Code]'s terminator directly. *)

type t

val of_program : Code.program -> t

val def_of : t -> Code.Var.t -> def_site option
(** [None] if the Var is never defined inside the program (e.g. a
    function parameter referenced but not introduced by this
    [program]). *)

val uses_of : t -> Code.Var.t -> use_site list
(** Empty list if the Var is never used. Order is implementation-
    defined (don't rely on it). *)
