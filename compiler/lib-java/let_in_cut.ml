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
      match Hashtbl.find_opt idom c with
      | None -> false  (* [c] unreachable from start: doesn't appear in idom *)
      | Some parent ->
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

(* [body_has_function_exit]: true if any block in [body_blocks] has
   a terminator that exits the outer function (Return / Raise /
   Stop / Invoke_tail). Those are inadmissible in a Let_in body —
   the helper would consume the exit and never return to the
   caller, changing semantics. *)
let body_has_function_exit prog body_blocks =
  Addr.Set.exists
    (fun a ->
      match Addr.Map.find_opt a prog.blocks with
      | None -> false
      | Some b ->
        (match b.branch with
         | Return _ | Raise _ | Stop | Invoke_tail _ -> true
         | _ -> false))
    body_blocks

(* Reject bodies whose [Pushtrap] handler edge or [Poptrap] target
   leaves the body via [join_block]. Rewriting such an edge to a
   [Return] stub doesn't preserve the exception-table semantics
   (the handler entry needs to absorb the operand-stack exception
   into [exn_var], not return it). Pushtraps fully internal to the
   body are fine — they emit their own exception table inside the
   helper. *)
let body_trap_to_join_unsafe prog body_blocks ~join_block =
  Addr.Set.exists
    (fun a ->
      match Addr.Map.find_opt a prog.blocks with
      | None -> false
      | Some b ->
        (match b.branch with
         | Pushtrap ((bt, _), _, (ht, _)) ->
           bt = join_block || ht = join_block
         | Poptrap (t, _) -> t = join_block
         | _ -> false))
    body_blocks

(* [body_trap_self_contained]: any [Pushtrap] / [Poptrap] inside
   [body_blocks] must pair with a counterpart also inside body.
   Checked via the per-block trap-context map: a block's context
   is the stack of active Pushtraps at its entry. [body_entry]'s
   context is what the body inherits from the caller. Any block
   inside body must have a context that *extends* body_entry's —
   if a body block's context is shorter than body_entry's, then
   some Poptrap between them popped a trap pushed outside body
   (leaks out), and emitting the helper would orphan that
   Pushtrap. Symmetrically a body block whose context is missing
   any trap from body_entry's prefix is also a leak. *)
let body_trap_self_contained contexts body_entry body_blocks =
  let entry_ctx =
    match Hashtbl.find_opt contexts body_entry with
    | Some c -> c
    | None -> []
  in
  let entry_depth = List.length entry_ctx in
  Addr.Set.for_all
    (fun a ->
      match Hashtbl.find_opt contexts a with
      | None -> true
      | Some ctx ->
        let depth = List.length ctx in
        if depth < entry_depth
        then false  (* popped something we didn't push *)
        else (
          (* Suffix of [ctx] of length [entry_depth] must equal
             [entry_ctx] — body must keep all inherited traps
             active. *)
          let rec drop n l =
            if n = 0 then l else drop (n - 1) (List.tl l)
          in
          drop (depth - entry_depth) ctx = entry_ctx))
    body_blocks

let candidates_for_join prog ~preds ~idom ~contexts ~join_addr (j : block) =
  match j.params with
  | [ result_param ] ->
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
              (* Apply currently only handles [Branch] callers —
                 the head rewrite splices [Let (v', Invoke_helper
                 ...)] + [Branch (join, [v'])] in place of the
                 original branch. Cond / Switch callers would need
                 a stub block on the matching arm to keep the
                 other arms unchanged; not implemented yet. *)
              let caller_ok =
                match Addr.Map.find_opt caller prog.blocks with
                | None -> false
                | Some cb ->
                  (match cb.branch with
                   | Branch (t, _) -> t = body_entry
                   | _ -> false)
              in
              if not caller_ok then [] else
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
              let no_function_exit =
                not (body_has_function_exit prog !body_blocks)
              in
              let trap_ok =
                body_trap_self_contained contexts body_entry !body_blocks
                && not
                     (body_trap_to_join_unsafe
                        prog
                        !body_blocks
                        ~join_block:join_addr)
              in
              if ok && no_external_entry && no_function_exit && trap_ok
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
  | _ ->
    (* Require exactly one param — single-result join. Multi-param
       joins (e.g. match arms carrying several values at once) are
       out of scope for the first pass; extraction requires
       rewriting terminators to return one value. *)
    []

let enumerate (prog : program) : candidate list =
  let preds = compute_predecessors prog in
  let rpo = reverse_postorder prog in
  let idom = compute_idoms prog ~rpo ~preds in
  let contexts = Code.compute_trap_contexts prog in
  Addr.Map.fold
    (fun addr b acc ->
      candidates_for_join
        prog
        ~preds
        ~idom
        ~contexts
        ~join_addr:addr
        b
      @ acc)
    prog.blocks
    []

(* --- Cut application --------------------------------------------- *)

type applied =
  { helper_entry_params : Var.t list
  ; helper_prog : program
  ; head_prog : program
  ; forwarded_args : Var.t list
  }

(* Live-in at [body_entry]: vars referenced inside [body_blocks] but
   not defined there. Excludes [body_entry]'s own params (those are
   supplied by the caller's original branch to body_entry) and
   keeps only vars that will actually cross the extraction
   boundary. *)
let live_in_at_body ~body_blocks ~body_entry_params prog =
  let used = ref Var.Set.empty in
  let defined =
    List.fold_left
      (fun s v -> Var.Set.add v s)
      Var.Set.empty
      body_entry_params
  in
  let defined = ref defined in
  Addr.Set.iter
    (fun a ->
      match Addr.Map.find_opt a prog.blocks with
      | None -> ()
      | Some (b : block) ->
        List.iter (fun v -> defined := Var.Set.add v !defined) b.params;
        Array.iter
          (fun i ->
            used := Var.Set.union !used (Var_refs.fv_instr i);
            defined :=
              Var.Set.union !defined (Var_refs.defs_of_instr i))
          b.body;
        used := Var.Set.union !used (Var_refs.fv_last b.branch))
    body_blocks;
  Var.Set.diff !used !defined

(* Build the helper program from [body_blocks] with edges to
   [join_block] rewritten to [Return] of the single result arg. *)
let build_helper_prog
    (prog : program)
    (c : candidate)
    ~forwarded_args
    ~free_pc_start =
  let free_pc = ref free_pc_start in
  let fresh_return_stub result_arg =
    let addr = !free_pc in
    incr free_pc;
    addr,
    { params = []
    ; body = [||]
    ; branch = Return result_arg
    }
  in
  let extra_blocks = ref [] in
  let rewrite_cont ((target, args) as c') =
    if target <> c.join_block then c'
    else (
      match args with
      | [ result_arg ] ->
        let addr, blk = fresh_return_stub result_arg in
        extra_blocks := (addr, blk) :: !extra_blocks;
        (addr, [])
      | _ ->
        (* enumeration validated [result_param] as the single param,
           and every edge must supply it. *)
        failwith "Let_in_cut.apply: join edge has !=1 args")
  in
  let rewrite_last = function
    | Return _ | Raise _ | Stop | Invoke_tail _ ->
      (* Should not occur — enumerator rejects bodies with these. *)
      failwith "Let_in_cut.apply: body has function-exit terminator"
    | Branch (target, args) when target = c.join_block ->
      (match args with
       | [ result_arg ] -> Return result_arg
       | _ ->
         failwith "Let_in_cut.apply: direct branch to join with !=1 args")
    | Branch cont -> Branch cont
    | Cond (v, c1, c2) -> Cond (v, rewrite_cont c1, rewrite_cont c2)
    | Switch (v, ints, tags) ->
      Switch
        ( v
        , Array.map rewrite_cont ints
        , Array.map rewrite_cont tags )
    | Pushtrap (body, exn_var, handler) ->
      Pushtrap (rewrite_cont body, exn_var, rewrite_cont handler)
    | Poptrap cont -> Poptrap (rewrite_cont cont)
  in
  let entry_block =
    match Addr.Map.find_opt c.body_entry prog.blocks with
    | Some b -> b
    | None ->
      failwith "Let_in_cut.apply: body_entry not in program"
  in
  let helper_entry_params =
    entry_block.params @ forwarded_args
  in
  let rewritten =
    Addr.Set.fold
      (fun a acc ->
        match Addr.Map.find_opt a prog.blocks with
        | None -> acc
        | Some b ->
          let b' =
            if a = c.body_entry
            then
              { b with
                params = helper_entry_params
              ; branch = rewrite_last b.branch
              }
            else { b with branch = rewrite_last b.branch }
          in
          Addr.Map.add a b' acc)
      c.body_blocks
      Addr.Map.empty
  in
  let blocks =
    List.fold_left
      (fun m (a, b) -> Addr.Map.add a b m)
      rewritten
      !extra_blocks
  in
  { start = c.body_entry
  ; blocks
  ; free_pc = !free_pc
  }

(* Build the head program: remove [body_blocks], rewrite caller's
   terminator, leave [join_block] otherwise alone (its params
   remain — the new Branch from the caller supplies the result). *)
let build_head_prog
    (prog : program)
    (c : candidate)
    ~forwarded_args
    ~class_
    ~method_
    ~descriptor
    ~is_static =
  (* Caller's original branch is Branch(body_entry, entry_args).
     We need entry_args (matching body_entry's param list) to pass
     to the helper call. *)
  let caller_block =
    match Addr.Map.find_opt c.caller prog.blocks with
    | Some b -> b
    | None -> failwith "Let_in_cut.apply: caller not in program"
  in
  let entry_args =
    match caller_block.branch with
    | Branch (target, args) when target = c.body_entry -> args
    | _ ->
      failwith
        "Let_in_cut.apply: caller terminator must be Branch (filter \
         in [enumerate] should reject otherwise)"
  in
  let v' = Var.fresh_n "let_in_result" in
  let helper_args = entry_args @ forwarded_args in
  let new_instr =
    Let
      ( v'
      , Invoke_helper
          { class_; method_; descriptor; args = helper_args; is_static }
      )
  in
  let new_caller_block =
    { caller_block with
      body = Array.append caller_block.body [| new_instr |]
    ; branch = Branch (c.join_block, [ v' ])
    }
  in
  let blocks =
    prog.blocks
    |> Addr.Set.fold Addr.Map.remove c.body_blocks
    |> Addr.Map.add c.caller new_caller_block
  in
  { prog with blocks }

let apply prog (c : candidate) ~class_ ~method_ ~descriptor ~is_static =
  let entry_block =
    match Addr.Map.find_opt c.body_entry prog.blocks with
    | Some b -> b
    | None -> failwith "Let_in_cut.apply: body_entry not in program"
  in
  let live_in =
    live_in_at_body
      ~body_blocks:c.body_blocks
      ~body_entry_params:entry_block.params
      prog
  in
  let forwarded_args = Var.Set.elements live_in in
  let helper_prog =
    build_helper_prog prog c ~forwarded_args ~free_pc_start:prog.free_pc
  in
  let head_prog =
    build_head_prog
      prog
      c
      ~forwarded_args
      ~class_
      ~method_
      ~descriptor
      ~is_static
  in
  let head_prog =
    { head_prog with free_pc = max head_prog.free_pc helper_prog.free_pc }
  in
  let helper_entry_params = entry_block.params @ forwarded_args in
  { helper_entry_params
  ; helper_prog
  ; head_prog
  ; forwarded_args
  }

