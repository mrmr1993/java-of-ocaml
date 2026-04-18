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

let classify_return_kind_at arr i func_list (current_fn : function_info) =
  if i = 0
  then K_int
  else
    let prev = arr.(i - 1) in
    if prev.opcode = closure_op
    then (
      let body_pc = prev.pc + prev.args.(1) + 2 in
      match find_function_by_body_pc func_list body_pc with
      | Some (fi : function_info) -> K_closure { name = fi.name; captures = [] }
      | None -> K_int)
    else if prev.opcode = closurerec_op
    then (
      let body_pc = prev.pc + 3 + prev.args.(2) in
      match find_function_by_body_pc func_list body_pc with
      | Some (fi : function_info) -> K_closure { name = fi.name; captures = [] }
      | None -> K_int)
    else if prev.opcode = offsetclosure0_op
         || prev.opcode = pushoffsetclosure0_op
    then K_closure { name = current_fn.name; captures = [] }
    else if prev.opcode = Bytecode.Op.makeblock
         || prev.opcode = Bytecode.Op.makeblock1
         || prev.opcode = Bytecode.Op.makeblock2
         || prev.opcode = Bytecode.Op.makeblock3
    then K_obj
    else if
      let op = prev.opcode in
      op = Bytecode.Op.const0
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
      || is_cmp_nullary op
    then K_int
    else K_obj

let kinds_agree a b =
  match a, b with
  | K_int, K_int -> true
  | K_string, K_string -> true
  | K_closure _, K_closure _ -> true
  | K_block _, K_block _ -> true
  | _ -> false

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
  let observed = ref [] in
  for i = fi.body_start_idx to fi.body_end_idx do
    if is_return arr.(i).opcode
    then observed := classify_return_kind_at arr i func_list fi :: !observed
  done;
  match !observed with
  | [] -> K_int
  | k :: rest when List.for_all (kinds_agree k) rest -> k
  | _ -> K_obj
