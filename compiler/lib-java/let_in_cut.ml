open Code

type candidate =
  { join_block : Addr.t
  ; result_param : Var.t
  ; body_entry : Addr.t
  ; body_blocks : Addr.Set.t
  ; caller : Addr.t
  ; cost : int
  }

(* --- Successor enumeration + predecessor map --- *)

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

(* --- Dominator tree (Cooper-Harvey-Kennedy) ---

   Smaller-scope duplicate of the routine in [Split_tree]; we avoid
   depending on [Split_tree] directly so this module stays
   structurally independent (and so the splitter can call us
   without a cache coupling). *)

let reverse_postorder (prog : program) =
  let visited = Hashtbl.create 16 in
  let rpo = ref [] in
  let rec dfs a =
    if not (Hashtbl.mem visited a)
    then (
      Hashtbl.add visited a ();
      match Addr.Map.find_opt a prog.blocks with
      | None -> rpo := a :: !rpo
      | Some b ->
        List.iter
          (fun s -> if Addr.Map.mem s prog.blocks then dfs s)
          (successors_of b);
        rpo := a :: !rpo)
  in
  dfs prog.start;
  !rpo

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

let dominates idom a b =
  if a = b
  then true
  else
    let rec walk c =
      let parent = Hashtbl.find idom c in
      if parent = c then false
      else if parent = a then true
      else walk parent
    in
    walk b

(* [nearest_common_dominator idom xs]: walk all pairs upward until
   converging. O(|xs| * depth). *)
let nearest_common_dominator idom = function
  | [] -> None
  | first :: rest ->
    let po = postorder_numbers in
    ignore po;
    let meet a b =
      (* Walk both up until equal. Using Cooper's intersect without
         postorder numbers: climb the lower-depth finger; we don't
         have depths here so we just alternate. Works for reducible
         CFGs — both fingers eventually reach the common ancestor. *)
      let visited_a = Hashtbl.create 8 in
      let visited_b = Hashtbl.create 8 in
      let rec walk a b =
        if a = b then a
        else (
          Hashtbl.add visited_a a ();
          Hashtbl.add visited_b b ();
          let a' =
            try Hashtbl.find idom a with Not_found -> a
          in
          let b' =
            try Hashtbl.find idom b with Not_found -> b
          in
          (* If one finger has already visited the other's position,
             return that — it's the meet. *)
          if Hashtbl.mem visited_b a' then a'
          else if Hashtbl.mem visited_a b' then b'
          else walk a' b')
      in
      walk a b
    in
    Some (List.fold_left meet first rest)

(* --- Candidate enumeration ---

   For each join block J with at least one param, try to form a
   candidate:

   1. result_param = J.params.(0).
   2. body_entry = nearest common dominator of J's predecessors
      that's not J itself.
   3. body_blocks = the set of blocks reachable from body_entry that
      are dominated by body_entry but not dominated by J (so not in
      J's subtree) — i.e. the part of the CFG "between" body_entry
      and J.
   4. Validity:
      - body_entry has exactly one predecessor (the caller), that
        predecessor is not in body_blocks.
      - Every edge from body_blocks to outside targets J.
      - Every edge into body_blocks from outside comes from the
        caller and targets body_entry.
      - None of body_blocks is [prog.start] (can't extract the
        entire program).
      - body_blocks doesn't include J.
      - body_blocks is non-empty.
*)

let candidates_for_join prog ~preds ~idom ~join_addr (j : block) =
  match j.params with
  | [] -> []
  | result_param :: _ ->
    let j_preds =
      try Hashtbl.find preds join_addr with Not_found -> []
    in
    if List.length j_preds < 2
    then
      (* Trivial shape (single predecessor) is a plain sequential
         split; [find_cut_toward] handles those. We want match /
         Cond merge points. *)
      []
    else (
      match nearest_common_dominator idom j_preds with
      | None -> []
      | Some body_entry ->
        if body_entry = join_addr
        then []
        else if body_entry = prog.start
        then []
        else (
          (* Collect body_blocks: dominated by body_entry, not
             dominated by join_addr. *)
          let body_blocks = ref Addr.Set.empty in
          Addr.Map.iter
            (fun a _ ->
              if dominates idom body_entry a
                 && (not (dominates idom join_addr a))
                 && a <> join_addr
              then body_blocks := Addr.Set.add a !body_blocks)
            prog.blocks;
          if Addr.Set.is_empty !body_blocks
          then []
          else (
            (* Validate: body_entry has exactly one predecessor
               outside body_blocks. *)
            let entry_preds =
              try Hashtbl.find preds body_entry with Not_found -> []
            in
            let external_entry_preds =
              List.filter
                (fun p -> not (Addr.Set.mem p !body_blocks))
                entry_preds
            in
            match external_entry_preds with
            | [ caller ] ->
              (* Validate: every block in body_blocks has all
                 successors in (body_blocks ∪ {join_addr}). *)
              let ok =
                Addr.Set.for_all
                  (fun a ->
                    match Addr.Map.find_opt a prog.blocks with
                    | None -> true
                    | Some b ->
                      List.for_all
                        (fun s ->
                          s = join_addr
                          || Addr.Set.mem s !body_blocks)
                        (successors_of b))
                  !body_blocks
              in
              (* Validate: no external block (other than caller)
                 has a successor in body_blocks. *)
              let no_external_entry =
                Addr.Map.for_all
                  (fun a b ->
                    if a = caller || Addr.Set.mem a !body_blocks
                    then true
                    else
                      List.for_all
                        (fun s ->
                          not (Addr.Set.mem s !body_blocks))
                        (successors_of b))
                  prog.blocks
              in
              if ok && no_external_entry
              then (
                let cost =
                  Addr.Set.fold
                    (fun a acc ->
                      match Addr.Map.find_opt a prog.blocks with
                      | None -> acc
                      | Some b -> acc + Code_cost.block b)
                    !body_blocks
                    0
                in
                [ { join_block = join_addr
                  ; result_param
                  ; body_entry
                  ; body_blocks = !body_blocks
                  ; caller
                  ; cost
                  }
                ])
              else []
            | _ -> [])))

let enumerate (prog : program) : candidate list =
  let preds = compute_predecessors prog in
  let rpo = reverse_postorder prog in
  let idom = compute_idoms prog ~rpo ~preds in
  Addr.Map.fold
    (fun addr b acc ->
      candidates_for_join prog ~preds ~idom ~join_addr:addr b @ acc)
    prog.blocks
    []
