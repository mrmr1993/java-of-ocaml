(** Pure-function analysis on [Code.program].

    Adapted from [js_of_ocaml/compiler/lib/pure_fun.ml]. A [Closure]
    binding [Let (f, Closure { body = (pc, _); _ })] is "pure" when
    its transitively-reachable body contains only pure instructions
    and its terminators never [Raise]. Loops (back-edges in the block
    graph reachable from the closure body) are conservatively treated
    as impure because we can't prove termination.

    The result is the set of [Var.t]s bound to pure closures. Callers
    (currently [Deadcode]) use it to treat [Apply { f; exact = true;
    _ }] as side-effect free when [f] is in the set. A small
    hardcoded allow-list of known-pure C primitives (comparison,
    structural equality, tag/size helpers) is also exposed via
    [is_pure_extern]. *)

val is_pure_extern : string -> bool
(** [true] for C primitives we know have no observable side
    effect. Used both inside this analysis and directly from
    [Deadcode.pure_expr]. *)

type t = Code.Var.Set.t

val empty : t

val pure_expr : t -> Code.expr -> bool
(** Mirrors [Deadcode.pure_expr] but promotes [Apply { exact = true;
    f; _ }] to pure when [f] is in the given set, and [Prim (Extern
    name, _)] to pure when [is_pure_extern name]. *)

val f : Code.program -> t
(** Compute the set of pure closure-bound [Var.t]s for the program. *)
