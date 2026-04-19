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
        List.fold_left
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
          List.fold_left
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

let cut_respects_trap_regions regions ~head ~tail =
  List.for_all
    (fun (pushtrap_addr, handler_addr, protected) ->
      let all_in set s = Addr.Set.for_all (fun a -> Addr.Set.mem a set) s in
      if Addr.Set.mem pushtrap_addr head
      then all_in head protected && Addr.Set.mem handler_addr head
      else if Addr.Set.mem pushtrap_addr tail
      then all_in tail protected && Addr.Set.mem handler_addr tail
      else true)
    regions

let cut_is_self_contained prog ~cut_addr ~head ~tail =
  let head_ok =
    Addr.Set.for_all
      (fun a ->
        List.for_all
          (fun s -> Addr.Set.mem s head || s = cut_addr)
          (successors prog a))
      head
  in
  let tail_ok =
    Addr.Set.for_all
      (fun a ->
        List.for_all (fun s -> Addr.Set.mem s tail) (successors prog a))
      tail
  in
  head_ok && tail_ok


(* Backward-dataflow [live_in] for every reachable block. One
   iteration in reverse post-order suffices for acyclic graphs;
   loops converge in a few extra passes. Returns a hashtable
   [addr -> Var.Set.t] where each entry is the set of vars needed
   at the block's entry but not supplied via its params.

   [cut_forwarded_vars] at a candidate cut equals [live_in] at
   that block (minus [env_var]), so precomputing this once per
   [find_cut_toward] replaces an O(|tail|) per-candidate scan with
   an O(1) lookup — the main driver of the [find_cut_toward]'s
   O(n²) cost on large [main] bodies like the stdlib+Base link.

   Block params are treated as "defined at entry": the caller
   hands values to them via branch args, so they aren't live-in.
   Per-block [use] and [def] sets are computed once upfront. *)
let precompute_live_in (prog : program) =
  let use_def =
    Addr.Map.mapi
      (fun _ (b : block) ->
        let defs = List.fold_left
          (fun s v -> Var.Set.add v s)
          Var.Set.empty
          b.params
        in
        let body_defs =
          List.fold_left
            (fun s i -> Var.Set.union s (defs_of_instr i))
            Var.Set.empty
            b.body
        in
        let defs = Var.Set.union defs body_defs in
        let uses =
          let body_uses =
            List.fold_left
              (fun s i -> Var.Set.union s (fv_instr i))
              Var.Set.empty
              b.body
          in
          Var.Set.union body_uses (fv_last b.branch)
        in
        (* [use_b] is the block's "gen" set: used in the block
           before any local def. Under strict SSA with defs
           preceding uses inside a block, this is just uses minus
           defs. *)
        Var.Set.diff uses defs, defs)
      prog.blocks
  in
  let live = Hashtbl.create (Addr.Map.cardinal prog.blocks) in
  Addr.Map.iter (fun a _ -> Hashtbl.replace live a Var.Set.empty) prog.blocks;
  let changed = ref true in
  while !changed do
    changed := false;
    Addr.Map.iter
      (fun a (b : block) ->
        let _use, def = Addr.Map.find a use_def in
        let live_out =
          List.fold_left
            (fun acc succ ->
              let succ_params =
                match Addr.Map.find_opt succ prog.blocks with
                | Some sb -> fv_set_of_list sb.params
                | None -> Var.Set.empty
              in
              let s =
                try Hashtbl.find live succ with Not_found -> Var.Set.empty
              in
              Var.Set.union acc (Var.Set.diff s succ_params))
            Var.Set.empty
            (let acc = ref [] in
             let step (s, _) =
               if Addr.Map.mem s prog.blocks then acc := s :: !acc
             in
             (match b.branch with
              | Return _ | Raise _ | Stop | Invoke_tail _ -> ()
              | Branch c -> step c
              | Cond (_, c1, c2) -> step c1; step c2
              | Switch (_, ints, tags) ->
                Array.iter step ints;
                Array.iter step tags
              | Pushtrap (body, _, handler) -> step body; step handler
              | Poptrap c -> step c);
             !acc)
        in
        let use, _ = Addr.Map.find a use_def in
        let new_in = Var.Set.union use (Var.Set.diff live_out def) in
        let prev = Hashtbl.find live a in
        if not (Var.Set.equal prev new_in)
        then (
          Hashtbl.replace live a new_in;
          changed := true))
      prog.blocks
  done;
  live

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

let try_cut ~reachable prog regions ~cut_addr =
  if cut_addr = prog.start
  then None
  else if not (Addr.Map.mem cut_addr prog.blocks)
  then None
  else (
    if not (Addr.Set.mem cut_addr reachable)
    then None
    else (
      let head =
        reachable_avoiding prog ~start:prog.start ~avoid:(Some cut_addr)
      in
      let tail = reachable_from prog ~start:cut_addr in
      if not (Addr.Set.is_empty (Addr.Set.inter head tail))
      then (
        if debug_split ()
        then Format.eprintf "[split]   cut=%d reject: head∩tail@." cut_addr;
        None)
      else if not (cut_respects_trap_regions regions ~head ~tail)
      then (
        if debug_split ()
        then
          Format.eprintf "[split]   cut=%d reject: trap-region@." cut_addr;
        None)
      else if not (cut_is_self_contained prog ~cut_addr ~head ~tail)
      then (
        if debug_split ()
        then
          Format.eprintf
            "[split]   cut=%d reject: not self-contained@."
            cut_addr;
        None)
      else Some { cut_addr; head; tail }))

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
   [block_cost] and [pushtrap_regions] are invariants of the
   original program: sub-programs are subsets, and the tables
   remain correct lookups (extra entries are ignored, missing
   entries fall back to 0). Only [reachable] and [live_in] change
   per sub-program and are recomputed inside each call. *)
type split_cache =
  { cache_block_cost : (Addr.t, int) Hashtbl.t
  ; cache_regions : (Addr.t * Addr.t * Addr.Set.t) list
  }

let build_split_cache (prog : program) =
  { cache_block_cost = precompute_block_costs prog
  ; cache_regions = pushtrap_regions prog
  }

let find_cut_toward ~cache ?env_var prog ~target =
  let reachable = reachable_from prog ~start:prog.start in
  let live_in = precompute_live_in prog in
  let best = ref None in
  Addr.Set.iter
    (fun a ->
      match try_cut ~reachable prog cache.cache_regions ~cut_addr:a with
      | None -> ()
      | Some cut ->
        let live_at_cut =
          try Hashtbl.find live_in cut.cut_addr
          with Not_found -> Var.Set.empty
        in
        let forwarded =
          match env_var with
          | Some e -> Var.Set.remove e live_at_cut
          | None -> live_at_cut
        in
        let score =
          score_cut
            ~block_cost:cache.cache_block_cost
            ~forward_size:(Var.Set.cardinal forwarded)
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
      ; body = []
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

let live_in_at ~suffix ~branch =
  let used =
    List.fold_left
      (fun acc i -> Var.Set.union acc (fv_instr i))
      (fv_last branch)
      suffix
  in
  let defined =
    List.fold_left
      (fun acc i -> Var.Set.union acc (defs_of_instr i))
      Var.Set.empty
      suffix
  in
  Var.Set.diff used defined

let pick_split_index ~target body =
  let n = List.length body in
  if n < 2
  then None
  else (
    let rec walk i acc = function
      | [] -> None
      | _ when acc >= target && i >= 1 && i <= n - 1 -> Some i
      | i' :: rest -> walk (i + 1) (acc + Code_cost.instr i') rest
    in
    match walk 0 0 body with
    | Some k -> Some k
    | None when n >= 2 -> Some (n / 2)
    | None -> None)

let split_list_at k xs =
  let rec loop i acc = function
    | [] -> List.rev acc, []
    | x :: rest when i < k -> loop (i + 1) (x :: acc) rest
    | rest -> List.rev acc, rest
  in
  loop 0 [] xs

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
       let prefix, suffix = split_list_at k b.body in
       let live = live_in_at ~suffix ~branch:b.branch in
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
       Some { prog with blocks; free_pc = fresh_addr + 1 })

let try_intrasplit ~limit prog =
  match Code_cost.heaviest_block prog with
  | None -> None
  | Some (addr, _) -> split_block_at prog ~addr ~target:(limit / 2)

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

let split ~limit ~class_name ~is_static ~return_kind ?env_var prog =
  let cache = build_split_cache prog in
  let helpers_rev = ref [] in
  let fresh_helper_name () =
    Printf.sprintf "split_%d" (List.length !helpers_rev)
  in
  let max_depth = 128 in
  let rec go depth prog =
    let cost = program_cost ~cache prog in
    if cost <= limit
    then prog
    else if depth >= max_depth
    then prog
    else (
      trace
        "depth=%d cost=%d limit=%d blocks=%d"
        depth
        cost
        limit
        (Addr.Map.cardinal prog.blocks);
      match find_cut_toward ~cache ?env_var prog ~target:(limit / 2) with
      | Some cut ->
        let forwarded = cut_forwarded_vars ~env_var prog cut in
        let prog = augment_cut_params prog cut forwarded in
        let cut_block = Addr.Map.find cut.cut_addr prog.blocks in
        let tail_params = cut_block.params in
        let tail = tail_subprogram prog cut in
        let tail_split = go (depth + 1) tail in
        let descriptor = descriptor_for_params tail_params ~return_kind in
        let method_name = fresh_helper_name () in
        helpers_rev :=
          { method_name; params = tail_params; prog = tail_split; descriptor }
          :: !helpers_rev;
        let head = head_subprogram prog cut in
        let head =
          rewrite_head_cut
            ~class_name
            ~is_static
            ~cut_addr:cut.cut_addr
            ~helper_name:method_name
            ~descriptor
            head
        in
        go (depth + 1) head
      | None ->
        trace "depth=%d: no valid cut, attempting intrasplit" depth;
        (match try_intrasplit ~limit prog with
         | Some prog' -> go (depth + 1) prog'
         | None ->
           trace "depth=%d: intrasplit also failed, giving up" depth;
           prog))
  in
  let head = go 0 prog in
  { head; helpers = List.rev !helpers_rev }
