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
  | Seq of node list
  | If of
      { cond_leaf : leaf
      ; t_branch : node
      ; f_branch : node
      ; join : node option
      }
  | Switch of
      { scrut_leaf : leaf
      ; int_cases : node array
      ; tag_cases : node array
      ; join : node option
      }
  | Loop of { header_leaf : leaf; body : node }
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

(* --- CFG traversal utilities --- *)

let successors_of (b : block) =
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

let compute_predecessors (prog : program) =
  let tbl : (Addr.t, Addr.t list) Hashtbl.t = Hashtbl.create 16 in
  Addr.Map.iter
    (fun a b ->
      List.iter
        (fun s ->
          if Addr.Map.mem s prog.blocks
          then (
            let cur = try Hashtbl.find tbl s with Not_found -> [] in
            Hashtbl.replace tbl s (a :: cur)))
        (successors_of b))
    prog.blocks;
  tbl

(* Reverse post-order: start first, exits last. Used as iteration
   order for Cooper-Harvey-Kennedy dominators. Only reachable blocks
   appear. *)
let reverse_postorder (prog : program) =
  let visited = Hashtbl.create 16 in
  let postorder = ref [] in
  let rec dfs a =
    if not (Hashtbl.mem visited a)
    then (
      Hashtbl.add visited a ();
      match Addr.Map.find_opt a prog.blocks with
      | None -> postorder := a :: !postorder
      | Some b ->
        List.iter
          (fun s -> if Addr.Map.mem s prog.blocks then dfs s)
          (successors_of b);
        postorder := a :: !postorder)
  in
  dfs prog.start;
  (* [postorder] is already reverse-postorder because we prepended on
     finish — start was pushed last, so it's at the head. *)
  !postorder

(* --- Dominators via Cooper-Harvey-Kennedy --- *)

(* Assign a postorder number to each reachable block: 0 for
   first-finished (deep leaves), [n-1] for start. Nodes unreachable
   from start aren't numbered; the dominator computation skips them. *)
let postorder_numbers (prog : program) =
  let nums = Hashtbl.create 16 in
  let visited = Hashtbl.create 16 in
  let counter = ref 0 in
  let rec dfs a =
    if not (Hashtbl.mem visited a)
    then (
      Hashtbl.add visited a ();
      (match Addr.Map.find_opt a prog.blocks with
       | None -> ()
       | Some b ->
         List.iter
           (fun s -> if Addr.Map.mem s prog.blocks then dfs s)
           (successors_of b));
      Hashtbl.add nums a !counter;
      incr counter)
  in
  dfs prog.start;
  nums

let compute_idoms (prog : program) ~rpo ~preds =
  let po = postorder_numbers prog in
  let idom : (Addr.t, Addr.t) Hashtbl.t = Hashtbl.create 16 in
  Hashtbl.add idom prog.start prog.start;
  let po_of a = try Hashtbl.find po a with Not_found -> -1 in
  let rec intersect b1 b2 =
    if b1 = b2
    then b1
    else if po_of b1 < po_of b2
    then intersect (Hashtbl.find idom b1) b2
    else intersect b1 (Hashtbl.find idom b2)
  in
  let changed = ref true in
  while !changed do
    changed := false;
    List.iter
      (fun b ->
        if b <> prog.start
        then (
          let ps = try Hashtbl.find preds b with Not_found -> [] in
          let ps_with_idom =
            List.filter (fun p -> Hashtbl.mem idom p) ps
          in
          match ps_with_idom with
          | [] -> ()
          | p0 :: rest ->
            let new_idom = List.fold_left intersect p0 rest in
            let prev =
              try Some (Hashtbl.find idom b) with Not_found -> None
            in
            if prev <> Some new_idom
            then (
              Hashtbl.replace idom b new_idom;
              changed := true)))
      rpo
  done;
  idom

(* [dominates idom a b]: does [a] dominate [b]? Walk [b] upward via
   [idom] until we reach [a] or the root. *)
let dominates idom a b =
  if a = b
  then true
  else
    let rec walk c =
      let parent = Hashtbl.find idom c in
      if parent = c then false  (* hit root without finding [a] *)
      else if parent = a then true
      else walk parent
    in
    walk b

(* --- Trap-region bookkeeping --- *)

let group_by_innermost contexts (prog : program) =
  let tbl : (Addr.t option, Addr.t list) Hashtbl.t = Hashtbl.create 16 in
  Addr.Map.iter
    (fun a _ ->
      let key =
        match Hashtbl.find_opt contexts a with
        | Some (top :: _) -> Some top
        | _ -> None
      in
      let cur = try Hashtbl.find tbl key with Not_found -> [] in
      Hashtbl.replace tbl key (a :: cur))
    prog.blocks;
  tbl

let poptraps_per_trap contexts (prog : program) =
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

(* --- Structural construction --- *)

(* The build walks the reachable graph in dominator order, emitting a
   structural node for each region. "Stop" predicates tell the walker
   where a recursive descent must halt (e.g. at a join block owned by
   an enclosing [If], or at the loop header when building a loop body).

   Blocks are visited at most once per top-level [of_program] call;
   the [visited] tracker catches any accidental re-entry. The tree
   still contains every reachable block exactly once as a leaf
   (possibly wrapped in structural nodes), which [to_program] relies
   on for round-trip identity. *)

type ctx =
  { prog : program
  ; preds : (Addr.t, Addr.t list) Hashtbl.t
  ; idom : (Addr.t, Addr.t) Hashtbl.t
  ; contexts : (Addr.t, Addr.t list) Hashtbl.t
  ; poptraps_of : (Addr.t, Addr.Set.t) Hashtbl.t
  ; visited : (Addr.t, unit) Hashtbl.t
  }

(* Count predecessors (within the current program). *)
let num_preds ctx a =
  match Hashtbl.find_opt ctx.preds a with
  | Some ps -> List.length ps
  | None -> 0

(* Is [a] in the trap-context of at least one enclosing trap in
   [active_traps]? Used to decide whether following an edge keeps us
   inside a Try_region's protected body. *)
let block_has_trap ctx a trap =
  match Hashtbl.find_opt ctx.contexts a with
  | Some ctxs -> List.mem trap ctxs
  | None -> false

(* [build addr ~stop] produces the tree rooted at [addr], descending
   into successors until we reach a block in [stop] (or a terminator,
   or a back-edge). Blocks in [stop] are owned by the caller. *)
let rec build ctx addr ~stop ~active_trap =
  if Hashtbl.mem ctx.visited addr || Addr.Set.mem addr stop
  then
    (* Shouldn't be called on a stopped block — the caller checks
       [stop] first. Visited means a back-edge / irreducible merge;
       return an empty Flat so we don't duplicate. *)
    Flat []
  else (
    Hashtbl.add ctx.visited addr ();
    match Addr.Map.find_opt addr ctx.prog.blocks with
    | None -> Flat []
    | Some b ->
      let this_leaf = leaf_of_block addr b in
      (* Leave the current trap region once we cross out of it. *)
      let still_in_trap =
        match active_trap with
        | None -> true
        | Some t -> block_has_trap ctx addr t
      in
      if not still_in_trap
      then (
        (* Unwind: caller's trap region ends; block belongs to the
           enclosing level. Emit as Leaf + successor chain. *)
        Hashtbl.remove ctx.visited addr;
        Flat [])
      else
        match b.branch with
        | Return _ | Raise _ | Stop | Invoke_tail _ ->
          Leaf this_leaf
        | Branch (target, _) ->
          extend_with_successor ctx this_leaf target ~stop ~active_trap
        | Cond (v, (t, _), (f, _)) ->
          build_if ctx this_leaf v t f ~stop ~active_trap
        | Switch (v, ints, tags) ->
          build_switch ctx this_leaf v ints tags ~stop ~active_trap
        | Pushtrap ((body_addr, _), exn_var, (handler_addr, _)) ->
          build_try ctx this_leaf ~body_addr ~exn_var ~handler_addr ~stop ~active_trap
        | Poptrap (target, _) ->
          (* A Poptrap ends the active trap region. A caller is at
             the enclosing level — caller stitches it. *)
          extend_with_successor ctx this_leaf target ~stop ~active_trap)

and extend_with_successor ctx this_leaf target ~stop ~active_trap =
  if Addr.Set.mem target stop
  then Leaf this_leaf
  else if Hashtbl.mem ctx.visited target
  then
    (* Back-edge or re-visit. Don't recurse, let the enclosing
       structural node (typically a Loop) pick it up. *)
    Leaf this_leaf
  else if num_preds ctx target > 1
  then
    (* Merge point: target has multiple predecessors, so it's a join
       owned by a common ancestor. Don't chain here. *)
    Leaf this_leaf
  else
    let rest = build ctx target ~stop ~active_trap in
    match rest with
    | Flat [] -> Leaf this_leaf
    | _ -> Seq [ Leaf this_leaf; rest ]

and build_if ctx cond_leaf _v t_addr f_addr ~stop ~active_trap =
  (* Find join: the nearest block dominated by cond_leaf that's
     reached via both branches. If we can't find a clean join we
     fall back to Flat. *)
  let cond_addr = cond_leaf.entry_addr in
  let join_opt =
    find_if_join ctx ~cond:cond_addr ~t_addr ~f_addr
  in
  let branch_stop =
    match join_opt with
    | Some j -> Addr.Set.add j stop
    | None -> stop
  in
  let t_branch = build_subtree ctx t_addr ~stop:branch_stop ~active_trap in
  let f_branch = build_subtree ctx f_addr ~stop:branch_stop ~active_trap in
  let join =
    match join_opt with
    | Some j when not (Hashtbl.mem ctx.visited j) ->
      Some (build ctx j ~stop ~active_trap)
    | _ -> None
  in
  If { cond_leaf; t_branch; f_branch; join }

and build_switch ctx scrut_leaf _v ints tags ~stop ~active_trap =
  (* Switches are harder to recognise cleanly (many cases, often no
     shared join). For now fall back to Flat with the scrutinee leaf
     and each case as a separate subtree. *)
  let build_case (addr, _) =
    build_subtree ctx addr ~stop ~active_trap
  in
  let int_cases = Array.map build_case ints in
  let tag_cases = Array.map build_case tags in
  Switch { scrut_leaf; int_cases; tag_cases; join = None }

and build_try ctx pushtrap_leaf ~body_addr ~exn_var ~handler_addr ~stop ~active_trap =
  let trap_addr = pushtrap_leaf.entry_addr in
  let poptraps =
    try Hashtbl.find ctx.poptraps_of trap_addr
    with Not_found -> Addr.Set.empty
  in
  let protected =
    build_subtree
      ctx
      body_addr
      ~stop
      ~active_trap:(Some trap_addr)
  in
  (* Handler lives at the enclosing trap's level; caller stitches. *)
  let _ = handler_addr in
  let _ = active_trap in
  Try_region
    { pushtrap = pushtrap_leaf
    ; exn_var
    ; handler_addr
    ; poptraps
    ; protected
    }

(* Kick off a subtree build from a branch target. Handles the case
   where a caller is already visited (no-op) or in [stop] (empty). *)
and build_subtree ctx addr ~stop ~active_trap =
  if Addr.Set.mem addr stop || Hashtbl.mem ctx.visited addr
  then Flat []
  else
    match Addr.Map.find_opt addr ctx.prog.blocks with
    | None -> Flat []
    | Some _ -> build ctx addr ~stop ~active_trap

(* Simple if-join detection: walk reachable sets from [t_addr] and
   [f_addr] (without revisiting) and pick the lowest-postorder block
   common to both that's dominated by [cond]. Returns [None] if no
   such block (branches don't reconverge). *)
and find_if_join ctx ~cond ~t_addr ~f_addr =
  let reach start =
    let seen = Hashtbl.create 8 in
    let rec dfs a =
      if not (Hashtbl.mem seen a)
      then (
        Hashtbl.add seen a ();
        match Addr.Map.find_opt a ctx.prog.blocks with
        | None -> ()
        | Some b ->
          List.iter
            (fun s ->
              if Addr.Map.mem s ctx.prog.blocks then dfs s)
            (successors_of b))
    in
    dfs start;
    seen
  in
  let rt = reach t_addr in
  let rf = reach f_addr in
  let candidates = ref [] in
  Hashtbl.iter
    (fun a () ->
      if Hashtbl.mem rf a && dominates ctx.idom cond a && a <> cond
      then candidates := a :: !candidates)
    rt;
  (* Pick the candidate that every other candidate reaches — the
     earliest post-dominator from the cond's perspective. Simple
     heuristic: pick the one with FEWEST predecessors among the set,
     breaking ties by addr (for determinism). *)
  match !candidates with
  | [] -> None
  | xs ->
    Some
      (List.fold_left
         (fun best a ->
           if num_preds ctx a < num_preds ctx best
              || (num_preds ctx a = num_preds ctx best && a < best)
           then a
           else best)
         (List.hd xs)
         (List.tl xs))

let of_program (prog : program) : t =
  let contexts = Code.compute_trap_contexts prog in
  let preds = compute_predecessors prog in
  let rpo = reverse_postorder prog in
  let idom = compute_idoms prog ~rpo ~preds in
  let poptraps_of = poptraps_per_trap contexts prog in
  let by_innermost = group_by_innermost contexts prog in
  let visited = Hashtbl.create 16 in
  let ctx = { prog; preds; idom; contexts; poptraps_of; visited } in
  (* Build from start; then sweep any unvisited blocks (dead code,
     handlers that weren't stitched) into a top-level Flat. *)
  let main = build ctx prog.start ~stop:Addr.Set.empty ~active_trap:None in
  let stragglers =
    Addr.Map.fold
      (fun a b acc ->
        if Hashtbl.mem visited a
        then acc
        else (
          Hashtbl.add visited a ();
          Leaf (leaf_of_block a b) :: acc))
      prog.blocks
      []
  in
  let _ = by_innermost in
  let root =
    match stragglers with
    | [] -> main
    | _ -> Flat (main :: stragglers)
  in
  { start = prog.start; free_pc = prog.free_pc; root }

(* --- Leaf iteration / trap regions / round-trip --- *)

let rec iter_leaves node f =
  match node with
  | Leaf l -> f l
  | Flat ns | Seq ns -> List.iter (fun n -> iter_leaves n f) ns
  | If { cond_leaf; t_branch; f_branch; join } ->
    f cond_leaf;
    iter_leaves t_branch f;
    iter_leaves f_branch f;
    Option.iter (fun j -> iter_leaves j f) join
  | Switch { scrut_leaf; int_cases; tag_cases; join } ->
    f scrut_leaf;
    Array.iter (fun n -> iter_leaves n f) int_cases;
    Array.iter (fun n -> iter_leaves n f) tag_cases;
    Option.iter (fun j -> iter_leaves j f) join
  | Loop { header_leaf; body } ->
    f header_leaf;
    iter_leaves body f
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

type kind_counts =
  { leaves : int
  ; flats : int
  ; seqs : int
  ; ifs : int
  ; switches : int
  ; loops : int
  ; trys : int
  ; stragglers : int
  }

let summarise (t : t) : kind_counts =
  let c =
    { leaves = 0
    ; flats = 0
    ; seqs = 0
    ; ifs = 0
    ; switches = 0
    ; loops = 0
    ; trys = 0
    ; stragglers = 0
    }
  in
  let c = ref c in
  let bump_leaves () = c := { !c with leaves = (!c).leaves + 1 } in
  let rec walk = function
    | Leaf _ -> bump_leaves ()
    | Flat ns ->
      c := { !c with flats = (!c).flats + 1 };
      List.iter walk ns
    | Seq ns ->
      c := { !c with seqs = (!c).seqs + 1 };
      List.iter walk ns
    | If { cond_leaf = _; t_branch; f_branch; join } ->
      c := { !c with ifs = (!c).ifs + 1 };
      bump_leaves ();
      walk t_branch;
      walk f_branch;
      Option.iter walk join
    | Switch { scrut_leaf = _; int_cases; tag_cases; join } ->
      c := { !c with switches = (!c).switches + 1 };
      bump_leaves ();
      Array.iter walk int_cases;
      Array.iter walk tag_cases;
      Option.iter walk join
    | Loop { header_leaf = _; body } ->
      c := { !c with loops = (!c).loops + 1 };
      bump_leaves ();
      walk body
    | Try_region { pushtrap = _; protected; _ } ->
      c := { !c with trys = (!c).trys + 1 };
      bump_leaves ();
      walk protected
  in
  (* Count top-level Flat children past the first as stragglers. *)
  (match t.root with
   | Flat (_ :: rest) ->
     c := { !c with stragglers = List.length rest }
   | _ -> ());
  walk t.root;
  !c

let trap_regions (t : t) =
  let acc = ref [] in
  let rec walk = function
    | Leaf _ -> ()
    | Flat ns | Seq ns -> List.iter walk ns
    | If { t_branch; f_branch; join; _ } ->
      walk t_branch;
      walk f_branch;
      Option.iter walk join
    | Switch { int_cases; tag_cases; join; _ } ->
      Array.iter walk int_cases;
      Array.iter walk tag_cases;
      Option.iter walk join
    | Loop { body; _ } -> walk body
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
