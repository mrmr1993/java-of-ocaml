open Code

let fv_set_of_list vs =
  List.fold_left (fun acc v -> Var.Set.add v acc) Var.Set.empty vs

let fv_prim_arg = function
  | Pv v -> Var.Set.singleton v
  | Pc _ -> Var.Set.empty

let fv_expr = function
  | Apply { f; args; _ } -> Var.Set.add f (fv_set_of_list args)
  | Block (_, fields) -> fv_set_of_list (Array.to_list fields)
  | Field (v, _) -> Var.Set.singleton v
  | Closure { captures; _ } -> fv_set_of_list captures
  | Constant _ -> Var.Set.empty
  | Prim (_, args) ->
    List.fold_left
      (fun acc a -> Var.Set.union acc (fv_prim_arg a))
      Var.Set.empty
      args
  | Invoke_helper { args; _ } -> fv_set_of_list args

let fv_instr = function
  | Let (_, e) -> fv_expr e
  | Set_field (x, _, y) -> Var.Set.add x (Var.Set.singleton y)
  | Offset_ref (x, _) -> Var.Set.singleton x
  | Array_set (a, i, v) ->
    Var.Set.add a (Var.Set.add i (Var.Set.singleton v))
  | Source_pc _ -> Var.Set.empty

let fv_cont (_, args) = fv_set_of_list args

let fv_last = function
  | Return v | Raise v -> Var.Set.singleton v
  | Stop -> Var.Set.empty
  | Branch c -> fv_cont c
  | Cond (v, c1, c2) ->
    Var.Set.add v (Var.Set.union (fv_cont c1) (fv_cont c2))
  | Switch (v, ints, tags) ->
    let s =
      Array.fold_left
        (fun acc c -> Var.Set.union acc (fv_cont c))
        Var.Set.empty
        ints
    in
    let s =
      Array.fold_left (fun acc c -> Var.Set.union acc (fv_cont c)) s tags
    in
    Var.Set.add v s
  | Pushtrap (body, exn_var, handler) ->
    (* [exn_var] is *bound* by the Pushtrap (it names the caught
       exception inside the handler); it shouldn't count as a free
       use just because it appears in [handler]'s args. *)
    let all = Var.Set.union (fv_cont body) (fv_cont handler) in
    Var.Set.remove exn_var all
  | Poptrap c -> fv_cont c
  | Invoke_tail { args; _ } -> fv_set_of_list args

let defs_of_instr = function
  | Let (v, _) -> Var.Set.singleton v
  | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> Var.Set.empty
