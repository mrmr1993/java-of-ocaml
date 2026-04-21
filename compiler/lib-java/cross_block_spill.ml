open Code

type stats =
  { spilled_classes : int
  ; carrier_size : int
  }

(* --- Config ----------------------------------------------------- *)

(* A class must touch at least this many distinct blocks to be
   worth spilling: the carrier's per-block threading cost pays back
   only once enough block-hops are eliminated. *)
let min_size = 3

(* A class can have at most this many "true" uses (body-instruction
   references or terminator-scrutinee positions — edge-arg
   occurrences are pure movement and don't count). More uses make
   the per-use [Field] read dominate the saved per-block slot. *)
let max_true_uses = 2

(* Don't run at all on programs small enough that [Method_split]
   won't bother. Below this byte budget the carrier-threading
   overhead isn't justified. *)
let min_program_cost = 30_000

(* --- Union-find over Var.t -------------------------------------- *)

(* State is local to each call to [run]. [parent v = v] means [v]
   is a root; otherwise [parent v] is a strict ancestor. *)
let uf_find parent v =
  let rec loop v =
    match Hashtbl.find_opt parent v with
    | None -> v
    | Some p when Var.equal p v -> v
    | Some p ->
      let r = loop p in
      if not (Var.equal r p) then Hashtbl.replace parent v r;
      r
  in
  loop v

let uf_union parent a b =
  let ra = uf_find parent a in
  let rb = uf_find parent b in
  if not (Var.equal ra rb) then Hashtbl.replace parent ra rb

(* --- Free-var / def helpers ------------------------------------- *)

(* Cross_block_spill uses generic [fv_*] from [Var_refs] plus a
   local [fv_last_scrutinee] — the latter is deliberately narrower
   than [Var_refs.fv_last] (only scrutinee uses, not edge-arg
   positions) since edge-args are coalesced through union-find
   instead of counted as true uses. *)

let fv_instr = Var_refs.fv_instr
let defs_of_instr = Var_refs.defs_of_instr

let fv_last_scrutinee = function
  | Return v | Raise v -> Var.Set.singleton v
  | Cond (v, _, _) -> Var.Set.singleton v
  | Switch (v, _, _) -> Var.Set.singleton v
  | Stop | Branch _ | Pushtrap _ | Poptrap _ | Invoke_tail _ ->
    Var.Set.empty

(* Iterate over every edge-arg position in a terminator. [f] is
   called with (target_addr, position, var). Pushtrap's exn_var is
   skipped (it's a def). Invoke_tail has no in-prog target. *)
let iter_edges f last =
  let walk_cont (addr, args) =
    List.iteri (fun i v -> f addr i v) args
  in
  match last with
  | Branch c -> walk_cont c
  | Cond (_, c1, c2) -> walk_cont c1; walk_cont c2
  | Switch (_, ints, tags) ->
    Array.iter walk_cont ints;
    Array.iter walk_cont tags
  | Pushtrap (body, _, handler) -> walk_cont body; walk_cont handler
  | Poptrap c -> walk_cont c
  | Return _ | Raise _ | Stop | Invoke_tail _ -> ()

(* --- Phase 1: build union-find over edges ----------------------- *)

let build_uf (prog : program) =
  let parent : (Var.t, Var.t) Hashtbl.t = Hashtbl.create 256 in
  Addr.Map.iter
    (fun _ (b : block) ->
      iter_edges
        (fun tgt i src ->
          match Addr.Map.find_opt tgt prog.blocks with
          | None -> ()
          | Some tb ->
            (match List.nth_opt tb.params i with
             | Some p -> uf_union parent src p
             | None -> ()))
        b.branch)
    prog.blocks;
  parent

(* --- Phase 2: per-class stats ----------------------------------- *)

(* Record, per root Var, the set of blocks it spans (via members
   defined in or param-bound by those blocks), its total member
   count, and its "true use" count — occurrences in body
   instructions or terminator scrutinees. Also notes whether any
   member is in an Invoke_tail arg (disqualifying) or is a param
   of the entry block (also disqualifying — can't purge a
   function-signature arg). *)
type class_stats =
  { mutable blocks : Addr.Set.t
  ; mutable size : int
  ; mutable true_uses : int
  ; mutable in_invoke_tail : bool
  ; mutable in_entry_params : bool
  ; mutable in_handler_exn_slot : bool
  ; mutable members : Var.Set.t
  }

let empty_class_stats () =
  { blocks = Addr.Set.empty
  ; size = 0
  ; true_uses = 0
  ; in_invoke_tail = false
  ; in_entry_params = false
  ; in_handler_exn_slot = false
  ; members = Var.Set.empty
  }

let get_class_stats tbl parent v =
  let r = uf_find parent v in
  match Hashtbl.find_opt tbl r with
  | Some s -> s
  | None ->
    let s = empty_class_stats () in
    Hashtbl.add tbl r s;
    s

let note_member tbl parent ~in_entry v addr =
  let s = get_class_stats tbl parent v in
  if not (Var.Set.mem v s.members)
  then (
    s.members <- Var.Set.add v s.members;
    s.size <- s.size + 1;
    s.blocks <- Addr.Set.add addr s.blocks;
    if in_entry then s.in_entry_params <- true)

let note_true_uses tbl parent vs =
  Var.Set.iter
    (fun v ->
      let s = get_class_stats tbl parent v in
      s.true_uses <- s.true_uses + 1)
    vs

let note_invoke_tail_arg tbl parent v =
  let s = get_class_stats tbl parent v in
  s.in_invoke_tail <- true

let compute_class_stats (prog : program) parent =
  let tbl : (Var.t, class_stats) Hashtbl.t = Hashtbl.create 128 in
  (* Precompute the [params[0]] Var.t of every block that's a
     Pushtrap handler target — those receive the caught exception
     value via a special emit path (handler prelude stores into
     [exn_var]'s slot, [emit_cont] then moves that value to the
     param). Our carrier threading doesn't reproduce that sequence,
     so classes touching this position must be disqualified. *)
  let handler_exn_params : Var.Set.t ref = ref Var.Set.empty in
  Addr.Map.iter
    (fun _ (b : block) ->
      match b.branch with
      | Pushtrap (_, _, (handler_addr, _)) ->
        (match Addr.Map.find_opt handler_addr prog.blocks with
         | Some hb ->
           (match hb.params with
            | p :: _ -> handler_exn_params := Var.Set.add p !handler_exn_params
            | [] -> ())
         | None -> ())
      | _ -> ())
    prog.blocks;
  Addr.Map.iter
    (fun addr (b : block) ->
      let in_entry = addr = prog.start in
      (* Register each param as a member of its class. *)
      List.iter
        (fun v ->
          note_member tbl parent ~in_entry v addr;
          if Var.Set.mem v !handler_exn_params
          then (get_class_stats tbl parent v).in_handler_exn_slot <- true)
        b.params;
      (* Register each Let-defined var as a member. *)
      Array.iter
        (fun i ->
          Var.Set.iter
            (fun v -> note_member tbl parent ~in_entry:false v addr)
            (defs_of_instr i))
        b.body;
      (* Count true uses in body. *)
      Array.iter
        (fun i ->
          let uses =
            Var.Set.diff (fv_instr i) (defs_of_instr i)
          in
          note_true_uses tbl parent uses)
        b.body;
      (* Count true uses in terminator scrutinee slots. *)
      note_true_uses tbl parent (fv_last_scrutinee b.branch);
      (* Flag Invoke_tail arg occurrences. *)
      (match b.branch with
       | Invoke_tail { args; _ } ->
         List.iter (fun v -> note_invoke_tail_arg tbl parent v) args
       | _ -> ()))
    prog.blocks;
  tbl

(* --- Phase 3: qualification ------------------------------------- *)

let qualify_classes stats =
  Hashtbl.fold
    (fun root s acc ->
      if s.in_invoke_tail
         || s.in_entry_params
         || s.in_handler_exn_slot
         || s.size < min_size
         || s.true_uses > max_true_uses
      then acc
      else (root, s) :: acc)
    stats
    []

(* --- Phase 4: rewrite ------------------------------------------- *)

(* Per-class info needed during rewrite. Only [slot] is consulted at
   emission time; every Let that defines any class member stores to
   [slot], and every non-edge use reads from it. A class that lacks
   any Let member is skipped up-front by [build_plans] so we can
   safely assume a write happens before any read. *)
type class_plan = { slot : int }

(* Does any member of the class have a defining [Let] in the
   program body? If not, the class's value has no materialisable
   source in this prog — skip. (Shouldn't happen for a class that
   passed the [in_entry_params] and [in_handler_exn_slot] filters,
   but handle defensively.) *)
let class_has_let_member (prog : program) (cls_members : Var.Set.t) =
  let found = ref false in
  (try
     Addr.Map.iter
       (fun _ (b : block) ->
         Array.iter
           (fun i ->
             match i with
             | Let (v, _) when Var.Set.mem v cls_members ->
               found := true;
               raise Exit
             | _ -> ())
           b.body)
       prog.blocks
   with Exit -> ());
  !found

let build_plans (prog : program) qualified =
  let plans : (Var.t, class_plan) Hashtbl.t =
    Hashtbl.create (List.length qualified)
  in
  let slot = ref 0 in
  List.iter
    (fun (root, (s : class_stats)) ->
      if class_has_let_member prog s.members
      then (
        Hashtbl.replace plans root { slot = !slot };
        incr slot))
    qualified;
  plans, !slot

(* Map each class member -> its root's plan, for quick lookup
   during rewrite. *)
let member_plans parent stats plans =
  let tbl : (Var.t, class_plan) Hashtbl.t = Hashtbl.create 256 in
  Hashtbl.iter
    (fun root (s : class_stats) ->
      match Hashtbl.find_opt plans root with
      | None -> ()
      | Some plan ->
        Var.Set.iter (fun v -> Hashtbl.add tbl v plan) s.members)
    stats;
  (* Suppress unused warnings *)
  ignore parent;
  tbl

(* Per-block keep_mask: boolean array parallel to b.params, true =
   keep, false = purge. Also append a single [true] for the carrier
   param, which every non-entry block receives. *)
let compute_keep_masks (prog : program) mem_plans =
  let masks : (Addr.t, bool array) Hashtbl.t =
    Hashtbl.create (Addr.Map.cardinal prog.blocks)
  in
  Addr.Map.iter
    (fun addr (b : block) ->
      let n = List.length b.params in
      let mask = Array.make n true in
      List.iteri
        (fun i v ->
          if Hashtbl.mem mem_plans v then mask.(i) <- false)
        b.params;
      Hashtbl.add masks addr mask)
    prog.blocks;
  masks

(* For each block, pick the [Var.t] that holds the carrier inside
   that block. Entry: the Let-bound carrier var. Non-entry: a
   fresh param Var that will be appended at purge-time. *)
let allocate_carriers (prog : program) =
  let t : (Addr.t, Var.t) Hashtbl.t =
    Hashtbl.create (Addr.Map.cardinal prog.blocks)
  in
  Addr.Map.iter
    (fun addr _ ->
      Hashtbl.add t addr (Var.fresh ()))
    prog.blocks;
  t

(* Given the class-member lookup and per-instr, rewrite any use of
   a class member with a fresh Field read. Returns (pre_lets,
   substituted_instr). Multiple occurrences of the same class in
   one instr share one fresh. The var being defined by [instr]
   itself is not rewritten even if it's a class member (its Set_
   field is emitted separately after the Let). *)
let rewrite_use_sites ~carrier ~mem_plans used_set =
  let subst : (Var.t, Var.t) Hashtbl.t = Hashtbl.create 8 in
  let pre = ref [] in
  Var.Set.iter
    (fun v ->
      match Hashtbl.find_opt mem_plans v with
      | None -> ()
      | Some plan ->
        let fresh = Var.fresh () in
        Hashtbl.replace subst v fresh;
        pre := Let (fresh, Field (carrier, plan.slot)) :: !pre)
    used_set;
  List.rev !pre, subst

let sub_var subst v =
  try Hashtbl.find subst v with Not_found -> v

let sub_prim_arg subst = function
  | Pv v -> Pv (sub_var subst v)
  | Pc _ as c -> c

let sub_expr subst = function
  | Apply { f; args; exact } ->
    Apply
      { f = sub_var subst f
      ; args = List.map (sub_var subst) args
      ; exact
      }
  | Block (tag, fs) -> Block (tag, Array.map (sub_var subst) fs)
  | Field (v, i) -> Field (sub_var subst v, i)
  | Closure { captures; body } ->
    Closure { captures = List.map (sub_var subst) captures; body }
  | Constant _ as c -> c
  | Prim (p, args) -> Prim (p, List.map (sub_prim_arg subst) args)

let sub_instr subst = function
  | Let (x, e) -> Let (x, sub_expr subst e)
  | Set_field (x, i, y) ->
    Set_field (sub_var subst x, i, sub_var subst y)
  | Offset_ref (x, i) -> Offset_ref (sub_var subst x, i)
  | Array_set (a, i, v) ->
    Array_set (sub_var subst a, sub_var subst i, sub_var subst v)
  | Source_pc _ as s -> s

(* Last-instruction substitution: only touches scrutinee positions
   (Return v / Raise v / Cond v / Switch v). Cont args are handled
   separately by [apply_mask_to_conts] so we can purge + append the
   carrier. *)
let sub_last_scrutinee subst = function
  | Return v -> Return (sub_var subst v)
  | Raise v -> Raise (sub_var subst v)
  | Cond (v, c1, c2) -> Cond (sub_var subst v, c1, c2)
  | Switch (v, ints, tags) -> Switch (sub_var subst v, ints, tags)
  | other -> other

(* Apply [masks.(tgt)] to the args of a cont targeting [tgt], then
   append [carrier_here]. *)
let apply_mask_to_cont ~masks ~carrier_here (tgt, args) =
  let args_arr = Array.of_list args in
  let kept = ref [] in
  (match Hashtbl.find_opt masks tgt with
   | None ->
     (* Target not in this prog (shouldn't happen, but defensive). *)
     kept := args
   | Some mask ->
     for i = Array.length args_arr - 1 downto 0 do
       if i < Array.length mask && mask.(i)
       then kept := args_arr.(i) :: !kept
     done);
  let base = !kept in
  tgt, base @ [ carrier_here ]

(* Rewrite a terminator: filter cont args by a caller's mask, then
   append the carrier. Invoke_tail is passed through unchanged (no
   in-prog target, no carrier threaded to a foreign helper). *)
let rewrite_branch ~masks ~carrier_here = function
  | Branch c -> Branch (apply_mask_to_cont ~masks ~carrier_here c)
  | Cond (v, c1, c2) ->
    Cond
      ( v
      , apply_mask_to_cont ~masks ~carrier_here c1
      , apply_mask_to_cont ~masks ~carrier_here c2 )
  | Switch (v, ints, tags) ->
    Switch
      ( v
      , Array.map (apply_mask_to_cont ~masks ~carrier_here) ints
      , Array.map (apply_mask_to_cont ~masks ~carrier_here) tags )
  | Pushtrap (body, x, handler) ->
    Pushtrap
      ( apply_mask_to_cont ~masks ~carrier_here body
      , x
      , apply_mask_to_cont ~masks ~carrier_here handler )
  | Poptrap c -> Poptrap (apply_mask_to_cont ~masks ~carrier_here c)
  | (Return _ | Raise _ | Stop | Invoke_tail _) as other -> other

let filter_params ~mask params =
  let arr = Array.of_list params in
  let kept = ref [] in
  for i = Array.length arr - 1 downto 0 do
    if i < Array.length mask && mask.(i)
    then kept := arr.(i) :: !kept
  done;
  !kept

(* Rewrite one block: replace body uses of class members with fresh
   Field reads, insert Set_field after class-defining Lets, purge
   params, thread the carrier, fix up the branch. *)
let rewrite_block
      ~prog_start
      ~mem_plans
      ~carriers
      ~masks
      ~carrier_size
      addr
      (b : block)
  =
  let carrier_here = Hashtbl.find carriers addr in
  let out = ref [] in
  let emit i = out := i :: !out in
  (* Entry prelude: alloc the carrier. All class heads are Lets
     (see [build_plans]), so their [Set_field]s are emitted at the
     Let's site later in [rewrite_block], not here. *)
  if addr = prog_start
  then
    emit
      (Let
         ( carrier_here
         , Prim
             ( Extern "alloc_block"
             , [ Pc (Int 0); Pc (Int carrier_size) ] ) ));
  (* Walk body. *)
  Array.iter
    (fun instr ->
      let used = fv_instr instr in
      let defs = defs_of_instr instr in
      let qused = Var.Set.diff used defs in
      let pre, subst =
        rewrite_use_sites ~carrier:carrier_here ~mem_plans qused
      in
      List.iter emit pre;
      let new_instr = sub_instr subst instr in
      emit new_instr;
      (* After any Let that defines a qualifying-class member,
         store the value into that class's carrier slot. A single
         class can have multiple Let members (e.g. two branches
         merging into one target with different sources), and each
         new definition needs to refresh the slot. *)
      match instr with
      | Let (v, _) ->
        (match Hashtbl.find_opt mem_plans v with
         | Some plan -> emit (Set_field (carrier_here, plan.slot, v))
         | None -> ())
      | _ -> ())
    b.body;
  (* Branch scrutinee rewrite (Cond / Switch / Return / Raise). For
     scrutinees we may need a Field read emitted at end of body. *)
  let branch_scrut = fv_last_scrutinee b.branch in
  let pre, subst =
    rewrite_use_sites ~carrier:carrier_here ~mem_plans branch_scrut
  in
  List.iter emit pre;
  let scrut_rewritten = sub_last_scrutinee subst b.branch in
  let new_branch =
    rewrite_branch ~masks ~carrier_here scrut_rewritten
  in
  let new_body = Array.of_list (List.rev !out) in
  let mask = Hashtbl.find masks addr in
  let filtered_params = filter_params ~mask b.params in
  let new_params =
    if addr = prog_start
    then filtered_params
    else filtered_params @ [ carrier_here ]
  in
  { params = new_params; body = new_body; branch = new_branch }

(* --- Entry point ------------------------------------------------ *)

let run (prog : program) : program * stats =
  (* Gate: skip trivial programs. *)
  if Code_cost.program prog < min_program_cost
  then prog, { spilled_classes = 0; carrier_size = 0 }
  else
    let parent = build_uf prog in
    let stats = compute_class_stats prog parent in
    let qualified = qualify_classes stats in
    if qualified = []
    then prog, { spilled_classes = 0; carrier_size = 0 }
    else (
      let plans_by_root, carrier_size = build_plans prog qualified in
      if carrier_size = 0
      then prog, { spilled_classes = 0; carrier_size = 0 }
      else (
        let mem_plans = member_plans parent stats plans_by_root in
        let masks = compute_keep_masks prog mem_plans in
        let carriers = allocate_carriers prog in
        let blocks =
          Addr.Map.mapi
            (fun addr b ->
              rewrite_block
                ~prog_start:prog.start
                ~mem_plans
                ~carriers
                ~masks
                ~carrier_size
                addr
                b)
            prog.blocks
        in
        ( { prog with blocks }
        , { spilled_classes = carrier_size; carrier_size } )))

let f prog =
  let prog, _ = run prog in
  prog
