open Code

type def_site =
  | Block_param of Addr.t * int
  | Let_instr of Addr.t * int
  | Exn_var of Addr.t

type use_site =
  | In_body of Addr.t * int
  | In_branch of Addr.t
  | In_branch_arg of Addr.t * int

type t =
  { defs : (Var.t, def_site) Hashtbl.t
  ; uses : (Var.t, use_site list ref) Hashtbl.t
  }

let record_def t v site =
  (* A Var should have exactly one def in strict SSA; guard against
     duplicate adds so bugs surface as an exception rather than a
     silently-stale entry. *)
  if Hashtbl.mem t.defs v
  then
    failwith
      (Printf.sprintf
         "Def_use: duplicate definition of %s"
         (Var.get_name v |> Option.value ~default:"<anon>"))
  else Hashtbl.add t.defs v site

let record_use t v site =
  let cell =
    match Hashtbl.find_opt t.uses v with
    | Some c -> c
    | None ->
      let c = ref [] in
      Hashtbl.add t.uses v c;
      c
  in
  cell := site :: !cell

let visit_cont t addr (_target, args) =
  List.iteri (fun i v -> record_use t v (In_branch_arg (addr, i))) args

let visit_last t addr (last : last) =
  (* The terminator's scrutinee / Return / Raise / Invoke_tail
     args go through [In_branch]; edge-arg positions go through
     [In_branch_arg]. The [Pushtrap]'s exn_var is a *def* (bound
     by the Pushtrap), not a use, and is handled separately. *)
  match last with
  | Return v | Raise v -> record_use t v (In_branch addr)
  | Stop -> ()
  | Branch c -> visit_cont t addr c
  | Cond (v, c1, c2) ->
    record_use t v (In_branch addr);
    visit_cont t addr c1;
    visit_cont t addr c2
  | Switch (v, ints, tags) ->
    record_use t v (In_branch addr);
    Array.iter (visit_cont t addr) ints;
    Array.iter (visit_cont t addr) tags
  | Pushtrap (body, exn_var, handler) ->
    record_def t exn_var (Exn_var addr);
    visit_cont t addr body;
    visit_cont t addr handler
  | Poptrap c -> visit_cont t addr c
  | Invoke_tail { args; _ } ->
    List.iter (fun v -> record_use t v (In_branch addr)) args

let visit_instr t addr i instr =
  let uses = Var_refs.fv_instr instr in
  Var.Set.iter (fun v -> record_use t v (In_body (addr, i))) uses;
  match instr with
  | Let (v, _) -> record_def t v (Let_instr (addr, i))
  | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> ()

let of_program (prog : program) : t =
  let n = Addr.Map.cardinal prog.blocks in
  let t =
    { defs = Hashtbl.create (4 * n)
    ; uses = Hashtbl.create (4 * n)
    }
  in
  Addr.Map.iter
    (fun addr (b : block) ->
      List.iteri
        (fun i v -> record_def t v (Block_param (addr, i)))
        b.params;
      Array.iteri (fun i instr -> visit_instr t addr i instr) b.body;
      visit_last t addr b.branch)
    prog.blocks;
  t

let def_of t v = Hashtbl.find_opt t.defs v

let uses_of t v =
  match Hashtbl.find_opt t.uses v with
  | Some cell -> !cell
  | None -> []
