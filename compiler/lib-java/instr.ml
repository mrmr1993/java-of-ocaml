type instr =
  { pc : int
  ; opcode : int
  ; args : int array
  }

let decode_all bc =
  let n = Array.length bc.Bytecode.code in
  let rec loop pc acc =
    if pc = n
    then List.rev acc
    else if pc > n
    then
      failwith
        (Printf.sprintf
           "java_of_ocaml: walked past end of code section at pc %d (len %d)"
           pc
           n)
    else
      let size = Bytecode.instr_size bc pc in
      let args =
        Array.init (max 0 (size - 1)) (fun i ->
          bc.Bytecode.code.(pc + 1 + i))
      in
      let instr = { pc; opcode = bc.Bytecode.code.(pc); args } in
      loop (pc + size) (instr :: acc)
  in
  loop 0 []

let is_cmp_jump op =
  op = 131 (* BEQ *) || op = 132 (* BNEQ *) || op = 133 (* BLTINT *)
  || op = 134 (* BLEINT *) || op = 135 (* BGTINT *) || op = 136 (* BGEINT *)

let is_cmp_nullary op =
  op = Bytecode.Op.eq
  || op = Bytecode.Op.neq
  || op = Bytecode.Op.ltint
  || op = Bytecode.Op.leint
  || op = Bytecode.Op.gtint
  || op = Bytecode.Op.geint

let is_c_call op = op >= 93 && op <= 98

let is_acc op =
  (op >= Bytecode.Op.acc0 && op <= Bytecode.Op.acc7)
  || op = Bytecode.Op.acc

let is_pushacc op =
  (op >= Bytecode.Op.pushacc0 && op <= Bytecode.Op.pushacc7)
  || op = Bytecode.Op.pushacc

let closurerec_op = Bytecode.Op.closurerec
let closure_op = Bytecode.Op.closure
let offsetclosure0_op = Bytecode.Op.offsetclosure0
let pushoffsetclosure0_op = Bytecode.Op.pushoffsetclosure0
let offsetclosurem3_op = Bytecode.Op.offsetclosurem3
let offsetclosure3_op = Bytecode.Op.offsetclosure3
let offsetclosure_op = Bytecode.Op.offsetclosure
let pushoffsetclosurem3_op = Bytecode.Op.pushoffsetclosurem3
let pushoffsetclosure3_op = Bytecode.Op.pushoffsetclosure3
let pushoffsetclosure_op = Bytecode.Op.pushoffsetclosure
let apply1_op = Bytecode.Op.apply1
let apply2_op = Bytecode.Op.apply2
let apply3_op = Bytecode.Op.apply3
let apply_op = Bytecode.Op.apply
let appterm_op = Bytecode.Op.appterm
let appterm1_op = Bytecode.Op.appterm1
let appterm2_op = Bytecode.Op.appterm2
let appterm3_op = Bytecode.Op.appterm3
let return_op = Bytecode.Op.return
let restart_op = Bytecode.Op.restart
let grab_op = Bytecode.Op.grab
let event_op = Bytecode.Op.event
let break_op = Bytecode.Op.break

let is_user_op (ins : instr) =
  let op = ins.opcode in
  op = Bytecode.Op.push
  || op = Bytecode.Op.push_retaddr
  || op = Bytecode.Op.pop
  || op = Bytecode.Op.assign
  || is_acc op
  || is_pushacc op
  || op = Bytecode.Op.const0
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
  || op = Bytecode.Op.offsetref
  || op = Bytecode.Op.makeblock
  || op = Bytecode.Op.makeblock1
  || op = Bytecode.Op.makeblock2
  || op = Bytecode.Op.makeblock3
  || op = Bytecode.Op.getfield0
  || op = Bytecode.Op.getfield1
  || op = Bytecode.Op.getfield2
  || op = Bytecode.Op.getfield3
  || op = Bytecode.Op.getfield
  || op = Bytecode.Op.setfield0
  || op = Bytecode.Op.setfield1
  || op = Bytecode.Op.setfield2
  || op = Bytecode.Op.setfield3
  || op = Bytecode.Op.setfield
  || op = Bytecode.Op.vectlength
  || op = Bytecode.Op.addint
  || op = Bytecode.Op.subint
  || op = Bytecode.Op.mulint
  || op = Bytecode.Op.divint
  || op = Bytecode.Op.modint
  || is_cmp_nullary op
  || op = Bytecode.Op.getglobal
  || op = Bytecode.Op.pushgetglobal
  || op = Bytecode.Op.branch
  || op = Bytecode.Op.branchif
  || op = Bytecode.Op.branchifnot
  || op = Bytecode.Op.switch
  || op = Bytecode.Op.pushtrap
  || op = Bytecode.Op.poptrap
  || op = Bytecode.Op.raise_
  || op = Bytecode.Op.reraise
  || op = Bytecode.Op.raise_notrace
  || op = Bytecode.Op.isint
  || op = Bytecode.Op.boolnot
  || is_cmp_jump op
  || is_c_call op
  || op = closurerec_op
  || op = closure_op
  || op = offsetclosure0_op
  || op = pushoffsetclosure0_op
  || op = offsetclosurem3_op
  || op = offsetclosure3_op
  || op = offsetclosure_op
  || op = pushoffsetclosurem3_op
  || op = pushoffsetclosure3_op
  || op = pushoffsetclosure_op
  || op = Bytecode.Op.envacc1
  || op = Bytecode.Op.envacc2
  || op = Bytecode.Op.envacc3
  || op = Bytecode.Op.envacc4
  || op = Bytecode.Op.envacc
  || op = Bytecode.Op.pushenvacc1
  || op = Bytecode.Op.pushenvacc2
  || op = Bytecode.Op.pushenvacc3
  || op = Bytecode.Op.pushenvacc4
  || op = Bytecode.Op.pushenvacc
  || op = apply1_op
  || op = apply2_op
  || op = apply3_op
  || op = apply_op
  || op = appterm_op
  || op = appterm1_op
  || op = appterm2_op
  || op = appterm3_op
  || op = return_op
  || op = restart_op
  || op = grab_op
  || op = event_op
  || op = break_op
  || op = 92 (* CHECK_SIGNALS — no-op at our level *)

let branch_target (ins : instr) =
  let op = ins.opcode in
  if op = Bytecode.Op.branch
     || op = Bytecode.Op.branchif
     || op = Bytecode.Op.branchifnot
     || op = Bytecode.Op.pushtrap
  then Some (ins.pc + ins.args.(0) + 1)
  else if is_cmp_jump op
  then Some (ins.pc + ins.args.(1) + 2)
  else None

let branch_targets (ins : instr) =
  if ins.opcode = Bytecode.Op.switch
  then (
    let sizes = ins.args.(0) in
    let num_ints = sizes land 0xffff in
    let num_tags = (sizes lsr 16) land 0xffff in
    let total = num_ints + num_tags in
    let targets = ref [] in
    for i = 0 to total - 1 do
      targets := (ins.pc + 2 + ins.args.(1 + i)) :: !targets
    done;
    !targets)
  else
    match branch_target ins with
    | Some t -> [ t ]
    | None -> []
