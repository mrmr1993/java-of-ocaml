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

(* Centralised in [Var_refs] so [Method_split], [Spill_long_lived],
   [Cross_block_spill], and [Def_use] all agree on what a free use
   is. Re-exposed locally for terseness. *)
let fv_instr = Var_refs.fv_instr
let fv_last = Var_refs.fv_last
let defs_of_instr = Var_refs.defs_of_instr

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
let debug_split_args = Debug.find "split_args"
let debug_split_lifetimes = Debug.find "split_lifetimes"

(* Per-block variable-lifetime analysis. Hypothesis under test: the
   200+-live-var blocks that force the arity cap down are dominated
   by an ML pattern where many [let a = e1 in let b = e2 in ... in
   big_expr_using_everything] bindings stack up before a final
   expression that uses them all, so their live ranges overlap
   completely. If so, the fix is to rewrite those blocks (or their
   corresponding parsed bytecode) rather than to keep trying cuts
   that can't reduce the simultaneously-live set.

   For each block, compute each [Var]'s def-position (-1 for params
   and pre-bound cut-augmented vars) and last-use position. Report
   blocks with high simultaneous liveness and the span distribution
   of their defs. *)
(* Count each Var's occurrences across a block's body and terminator.
   Distinguishes from [fv_instr] (which returns a set) because we
   want per-use totals, not per-instruction presence — a [Prim]
   that reads the same [Var] twice counts as 2 uses. That
   distinction matters for the "single-use" classifier: a var
   referenced in three instructions at one position each = 3 uses;
   a var referenced once in a Prim that loads it twice = 2 uses. *)
let count_uses_in_block (b : block) =
  let counts : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
  let bump v =
    let c = try Hashtbl.find counts v with Not_found -> 0 in
    Hashtbl.replace counts v (c + 1)
  in
  let bump_prim_arg = function
    | Pv v -> bump v
    | Pc _ -> ()
  in
  let bump_expr = function
    | Apply { f; args; _ } -> bump f; List.iter bump args
    | Block (_, fs) -> Array.iter bump fs
    | Field (v, _) -> bump v
    | Closure { captures; _ } -> List.iter bump captures
    | Constant _ -> ()
    | Prim (_, args) -> List.iter bump_prim_arg args
    | Invoke_helper { args; _ } -> List.iter bump args
  in
  let bump_instr = function
    | Let (_, e) -> bump_expr e
    | Set_field (x, _, y) -> bump x; bump y
    | Offset_ref (x, _) -> bump x
    | Array_set (a, i, v) -> bump a; bump i; bump v
    | Source_pc _ -> ()
  in
  let bump_cont (_, args) = List.iter bump args in
  let bump_last = function
    | Return v | Raise v -> bump v
    | Stop -> ()
    | Branch c -> bump_cont c
    | Cond (v, c1, c2) -> bump v; bump_cont c1; bump_cont c2
    | Switch (v, ints, tags) ->
      bump v;
      Array.iter bump_cont ints;
      Array.iter bump_cont tags
    | Pushtrap (body, _, handler) ->
      bump_cont body;
      bump_cont handler
    | Poptrap c -> bump_cont c
    | Invoke_tail { args; _ } -> List.iter bump args
  in
  Array.iter bump_instr b.body;
  bump_last b.branch;
  counts

let analyze_block_lifetimes (b : block) =
  let n = Array.length b.body in
  (* def_pos: where each var is defined. Params get -1. Body Let
     bindings get their index. Vars defined elsewhere don't appear
     in this table. *)
  let def_pos : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
  List.iter (fun v -> Hashtbl.replace def_pos v (-1)) b.params;
  Array.iteri
    (fun k i ->
      Var.Set.iter (fun v -> Hashtbl.replace def_pos v k) (defs_of_instr i))
    b.body;
  (* last_use: last body index at which each var was referenced.
     Branch uses count as index n. *)
  let last_use : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
  Array.iteri
    (fun k i ->
      Var.Set.iter (fun v -> Hashtbl.replace last_use v k) (fv_instr i))
    b.body;
  Var.Set.iter
    (fun v -> Hashtbl.replace last_use v n)
    (fv_last b.branch);
  (* Per-k live count: standard backward scan. *)
  let live_count = Array.make (n + 1) 0 in
  let live = ref (fv_last b.branch) in
  live_count.(n) <- Var.Set.cardinal !live;
  for k = n - 1 downto 0 do
    let i = b.body.(k) in
    live := Var.Set.diff !live (defs_of_instr i);
    live := Var.Set.union !live (fv_instr i);
    live_count.(k) <- Var.Set.cardinal !live
  done;
  let max_live =
    Array.fold_left max 0 live_count
  in
  let uses = count_uses_in_block b in
  (* Span per defined var, expressed as body-index distance. Params
     count from -1 so their span is last_use + 1. Each row also
     carries the var's total use count so the reporter can bucket
     single-use / multi-use long-livers. *)
  let spans = ref [] in
  Hashtbl.iter
    (fun v dp ->
      match Hashtbl.find_opt last_use v with
      | None -> ()
      | Some lu ->
        let uc = try Hashtbl.find uses v with Not_found -> 0 in
        spans := (v, dp, lu, lu - dp, uc) :: !spans)
    def_pos;
  !spans, max_live, n

let report_lifetimes_if_requested prog =
  if not (debug_split_lifetimes ())
  then ()
  else
    let threshold = 100 in
    let rows =
      Addr.Map.fold
        (fun addr (blk : block) acc ->
          let spans, max_live, n = analyze_block_lifetimes blk in
          if max_live >= threshold
          then (addr, blk, spans, max_live, n) :: acc
          else acc)
        prog.blocks
        []
      |> List.sort (fun (_, _, _, a, _) (_, _, _, b, _) -> compare b a)
    in
    if rows = []
    then ()
    else (
      Format.eprintf
        "[lifetimes] blocks with max_live >= %d: %d@."
        threshold
        (List.length rows);
      let show = 10 in
      List.iteri
        (fun i (addr, (blk : block), spans, max_live, n) ->
          if i >= show
          then ()
          else (
            let k = List.length spans in
            let nparams = List.length blk.params in
            let long_threshold = max 1 (n * 8 / 10) in
            let long_lived =
              List.fold_left
                (fun acc (_, _, _, span, _) ->
                  if span >= long_threshold then acc + 1 else acc)
                0
                spans
            in
            let short_lived =
              List.fold_left
                (fun acc (_, _, _, span, _) ->
                  if span <= 5 then acc + 1 else acc)
                0
                spans
            in
            (* Use-count buckets for long-lived vars. A long-lived
               single-use var is the cleanest candidate for sinking
               its def down to its use site: no aliasing concern,
               and the transform strictly shrinks live range. *)
            let ll_use_bucket = Array.make 6 0 in
            (* 0 -> 1 use, 1 -> 2, 2 -> 3, 3 -> 4, 4 -> 5, 5 -> 6+ *)
            List.iter
              (fun (_, _, _, span, uc) ->
                if span >= long_threshold
                then (
                  let idx = if uc >= 6 then 5 else max 0 (uc - 1) in
                  ll_use_bucket.(idx) <- ll_use_bucket.(idx) + 1))
              spans;
            let sorted =
              List.sort
                (fun (_, _, _, a, _) (_, _, _, b, _) -> compare a b)
                spans
            in
            let arr = Array.of_list sorted in
            let pct p =
              if Array.length arr = 0
              then 0
              else
                let idx =
                  min (Array.length arr - 1)
                    (Array.length arr * p / 100)
                in
                let _, _, _, s, _ = arr.(idx) in
                s
            in
            Format.eprintf
              "[lifetimes]   addr=%d body=%d params=%d max_live=%d \
               vars_tracked=%d long(>=%d%%)=%d short(<=5)=%d \
               span_p25=%d p50=%d p75=%d p90=%d@."
              addr
              n
              nparams
              max_live
              k
              80
              long_lived
              short_lived
              (pct 25)
              (pct 50)
              (pct 75)
              (pct 90);
            if long_lived > 0
            then
              Format.eprintf
                "[lifetimes]     long-lived uses: 1=%d 2=%d 3=%d 4=%d 5=%d 6+=%d@."
                ll_use_bucket.(0)
                ll_use_bucket.(1)
                ll_use_bucket.(2)
                ll_use_bucket.(3)
                ll_use_bucket.(4)
                ll_use_bucket.(5)))
        rows)

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
   per candidate — see [try_cut_fast]).

   Relaxed rule (vs the original "everything on one side"):

   - Pushtrap, handler, and every Poptrap for the trap must all be
     on the same side. They share a method's constant pool, the
     JVM exception-table entry, the handler bytecode label, and
     the trap-context stack depth — none of which can span
     methods.
   - Protected *body* blocks can be on either side. When a
     protected body ends up in the tail helper, exceptions thrown
     there propagate up through the JVM call stack to the head's
     [Invoke_tail] site. That site sits inside the exception-table
     range for T (because [compute_trap_contexts] records the
     stub's trap context correctly), so T's handler catches. *)
let debug_strict_traps = Debug.find "strict_traps"

(* Print Split_tree node-kind counts on every cache rebuild — useful
   for checking how much structure the builder recovered vs. how
   much fell through to [Flat] / top-level stragglers. *)
let debug_split_tree_stats = Debug.find "split_tree_stats"

(* Print [Let_in_cut] candidate counts per [split] entry. Useful for
   gauging how much of a lever the Let_in extraction will be before
   wiring it into the splitter's cut pipeline. *)
let debug_let_in_stats = Debug.find "let_in_stats"

(* Enable [Let_in_cut] extraction in the [split] pipeline. Off by
   default pending a large test binary verification; flip on with
   [JAVA_OF_OCAML_DEBUG=let_in]. *)
let debug_let_in = Debug.find "let_in"

(* [try_apply_let_in_cut] is defined later — it depends on
   [descriptor_for_params] and [Return_object]. *)

let cut_respects_trap_regions_fast ~reachable ~tail_tbl regions =
  let in_tail a = Hashtbl.mem tail_tbl a in
  let in_head a = Addr.Set.mem a reachable && not (in_tail a) in
  let strict = debug_strict_traps () in
  List.for_all
    (fun (pushtrap_addr, handler_addr, poptraps, protected) ->
      let all_in_tail s = Addr.Set.for_all in_tail s in
      let all_in_head s = Addr.Set.for_all in_head s in
      if in_tail pushtrap_addr
      then
        in_tail handler_addr
        && all_in_tail poptraps
        && (not strict || all_in_tail protected)
      else if in_head pushtrap_addr
      then
        in_head handler_addr
        && (not strict
            || (all_in_head protected && all_in_head poptraps))
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
(* Reusable BFS scratch. The caller allocates once per [find_end_cut]
   (~hundreds of candidates per call) and passes it here; each call
   clears and reuses both the [Hashtbl] and the [Stack]. Without
   this we were paying Hashtbl allocation + amortized resize on
   every candidate — ~80k allocations per run. *)
type bfs_scratch =
  { tail_tbl : (Addr.t, unit) Hashtbl.t
  ; stack : Addr.t Stack.t
  ; mutable tail_cost : int
      (** Sum of block costs accumulated during BFS. Only populated
          when the caller passes [~block_cost]; else left at 0. *)
  }

let make_bfs_scratch () =
  { tail_tbl = Hashtbl.create 64
  ; stack = Stack.create ()
  ; tail_cost = 0
  }

let try_cut_fast
    ?cost_cap
    ?(block_cost : (Addr.t, int) Hashtbl.t option)
    ~scratch
    ~reachable
    ~predecessors
    prog
    regions
    ~cut_addr =
  if cut_addr = prog.start
  then None
  else if not (Addr.Map.mem cut_addr prog.blocks)
  then None
  else if not (Addr.Set.mem cut_addr reachable)
  then None
  else (
    let tail_tbl = scratch.tail_tbl in
    let stack = scratch.stack in
    Hashtbl.clear tail_tbl;
    Stack.clear stack;
    scratch.tail_cost <- 0;
    let over_cap = ref false in
    let add_to_tail a =
      Hashtbl.add tail_tbl a ();
      Stack.push a stack;
      (match cost_cap, block_cost with
       | Some cap, Some costs ->
         scratch.tail_cost
           <- scratch.tail_cost
              + (try Hashtbl.find costs a with Not_found -> 0);
         if scratch.tail_cost > cap then over_cap := true
       | _ -> ())
    in
    add_to_tail cut_addr;
    while (not !over_cap) && not (Stack.is_empty stack) do
      let a = Stack.pop stack in
      List.iter
        (fun s -> if not (Hashtbl.mem tail_tbl s) then add_to_tail s)
        (successors prog a)
    done;
    if !over_cap
    then None
    else
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
let try_cut ~scratch ~reachable ~predecessors prog regions ~cut_addr =
  match
    try_cut_fast ~scratch ~reachable ~predecessors prog regions ~cut_addr
  with
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
   descriptor length, call-site byte count, and stack pressure.
   [structural_bonus] subtracts a flat credit when the cut aligns
   with a [Split_tree] region boundary — those cuts have clean
   forwarded-var profiles and predictable trap-cohesion. *)
let score_cut
    ~block_cost
    ~forward_size
    ~target
    ~structural_bonus
    (cut : cut) =
  let head_cost =
    Addr.Set.fold
      (fun a acc ->
        acc + (try Hashtbl.find block_cost a with Not_found -> 0))
      cut.head
      0
  in
  let balance_cost = abs (head_cost - target) in
  let forward_penalty = forward_size * 50 in
  balance_cost + forward_penalty - structural_bonus

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
(* Structurally-preferred cut addresses derived from the tree. Cuts
   here align with a region boundary so scoring gives them a credit:

   - [Try_region.pushtrap.entry_addr] — cutting here moves the whole
     trap (pushtrap + body + handler) into the tail; trap cohesion
     is preserved trivially.

   - The body-edge target of the [Pushtrap] branch — cutting here
     moves just the protected body into the tail, under the relaxed
     trap rule (pushtrap + handler stay in head, JVM propagation
     delivers any tail-thrown exception through the [Invoke_tail]
     site to the head's handler). *)
let preferred_cut_addrs (tree : Split_tree.t) =
  let acc = ref Addr.Set.empty in
  let rec walk = function
    | Split_tree.Leaf _ -> ()
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
    | Try_region { pushtrap; protected; _ } ->
      acc := Addr.Set.add pushtrap.entry_addr !acc;
      (match pushtrap.branch with
       | Pushtrap ((body_addr, _), _, _) ->
         acc := Addr.Set.add body_addr !acc
       | _ -> ());
      walk protected
  in
  walk tree.Split_tree.root;
  !acc

type split_cache =
  { cache_block_cost : (Addr.t, int) Hashtbl.t
  ; cache_regions : (Addr.t * Addr.t * Addr.Set.t * Addr.Set.t) list
  ; cache_predecessors : (Addr.t, Addr.t list) Hashtbl.t
  ; cache_tree : Split_tree.t
        (** Structural view of [prog]; built once per cache rebuild.
            [find_cut_toward] enumerates candidate cut addresses via
            the tree, and [trap_regions] is derived from it. *)
  ; cache_preferred : Addr.Set.t
        (** Structurally-preferred cut addresses (Try_region pushtrap
            addrs + protected-body entries). Cached so per-iteration
            cut finders don't re-walk the tree. *)
  }

let build_split_cache (prog : program) =
  let t0 = Sys.time () in
  let tree = Split_tree.of_program prog in
  let tree_ms = (Sys.time () -. t0) *. 1000. in
  if tree_ms > 100.
  then
    Printf.eprintf
      "[split_tree] of_program took %.0fms on %d blocks\n%!"
      tree_ms
      (Addr.Map.cardinal prog.blocks);
  (* One-shot safety: the tree's leaf-addr set must match reachability
     from [prog.start]. Divergence here means either [Split_tree]
     dropped a block during construction or [prog] contains
     unreachable blocks — both of which would cause cut enumeration
     to produce wrong results downstream. *)
  let tree_addrs = Split_tree.leaf_addrs tree in
  let reachable = reachable_from prog ~start:prog.start in
  (* tree_addrs is [prog.blocks]'s key set; reachable_from is a
     subset (prog can have dead blocks left over from intra-split,
     deadcode quirks, etc.). Only fail if a reachable block is
     *missing* from the tree — that would be a real construction
     bug. Extra (unreachable) tree leaves are harmless: cut
     enumerators iterate them, [try_cut] rejects, no harm done. *)
  let only_reach = Addr.Set.diff reachable tree_addrs in
  if not (Addr.Set.is_empty only_reach)
  then (
    Printf.eprintf
      "[split_tree] reachable block missing from tree: %s\n"
      (String.concat "," (List.map string_of_int (Addr.Set.elements only_reach)));
    failwith "Split_tree.leaf_addrs missing reachable block");
  if debug_split_tree_stats ()
  then (
    let s = Split_tree.summarise tree in
    Printf.eprintf
      "[split_tree] blocks=%d leaves=%d flats=%d seqs=%d ifs=%d \
       switches=%d loops=%d trys=%d stragglers=%d\n%!"
      (Addr.Map.cardinal prog.blocks)
      s.leaves
      s.flats
      s.seqs
      s.ifs
      s.switches
      s.loops
      s.trys
      s.stragglers);
  { cache_block_cost = precompute_block_costs prog
  ; cache_regions = Split_tree.trap_regions tree
  ; cache_predecessors = compute_predecessors prog
  ; cache_tree = tree
  ; cache_preferred = preferred_cut_addrs tree
  }

(* Magic-number bonus applied by [score_cut] when a candidate matches
   a structurally-preferred addr. Calibrated to roughly 4 forwarded
   vars' worth of penalty (4 * 50) — enough to prefer an aligned cut
   when the raw scores are close, not enough to override a
   meaningfully better cut elsewhere in the CFG. *)
let structural_bonus_value = 200

let find_cut_toward ?env_var ~cache prog ~target =
  let reachable = reachable_from prog ~start:prog.start in
  (* Iterate candidates via the structural tree. The tree's leaf set
     is [prog.blocks]'s keys; [build_split_cache] asserts it matches
     [reachable_from prog] on every rebuild, so candidate iteration
     is equivalent to the legacy [Addr.Set.iter reachable]. *)
  let candidates = Split_tree.leaf_addrs cache.cache_tree in
  let preferred = cache.cache_preferred in
  let scratch = make_bfs_scratch () in
  let best = ref None in
  Addr.Set.iter
    (fun a ->
      match
        try_cut
          ~scratch
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
        let structural_bonus =
          if Addr.Set.mem a preferred
          then structural_bonus_value
          else 0
        in
        let score =
          score_cut
            ~block_cost:cache.cache_block_cost
            ~forward_size
            ~target
            ~structural_bonus
            cut
        in
        (match !best with
         | None -> best := Some (score, cut)
         | Some (s, _) when score < s -> best := Some (score, cut)
         | _ -> ()))
    candidates;
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
(* Bytes added to a structural candidate's effective [tail_cost] in
   [find_end_cut]'s greedy selection. At ~5000 bytes, a
   Try_region-aligned candidate beats a non-structural one that's up
   to 5 KB larger — big enough to actually flip choices on typical
   trap-heavy functions, small enough to not override a cut that's
   way better on pure size. *)
let find_end_cut_structural_bonus = 5000

let find_end_cut ~cache prog ~limit =
  let reachable = reachable_from prog ~start:prog.start in
  let candidates, subtree_cost =
    postorder_with_subtree_cost ~cache prog ~start:prog.start
  in
  let preferred = cache.cache_preferred in
  let scratch = make_bfs_scratch () in
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
              ~cost_cap:limit
              ~block_cost:cache.cache_block_cost
              ~scratch
              ~reachable
              ~predecessors
              prog
              cache.cache_regions
              ~cut_addr:a
          with
          | None -> ()
          | Some (_, tail_tbl) ->
            let tail_cost = scratch.tail_cost in
            if tail_cost > 0 && tail_cost <= limit
            then
              let effective =
                if Addr.Set.mem a preferred
                then tail_cost + find_end_cut_structural_bonus
                else tail_cost
              in
              let better =
                match !best with
                | None -> true
                | Some (c, _, _) -> effective > c
              in
              if better
              then (
                (* [tail_tbl] is [scratch]'s, about to be clobbered
                   by the next candidate. Snapshot the tail as an
                   [Addr.Set.t] now. *)
                let tail =
                  Hashtbl.fold
                    (fun a () acc -> Addr.Set.add a acc)
                    tail_tbl
                    Addr.Set.empty
                in
                best := Some (effective, a, tail))))
    candidates;
  match !best with
  | None -> None
  | Some (_, cut_addr, tail) ->
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

(* Rewrite [Poptrap c] -> [Branch c] for any tail block whose
   top-of-stack trap was pushed OUTSIDE the tail. After the cut,
   tail runs as its own method with an empty trap stack at entry;
   an orphan [Poptrap] there would (a) crash [compute_trap_contexts]
   on the tail sub-program, and (b) semantically try to pop a trap
   that was never installed in this method. Dropping the pop is
   safe — the trap's exception table is emitted in head's method,
   JVM propagation handles the handler lookup via the [Invoke_tail]
   site in head, and the pop-stack accounting only matters within
   a single method. *)
let tail_subprogram prog (cut : cut) =
  let contexts = Code.compute_trap_contexts prog in
  let in_tail a = Addr.Set.mem a cut.tail in
  let blocks =
    Addr.Set.fold
      (fun a acc ->
        match Addr.Map.find_opt a prog.blocks with
        | None -> acc
        | Some b ->
          let b =
            match b.branch with
            | Poptrap c ->
              let trap_in_tail =
                match Hashtbl.find_opt contexts a with
                | Some (top :: _) -> in_tail top
                | _ -> false
              in
              if trap_in_tail then b else { b with branch = Branch c }
            | _ -> b
          in
          Addr.Map.add a b acc)
      cut.tail
      Addr.Map.empty
  in
  { start = cut.cut_addr; blocks; free_pc = prog.free_pc }

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

(* --- Let_in cut integration ---------------------------------------- *)

(* Max number of helper-method args the Let_in cut may produce.
   The JVM hard limit is 255 slots; reserve headroom for receiver
   + locals so helpers don't blow it. *)
let let_in_max_args = 200

(* Pick the best applicable [Let_in_cut] candidate, apply it, and
   return the pieces [split]'s driver needs. [None] if no candidate
   fits the budget. Selection: largest cost that (a) fits under
   [limit] and (b) has [≤ let_in_max_args] forwarded args. *)
let try_apply_let_in_cut ~limit ~class_name ~is_static prog =
  let cs = Let_in_cut.enumerate prog in
  let fit =
    List.filter
      (fun (c : Let_in_cut.candidate) ->
        c.cost > 0 && c.cost <= limit)
      cs
  in
  let rec pick_best = function
    | [] -> None
    | [ c ] -> Some c
    | (c : Let_in_cut.candidate) :: rest ->
      (match pick_best rest with
       | None -> Some c
       | Some (best : Let_in_cut.candidate)
         when c.cost > best.cost -> Some c
       | r -> r)
  in
  match pick_best fit with
  | None -> None
  | Some c ->
    let entry_block = Addr.Map.find c.body_entry prog.blocks in
    (* Mirror [Let_in_cut.apply]'s live-in computation so we can
       reject over-arity candidates before committing. *)
    let live_in =
      let used = ref Var.Set.empty in
      let defined =
        ref
          (List.fold_left
             (fun s v -> Var.Set.add v s)
             Var.Set.empty
             entry_block.params)
      in
      Addr.Set.iter
        (fun a ->
          match Addr.Map.find_opt a prog.blocks with
          | None -> ()
          | Some (b : block) ->
            List.iter (fun v -> defined := Var.Set.add v !defined) b.params;
            Array.iter
              (fun i ->
                used := Var.Set.union !used (fv_instr i);
                defined := Var.Set.union !defined (defs_of_instr i))
              b.body;
            used := Var.Set.union !used (fv_last b.branch))
        c.body_blocks;
      Var.Set.diff !used !defined
    in
    let n_args =
      List.length entry_block.params + Var.Set.cardinal live_in
    in
    if n_args > let_in_max_args
    then None
    else (
      let method_ = Printf.sprintf "let_in_%d" (Var.count ()) in
      let descriptor =
        descriptor_for_params
          (List.init n_args (fun _ -> Var.fresh ()))
          ~return_kind:Return_object
      in
      let applied =
        Let_in_cut.apply
          prog
          c
          ~class_:class_name
          ~method_
          ~descriptor
          ~is_static
      in
      Some (applied, method_, descriptor))

(* --- Per-helper arg statistics -------------------------------------- *)

(* Classify each helper's params as "locally used" vs "only forwarded".
   A param is locally used if it appears in any body instruction's free
   vars, or as a terminator value that isn't a continuation arg
   (Return / Raise scrutinee, Cond / Switch discriminator). Anything
   else — continuation args, Invoke_tail args — is forwarding: the
   helper is just threading the value through to the next cut.

   Forwarding params are the ones a smarter cut placement (or a
   spill-through-object-array escape hatch) could remove without
   changing semantics. This split is the thing to measure before
   designing a fix for the JVM 255-arg limit. *)
let locally_used_vars (prog : program) =
  let used = ref Var.Set.empty in
  Addr.Map.iter
    (fun _ b ->
      Array.iter (fun i -> used := Var.Set.union !used (fv_instr i)) b.body;
      match b.branch with
      | Return v | Raise v -> used := Var.Set.add v !used
      | Cond (v, _, _) -> used := Var.Set.add v !used
      | Switch (v, _, _) -> used := Var.Set.add v !used
      | Stop | Branch _ | Pushtrap _ | Poptrap _ | Invoke_tail _ -> ())
    prog.blocks;
  !used

(* Cross-invocation totals so a single at-exit summary captures the
   whole compile run, not just each split call in isolation. *)
let stats_totals =
  let z () = Array.make 8 0 in
  object
    val mutable helpers = 0
    val mutable total_params = 0
    val mutable buckets = z ()
    val mutable affected = 0
    val mutable affected_intra = 0
    val mutable affected_structural = 0
    val mutable affected_used = 0
    val mutable affected_forwarded = 0
    method add ~h ~tp ~bk ~aff ~ai ~as_ ~au ~af =
      helpers <- helpers + h;
      total_params <- total_params + tp;
      for i = 0 to 7 do buckets.(i) <- buckets.(i) + bk.(i) done;
      affected <- affected + aff;
      affected_intra <- affected_intra + ai;
      affected_structural <- affected_structural + as_;
      affected_used <- affected_used + au;
      affected_forwarded <- affected_forwarded + af
    method read =
      helpers, total_params, buckets,
      affected, affected_intra, affected_structural,
      affected_used, affected_forwarded
  end

let () =
  at_exit (fun () ->
    if debug_split_args () then
      let h, tp, bk, aff, ai, as_, au, af = stats_totals#read in
      if h > 0 then (
        let labels =
          [| "  0..7 "; "  8..15"; " 16..31"; " 32..63"; " 64..127"
           ; "128..199"; "200..254"; "  255+ " |]
        in
        Format.eprintf "[split_args:TOTAL] helpers=%d total_params=%d@." h tp;
        Format.eprintf "[split_args:TOTAL] histogram:@.";
        Array.iteri (fun i c ->
          if c > 0 then Format.eprintf "[split_args:TOTAL]   %s : %d@." labels.(i) c)
          bk;
        if aff > 0 then (
          Format.eprintf
            "[split_args:TOTAL] >=100 params: %d helpers (%d intra, %d structural)@."
            aff ai as_;
          Format.eprintf
            "[split_args:TOTAL]   %d used, %d forwarded (%.1f%% forwarded)@."
            au af
            (100.0 *. float_of_int af /. float_of_int (max 1 (au + af))))))

let report_helper_arg_stats helpers origins =
  let bucket_of n =
    if n <= 7 then 0
    else if n <= 15 then 1
    else if n <= 31 then 2
    else if n <= 63 then 3
    else if n <= 127 then 4
    else if n <= 199 then 5
    else if n <= 254 then 6
    else 7
  in
  let bucket_labels =
    [| "  0..7 "; "  8..15"; " 16..31"; " 32..63"; " 64..127"
     ; "128..199"; "200..254"; "  255+ " |]
  in
  let buckets = Array.make 8 0 in
  let total = ref 0 in
  let total_params = ref 0 in
  let affected = ref [] in
  let sum_used = ref 0 in
  let sum_passthrough = ref 0 in
  let intra_affected = ref 0 in
  let structural_affected = ref 0 in
  let affected_threshold = 100 in
  List.iter2
    (fun (h : helper) origin ->
      let n = List.length h.params in
      buckets.(bucket_of n) <- buckets.(bucket_of n) + 1;
      incr total;
      total_params := !total_params + n;
      if n >= affected_threshold
      then (
        let used_set = locally_used_vars h.prog in
        let used, pt =
          List.fold_left
            (fun (u, p) v ->
              if Var.Set.mem v used_set then u + 1, p else u, p + 1)
            (0, 0) h.params
        in
        sum_used := !sum_used + used;
        sum_passthrough := !sum_passthrough + pt;
        (match origin with
         | `Intra_chunk -> incr intra_affected
         | `Structural -> incr structural_affected);
        affected := (h.method_name, n, used, pt, origin) :: !affected))
    helpers origins;
  stats_totals#add
    ~h:!total ~tp:!total_params ~bk:buckets
    ~aff:(List.length !affected)
    ~ai:!intra_affected ~as_:!structural_affected
    ~au:!sum_used ~af:!sum_passthrough;
  (* Per-call report is noisy for tiny closures — skip anything that
     wouldn't show structure. *)
  let n_affected = List.length !affected in
  if !total < 20 then () else (
  Format.eprintf "[split_args] helpers=%d total_params=%d@."
    !total !total_params;
  Format.eprintf "[split_args] histogram (params per helper):@.";
  Array.iteri
    (fun i c ->
      if c > 0
      then Format.eprintf "[split_args]   %s : %d@." bucket_labels.(i) c)
    buckets;
  if n_affected > 0
  then (
    Format.eprintf
      "[split_args] with >=%d params: %d helpers (%d intra-chunk, %d structural)@."
      affected_threshold
      n_affected
      !intra_affected
      !structural_affected;
    Format.eprintf
      "[split_args]   aggregate: %d used, %d forwarded (%.1f%% forwarded)@."
      !sum_used
      !sum_passthrough
      (100.0 *. float_of_int !sum_passthrough
       /. float_of_int (max 1 (!sum_used + !sum_passthrough)));
    let worst =
      List.sort (fun (_, a, _, _, _) (_, b, _, _, _) -> compare b a) !affected
    in
    let show = 10 in
    Format.eprintf "[split_args]   top %d by param count:@." show;
    List.iteri
      (fun i (name, n, used, pt, origin) ->
        if i < show
        then
          Format.eprintf
            "[split_args]     %-14s n=%-4d used=%-4d forwarded=%-4d (%s)@."
            name n used pt
            (match origin with
             | `Intra_chunk -> "intra"
             | `Structural -> "struct"))
      worst))

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
  Stat.track "drive_intrasplit" (fun () ->
    let acc_addrs = ref [] in
    (* One-pass scan for blocks whose cost exceeds [limit]. The
       [length * max_instr_cost] upper bound is cheap; the full
       [Code_cost.block] walk only happens when the upper bound is
       itself too big. *)
    let work = Queue.create () in
    Addr.Map.iter
      (fun a b ->
        let upper =
          (Array.length b.body * Code_cost.max_instr_cost)
          + Code_cost.max_instr_cost
        in
        if upper > limit && Code_cost.block b > limit
        then Queue.push a work)
      prog.blocks;
    let prog = ref prog in
    while not (Queue.is_empty work) do
      let addr = Queue.pop work in
      (match Addr.Map.find_opt addr (!prog).blocks with
       | None -> ()
       | Some b when Code_cost.block b <= limit -> ()
       | Some _ ->
         let split =
           match intra_split_block_at ~limit !prog ~addr with
           | Some r -> Some r
           | None -> split_block_at !prog ~addr ~target:(limit / 2)
         in
         (match split with
          | None -> ()
          | Some (p', new_addrs) ->
            prog := p';
            acc_addrs := List.rev_append new_addrs !acc_addrs;
            (* Chunks are sized under [limit] by the splitter's own
               budget check, so requeuing them is just a safety
               net — the [cost <= limit] guard at the top of the
               loop is what lets the queue drain. Requeue [addr]
               too; [intra_split_block_at] kept it as chunk 0 but
               its new body might, in theory, still be heavy. *)
            Queue.push addr work;
            List.iter (fun a -> Queue.push a work) new_addrs))
    done;
    !prog, !acc_addrs)

(* Consume the next valid known cut from [queue] (deepest-first). A
   known cut is an address that intra-splitting created as a fresh
   chain link: by construction it has exactly one predecessor (the
   prior chunk's [Branch]), so the head/tail partition is trivially
   disjoint and self-contained — [try_cut] only re-checks
   trap-region coherence. The first one that passes is returned;
   addresses no longer in the program (already swallowed by an
   earlier cut's tail) are skipped. *)
let pop_known_cut ~reachable ~predecessors prog regions queue =
  let scratch = make_bfs_scratch () in
  let rec drop = function
    | [] -> None, []
    | addr :: rest ->
      if not (Addr.Map.mem addr prog.blocks)
      then drop rest
      else (
        match
          try_cut
            ~scratch
            ~reachable
            ~predecessors
            prog
            regions
            ~cut_addr:addr
        with
        | Some cut -> Some cut, rest
        | None -> drop rest)
  in
  drop queue

let split ~limit ~class_name ~is_static ~return_kind ?env_var prog =
  if debug_split_tree_stats ()
  then (
    let tree = Split_tree.of_program prog in
    let s = Split_tree.summarise tree in
    Printf.eprintf
      "[split_tree] blocks=%d leaves=%d flats=%d seqs=%d ifs=%d \
       switches=%d loops=%d trys=%d stragglers=%d\n%!"
      (Addr.Map.cardinal prog.blocks)
      s.leaves
      s.flats
      s.seqs
      s.ifs
      s.switches
      s.loops
      s.trys
      s.stragglers);
  if debug_let_in_stats ()
  then (
    let cs = Let_in_cut.enumerate prog in
    let under_limit =
      List.filter
        (fun (c : Let_in_cut.candidate) -> c.cost <= limit)
        cs
    in
    let max_cost =
      List.fold_left
        (fun acc (c : Let_in_cut.candidate) -> max acc c.cost)
        0
        cs
    in
    Printf.eprintf
      "[let_in] blocks=%d candidates=%d under_limit=%d max_cost=%d\n%!"
      (Addr.Map.cardinal prog.blocks)
      (List.length cs)
      (List.length under_limit)
      max_cost);
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
  let () = report_lifetimes_if_requested prog in
  let helpers_rev = ref [] in
  (* Parallel list — origin of each helper's cut. [Intra_chunk] means
     the cut_addr was introduced by Phase-1 intra-block chunking and
     adopted straight off the known-clean queue; [Structural] means
     the cut was found by [find_end_cut] or [find_cut_toward] over
     the CFG. Only read when [split_args] is enabled. *)
  let helper_origins_rev : [ `Intra_chunk | `Structural ] list ref = ref [] in
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
  (* [blocks_clean] tracks whether every block in [prog] already fits
     under [limit]. Once [drive_intrasplit] runs it's true, and since
     structural cuts only partition blocks (never grow any), it stays
     true for head/tail sub-programs. [drive_intrasplit] is the
     [heaviest_block] walk plus optional splitting; skipping it on a
     known-clean program elides the O(|blocks|) scan entirely. *)
  let rec go depth ~blocks_clean queue prog =
    if depth >= max_depth
    then prog
    else (
      (* Phase 1: shrink any individually-oversized block via
         intra-block splitting. The fresh chunk addresses go onto
         [queue] as known-clean cut points so Phase 2 can adopt them
         directly without re-deriving them via [find_end_cut]. *)
      let prog, new_addrs =
        if blocks_clean then prog, [] else drive_intrasplit ~limit prog
      in
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
        (* Let_in_cut (SESE extraction via [Invoke_helper]) is tried
           before the tail-only cuts. When it fires it produces a
           different shape (asymmetric head/helper), so it takes its
           own recursion branch and skips the existing
           augment_cut_params / tail_subprogram / rewrite_head_cut
           pipeline.

           Enumerate is O(N²) in [prog.blocks] (per join, dominator
           subtree intersection); running it at every recursion
           level on a multi-thousand-block main blows the budget.
           Cap to depth ≤ 4 — the first few levels see the biggest
           heads where Let_in is worth most, and deeper helpers are
           usually small enough that tail-cut alone copes. *)
        let let_in =
          if cut_opt <> None
             || not (debug_let_in ())
             || depth > 4
          then None
          else
            Stat.track "let_in" (fun () ->
              try_apply_let_in_cut ~limit ~class_name ~is_static prog)
        in
        (match let_in with
         | Some (applied, method_name, descriptor) ->
           trace
             "depth=%d let_in: body=%d forwarded=%d"
             depth
             (List.length applied.Let_in_cut.helper_entry_params)
             (List.length applied.forwarded_args);
           let helper_split =
             go (depth + 1) ~blocks_clean:false [] applied.helper_prog
           in
           helpers_rev :=
             { method_name
             ; params = applied.helper_entry_params
             ; prog = helper_split
             ; descriptor
             }
             :: !helpers_rev;
           helper_origins_rev := `Structural :: !helper_origins_rev;
           go
             (depth + 1)
             ~blocks_clean:false
             queue
             applied.head_prog
         | None ->
        let cut_opt, cut_origin =
          match cut_opt with
          | Some _ as r -> r, `Intra_chunk
          | None ->
            let r =
              match Stat.track "find_end_cut" (fun () ->
                find_end_cut ~cache prog ~limit) with
              | Some _ as r -> r
              | None ->
                Stat.track "find_cut_toward" (fun () ->
                  find_cut_toward ?env_var ~cache prog ~target:(limit / 2))
            in
            r, `Structural
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
          let tail_split = go (depth + 1) ~blocks_clean:true [] tail in
          let descriptor = descriptor_for_params tail_params ~return_kind in
          let method_name = fresh_helper_name () in
          helpers_rev :=
            { method_name; params = tail_params; prog = tail_split; descriptor }
            :: !helpers_rev;
          helper_origins_rev := cut_origin :: !helper_origins_rev;
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
          go (depth + 1) ~blocks_clean:true queue head
        | None ->
          trace "depth=%d: no structural cut, giving up" depth;
          prog)))
  in
  let head = go 0 ~blocks_clean:false [] prog in
  let helpers = List.rev !helpers_rev in
  let origins = List.rev !helper_origins_rev in
  if debug_split_args () then report_helper_arg_stats helpers origins;
  { head; helpers }
