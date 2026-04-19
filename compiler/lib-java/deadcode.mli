(** Dead-code elimination on [Code.program].

    Adapted (in miniature) from
    [js_of_ocaml/compiler/lib/deadcode.ml]. Two layered passes:

    1. Reachability pruning drops blocks not reachable from
       [prog.start] via the block graph ([Branch] / [Cond] /
       [Switch] / [Pushtrap] / [Poptrap] / [Return] / [Raise] /
       [Stop]).

    2. Dead-[Let] removal drops [Let (x, e)] bindings where [x] has
       no uses and [e] is side-effect free. Purity is determined by
       {!Pure_fun}: pure primitives (comparison / structural /
       allow-listed externs), allocation-only expressions ([Block],
       [Closure], [Constant], [Field]), and [Apply { exact = true;
       f; _ }] when [f] is a known-pure closure. [Apply { exact =
       false; _ }], [Prim (Extern _)] outside the allow-list, [Prim
       (Array_get, _)] (may raise), and every non-[Let] instruction
       stay impure.

    The pass is idempotent and conservative — it never removes an
    impure expression, never drops a block that might be a branch
    target, and never changes a block's [params] or its
    terminator's cont arg arity. Further passes (dead-param
    elimination, block shortcutting) can layer on. *)

val f : Code.program -> Code.program

type stats =
  { deleted_blocks : int
  ; deleted_instrs : int
  }

val run : Code.program -> Code.program * stats
(** Same as [f] but also reports how much was removed. Useful for
    the [times] / [stats] debug traces. *)
