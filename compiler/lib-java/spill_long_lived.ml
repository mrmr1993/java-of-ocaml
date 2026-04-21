open Code

(* --- Config ----------------------------------------------------- *)

(* Block bodies shorter than this never benefit from spilling — the
   alloc-block overhead dominates the per-var save. *)
let min_body_len = 30

(* Span threshold for "long-lived": a var is a candidate if its last
   use sits at least [long_span_num / long_span_den] of the body
   past its definition. Matches the 80% threshold used in the
   [split_lifetimes] instrumentation. *)
let long_span_num = 80
let long_span_den = 100

(* Use-count ceiling. Vars used more than this many times pay too
   much in per-use [Field] reads to benefit. 2 captures the
   single-use + through-join pattern the stats showed dominating. *)
let max_few_uses = 2

(* Don't bother unless we can spill at least this many vars per
   block; otherwise the ~15-byte alloc prolog is paying too much
   for too little. *)
let min_qualifying = 4

(* --- Free-var / def helpers (shared in [Var_refs]) -------------- *)

let fv_instr = Var_refs.fv_instr
let fv_last = Var_refs.fv_last
let defs_of_instr = Var_refs.defs_of_instr

(* --- Use-count (occurrences, not set membership) ---------------- *)

let count_uses_in_block (b : block) =
  let counts : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
  let bump v =
    let c = try Hashtbl.find counts v with Not_found -> 0 in
    Hashtbl.replace counts v (c + 1)
  in
  let bump_pa = function Pv v -> bump v | Pc _ -> () in
  let bump_expr = function
    | Apply { f; args; _ } -> bump f; List.iter bump args
    | Block (_, fs) -> Array.iter bump fs
    | Field (v, _) -> bump v
    | Closure { captures; _ } -> List.iter bump captures
    | Constant _ -> ()
    | Prim (_, args) -> List.iter bump_pa args
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
    | Pushtrap (body, _, handler) -> bump_cont body; bump_cont handler
    | Poptrap c -> bump_cont c
    | Invoke_tail { args; _ } -> List.iter bump args
  in
  Array.iter bump_instr b.body;
  bump_last b.branch;
  counts

(* --- Qualifier selection ---------------------------------------- *)

(* Returns [(var, slot_index)] for each var that meets the long-lived
   + few-use gate. Slot assignment follows def-order for
   determinism. *)
let qualifying (b : block) =
  let n = Array.length b.body in
  if n < min_body_len
  then []
  else (
    let long_threshold = max 1 (n * long_span_num / long_span_den) in
    (* def_pos: -1 for params, body index for body-defined. *)
    let def_pos : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
    List.iter (fun v -> Hashtbl.replace def_pos v (-1)) b.params;
    Array.iteri
      (fun k instr ->
        Var.Set.iter
          (fun v -> Hashtbl.replace def_pos v k)
          (defs_of_instr instr))
      b.body;
    (* last-use: max body index where referenced (n for branch). *)
    let last_use : (Var.t, int) Hashtbl.t = Hashtbl.create 64 in
    Array.iteri
      (fun k instr ->
        Var.Set.iter
          (fun v -> Hashtbl.replace last_use v k)
          (fv_instr instr))
      b.body;
    Var.Set.iter
      (fun v -> Hashtbl.replace last_use v n)
      (fv_last b.branch);
    let uses = count_uses_in_block b in
    let rows = ref [] in
    Hashtbl.iter
      (fun v dp ->
        match Hashtbl.find_opt last_use v with
        | None -> ()
        | Some lu ->
          let span = lu - dp in
          let uc = try Hashtbl.find uses v with Not_found -> 0 in
          if span >= long_threshold && uc <= max_few_uses && uc >= 1
          then rows := (v, dp) :: !rows)
      def_pos;
    (* Order by def-position so slot indices are stable / readable. *)
    let ordered =
      List.sort (fun (_, a) (_, b) -> compare a b) !rows
      |> List.map fst
    in
    if List.length ordered < min_qualifying
    then []
    else List.mapi (fun i v -> v, i) ordered)

(* --- Per-instruction substitution ------------------------------- *)

(* Rewrite each occurrence of a qualifying var [v] in an expression
   to [subst v], leaving other vars untouched. [subst] is a
   per-instruction mapping populated by the caller. *)
let sub_var subst v = try Hashtbl.find subst v with Not_found -> v

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
  | Invoke_helper ({ args; _ } as i) ->
    Invoke_helper { i with args = List.map (sub_var subst) args }

let sub_instr subst = function
  | Let (x, e) -> Let (x, sub_expr subst e)
  | Set_field (x, i, y) ->
    Set_field (sub_var subst x, i, sub_var subst y)
  | Offset_ref (x, i) -> Offset_ref (sub_var subst x, i)
  | Array_set (a, i, v) ->
    Array_set (sub_var subst a, sub_var subst i, sub_var subst v)
  | Source_pc _ as s -> s

let sub_cont subst (a, args) = a, List.map (sub_var subst) args

let sub_last subst = function
  | Return v -> Return (sub_var subst v)
  | Raise v -> Raise (sub_var subst v)
  | Stop -> Stop
  | Branch c -> Branch (sub_cont subst c)
  | Cond (v, c1, c2) ->
    Cond (sub_var subst v, sub_cont subst c1, sub_cont subst c2)
  | Switch (v, ints, tags) ->
    Switch
      ( sub_var subst v
      , Array.map (sub_cont subst) ints
      , Array.map (sub_cont subst) tags )
  | Pushtrap (body, x, handler) ->
    Pushtrap (sub_cont subst body, x, sub_cont subst handler)
  | Poptrap c -> Poptrap (sub_cont subst c)
  | Invoke_tail { class_; method_; descriptor; args; is_static } ->
    Invoke_tail
      { class_
      ; method_
      ; descriptor
      ; args = List.map (sub_var subst) args
      ; is_static
      }

(* --- Block rewrite ---------------------------------------------- *)

let rewrite_block (b : block) =
  match qualifying b with
  | [] -> b
  | qualified ->
    let slot_of : (Var.t, int) Hashtbl.t = Hashtbl.create 16 in
    List.iter (fun (v, slot) -> Hashtbl.replace slot_of v slot) qualified;
    let is_qualifying v = Hashtbl.mem slot_of v in
    let spill = Var.fresh () in
    let n = List.length qualified in
    let emit_alloc_and_param_stores () =
      let alloc =
        Let
          ( spill
          , Prim
              ( Extern "alloc_block"
              , [ Pc (Int 0); Pc (Int n) ] ) )
      in
      let stores =
        List.filter_map
          (fun v ->
            if is_qualifying v
            then Some (Set_field (spill, Hashtbl.find slot_of v, v))
            else None)
          b.params
      in
      alloc :: stores
    in
    (* Walk body. For each instruction, synthesise per-use
       [Let (fresh, Field (spill, slot))] pre-instructions for every
       qualifying var referenced (except the var being defined by
       this instr itself, which is the source for the Set_field we
       emit AFTER the instr). Same qualifying var referenced twice
       in one instr → one fresh suffices. *)
    let rewrite_use_sites used_qvars =
      let subst : (Var.t, Var.t) Hashtbl.t =
        Hashtbl.create (Var.Set.cardinal used_qvars)
      in
      let pre =
        Var.Set.fold
          (fun qv acc ->
            let fresh = Var.fresh () in
            Hashtbl.replace subst qv fresh;
            Let (fresh, Field (spill, Hashtbl.find slot_of qv)) :: acc)
          used_qvars
          []
      in
      pre, subst
    in
    let out = ref (List.rev (emit_alloc_and_param_stores ())) in
    let emit i = out := i :: !out in
    Array.iter
      (fun instr ->
        let used = fv_instr instr in
        (* Don't rewrite the var the instr is about to *define* —
           that one's value comes from the expr, not the spill. *)
        let defs = defs_of_instr instr in
        let qused = Var.Set.filter is_qualifying (Var.Set.diff used defs) in
        let pre, subst = rewrite_use_sites qused in
        List.iter emit pre;
        let new_instr = sub_instr subst instr in
        emit new_instr;
        (* If this Let defines a qualifying var, store to spill. *)
        match instr with
        | Let (v, _) when is_qualifying v ->
          emit (Set_field (spill, Hashtbl.find slot_of v, v))
        | _ -> ())
      b.body;
    (* Branch rewrite: emit Lets at end of body, substitute in the
       terminator. *)
    let branch_used = fv_last b.branch in
    let qbranch_used = Var.Set.filter is_qualifying branch_used in
    let pre, subst = rewrite_use_sites qbranch_used in
    List.iter emit pre;
    let new_branch = sub_last subst b.branch in
    let new_body = Array.of_list (List.rev !out) in
    { b with body = new_body; branch = new_branch }

(* --- Program entry ---------------------------------------------- *)

let f (prog : program) : program =
  let blocks = Addr.Map.map rewrite_block prog.blocks in
  { prog with blocks }
