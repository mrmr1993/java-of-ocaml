(** Block-local constant folding on [Code.program].

    Adapted (in miniature) from
    [js_of_ocaml/compiler/lib/eval.ml]. For each block we walk the
    body in order, tracking [Var.t -> constant] bindings from
    [Let (x, Constant c)] instructions, and folding any subsequent
    pure arithmetic / comparison primitive whose operands all
    resolve to constants.

    The env is block-local (reset at every block boundary); jsoo's
    full eval reaches across blocks via [Flow.Info.t], which we
    don't have yet. Without it, any Var that crosses a block edge
    (passed as a cont arg) loses its constant binding on the
    receiving side.

    This pass is paired with {!Deadcode}: folding [Let (x, Prim
    add_int [1; 2])] to [Let (x, Constant 3)] makes the original
    arg bindings unused if they're only read by the folded
    primitive, so a subsequent {!Deadcode.f} trims them. *)

type stats = { folded : int  (** Number of [Let] RHSs simplified. *) }

val f : Code.program -> Code.program

val run : Code.program -> Code.program * stats
