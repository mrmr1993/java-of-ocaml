open Code

type helper =
  { method_name : string
  ; params : Var.t list
  ; prog : program
  ; descriptor : string
  }

type split_result =
  { head : program
  ; helpers : helper list
  }

type cut =
  { cut_addr : Addr.t
  ; head : Addr.Set.t
  ; tail : Addr.Set.t
  }

(* --- Free-var / def helpers ----------------------------------------- *)

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

let fv_instr = function
  | Let (_, e) -> fv_expr e
  | Set_field (x, _, y) -> Var.Set.add x (Var.Set.singleton y)
  | Offset_ref (x, _) -> Var.Set.singleton x
  | Array_set (a, i, v) ->
    Var.Set.add a (Var.Set.add i (Var.Set.singleton v))
  | Source_pc _ -> Var.Set.empty

let defs_of_instr = function
  | Let (v, _) -> Var.Set.singleton v
  | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> Var.Set.empty

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
       use just because it appears in [handler]'s args. Subtract
       it from the union so cross-block liveness doesn't treat it
       as an input that needs forwarding. *)
    let all = Var.Set.union (fv_cont body) (fv_cont handler) in
    Var.Set.remove exn_var all
  | Poptrap c -> fv_cont c
  | Invoke_tail { args; _ } -> fv_set_of_list args

let defined_in_blocks prog addrs =
  Addr.Set.fold
    (fun a acc ->
      match Addr.Map.find_opt a prog.blocks with
      | None -> acc
      | Some b ->
        let acc =
          List.fold_left (fun s v -> Var.Set.add v s) acc b.params
        in
        Array.fold_left
          (fun s i -> Var.Set.union s (defs_of_instr i))
          acc
          b.body)
    addrs
    Var.Set.empty

let used_in_blocks prog addrs =
  Addr.Set.fold
    (fun a acc ->
      match Addr.Map.find_opt a prog.blocks with
      | None -> acc
      | Some b ->
        let acc =
          Array.fold_left
            (fun s i -> Var.Set.union s (fv_instr i))
            acc
            b.body
        in
        Var.Set.union acc (fv_last b.branch))
    addrs
    Var.Set.empty


(* Vars needing to be forwarded into the helper when cutting at
   [cut.cut_addr]. Under strict SSA, [used_in_tail \
   defined_in_tail] coincides with the classical live-in set at
   [cut_addr], so we compute it directly as a set-diff.

   The [cut]-indexed variant recomputes from scratch each time and
   is O(|tail|) per call. [precompute_live_in] below builds the
   same set for *every* reachable block in one backward-dataflow
   pass, and [find_cut_toward] uses that cache so per-candidate
   work is O(1). *)
let cut_forwarded_vars ~env_var prog (cut : cut) =
  let used = used_in_blocks prog cut.tail in
  let defined = defined_in_blocks prog cut.tail in
  let live = Var.Set.diff used defined in
  match env_var with
  | Some e -> Var.Set.remove e live
  | None -> live

(* --- Graph analysis -------------------------------------------------- *)

(* Edges followed by the emitter. Edges to blocks NOT present in the
   program are filtered — those are cut-point redirections already
   handled in the enclosing scope, and tracking them here would make
   reachability include addresses that aren't real nodes. *)
let successors (prog : program) addr =
  match Addr.Map.find_opt addr prog.blocks with
  | None -> []
  | Some b ->
    let acc = ref [] in
    let step (a, _args) =
      if Addr.Map.mem a prog.blocks then acc := a :: !acc
    in
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

let reachable_avoiding prog ~start ~avoid =
  let visited = ref Addr.Set.empty in
  let rec visit addr =
    if Addr.Set.mem addr !visited
       || (match avoid with
           | Some a -> a = addr
           | None -> false)
    then ()
    else (
      visited := Addr.Set.add addr !visited;
      List.iter visit (successors prog addr))
  in
  visit start;
  !visited

let reachable_from prog ~start =
  reachable_avoiding prog ~start ~avoid:None

let pushtrap_regions (prog : program) =
  let regions = ref [] in
  Addr.Map.iter
    (fun pushtrap_addr (b : block) ->
      match b.branch with
      | Pushtrap ((body_addr, _), _, (handler_addr, _)) ->
        let protected = ref Addr.Set.empty in
        let rec collect addr =
          if Addr.Set.mem addr !protected
          then ()
          else (
            protected := Addr.Set.add addr !protected;
            match Addr.Map.find_opt addr prog.blocks with
            | None -> ()
            | Some b ->
              let step (a, _) = collect a in
              (match b.branch with
               | Return _ | Raise _ | Stop | Poptrap _ | Invoke_tail _ ->
                 ()
               | Branch c -> step c
               | Cond (_, c1, c2) ->
                 step c1;
                 step c2
               | Switch (_, ints, tags) ->
                 Array.iter step ints;
                 Array.iter step tags
               | Pushtrap (b_c, _, _) -> step b_c))
        in
        collect body_addr;
        regions := (pushtrap_addr, handler_addr, !protected) :: !regions
      | _ -> ())
    prog.blocks;
  !regions

(* [cut_respects_trap_regions] and [cut_is_self_contained] used to
   be the set-based trap + disjointness checks inside [try_cut].
   [try_cut_fast]'s predecessor-based validation plus
   [cut_respects_trap_regions_fast] subsume them. Removed. *)


(* Cache per-block cost for the duration of one [find_cut_toward]
   call. Used both for scoring (needs head cost, which is the
   program total minus the tail's accumulated cost) and to avoid
   re-walking each block's body list multiple times. *)
let precompute_block_costs (prog : program) =
  let tbl = Hashtbl.create (Addr.Map.cardinal prog.blocks) in
  Addr.Map.iter
    (fun a b -> Hashtbl.replace tbl a (Code_cost.block b))
    prog.blocks;
  tbl

let debug_split = Debug.find "split"
let debug_split_times = Debug.find "split_times"

(* Per-phase wall-clock counters inside [split], printed at process
   exit when [JAVA_OF_OCAML_DEBUG=split_times]. The structural-cut
   path and the intra-block path each touch many independent helpers
   ([find_end_cut], [find_cut_toward], [intra_split_block_at],
   [build_split_cache], [augment_cut_params], [rewrite_head_cut],
   etc.); knowing which one dominates a given run is what makes a
   fix-iteration loop tractable. *)
module Stat = struct
  let table : (string, float * int) Hashtbl.t = Hashtbl.create 16
  let printed = ref false
  let track name f =
    if not (debug_split_times ())
    then f ()
    else (
      let start = Sys.time () in
      let r = f () in
      let elapsed = Sys.time () -. start in
      let t, c =
        match Hashtbl.find_opt table name with
        | Some p -> p
        | None -> 0.0, 0
      in
      Hashtbl.replace table name (t +. elapsed, c + 1);
      r)
  let () =
    at_exit (fun () ->
      if debug_split_times () && not !printed
      then (
        printed := true;
        let entries =
          Hashtbl.fold (fun k (t, c) acc -> (k, t, c) :: acc) table []
          |> List.sort (fun (_, a, _) (_, b, _) -> compare b a)
        in
        let total =
          List.fold_left (fun acc (_, t, _) -> acc +. t) 0.0 entries
        in
        Format.eprintf "[split_times] total=%.2fs@." total;
        List.iter
          (fun (k, t, c) ->
            Format.eprintf
              "[split_times]   %-26s %6.2fs (%d calls)@."
              k
              t
              c)
          entries))
end

(* Predecessor map built once per split_cache. The predecessor of [b]
   is any block whose terminator's successor edges include [b]. We
   only record edges to blocks that are still in [prog.blocks]
   (matching [successors]'s filter). *)
let compute_predecessors (prog : program) =
  let tbl = Hashtbl.create (Addr.Map.cardinal prog.blocks) in
  Addr.Map.iter
    (fun src b ->
      let step (s, _) =
        if Addr.Map.mem s prog.blocks
        then (
          let prev =
            match Hashtbl.find_opt tbl s with Some l -> l | None -> []
          in
          Hashtbl.replace tbl s (src :: prev))
      in
      match b.branch with
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
      | Poptrap c -> step c)
    prog.blocks;
  tbl

(* Trap-region check that works from a [Hashtbl] tail set plus the
   outer [reachable] set (so [head] doesn't need to be materialized
   per candidate — see [try_cut_fast]). Semantically equivalent to
   [cut_respects_trap_regions]: a region must sit entirely in the
   same side as its pushtrap. *)
let cut_respects_trap_regions_fast ~reachable ~tail_tbl regions =
  let in_tail a = Hashtbl.mem tail_tbl a in
  let in_head a = Addr.Set.mem a reachable && not (in_tail a) in
  List.for_all
    (fun (pushtrap_addr, handler_addr, protected) ->
      if in_tail pushtrap_addr
      then
        Addr.Set.for_all in_tail protected && in_tail handler_addr
      else if in_head pushtrap_addr
      then
        Addr.Set.for_all in_head protected && in_head handler_addr
      else true)
    regions

(* O(|tail|) cut validation via predecessor table. [try_cut] with
   the old two-BFS + intersection-test approach was O(|reachable|)
   per candidate with balanced-tree [Addr.Set] ops in tight loops —
   100+ ms per call on sub-programs with a few hundred blocks. This
   version:

   - runs a single BFS from [cut_addr] using a [Hashtbl] (O(1) ops),
   - validates the cut by checking that every reachable predecessor
     of a tail block is either in the tail or is [cut_addr] itself
     (equivalent to the old head/tail-disjointness plus self-
     containment checks combined),
   - defers materializing [head] as an [Addr.Set.t] until the
     winning candidate — [find_end_cut]'s scoring only needs the
     tail cost, which sums directly out of the [Hashtbl].

   Returns [None] / [Some (cut_addr, tail_tbl)] rather than a
   [cut] record so callers can decide when to pay the set-build.
   The final [cut] is assembled only for the one chosen winner. *)
let try_cut_fast ~reachable ~predecessors prog regions ~cut_addr =
  if cut_addr = prog.start
  then None
  else if not (Addr.Map.mem cut_addr prog.blocks)
  then None
  else if not (Addr.Set.mem cut_addr reachable)
  then None
  else (
    let tail_tbl = Hashtbl.create 32 in
    let stack = Stack.create () in
    Hashtbl.add tail_tbl cut_addr ();
    Stack.push cut_addr stack;
    while not (Stack.is_empty stack) do
      let a = Stack.pop stack in
      List.iter
        (fun s ->
          if not (Hashtbl.mem tail_tbl s)
          then (
            Hashtbl.add tail_tbl s ();
            Stack.push s stack))
        (successors prog a)
    done;
    let exception Invalid in
    match
      try
        Hashtbl.iter
          (fun a () ->
            if a <> cut_addr
            then
              let preds =
                match Hashtbl.find_opt predecessors a with
                | Some l -> l
                | None -> []
              in
              List.iter
                (fun p ->
                  if p <> cut_addr
                     && not (Hashtbl.mem tail_tbl p)
                     && Addr.Set.mem p reachable
                  then raise_notrace Invalid)
                preds)
          tail_tbl;
        true
      with Invalid -> false
    with
    | false ->
      if debug_split ()
      then
        Format.eprintf
          "[split]   cut=%d reject: head-reaches-tail@."
          cut_addr;
      None
    | true ->
      if not (cut_respects_trap_regions_fast ~reachable ~tail_tbl regions)
      then (
        if debug_split ()
        then
          Format.eprintf "[split]   cut=%d reject: trap-region@." cut_addr;
        None)
      else Some (cut_addr, tail_tbl))

(* Materializing wrapper around [try_cut_fast]: produces the full
   [cut] record with [head] and [tail] as [Addr.Set.t]. Callers
   outside the hot inner loop of [find_end_cut] use this because
   they need to plug the cut straight into [head_subprogram] /
   [tail_subprogram] / [augment_cut_params]. *)
let try_cut ~reachable ~predecessors prog regions ~cut_addr =
  match try_cut_fast ~reachable ~predecessors prog regions ~cut_addr with
  | None -> None
  | Some (cut_addr, tail_tbl) ->
    let tail =
      Hashtbl.fold (fun a () acc -> Addr.Set.add a acc) tail_tbl Addr.Set.empty
    in
    let head = Addr.Set.diff reachable tail in
    Some { cut_addr; head; tail }

(* Score a cut: primary term balances head cost against [target]
   (halve toward the limit); secondary term penalises the number
   of vars that must be forwarded, since each adds to helper
   descriptor length, call-site byte count, and stack pressure. *)
let score_cut ~block_cost ~forward_size ~target (cut : cut) =
  let head_cost =
    Addr.Set.fold
      (fun a acc ->
        acc + (try Hashtbl.find block_cost a with Not_found -> 0))
      cut.head
      0
  in
  let balance_cost = abs (head_cost - target) in
  let forward_penalty = forward_size * 50 in
  balance_cost + forward_penalty

(* Precomputed tables that stay valid across the split recursion.
   [block_cost], [pushtrap_regions], and [forward_size] are
   invariants of the original program: sub-programs are subsets, and
   the cached live-in at a block B is identical in the sub-program
   (uses inside B are unchanged; successors that live in B's sub-
   program have the same live-in they had in the original;
   successors that were cut off are reached via [Invoke_tail] with
   the exact live-out set as forwarded args, so what flows through
   B is unchanged). Extra entries for addresses not in the current
   sub-program are ignored on lookup.

   [forward_size] stores only the [int] count of vars we'd need to
   forward at a cut placed at each block — the scoring loop reads
   this directly instead of allocating and cardinalling a set per
   candidate. The actual [Var.Set.t] of forwarded vars is cheap to
   compute on demand at the one cut we commit to. *)
type split_cache =
  { cache_block_cost : (Addr.t, int) Hashtbl.t
  ; cache_regions : (Addr.t * Addr.t * Addr.Set.t) list
  ; cache_predecessors : (Addr.t, Addr.t list) Hashtbl.t
  }

let build_split_cache (prog : program) =
  { cache_block_cost = precompute_block_costs prog
  ; cache_regions = pushtrap_regions prog
  ; cache_predecessors = compute_predecessors prog
  }

let find_cut_toward ?env_var ~cache prog ~target =
  let reachable = reachable_from prog ~start:prog.start in
  let best = ref None in
  Addr.Set.iter
    (fun a ->
      match
        try_cut
          ~reachable
          ~predecessors:cache.cache_predecessors
          prog
          cache.cache_regions
          ~cut_addr:a
      with
      | None -> ()
      | Some cut ->
        let forward_size =
          Var.Set.cardinal (cut_forwarded_vars ~env_var prog cut)
        in
        let score =
          score_cut
            ~block_cost:cache.cache_block_cost
            ~forward_size
            ~target
            cut
        in
        (match !best with
         | None -> best := Some (score, cut)
         | Some (s, _) when score < s -> best := Some (score, cut)
         | _ -> ()))
    reachable;
  match !best with
  | None -> None
  | Some (_, cut) -> Some cut

(* Reverse post-order of reachable blocks (exits first). Candidates
   near the front dominate small tails, so when [find_end_cut]
   walks this order it finds a cut whose tail-cost fits under the
   limit early — no need to score every candidate against a balance
   target. *)
(* [find_end_cut] sums tail cost from [try_cut_fast]'s [Hashtbl]
   directly; the previous set-based helper is no longer needed. *)

(* DFS-subtree cost per block: [subtree_cost.(a) = block_cost.(a) +
   sum(subtree_cost of DFS children of a)]. Computed alongside a
   post-order traversal. Reachable-from a block is always a superset
   of its DFS subtree, so [subtree_cost] is a lower bound on
   [tail_cost] — if subtree_cost > limit, the candidate is
   guaranteed out of budget and the expensive [try_cut] can be
   skipped.

   The returned list is in post-order: a block's DFS descendants
   appear before it, so we visit leaves first and the program's
   start node last. That ordering matters for the suffix-chop
   below: leaves have the smallest tails and are the easiest valid
   cuts; we want to find a candidate whose tail cost is close to
   (but ≤) the limit, which lives somewhere between the leaves
   and the start. *)
let postorder_with_subtree_cost ~cache (prog : program) ~start =
  let visited = ref Addr.Set.empty in
  let subtree_cost = Hashtbl.create 64 in
  let order = ref [] in
  let rec visit addr =
    if Addr.Set.mem addr !visited
    then ()
    else (
      visited := Addr.Set.add addr !visited;
      let own =
        try Hashtbl.find cache.cache_block_cost addr with Not_found -> 0
      in
      let children = successors prog addr in
      let child_cost =
        List.fold_left
          (fun acc c ->
            visit c;
            acc
            + (try Hashtbl.find subtree_cost c with Not_found -> 0))
          0
          children
      in
      Hashtbl.replace subtree_cost addr (own + child_cost);
      (* Post-visit append: start ends up at the tail, leaves at the
         head. List.rev at the end gives start-first (not what we
         want); iterate as-is to walk leaves-first. *)
      order := addr :: !order)
  in
  visit start;
  List.rev !order, subtree_cost

(* Pick a cut at "the end" of the program: among candidates whose
   DFS subtree cost fits under [limit] (cheap lower bound on tail
   cost), return the one whose actual tail_cost under [try_cut] is
   the largest but still ≤ limit. This produces helper-sized
   chunks (close to [limit] bytes each) without ever paying the
   per-candidate balanced-score walk. Candidates with subtree_cost
   > limit are skipped without running try_cut.

   Iteration direction: post-order (leaves first). [subtree_cost]
   grows monotonically as we move toward [start], so once we see a
   candidate with subtree_cost > limit along a DFS path, we can
   stop considering it for now — deeper candidates on that path
   have already been checked. *)
let find_end_cut ~cache prog ~limit =
  let reachable = reachable_from prog ~start:prog.start in
  let candidates, subtree_cost =
    postorder_with_subtree_cost ~cache prog ~start:prog.start
  in
  let best = ref None in
  let predecessors = cache.cache_predecessors in
  List.iter
    (fun a ->
      if a = prog.start
      then ()
      else
        let lower =
          try Hashtbl.find subtree_cost a with Not_found -> 0
        in
        (* Cheap filter: a's subtree is a subset of its reachable-
           from set, so tail_cost ≥ subtree_cost. If the lower
           bound already exceeds the limit, skip without try_cut. *)
        if lower > limit
        then ()
        else (
          match
            try_cut_fast
              ~reachable
              ~predecessors
              prog
              cache.cache_regions
              ~cut_addr:a
          with
          | None -> ()
          | Some (_, tail_tbl) ->
            let tail_cost =
              Hashtbl.fold
                (fun a () acc ->
                  acc
                  + (try Hashtbl.find cache.cache_block_cost a
                     with Not_found -> 0))
                tail_tbl
                0
            in
            if tail_cost > 0 && tail_cost <= limit
            then
              match !best with
              | None -> best := Some (tail_cost, a, tail_tbl)
              | Some (c, _, _) when tail_cost > c ->
                best := Some (tail_cost, a, tail_tbl)
              | _ -> ()))
    candidates;
  match !best with
  | None -> None
  | Some (_, cut_addr, tail_tbl) ->
    (* Now materialize the [Addr.Set.t] head/tail for the one
       winning candidate. *)
    let tail =
      Hashtbl.fold (fun a () acc -> Addr.Set.add a acc) tail_tbl Addr.Set.empty
    in
    let head = Addr.Set.diff reachable tail in
    Some { cut_addr; head; tail }

let program_cost ~cache (prog : program) =
  Addr.Map.fold
    (fun a _ acc ->
      acc + (try Hashtbl.find cache.cache_block_cost a with Not_found -> 0))
    prog.blocks
    0
  + Code_cost.entry_overhead prog

let find_cut prog =
  let cache = build_split_cache prog in
  let target = max 1 (program_cost ~cache prog / 2) in
  find_cut_toward ~cache prog ~target

(* --- Sub-program construction -------------------------------------- *)

let restrict (prog : program) keep =
  Addr.Map.filter (fun a _ -> Addr.Set.mem a keep) prog.blocks

let head_subprogram prog cut =
  { prog with blocks = restrict prog cut.head }

let tail_subprogram prog cut =
  { start = cut.cut_addr
  ; blocks = restrict prog cut.tail
  ; free_pc = prog.free_pc
  }

type return_kind =
  | Return_object
  | Return_void

let descriptor_for_params (params : Var.t list) ~return_kind =
  let b = Buffer.create 16 in
  Buffer.add_char b '(';
  List.iter (fun _ -> Buffer.add_string b "Ljava/lang/Object;") params;
  Buffer.add_char b ')';
  (match return_kind with
   | Return_object -> Buffer.add_string b "Ljava/lang/Object;"
   | Return_void -> Buffer.add_char b 'V');
  Buffer.contents b

(* --- Head rewrite: branches to cut_addr → [Invoke_tail] -------------- *)

let rewrite_head_cut
    ~class_name
    ~is_static
    ~cut_addr
    ~helper_name
    ~descriptor
    (head : program)
  =
  let free_pc = ref head.free_pc in
  let extra_blocks = ref Addr.Map.empty in
  let make_stub args =
    let addr = !free_pc in
    incr free_pc;
    let blk =
      { params = []
      ; body = [||]
      ; branch =
          Invoke_tail
            { class_ = class_name
            ; method_ = helper_name
            ; descriptor
            ; args
            ; is_static
            }
      }
    in
    extra_blocks := Addr.Map.add addr blk !extra_blocks;
    addr
  in
  let rewrite_cont ((a, args) as c) =
    if a = cut_addr then make_stub args, [] else c
  in
  let rewrite_branch = function
    | Branch (a, args) when a = cut_addr ->
      Invoke_tail
        { class_ = class_name
        ; method_ = helper_name
        ; descriptor
        ; args
        ; is_static
        }
    | Branch c -> Branch c
    | Cond (v, c1, c2) -> Cond (v, rewrite_cont c1, rewrite_cont c2)
    | Switch (v, ints, tags) ->
      Switch (v, Array.map rewrite_cont ints, Array.map rewrite_cont tags)
    | Pushtrap (body, x, handler) ->
      Pushtrap (rewrite_cont body, x, rewrite_cont handler)
    | Poptrap (a, args) when a = cut_addr ->
      let stub = make_stub args in
      Poptrap (stub, [])
    | Poptrap c -> Poptrap c
    | (Return _ | Raise _ | Stop | Invoke_tail _) as b -> b
  in
  let rewritten =
    Addr.Map.map (fun b -> { b with branch = rewrite_branch b.branch }) head.blocks
  in
  let blocks =
    Addr.Map.fold Addr.Map.add !extra_blocks rewritten
  in
  { head with blocks; free_pc = !free_pc }

(* --- Intra-block splitting ------------------------------------------ *)

let live_in_at_arr ~body ~lo ~hi ~branch =
  let used = ref (fv_last branch) in
  for k = hi - 1 downto lo do
    let i = body.(k) in
    used := Var.Set.diff !used (defs_of_instr i);
    used := Var.Set.union !used (fv_instr i)
  done;
  !used

let pick_split_index ~target body =
  let n = Array.length body in
  if n < 2
  then None
  else (
    let acc = ref 0 in
    let chosen = ref None in
    let i = ref 0 in
    while !chosen = None && !i < n do
      if !acc >= target && !i >= 1 && !i <= n - 1 then chosen := Some !i
      else (
        acc := !acc + Code_cost.instr body.(!i);
        incr i)
    done;
    match !chosen with
    | Some _ as r -> r
    | None when n >= 2 -> Some (n / 2)
    | None -> None)

(* Split [addr]'s block body at the cost midpoint. The original block
   retains its addr and params; its body becomes the prefix and its
   terminator becomes [Branch (fresh_addr, live_out)]. A fresh block
   at [fresh_addr] has [params = live_out], the suffix body, and the
   original terminator. Returns [None] if no productive split is
   possible (fewer than 2 instructions in the body). *)
let split_block_at prog ~addr ~target =
  match Addr.Map.find_opt addr prog.blocks with
  | None -> None
  | Some b ->
    (match pick_split_index ~target b.body with
     | None -> None
     | Some k ->
       let n = Array.length b.body in
       let prefix = Array.sub b.body 0 k in
       let suffix = Array.sub b.body k (n - k) in
       let live =
         live_in_at_arr ~body:b.body ~lo:k ~hi:n ~branch:b.branch
       in
       let live_list = Var.Set.elements live in
       let fresh_addr = prog.free_pc in
       let suffix_block =
         { params = live_list; body = suffix; branch = b.branch }
       in
       let new_first_block =
         { params = b.params
         ; body = prefix
         ; branch = Branch (fresh_addr, live_list)
         }
       in
       let blocks =
         prog.blocks
         |> Addr.Map.add addr new_first_block
         |> Addr.Map.add fresh_addr suffix_block
       in
       Some ({ prog with blocks; free_pc = fresh_addr + 1 }, [ fresh_addr ]))

(* Multi-chunk intra-block splitter.

   Walks [addr]'s body once to build three arrays indexed by gap
   positions [0..n]:
   - [cost_from_end.(k)] = cost of body[k..n-1] + original terminator
   - [live_count.(k)]    = number of vars live across gap k
                           (i.e. live-in to body[k..])

   Then a greedy backward sweep picks cut positions by repeatedly
   selecting the gap with the largest [cost_from_end.(k)] satisfying
   [cost_from_end.(k) + 50 * live_count.(k) <= B], where [B] starts
   at [limit] and is updated after each cut so the precomputed
   [cost_from_end] entries stay directly comparable:

     B := B + cost_from_end.(bk) - 50 * live_count.(bk)

   The first term cancels the double-counted tail-cost component now
   sitting in helper land; the second discounts the per-var cost the
   head must pay to forward [live_count.(bk)] vars at the new edge.
   This avoids any per-step subtraction over [cost_from_end].

   Live [Var.Set.t] values at the chosen cut positions are
   reconstructed in one extra backward pass, not stored during the
   scan.

   Returns [None] when the block is too small to split or when no
   gap satisfies the budget. *)
let intra_split_block_at ~limit prog ~addr =
  match Addr.Map.find_opt addr prog.blocks with
  | None -> None
  | Some b ->
    let body_arr = b.body in
    let n = Array.length body_arr in
    if n < 2
    then None
    else (
      let term_cost = Code_cost.last b.branch in
      let cost_from_end = Array.make (n + 1) 0 in
      cost_from_end.(n) <- term_cost;
      for k = n - 1 downto 0 do
        cost_from_end.(k) <-
          Code_cost.instr body_arr.(k) + cost_from_end.(k + 1)
      done;
      let live_count = Array.make (n + 1) 0 in
      let live = ref (fv_last b.branch) in
      live_count.(n) <- Var.Set.cardinal !live;
      for k = n - 1 downto 0 do
        let i = body_arr.(k) in
        live := Var.Set.diff !live (defs_of_instr i);
        live := Var.Set.union !live (fv_instr i);
        live_count.(k) <- Var.Set.cardinal !live
      done;
      let b_eff = ref limit in
      let cut_pos = ref n in
      let cuts = ref [] in
      let keep_going = ref true in
      while !keep_going do
        let best = ref None in
        let k = ref (!cut_pos - 1) in
        let stop = ref false in
        while not !stop && !k >= 1 do
          if cost_from_end.(!k) > !b_eff
          then stop := true
          else (
            if cost_from_end.(!k) + (50 * live_count.(!k)) <= !b_eff
            then (
              match !best with
              | None -> best := Some !k
              | Some b' ->
                if cost_from_end.(!k) > cost_from_end.(b')
                then best := Some !k);
            decr k)
        done;
        match !best with
        | None -> keep_going := false
        | Some bk ->
          cuts := bk :: !cuts;
          b_eff := !b_eff + cost_from_end.(bk) - (50 * live_count.(bk));
          cut_pos := bk
      done;
      let cuts_arr = Array.of_list !cuts in
      let m = Array.length cuts_arr in
      if m = 0
      then None
      else (
        let live_at = Array.make m Var.Set.empty in
        let live = ref (fv_last b.branch) in
        let next_idx = ref (m - 1) in
        for k = n - 1 downto 0 do
          let i = body_arr.(k) in
          live := Var.Set.diff !live (defs_of_instr i);
          live := Var.Set.union !live (fv_instr i);
          if !next_idx >= 0 && cuts_arr.(!next_idx) = k
          then (
            live_at.(!next_idx) <- !live;
            decr next_idx)
        done;
        let live_lists = Array.map Var.Set.elements live_at in
        let fresh_addrs = Array.init m (fun i -> prog.free_pc + i) in
        let chunk_body i =
          let lo = if i = 0 then 0 else cuts_arr.(i - 1) in
          let hi = if i = m then n else cuts_arr.(i) in
          Array.sub body_arr lo (hi - lo)
        in
        let chunk_params i =
          if i = 0 then b.params else live_lists.(i - 1)
        in
        let chunk_branch i =
          if i = m then b.branch else Branch (fresh_addrs.(i), live_lists.(i))
        in
        let blocks = ref prog.blocks in
        blocks :=
          Addr.Map.add
            addr
            { params = chunk_params 0
            ; body = chunk_body 0
            ; branch = chunk_branch 0
            }
            !blocks;
        for i = 1 to m do
          blocks :=
            Addr.Map.add
              fresh_addrs.(i - 1)
              { params = chunk_params i
              ; body = chunk_body i
              ; branch = chunk_branch i
              }
              !blocks
        done;
        Some
          ( { prog with blocks = !blocks; free_pc = prog.free_pc + m }
          , Array.to_list fresh_addrs )))

(* --- Top-level split pipeline --------------------------------------- *)

(* Thread the [forwarded] vars through as extra params of
   [cut.cut_addr], and as extra args on every branch to
   [cut.cut_addr] in the program. Live-vars analysis guarantees the
   forwarded vars are defined at every predecessor, so extending
   the branch args is always well-formed. *)
let augment_cut_params prog (cut : cut) forwarded =
  if Var.Set.is_empty forwarded
  then prog
  else (
    let extra_list = Var.Set.elements forwarded in
    let update_cont ((a, args) as c) =
      if a = cut.cut_addr then a, args @ extra_list else c
    in
    let update_branch = function
      | Branch c -> Branch (update_cont c)
      | Cond (v, c1, c2) -> Cond (v, update_cont c1, update_cont c2)
      | Switch (v, ints, tags) ->
        Switch (v, Array.map update_cont ints, Array.map update_cont tags)
      | Pushtrap (body, x, handler) ->
        Pushtrap (update_cont body, x, update_cont handler)
      | Poptrap c -> Poptrap (update_cont c)
      | (Return _ | Raise _ | Stop | Invoke_tail _) as b -> b
    in
    let cut_block = Addr.Map.find cut.cut_addr prog.blocks in
    let new_cut_block =
      { cut_block with
        params = cut_block.params @ extra_list
      ; branch = update_branch cut_block.branch
      }
    in
    let blocks =
      Addr.Map.mapi
        (fun a b ->
          if a = cut.cut_addr
          then new_cut_block
          else { b with branch = update_branch b.branch })
        prog.blocks
    in
    { prog with blocks })

let trace fmt =
  if debug_split ()
  then Format.kasprintf (fun s -> prerr_endline ("[split] " ^ s)) fmt
  else Format.ikfprintf (fun _ -> ()) Format.std_formatter fmt

(* Drive the multi-chunk intra-block splitter until no single block
   exceeds [limit]. Structural cuts can only redistribute whole
   blocks, so they cannot fix an oversized block — running them
   first wastes the per-iteration [find_end_cut] CFG walk. Doing
   intra-splitting up front means the structural pass that follows
   sees only block-sized helpers and can cut between them at will.

   Falls back to the single-midpoint [split_block_at] when the
   multi-chunk variant finds no productive cut (e.g. a single
   pathologically large instruction). When neither makes progress,
   stops to avoid an infinite loop; the structural pass then
   shoulders whatever it can. *)
let drive_intrasplit ~limit prog =
  let acc_addrs = ref [] in
  let rec loop p =
    match Code_cost.heaviest_block p with
    | Some (addr, c) when c > limit ->
      let n_before = Addr.Map.cardinal p.blocks in
      let p' =
        match Stat.track "intra_split_block_at" (fun () ->
          intra_split_block_at ~limit p ~addr) with
        | Some (p', addrs) ->
          acc_addrs := List.rev_append addrs !acc_addrs;
          p'
        | None ->
          (match Stat.track "split_block_at" (fun () ->
            split_block_at p ~addr ~target:(limit / 2)) with
           | Some (p', addrs) ->
             acc_addrs := List.rev_append addrs !acc_addrs;
             p'
           | None -> p)
      in
      if Addr.Map.cardinal p'.blocks > n_before then loop p' else p'
    | _ -> p
  in
  let prog' = Stat.track "drive_intrasplit" (fun () -> loop prog) in
  (* [acc_addrs] is reverse-of-creation order; later (deeper) chunks
     come first, which is exactly the order we want to peel them as
     helper tails — smallest tail off the end first. *)
  prog', !acc_addrs

(* Consume the next valid known cut from [queue] (deepest-first). A
   known cut is an address that intra-splitting created as a fresh
   chain link: by construction it has exactly one predecessor (the
   prior chunk's [Branch]), so the head/tail partition is trivially
   disjoint and self-contained — [try_cut] only re-checks
   trap-region coherence. The first one that passes is returned;
   addresses no longer in the program (already swallowed by an
   earlier cut's tail) are skipped. *)
let pop_known_cut ~reachable ~predecessors prog regions queue =
  let rec drop = function
    | [] -> None, []
    | addr :: rest ->
      if not (Addr.Map.mem addr prog.blocks)
      then drop rest
      else (
        match try_cut ~reachable ~predecessors prog regions ~cut_addr:addr with
        | Some cut -> Some cut, rest
        | None -> drop rest)
  in
  drop queue

let split ~limit ~class_name ~is_static ~return_kind ?env_var prog =
  (* Two-tier early return for the common case (tiny closure that
     already fits):
     1. Array-length upper bound — no per-instr walk, just sums
        [max_instr_cost * body_length] across blocks. Nearly every
        closure in a real link short-circuits here.
     2. Exact program cost — only walked when the upper bound
        exceeds the limit. *)
  if Code_cost.program_upper_bound prog <= limit
     || Code_cost.program prog <= limit
  then { head = prog; helpers = [] }
  else
  let helpers_rev = ref [] in
  let fresh_helper_name () =
    Printf.sprintf "split_%d" (List.length !helpers_rev)
  in
  (* Recursion depth = longest root-to-leaf path in the head/tail
     split tree, NOT the helper count. With intra-first chunking the
     recursion converges naturally when the program is fully cut up;
     the cap is a runaway safety, not a feature bound. The deepest
     real case we've measured (250 MB main, 465 cuts) needed
     depth ≤ 256; 1024 gives a 4× safety margin without costing
     anything extra (recursion only runs as deep as needed). *)
  let max_depth = 1024 in
  let rec go depth queue prog =
    if depth >= max_depth
    then prog
    else (
      (* Phase 1: shrink any individually-oversized block via
         intra-block splitting. The fresh chunk addresses go onto
         [queue] as known-clean cut points so Phase 2 can adopt them
         directly without re-deriving them via [find_end_cut]. *)
      let prog, new_addrs = drive_intrasplit ~limit prog in
      let queue = new_addrs @ queue in
      (* Phase 2: structural cut. Cache is rebuilt per recursion
         level because Phase 1 may have added blocks; the cache only
         supports subsetting, not extension. *)
      let cache = Stat.track "build_split_cache" (fun () ->
        build_split_cache prog) in
      let cost = Stat.track "program_cost" (fun () ->
        program_cost ~cache prog) in
      if cost <= limit
      then prog
      else (
        trace
          "depth=%d cost=%d limit=%d blocks=%d queue=%d"
          depth
          cost
          limit
          (Addr.Map.cardinal prog.blocks)
          (List.length queue);
        let reachable_lazy = lazy (reachable_from prog ~start:prog.start) in
        let cut_opt, queue =
          Stat.track "pop_known_cut" (fun () ->
            pop_known_cut
              ~reachable:(Lazy.force reachable_lazy)
              ~predecessors:cache.cache_predecessors
              prog
              cache.cache_regions
              queue)
        in
        let cut_opt =
          match cut_opt with
          | Some _ as r -> r
          | None ->
            (match Stat.track "find_end_cut" (fun () ->
               find_end_cut ~cache prog ~limit) with
             | Some _ as r -> r
             | None ->
               Stat.track "find_cut_toward" (fun () ->
                 find_cut_toward ?env_var ~cache prog ~target:(limit / 2)))
        in
        match cut_opt with
        | Some cut ->
          let forwarded = Stat.track "cut_forwarded_vars" (fun () ->
            cut_forwarded_vars ~env_var prog cut) in
          let prog = Stat.track "augment_cut_params" (fun () ->
            augment_cut_params prog cut forwarded) in
          let cut_block = Addr.Map.find cut.cut_addr prog.blocks in
          let tail_params = cut_block.params in
          let tail = Stat.track "tail_subprogram" (fun () ->
            tail_subprogram prog cut) in
          let tail_split = go (depth + 1) [] tail in
          let descriptor = descriptor_for_params tail_params ~return_kind in
          let method_name = fresh_helper_name () in
          helpers_rev :=
            { method_name; params = tail_params; prog = tail_split; descriptor }
            :: !helpers_rev;
          let head = Stat.track "head_subprogram" (fun () ->
            head_subprogram prog cut) in
          let head =
            Stat.track "rewrite_head_cut" (fun () ->
              rewrite_head_cut
                ~class_name
                ~is_static
                ~cut_addr:cut.cut_addr
                ~helper_name:method_name
                ~descriptor
                head)
          in
          go (depth + 1) queue head
        | None ->
          trace "depth=%d: no structural cut, giving up" depth;
          prog))
  in
  let head = go 0 [] prog in
  { head; helpers = List.rev !helpers_rev }
