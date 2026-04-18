open Kind
open Instr

type function_info =
  { name : string
  ; closurerec_pc : int [@warning "-69"]
  ; body_pc : int
  ; body_start_idx : int
  ; body_end_idx : int
  ; nargs : int
  ; ncaps : int [@warning "-69"]
  ; return_kind : kind ref
  ; arg_kinds : kind list ref
  ; capture_kinds : kind list ref
  ; recursive : bool [@warning "-69"]
  ; group_idx : int [@warning "-69"]
  ; mutable group : function_info array
  }

module Int_set = Set.Make (Int)

let find_function_body_range arr body_pc =
  let n = Array.length arr in
  let start_idx = ref (-1) in
  for i = 0 to n - 1 do
    if !start_idx < 0 && arr.(i).pc = body_pc then start_idx := i
  done;
  if !start_idx < 0
  then
    failwith (Printf.sprintf "java_of_ocaml: no instruction at body_pc %d" body_pc);
  let real_start = ref !start_idx in
  if arr.(!real_start).opcode = restart_op then incr real_start;
  let nargs =
    if arr.(!real_start).opcode = grab_op
    then (
      let n = arr.(!real_start).args.(0) + 1 in
      incr real_start;
      n)
    else 1
  in
  let outstanding = ref Int_set.empty in
  let rec loop i =
    if i >= n
    then
      failwith "java_of_ocaml: walked past end of code while tracing function body"
    else
      let ins = arr.(i) in
      outstanding := Int_set.remove ins.pc !outstanding;
      List.iter
        (fun t ->
          if t <> ins.pc then outstanding := Int_set.add t !outstanding)
        (branch_targets ins);
      let ends_here =
        (ins.opcode = return_op
         || ins.opcode = appterm_op
         || ins.opcode = appterm1_op
         || ins.opcode = appterm2_op
         || ins.opcode = appterm3_op
         || ins.opcode = Bytecode.Op.stop
         || ins.opcode = Bytecode.Op.raise_
         || ins.opcode = Bytecode.Op.reraise
         || ins.opcode = Bytecode.Op.raise_notrace)
        && Int_set.is_empty !outstanding
      in
      if ends_here then i else loop (i + 1)
  in
  let end_idx = loop !real_start in
  !real_start, end_idx, nargs
