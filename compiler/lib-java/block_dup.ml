open Code

type duplicated =
  { new_blocks : block Addr.Map.t
  ; addr_subst : (Addr.t, Addr.t) Hashtbl.t
  ; var_subst : (Var.t, Var.t) Hashtbl.t
  ; free_pc : Addr.t
  }

(* CFG successors for a single block, mirroring [Code.fold_children]
   but as a list. Local copy to avoid the cross-module dep. *)
let successors_of (b : block) : Addr.t list =
  let acc = ref [] in
  let step (a, _) = acc := a :: !acc in
  (match b.branch with
   | Return _ | Raise _ | Stop | Invoke_tail _ -> ()
   | Branch c -> step c
   | Cond (_, c1, c2) ->
     step c1;
     step c2
   | Switch (_, ints, tags) ->
     Array.iter step ints;
     Array.iter step tags
   | Pushtrap (body, _, handler) ->
     step body;
     step handler
   | Poptrap c -> step c);
  !acc

(* Per-instruction Var substitution. [sub] maps original-var → new-var
   (or returns the original if the var isn't in the table). Vars
   defined *outside* the cloned subgraph stay as-is, so closures /
   forwarded args / loop-carried values keep referencing their
   original definitions. *)
let sub_var (sub : (Var.t, Var.t) Hashtbl.t) v =
  try Hashtbl.find sub v with Not_found -> v

let sub_prim_arg sub = function
  | Pv v -> Pv (sub_var sub v)
  | Pc _ as c -> c

let sub_expr sub = function
  | Apply { f; args; exact } ->
    Apply
      { f = sub_var sub f
      ; args = List.map (sub_var sub) args
      ; exact
      }
  | Block (tag, fs) -> Block (tag, Array.map (sub_var sub) fs)
  | Field (v, i) -> Field (sub_var sub v, i)
  | Closure { captures; body } ->
    Closure { captures = List.map (sub_var sub) captures; body }
  | Constant _ as c -> c
  | Prim (p, args) -> Prim (p, List.map (sub_prim_arg sub) args)

let sub_instr sub = function
  | Let (v, e) -> Let (sub_var sub v, sub_expr sub e)
  | Set_field (x, i, y) ->
    Set_field (sub_var sub x, i, sub_var sub y)
  | Offset_ref (x, i) -> Offset_ref (sub_var sub x, i)
  | Array_set (a, i, v) ->
    Array_set (sub_var sub a, sub_var sub i, sub_var sub v)
  | Source_pc _ as s -> s

let sub_cont sub addr_sub (a, args) =
  let a' = try Hashtbl.find addr_sub a with Not_found -> a in
  let args' = List.map (sub_var sub) args in
  a', args'

let sub_last sub addr_sub = function
  | Return v -> Return (sub_var sub v)
  | Raise v -> Raise (sub_var sub v)
  | Stop -> Stop
  | Branch c -> Branch (sub_cont sub addr_sub c)
  | Cond (v, c1, c2) ->
    Cond
      ( sub_var sub v
      , sub_cont sub addr_sub c1
      , sub_cont sub addr_sub c2 )
  | Switch (v, ints, tags) ->
    Switch
      ( sub_var sub v
      , Array.map (sub_cont sub addr_sub) ints
      , Array.map (sub_cont sub addr_sub) tags )
  | Pushtrap (body, exn_v, handler) ->
    Pushtrap
      ( sub_cont sub addr_sub body
      , sub_var sub exn_v
      , sub_cont sub addr_sub handler )
  | Poptrap c -> Poptrap (sub_cont sub addr_sub c)
  | Invoke_tail { class_; method_; descriptor; args; is_static } ->
    Invoke_tail
      { class_
      ; method_
      ; descriptor
      ; args = List.map (sub_var sub) args
      ; is_static
      }

let duplicate_subgraph (prog : program) ~roots ~stop ~free_pc =
  let addr_subst : (Addr.t, Addr.t) Hashtbl.t = Hashtbl.create 16 in
  let var_subst : (Var.t, Var.t) Hashtbl.t = Hashtbl.create 64 in
  let free_pc = ref free_pc in
  let alloc_addr () =
    let a = !free_pc in
    incr free_pc;
    a
  in
  (* Pass 1: BFS forward from [roots], allocating fresh clone-addrs.
     Stop at [stop] blocks (their original stays in the program; we
     don't clone them) and at terminators (no successors). *)
  let to_clone : Addr.t Queue.t = Queue.create () in
  let mark addr =
    if (not (Addr.Set.mem addr stop)) && not (Hashtbl.mem addr_subst addr)
    then (
      match Addr.Map.find_opt addr prog.blocks with
      | None -> ()  (* unknown addr — leave alone *)
      | Some _ ->
        Hashtbl.add addr_subst addr (alloc_addr ());
        Queue.add addr to_clone)
  in
  List.iter mark roots;
  while not (Queue.is_empty to_clone) do
    let orig = Queue.pop to_clone in
    match Addr.Map.find_opt orig prog.blocks with
    | None -> ()
    | Some b -> List.iter mark (successors_of b)
  done;
  (* Pass 2: allocate fresh Vars for every block-param and Let-def
     in the cloned set. Pushtrap's exn_var is also bound (and
     referenced inside the protected region's handler arm), so it
     gets a fresh var too. *)
  let alloc_var orig =
    if not (Hashtbl.mem var_subst orig)
    then Hashtbl.add var_subst orig (Var.fresh ())
  in
  Hashtbl.iter
    (fun orig _new ->
      let b = Addr.Map.find orig prog.blocks in
      List.iter alloc_var b.params;
      Array.iter
        (fun instr ->
          match instr with
          | Let (v, _) -> alloc_var v
          | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> ())
        b.body;
      match b.branch with
      | Pushtrap (_, exn_v, _) -> alloc_var exn_v
      | _ -> ())
    addr_subst;
  (* Pass 3: build the cloned blocks with substituted vars and
     addrs. *)
  let new_blocks =
    Hashtbl.fold
      (fun orig new_addr acc ->
        let b = Addr.Map.find orig prog.blocks in
        let nb =
          { params = List.map (sub_var var_subst) b.params
          ; body = Array.map (sub_instr var_subst) b.body
          ; branch = sub_last var_subst addr_subst b.branch
          }
        in
        Addr.Map.add new_addr nb acc)
      addr_subst
      Addr.Map.empty
  in
  { new_blocks; addr_subst; var_subst; free_pc = !free_pc }
