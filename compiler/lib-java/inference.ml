open Kind
open Instr
open Function_info
open Prim

let supported_call_indices arr ~prim_table =
  let n = Array.length arr in
  let is_seed_call ins =
    is_c_call ins.opcode
    &&
    match Hashtbl.find_opt prim_table ins.args.(0) with
    | Some (_, _, seed) -> seed
    | None -> false
  in
  let rec find_first i =
    if i >= n then None
    else if is_seed_call arr.(i) then Some i
    else find_first (i + 1)
  in
  let rec find_last i =
    if i < 0 then None
    else if is_seed_call arr.(i) then Some i
    else find_last (i - 1)
  in
  match find_first 0, find_last (n - 1) with
  | Some f, Some l -> Some (f, l)
  | _ -> None

let walk_back_user_start arr start_idx =
  let rec loop i =
    if i < 0 then 0
    else if is_user_op arr.(i) then loop (i - 1)
    else i + 1
  in
  loop (start_idx - 1)

let walk_forward_user_end arr end_idx =
  let n = Array.length arr in
  let rec loop i =
    if i >= n then n - 1
    else if is_user_op arr.(i) then loop (i + 1)
    else i - 1
  in
  loop (end_idx + 1)

let find_function_by_body_pc func_list body_pc =
  List.find_opt (fun (fi : function_info) -> fi.body_pc = body_pc) func_list

(* A terminator — its continuation is whatever jump target it names,
   and there's no fall-through to the next instruction. *)
let is_terminator op =
  op = return_op
  || op = appterm_op
  || op = appterm1_op
  || op = appterm2_op
  || op = appterm3_op
  || op = Bytecode.Op.raise_
  || op = Bytecode.Op.reraise
  || op = Bytecode.Op.raise_notrace
  || op = Bytecode.Op.stop
  || op = Bytecode.Op.branch

(* Per-function predecessor table: for each body-local index, the
   list of indices whose control flow can reach it. Includes:
   - fall-through (the instruction before, unless that one was a
     terminator)
   - branch targets (any instruction that can jump here)
   Keyed by idx, not pc. *)
let build_predecessors arr ~lo ~hi =
  let pc_to_idx = Hashtbl.create (hi - lo + 1) in
  for i = lo to hi do
    Hashtbl.replace pc_to_idx arr.(i).pc i
  done;
  let preds = Hashtbl.create (hi - lo + 1) in
  let add_pred target src =
    let existing =
      try Hashtbl.find preds target with Not_found -> []
    in
    Hashtbl.replace preds target (src :: existing)
  in
  for i = lo to hi do
    let ins = arr.(i) in
    let op = ins.opcode in
    List.iter
      (fun target_pc ->
        match Hashtbl.find_opt pc_to_idx target_pc with
        | Some target_idx -> add_pred target_idx i
        | None -> ())
      (branch_targets ins);
    (* Fall-through edge to the next instruction unless this was a
       terminator. *)
    if (not (is_terminator op)) && i + 1 <= hi
    then add_pred (i + 1) i
  done;
  preds

let predecessors_of preds idx =
  try Hashtbl.find preds idx with Not_found -> []

(* [instruction_acc_kind arr i func_list fi]: the kind this
   instruction leaves in acc, when it's a "value producer" (writes
   acc). Returns [None] for instructions that don't touch acc
   (PUSH, POP, SETFIELD, branches, PUSHTRAP, POPTRAP, …) so the
   reverse walk continues through them. *)
let instruction_acc_kind
    arr
    i
    (func_list : function_info list)
    (current_fn : function_info)
  =
  let ins = arr.(i) in
  let op = ins.opcode in
  let offsetclosure_sibling offset =
    (* OFFSETCLOSURE N: move [N/3] sibling positions within the
       enclosing CLOSUREREC group. Return kind is a closure pointing
       at the resolved sibling. *)
    let target_idx = current_fn.group_idx + (offset / 3) in
    if target_idx >= 0 && target_idx < Array.length current_fn.group
    then (
      let target = current_fn.group.(target_idx) in
      Some (K_closure { name = target.name; captures = [] }))
    else Some K_obj
  in
  if op = closure_op
  then (
    let body_pc = ins.pc + ins.args.(1) + 2 in
    match find_function_by_body_pc func_list body_pc with
    | Some (fi : function_info) ->
      Some (K_closure { name = fi.name; captures = [] })
    | None -> Some K_obj)
  else if op = closurerec_op
  then (
    let body_pc = ins.pc + 3 + ins.args.(2) in
    match find_function_by_body_pc func_list body_pc with
    | Some (fi : function_info) ->
      Some (K_closure { name = fi.name; captures = [] })
    | None -> Some K_obj)
  else if op = offsetclosure0_op || op = pushoffsetclosure0_op
  then Some (K_closure { name = current_fn.name; captures = [] })
  else if op = offsetclosurem3_op || op = pushoffsetclosurem3_op
  then offsetclosure_sibling (-3)
  else if op = offsetclosure3_op || op = pushoffsetclosure3_op
  then offsetclosure_sibling 3
  else if op = offsetclosure_op || op = pushoffsetclosure_op
  then offsetclosure_sibling ins.args.(0)
  else if op = Bytecode.Op.makeblock
       || op = Bytecode.Op.makeblock1
       || op = Bytecode.Op.makeblock2
       || op = Bytecode.Op.makeblock3
       || op = Bytecode.Op.makefloatblock
       || op = Bytecode.Op.atom0
       || op = Bytecode.Op.atom
       || op = Bytecode.Op.pushatom0
       || op = Bytecode.Op.pushatom
  then Some K_obj
  else if op = Bytecode.Op.const0
       || op = Bytecode.Op.const1
       || op = Bytecode.Op.const2
       || op = Bytecode.Op.const3
       || op = Bytecode.Op.constint
       || op = Bytecode.Op.pushconst0
       || op = Bytecode.Op.pushconst1
       || op = Bytecode.Op.pushconst2
       || op = Bytecode.Op.pushconst3
       || op = Bytecode.Op.pushconstint
       || op = Bytecode.Op.offsetint
       || op = Bytecode.Op.negint
       || op = Bytecode.Op.addint
       || op = Bytecode.Op.subint
       || op = Bytecode.Op.mulint
       || op = Bytecode.Op.divint
       || op = Bytecode.Op.modint
       || op = Bytecode.Op.andint
       || op = Bytecode.Op.orint
       || op = Bytecode.Op.xorint
       || op = Bytecode.Op.lslint
       || op = Bytecode.Op.lsrint
       || op = Bytecode.Op.asrint
       || op = Bytecode.Op.vectlength
       || op = Bytecode.Op.isint
       || op = Bytecode.Op.boolnot
       || op = Bytecode.Op.ultint
       || op = Bytecode.Op.ugeint
       || op = Bytecode.Op.getstringchar
       || op = Bytecode.Op.getbyteschar
       || is_cmp_nullary op
  then Some K_int
  else if op = Bytecode.Op.getfloatfield
  then Some K_float
  else if op = Bytecode.Op.getfield0
       || op = Bytecode.Op.getfield1
       || op = Bytecode.Op.getfield2
       || op = Bytecode.Op.getfield3
       || op = Bytecode.Op.getfield
       || op = Bytecode.Op.getvectitem
       || op = Bytecode.Op.getglobal
       || op = Bytecode.Op.pushgetglobal
       || op = Bytecode.Op.getglobalfield
       || op = Bytecode.Op.pushgetglobalfield
  then Some K_obj
  else if is_c_call op
  then Some K_obj
  else if op = apply_op
       || op = apply1_op
       || op = apply2_op
       || op = apply3_op
  then Some K_obj
  else if op = Bytecode.Op.envacc1
       || op = Bytecode.Op.envacc2
       || op = Bytecode.Op.envacc3
       || op = Bytecode.Op.envacc4
       || op = Bytecode.Op.envacc
       || op = Bytecode.Op.pushenvacc1
       || op = Bytecode.Op.pushenvacc2
       || op = Bytecode.Op.pushenvacc3
       || op = Bytecode.Op.pushenvacc4
       || op = Bytecode.Op.pushenvacc
  then Some K_obj
  else if op = Bytecode.Op.acc0
       || op = Bytecode.Op.acc1
       || op = Bytecode.Op.acc2
       || op = Bytecode.Op.acc3
       || op = Bytecode.Op.acc4
       || op = Bytecode.Op.acc5
       || op = Bytecode.Op.acc6
       || op = Bytecode.Op.acc7
       || op = Bytecode.Op.acc
       || op = Bytecode.Op.pushacc0
       || op = Bytecode.Op.pushacc1
       || op = Bytecode.Op.pushacc2
       || op = Bytecode.Op.pushacc3
       || op = Bytecode.Op.pushacc4
       || op = Bytecode.Op.pushacc5
       || op = Bytecode.Op.pushacc6
       || op = Bytecode.Op.pushacc7
       || op = Bytecode.Op.pushacc
  then Some K_obj
  else None

(* Path-unioning return-kind inference: for each RETURN / APPTERM,
   reverse-BFS through predecessors until we hit a value producer.
   Union the kinds over all paths.

   Bounded to avoid pathological bytecode — cap at [max_edges]
   edges explored per return site. On overflow we conservatively
   yield [K_obj] for the whole walk. *)
let max_edges = 200

let collect_return_kinds arr preds start_idx func_list current_fn =
  let visited = Hashtbl.create 16 in
  let kinds = ref [] in
  let explored = ref 0 in
  let overflow = ref false in
  let rec loop worklist =
    if !overflow
    then ()
    else
      match worklist with
      | [] -> ()
      | idx :: rest when idx < 0 || Hashtbl.mem visited idx -> loop rest
      | idx :: rest ->
        incr explored;
        if !explored > max_edges
        then overflow := true
        else (
          Hashtbl.add visited idx ();
          match instruction_acc_kind arr idx func_list current_fn with
          | Some k ->
            kinds := k :: !kinds;
            loop rest
          | None ->
            let preds_of = predecessors_of preds idx in
            loop (preds_of @ rest))
  in
  loop (predecessors_of preds start_idx);
  if !overflow then None else Some !kinds

let kinds_agree a b =
  match a, b with
  | K_int, K_int -> true
  | K_string, K_string -> true
  | K_float, K_float -> true
  | K_closure _, K_closure _ -> true
  | K_block _, K_block _ -> true
  | K_obj, K_obj -> true
  | _ -> false

let union_kinds = function
  | [] -> K_obj
  | k :: rest when List.for_all (kinds_agree k) rest -> k
  | _ -> K_obj

let infer_arg_kinds arr prim_table (fi : function_info) =
  let kinds = Array.make fi.nargs K_int in
  let is_print_endline_prim idx =
    match Hashtbl.find_opt prim_table idx with
    | Some (_, P_println_string, _) -> true
    | _ -> false
  in
  let acc_arg_index op args =
    if op >= Bytecode.Op.acc0 && op <= Bytecode.Op.acc7
    then Some (op - Bytecode.Op.acc0)
    else if op = Bytecode.Op.acc
    then Some args.(0)
    else None
  in
  for i = fi.body_start_idx to fi.body_end_idx do
    let ins = arr.(i) in
    if ins.opcode = Bytecode.Op.c_call1
       && is_print_endline_prim ins.args.(0)
       && i > fi.body_start_idx
    then (
      let prev = arr.(i - 1) in
      match acc_arg_index prev.opcode prev.args with
      | Some k when k < fi.nargs -> kinds.(k) <- K_string
      | _ -> ())
  done;
  Array.to_list kinds

let infer_return_kind arr (func_list : function_info list) (fi : function_info) =
  let is_return op =
    op = return_op
    || op = appterm_op
    || op = appterm1_op
    || op = appterm2_op
    || op = appterm3_op
  in
  let preds =
    build_predecessors arr ~lo:fi.body_start_idx ~hi:fi.body_end_idx
  in
  let all_kinds = ref [] in
  let overflowed = ref false in
  for i = fi.body_start_idx to fi.body_end_idx do
    if is_return arr.(i).opcode
    then (
      match collect_return_kinds arr preds i func_list fi with
      | None -> overflowed := true
      | Some ks -> all_kinds := ks @ !all_kinds)
  done;
  if !overflowed
  then K_obj
  else (
    match !all_kinds with
    | [] -> K_int
    | ks -> union_kinds ks)
