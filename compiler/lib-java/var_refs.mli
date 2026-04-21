(** Free-variable and definition helpers on [Code] constructs.

    Extracted from the copies that previously lived in [Method_split],
    [Spill_long_lived], and [Cross_block_spill] so they stay in sync
    as [Code.expr] and [Code.last] gain new variants. A walker that
    forgets to update a case here would otherwise silently under-count
    uses / defs, breaking one pass at a time.

    Semantics are the standard free-var notion — vars that are
    *referenced* (not bound) by the construct. [Pushtrap]'s [exn_var]
    is bound by the construct, so it's subtracted from the handler
    side's uses. *)

val fv_set_of_list : Code.Var.t list -> Code.Var.Set.t

val fv_prim_arg : Code.prim_arg -> Code.Var.Set.t

val fv_expr : Code.expr -> Code.Var.Set.t

val fv_instr : Code.instr -> Code.Var.Set.t

val fv_cont : Code.cont -> Code.Var.Set.t

val fv_last : Code.last -> Code.Var.Set.t

val defs_of_instr : Code.instr -> Code.Var.Set.t
