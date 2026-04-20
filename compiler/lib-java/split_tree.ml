open Code

type leaf =
  { entry_addr : Addr.t
  ; params : Var.t list
  ; body : instr array
  ; branch : last
  }

type node =
  | Leaf of leaf
  | Flat of node list
  | Try_region of
      { pushtrap : leaf
      ; exn_var : Var.t
      ; handler_addr : Addr.t
      ; poptraps : Addr.Set.t
      ; protected : node
      }

type t =
  { start : Addr.t
  ; free_pc : Addr.t
  ; root : node
  }

let leaf_of_block addr (b : block) : leaf =
  { entry_addr = addr; params = b.params; body = b.body; branch = b.branch }

(* Group blocks by the innermost active trap (top of their trap
   context). Blocks with empty context go under [None]. The pushtrap
   block *itself* is grouped with its parent level — its own trap
   becomes active only on the body edge, not at the block's entry. *)
let group_by_innermost (contexts : (Addr.t, Addr.t list) Hashtbl.t)
      (prog : program) =
  let by_innermost : (Addr.t option, Addr.t list) Hashtbl.t =
    Hashtbl.create 16
  in
  Addr.Map.iter
    (fun a _ ->
      let key =
        match Hashtbl.find_opt contexts a with
        | Some (top :: _) -> Some top
        | _ -> None
      in
      let cur =
        try Hashtbl.find by_innermost key with Not_found -> []
      in
      Hashtbl.replace by_innermost key (a :: cur))
    prog.blocks;
  by_innermost

let poptraps_per_trap (contexts : (Addr.t, Addr.t list) Hashtbl.t)
      (prog : program) =
  let tbl : (Addr.t, Addr.Set.t) Hashtbl.t = Hashtbl.create 8 in
  Addr.Map.iter
    (fun a (b : block) ->
      match b.branch with
      | Poptrap _ ->
        (match Hashtbl.find_opt contexts a with
         | Some (top :: _) ->
           let cur =
             try Hashtbl.find tbl top with Not_found -> Addr.Set.empty
           in
           Hashtbl.replace tbl top (Addr.Set.add a cur)
         | _ -> ())
      | _ -> ())
    prog.blocks;
  tbl

(* Traps keyed by their parent trap (the innermost active trap at the
   pushtrap block's own entry). None = outermost. *)
let child_traps_per_parent (contexts : (Addr.t, Addr.t list) Hashtbl.t)
      (prog : program) =
  let tbl : (Addr.t option, Addr.t list) Hashtbl.t = Hashtbl.create 8 in
  Addr.Map.iter
    (fun a (b : block) ->
      match b.branch with
      | Pushtrap _ ->
        let parent =
          match Hashtbl.find_opt contexts a with
          | Some (top :: _) -> Some top
          | _ -> None
        in
        let cur = try Hashtbl.find tbl parent with Not_found -> [] in
        Hashtbl.replace tbl parent (a :: cur)
      | _ -> ())
    prog.blocks;
  tbl

let of_program (prog : program) : t =
  let contexts = Code.compute_trap_contexts prog in
  let by_innermost = group_by_innermost contexts prog in
  let poptraps_of = poptraps_per_trap contexts prog in
  let child_traps_of = child_traps_per_parent contexts prog in
  let rec build_at ~parent =
    let my_blocks =
      try Hashtbl.find by_innermost parent with Not_found -> []
    in
    let child_traps =
      try Hashtbl.find child_traps_of parent with Not_found -> []
    in
    let child_trap_set =
      List.fold_left
        (fun s a -> Addr.Set.add a s)
        Addr.Set.empty
        child_traps
    in
    let leaves =
      List.filter_map
        (fun a ->
          if Addr.Set.mem a child_trap_set
          then None
          else
            match Addr.Map.find_opt a prog.blocks with
            | None -> None
            | Some b -> Some (Leaf (leaf_of_block a b)))
        my_blocks
    in
    let try_nodes =
      List.map
        (fun trap_addr ->
          let b = Addr.Map.find trap_addr prog.blocks in
          let exn_var, handler_addr =
            match b.branch with
            | Pushtrap (_, exn_var, (ha, _)) -> exn_var, ha
            | _ -> assert false
          in
          let poptraps =
            try Hashtbl.find poptraps_of trap_addr
            with Not_found -> Addr.Set.empty
          in
          let protected = build_at ~parent:(Some trap_addr) in
          Try_region
            { pushtrap = leaf_of_block trap_addr b
            ; exn_var
            ; handler_addr
            ; poptraps
            ; protected
            })
        child_traps
    in
    Flat (leaves @ try_nodes)
  in
  { start = prog.start
  ; free_pc = prog.free_pc
  ; root = build_at ~parent:None
  }

let rec iter_leaves node f =
  match node with
  | Leaf l -> f l
  | Flat ns -> List.iter (fun n -> iter_leaves n f) ns
  | Try_region { pushtrap; protected; _ } ->
    f pushtrap;
    iter_leaves protected f

let to_program (t : t) : program =
  let blocks = ref Addr.Map.empty in
  iter_leaves t.root (fun l ->
    blocks :=
      Addr.Map.add
        l.entry_addr
        { params = l.params; body = l.body; branch = l.branch }
        !blocks);
  { start = t.start; free_pc = t.free_pc; blocks = !blocks }

let leaf_addrs (t : t) : Addr.Set.t =
  let acc = ref Addr.Set.empty in
  iter_leaves t.root (fun l -> acc := Addr.Set.add l.entry_addr !acc);
  !acc

let trap_regions (t : t) =
  let acc = ref [] in
  let rec walk = function
    | Leaf _ -> ()
    | Flat ns -> List.iter walk ns
    | Try_region { pushtrap; handler_addr; poptraps; protected; _ } ->
      let protected_set = ref Addr.Set.empty in
      iter_leaves protected (fun l ->
        protected_set := Addr.Set.add l.entry_addr !protected_set);
      acc :=
        (pushtrap.entry_addr, handler_addr, poptraps, !protected_set)
        :: !acc;
      walk protected
  in
  walk t.root;
  !acc
