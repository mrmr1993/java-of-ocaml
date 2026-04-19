open Code

type stats =
  { deleted_blocks : int
  ; deleted_instrs : int
  }

(* --- Reachability ---------------------------------------------------- *)

let reachable_addrs (prog : program) : Addr.Set.t =
  let seen = ref Addr.Set.empty in
  let rec visit addr =
    if Addr.Set.mem addr !seen
    then ()
    else (
      seen := Addr.Set.add addr !seen;
      match Addr.Map.find_opt addr prog.blocks with
      | None -> ()
      | Some b ->
        let step (a, _) = visit a in
        match b.branch with
        | Return _ | Raise _ | Stop | Invoke_tail _ -> ()
        | Branch c | Poptrap c -> step c
        | Cond (_, c1, c2) ->
          step c1;
          step c2
        | Switch (_, ints, tags) ->
          Array.iter step ints;
          Array.iter step tags
        | Pushtrap (body, _, handler) ->
          step body;
          step handler)
  in
  visit prog.start;
  !seen

(* --- Variable-use counts --------------------------------------------- *)

module VarTbl = Hashtbl.Make (struct
  type t = Var.t

  let equal = Var.equal
  let hash = Var.idx
end)

(* Could use the existing [Var.Hashtbl], but small tables are
   cheaper to manage explicitly here. *)

let bump t v =
  match VarTbl.find_opt t v with
  | Some n -> VarTbl.replace t v (n + 1)
  | None -> VarTbl.add t v 1

let bump_prim_arg t = function
  | Pv v -> bump t v
  | Pc _ -> ()

(* Count every use of every Var across the whole program, except
   uses from within a [Let (x, e)] where we'll potentially drop the
   binding. Those get counted after we decide which bindings to
   keep. *)
let count_uses (prog : program) : int VarTbl.t =
  let uses = VarTbl.create 64 in
  let expr_uses = function
    | Apply { f; args; _ } ->
      bump uses f;
      List.iter (bump uses) args
    | Block (_, fields) -> Array.iter (bump uses) fields
    | Field (v, _) -> bump uses v
    | Closure { captures; body = _, args } ->
      List.iter (bump uses) captures;
      List.iter (bump uses) args
    | Constant _ -> ()
    | Prim (_, args) -> List.iter (bump_prim_arg uses) args
  in
  let instr_uses = function
    | Let (_, e) -> expr_uses e
    | Set_field (b, _, v) ->
      bump uses b;
      bump uses v
    | Offset_ref (v, _) -> bump uses v
    | Array_set (a, i, v) ->
      bump uses a;
      bump uses i;
      bump uses v
  in
  let cont_uses (_, args) = List.iter (bump uses) args in
  Addr.Map.iter
    (fun _ b ->
      List.iter instr_uses b.body;
      match b.branch with
      | Return v -> bump uses v
      | Raise v -> bump uses v
      | Stop -> ()
      | Branch c | Poptrap c -> cont_uses c
      | Cond (v, c1, c2) ->
        bump uses v;
        cont_uses c1;
        cont_uses c2
      | Switch (v, ints, tags) ->
        bump uses v;
        Array.iter cont_uses ints;
        Array.iter cont_uses tags
      | Pushtrap (body, _exn, handler) ->
        cont_uses body;
        cont_uses handler
      | Invoke_tail { args; _ } -> List.iter (bump uses) args)
    prog.blocks;
  uses

(* --- Purity -----------------------------------------------------------

   A pure expression can be dropped without changing program
   behaviour. Delegated to [Pure_fun]: that module provides the
   [Var.Set.t] of closure-bound vars whose bodies are known to have
   no observable side effect, plus a hardcoded allow-list of pure C
   primitives (comparison / structural equality / tag / Sys
   constants).

   [Apply { exact = false; _ }] remains impure: we don't know which
   closure [f] eventually dispatches to through the PartialClosure
   path, so we can't claim purity. The bytecode frontend currently
   emits all applies as [exact = false], so in practice this path
   only kicks in when a future pass promotes known-arity calls. *)

let pure_expr pure_funs e = Pure_fun.pure_expr pure_funs e

(* --- Passes ---------------------------------------------------------- *)

let prune_unreachable (prog : program) : program * int =
  let live = reachable_addrs prog in
  let before = Addr.Map.cardinal prog.blocks in
  let blocks =
    Addr.Map.filter (fun addr _ -> Addr.Set.mem addr live) prog.blocks
  in
  let after = Addr.Map.cardinal blocks in
  { prog with blocks }, before - after

let drop_dead_lets ~pure_funs (prog : program) : program * int =
  let uses = count_uses prog in
  let deleted = ref 0 in
  let keep_instr = function
    | Let (x, e) as i ->
      let used = try VarTbl.find uses x > 0 with Not_found -> false in
      if (not used) && pure_expr pure_funs e
      then (
        incr deleted;
        None)
      else Some i
    | i -> Some i
  in
  let blocks =
    Addr.Map.map
      (fun b -> { b with body = List.filter_map keep_instr b.body })
      prog.blocks
  in
  { prog with blocks }, !deleted

(* --- Entry points ---------------------------------------------------- *)

let run prog =
  (* Compute purity before pruning: the reachability filter drops
     closure-body blocks that are only referenced through [Closure],
     and [Pure_fun] needs those bodies to classify the closure. *)
  let pure_funs = Pure_fun.f prog in
  let prog, deleted_blocks = prune_unreachable prog in
  let prog, deleted_instrs = drop_dead_lets ~pure_funs prog in
  prog, { deleted_blocks; deleted_instrs }

let f prog =
  let prog, _ = run prog in
  prog
