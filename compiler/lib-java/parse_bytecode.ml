(* Lower OCaml bytecode to the Code IR.

   Mirrors js_of_ocaml/compiler/lib/parse_bytecode.ml in structure:
   compute block boundaries by scanning branches, then process each
   block with a State threading accu + stack, emitting Let/Assign/etc
   and a block terminator. *)

open Code

exception Not_supported of string

module IntSet = Set.Make (Int)
module IntMap = Map.Make (Int)

(* ------------------------------------------------------------------
   Block boundary discovery
   ------------------------------------------------------------------ *)

(* [block_starts] returns the sorted set of PCs that start a block
   within [start_pc..end_pc). A block starts at:
   - [start_pc] itself
   - any branch target
   - the PC immediately after a terminator
   - the PC immediately after a PUSHTRAP (the handler prelude target)
     is already covered as a branch target, and the fall-through PC
     starts a block too. *)
let block_starts instrs ~start_pc ~end_pc =
  let s = ref (IntSet.singleton start_pc) in
  let in_range pc = pc >= start_pc && pc < end_pc in
  let add pc = if in_range pc then s := IntSet.add pc !s in
  List.iter
    (fun (ins : Instr.instr) ->
      if in_range ins.pc
      then (
        List.iter add (Instr.branch_targets ins);
        if Instr.is_terminator ins.opcode
           || ins.opcode = Bytecode.Op.pushtrap
           || ins.opcode = Bytecode.Op.poptrap
        then
          (* PC after the instruction starts a new block. We need the
             next instruction's pc; find the successor from the array
             below. *)
          ()))
    instrs;
  (* Add PCs after terminators / trap ops; do it in a second pass that
     knows instruction successors. *)
  let arr = Array.of_list instrs in
  for i = 0 to Array.length arr - 1 do
    let ins = arr.(i) in
    if in_range ins.pc
       && (Instr.is_terminator ins.opcode
          || ins.opcode = Bytecode.Op.pushtrap
          || ins.opcode = Bytecode.Op.poptrap)
       && i + 1 < Array.length arr
    then add arr.(i + 1).pc
  done;
  !s

(* ------------------------------------------------------------------
   Parser state
   ------------------------------------------------------------------ *)

(* [elt] matches jsoo's: a stack slot is either a live Var or a Dummy
   placeholder (PUSH_RETADDR sentinels, PUSHTRAP trap-frame words).
   Dummies are never materialised in the IR; they only keep the stack
   depth consistent so ACC k resolves to the right slot. *)
type elt =
  | V of Var.t
  | Dummy

type state =
  { mutable accu : elt
  ; mutable stack : elt list
  ; mutable body : instr list
  ; target_params : (Addr.t, Var.t list) Hashtbl.t
  }

let emit s i = s.body <- i :: s.body

let var_of = function
  | V v -> v
  | Dummy -> raise (Not_supported "read of Dummy stack slot")

(* Retrieve or allocate the canonical params list for a target block. *)
let params_for state addr ~accu_and_stack =
  match Hashtbl.find_opt state.target_params addr with
  | Some ps -> ps
  | None ->
    let ps = List.map (fun _ -> Var.fresh ()) accu_and_stack in
    Hashtbl.add state.target_params addr ps;
    ps

(* ------------------------------------------------------------------
   Constant conversion: OCaml [Obj.t] -> [Code.constant]
   ------------------------------------------------------------------ *)

let[@warning "-32"] rec constant_of_obj (o : Obj.t) : constant =
  if Obj.is_int o
  then Int (Obj.magic o : int)
  else
    let t = Obj.tag o in
    if t = Obj.string_tag
    then String (Obj.magic o : string)
    else if t = Obj.double_tag
    then Float (Obj.magic o : float)
    else if t < Obj.no_scan_tag
    then (
      let n = Obj.size o in
      let fields = Array.init n (fun i -> constant_of_obj (Obj.field o i)) in
      Block (t, fields))
    else raise (Not_supported (Printf.sprintf "unsupported global tag %d" t))

(* ------------------------------------------------------------------
   Accumulator / stack helpers
   ------------------------------------------------------------------ *)

let push_elt s e = s.stack <- e :: s.stack
let pop s =
  match s.stack with
  | [] -> raise (Not_supported "pop on empty stack")
  | x :: rest -> s.stack <- rest; x
let pop_var s = var_of (pop s)

let take_args s n =
  let rec loop i acc =
    if i = 0 then List.rev acc
    else loop (i - 1) (pop_var s :: acc)
  in
  loop n []

let set_accu_let s e =
  let x = Var.fresh () in
  emit s (Let (x, e));
  s.accu <- V x

(* ------------------------------------------------------------------
   Per-opcode lowering
   ------------------------------------------------------------------ *)

(* Given a prim + N args popped/consumed from accu + stack, bind the
   result to a fresh Var and leave it in accu. *)
let binop s p =
  let a = var_of s.accu in
  let b = pop_var s in
  set_accu_let s (Prim (p, [ Pv a; Pv b ]))

let unop s p =
  let a = var_of s.accu in
  set_accu_let s (Prim (p, [ Pv a ]))

let const_int s n =
  set_accu_let s (Constant (Int n))


(* For slot-read/write (ACC / ASSIGN): OCaml stack is 0-indexed from
   the top; stack[0] = top. *)
let nth_stack s k =
  try List.nth s.stack k
  with _ -> raise (Not_supported (Printf.sprintf "stack index %d out of range" k))

let acc s k = s.accu <- nth_stack s k

(* ------------------------------------------------------------------
   Block processing
   ------------------------------------------------------------------ *)

let s_to_list state =
  let of_elt = function
    | V v -> v
    | Dummy -> raise (Not_supported "Dummy slot spans a block boundary")
  in
  of_elt state.accu :: List.map of_elt state.stack

(* Produce a cont = (target_pc, args) by materialising accu + stack as
   the args for a caller block's params. *)
let make_cont state target_pc =
  let accu_and_stack = s_to_list state in
  let _params = params_for state target_pc ~accu_and_stack in
  (target_pc, accu_and_stack)

(* Advance the state by one instruction. Returns [Some last] if the
   instruction was a terminator, [None] otherwise. *)
let step (state : state) (ins : Instr.instr) : last option =
  let op = ins.opcode in
  let args = ins.args in
  let nullary p = unop state p in
  let _ = nullary in
  (* ACC k *)
  if Instr.is_acc op
  then (
    let k = if op = Bytecode.Op.acc then args.(0) else op - Bytecode.Op.acc0 in
    acc state k;
    None)
  else if Instr.is_pushacc op
  then (
    let k =
      if op = Bytecode.Op.pushacc then args.(0) else op - Bytecode.Op.pushacc0
    in
    push_elt state state.accu;
    acc state k;
    None)
  else if op = Bytecode.Op.push
  then (
    push_elt state state.accu;
    None)
  else if op = Bytecode.Op.pop
  then (
    for _ = 1 to args.(0) do
      ignore (pop state)
    done;
    None)
  else if op = Bytecode.Op.push_retaddr
  then (
    push_elt state Dummy;
    push_elt state Dummy;
    push_elt state Dummy;
    None)
  else if op = Bytecode.Op.const0
  then (const_int state 0; None)
  else if op = Bytecode.Op.const1
  then (const_int state 1; None)
  else if op = Bytecode.Op.const2
  then (const_int state 2; None)
  else if op = Bytecode.Op.const3
  then (const_int state 3; None)
  else if op = Bytecode.Op.constint
  then (const_int state args.(0); None)
  else if op = Bytecode.Op.pushconst0
  then (push_elt state state.accu; const_int state 0; None)
  else if op = Bytecode.Op.pushconst1
  then (push_elt state state.accu; const_int state 1; None)
  else if op = Bytecode.Op.pushconst2
  then (push_elt state state.accu; const_int state 2; None)
  else if op = Bytecode.Op.pushconst3
  then (push_elt state state.accu; const_int state 3; None)
  else if op = Bytecode.Op.pushconstint
  then (push_elt state state.accu; const_int state args.(0); None)
  else if op = Bytecode.Op.negint
  then (unop state (Extern "neg_int"); None)
  else if op = Bytecode.Op.addint
  then (binop state (Extern "add_int"); None)
  else if op = Bytecode.Op.subint
  then (binop state (Extern "sub_int"); None)
  else if op = Bytecode.Op.mulint
  then (binop state (Extern "mul_int"); None)
  else if op = Bytecode.Op.divint
  then (binop state (Extern "div_int"); None)
  else if op = Bytecode.Op.modint
  then (binop state (Extern "mod_int"); None)
  else if op = Bytecode.Op.andint
  then (binop state (Extern "and_int"); None)
  else if op = Bytecode.Op.orint
  then (binop state (Extern "or_int"); None)
  else if op = Bytecode.Op.xorint
  then (binop state (Extern "xor_int"); None)
  else if op = Bytecode.Op.lslint
  then (binop state (Extern "lsl_int"); None)
  else if op = Bytecode.Op.lsrint
  then (binop state (Extern "lsr_int"); None)
  else if op = Bytecode.Op.asrint
  then (binop state (Extern "asr_int"); None)
  else if op = Bytecode.Op.offsetint
  then (
    let a = var_of state.accu in
    let c = Var.fresh () in
    emit state (Let (c, Constant (Int args.(0))));
    let r = Var.fresh () in
    emit state (Let (r, Prim (Extern "add_int", [ Pv a; Pv c ])));
    state.accu <- V r;
    None)
  else if op = Bytecode.Op.offsetref
  then (
    let a = var_of state.accu in
    emit state (Offset_ref (a, args.(0)));
    None)
  else if op = Bytecode.Op.boolnot
  then (unop state Not; None)
  else if op = Bytecode.Op.isint
  then (unop state IsInt; None)
  else if op = Bytecode.Op.eq
  then (binop state Eq; None)
  else if op = Bytecode.Op.neq
  then (binop state Neq; None)
  else if op = Bytecode.Op.ltint
  then (binop state Lt; None)
  else if op = Bytecode.Op.leint
  then (binop state Le; None)
  else if op = Bytecode.Op.gtint
  then (binop state Gt; None)
  else if op = Bytecode.Op.geint
  then (binop state Ge; None)
  else if op = Bytecode.Op.ultint
  then (binop state Ult; None)
  else if op = Bytecode.Op.ugeint
  then (binop state Uge; None)
  else if op = Bytecode.Op.vectlength
  then (unop state Vectlength; None)
  else if op = Bytecode.Op.getvectitem
  then (binop state Array_get; None)
  else if op = Bytecode.Op.setvectitem
  then (
    let a = var_of state.accu in
    let i = pop_var state in
    let v = pop_var state in
    emit state (Array_set (a, i, v));
    state.accu <- V a;
    None)
  (* GETFIELD *)
  else if op = Bytecode.Op.getfield0
  then (let a = var_of state.accu in set_accu_let state (Field (a, 0)); None)
  else if op = Bytecode.Op.getfield1
  then (let a = var_of state.accu in set_accu_let state (Field (a, 1)); None)
  else if op = Bytecode.Op.getfield2
  then (let a = var_of state.accu in set_accu_let state (Field (a, 2)); None)
  else if op = Bytecode.Op.getfield3
  then (let a = var_of state.accu in set_accu_let state (Field (a, 3)); None)
  else if op = Bytecode.Op.getfield
  then (
    let a = var_of state.accu in
    set_accu_let state (Field (a, args.(0)));
    None)
  else if op = Bytecode.Op.setfield0
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 0, v));
    None)
  else if op = Bytecode.Op.setfield1
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 1, v));
    None)
  else if op = Bytecode.Op.setfield2
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 2, v));
    None)
  else if op = Bytecode.Op.setfield3
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 3, v));
    None)
  else if op = Bytecode.Op.setfield
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, args.(0), v));
    None)
  else if op = Bytecode.Op.makeblock1
  then (
    let f0 = var_of state.accu in
    set_accu_let state (Block (args.(0), [| f0 |]));
    None)
  else if op = Bytecode.Op.makeblock2
  then (
    let f0 = var_of state.accu in
    let f1 = pop_var state in
    set_accu_let state (Block (args.(0), [| f0; f1 |]));
    None)
  else if op = Bytecode.Op.makeblock3
  then (
    let f0 = var_of state.accu in
    let f1 = pop_var state in
    let f2 = pop_var state in
    set_accu_let state (Block (args.(0), [| f0; f1; f2 |]));
    None)
  else if op = Bytecode.Op.makeblock
  then (
    let n = args.(0) in
    let tag = args.(1) in
    let fields = Array.make n (Var.fresh ()) in
    fields.(0) <- var_of state.accu;
    for i = 1 to n - 1 do
      fields.(i) <- pop_var state
    done;
    set_accu_let state (Block (tag, fields));
    None)
  (* GETGLOBAL / GETGLOBALFIELD — treated as opaque externs that take a
     numeric argument. The JVM generator resolves these via the globals
     table. *)
  else if op = Bytecode.Op.getglobal
  then (
    set_accu_let
      state
      (Prim (Extern "get_global", [ Pc (Int args.(0)) ]));
    None)
  else if op = Bytecode.Op.pushgetglobal
  then (
    push_elt state state.accu;
    set_accu_let
      state
      (Prim (Extern "get_global", [ Pc (Int args.(0)) ]));
    None)
  else if op = Bytecode.Op.getglobalfield
  then (
    set_accu_let
      state
      (Prim
         ( Extern "get_global_field"
         , [ Pc (Int args.(0)); Pc (Int args.(1)) ] ));
    None)
  else if op = Bytecode.Op.pushgetglobalfield
  then (
    push_elt state state.accu;
    set_accu_let
      state
      (Prim
         ( Extern "get_global_field"
         , [ Pc (Int args.(0)); Pc (Int args.(1)) ] ));
    None)
  else if op = Bytecode.Op.setglobal
  then (
    let a = var_of state.accu in
    emit
      state
      (Let
         ( Var.fresh ()
         , Prim (Extern "set_global", [ Pc (Int args.(0)); Pv a ]) ));
    (* acc becomes unit (Int 0) after SETGLOBAL *)
    const_int state 0;
    None)
  (* APPLY family *)
  else if op = Bytecode.Op.apply1
  then (
    let f = var_of state.accu in
    let a = pop_var state in
    set_accu_let state (Apply { f; args = [ a ]; exact = false });
    None)
  else if op = Bytecode.Op.apply2
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    set_accu_let state (Apply { f; args = [ a0; a1 ]; exact = false });
    None)
  else if op = Bytecode.Op.apply3
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let a2 = pop_var state in
    set_accu_let state (Apply { f; args = [ a0; a1; a2 ]; exact = false });
    None)
  else if op = Bytecode.Op.apply
  then (
    let f = var_of state.accu in
    let n = args.(0) in
    let call_args = take_args state n in
    set_accu_let state (Apply { f; args = call_args; exact = false });
    (* Pop the 3 PUSH_RETADDR dummies. *)
    for _ = 1 to 3 do
      match pop state with
      | Dummy -> ()
      | V _ ->
        raise (Not_supported "APPLY: expected Dummy retaddr slots")
    done;
    None)
  (* Terminators *)
  else if op = Bytecode.Op.return
  then Some (Return (var_of state.accu))
  else if op = Bytecode.Op.stop
  then Some Stop
  else if op = Bytecode.Op.raise_
          || op = Bytecode.Op.reraise
          || op = Bytecode.Op.raise_notrace
  then Some (Raise (var_of state.accu))
  else if op = Bytecode.Op.branch
  then Some (Branch (make_cont state (ins.pc + args.(0) + 1)))
  else if op = Bytecode.Op.branchif
  then (
    let v = var_of state.accu in
    let then_pc = ins.pc + args.(0) + 1 in
    let else_pc = ins.pc + 2 in
    Some (Cond (v, make_cont state then_pc, make_cont state else_pc)))
  else if op = Bytecode.Op.branchifnot
  then (
    let v = var_of state.accu in
    let else_pc = ins.pc + args.(0) + 1 in
    let then_pc = ins.pc + 2 in
    Some (Cond (v, make_cont state then_pc, make_cont state else_pc)))
  else if Instr.is_cmp_jump op
  then (
    let a = var_of state.accu in
    let cmp =
      if op = 131 then Eq
      else if op = 132 then Neq
      else if op = 133 then Lt
      else if op = 134 then Le
      else if op = 135 then Gt
      else Ge
    in
    let c = Var.fresh () in
    emit state (Let (c, Constant (Int args.(0))));
    let r = Var.fresh () in
    emit state (Let (r, Prim (cmp, [ Pv a; Pv c ])));
    let then_pc = ins.pc + args.(1) + 2 in
    let else_pc = ins.pc + 3 in
    Some (Cond (r, make_cont state then_pc, make_cont state else_pc)))
  (* APPTERM / APPTERM1..3 — tail calls collapse to Apply + Return. *)
  else if op = Bytecode.Op.appterm1
  then (
    let f = var_of state.accu in
    let a = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm2
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a0; a1 ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm3
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let a2 = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a0; a1; a2 ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm
  then (
    let n = args.(0) in
    let f = var_of state.accu in
    let call_args = take_args state n in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = call_args; exact = false }));
    Some (Return r))
  (* Remaining opcodes not yet supported by the IR path. Raising lets
     the forward-walk fallback pick up the slack; callers should catch
     and skip to the legacy emitter. *)
  else
    raise
      (Not_supported
         (Printf.sprintf
            "opcode %d (%s)"
            op
            (Bytecode.opcode_name op)))

(* ------------------------------------------------------------------
   Top-level drivers
   ------------------------------------------------------------------ *)

let build_addr_map instrs =
  let m = ref IntMap.empty in
  List.iter (fun (ins : Instr.instr) -> m := IntMap.add ins.pc ins !m) instrs;
  !m

(* Process one block: consume instructions until we hit the next block
   boundary or a terminator. Returns the constructed [block]. *)
let process_block state start_pc next_starts addr_map =
  let accu_v = Var.fresh () in
  let stack_vs = List.map (fun _ -> Var.fresh ()) state.stack in
  (* Install params for this block if not yet present. *)
  let params = accu_v :: stack_vs in
  Hashtbl.replace state.target_params start_pc params;
  state.accu <- V accu_v;
  state.stack <- List.map (fun v -> V v) stack_vs;
  state.body <- [];
  let rec walk pc =
    if IntSet.mem pc next_starts && pc <> start_pc
    then (
      (* Fall through to next block. *)
      let cont = make_cont state pc in
      Branch cont)
    else
      match IntMap.find_opt pc addr_map with
      | None ->
        raise
          (Not_supported (Printf.sprintf "PC %d has no decoded instr" pc))
      | Some ins ->
        (match step state ins with
         | Some last -> last
         | None ->
           (* Find next PC (pc of the next instruction in the array). *)
           let next_pc =
             (* Use addr_map ordered keys. *)
             let rec find p =
               let p' = p + 1 in
               if IntMap.mem p' addr_map
               then p'
               else if p' > pc + 256
               then raise (Not_supported "can't find successor pc")
               else find p'
             in
             find ins.pc
           in
           walk next_pc)
  in
  let br = walk start_pc in
  { params; body = List.rev state.body; branch = br }

let parse_generic_with_stack instrs ~start_pc ~end_pc ~initial_stack =
  let starts = block_starts instrs ~start_pc ~end_pc in
  let addr_map = build_addr_map instrs in
  let state =
    { accu = V (Var.fresh ())
    ; stack = List.map (fun v -> V v) initial_stack
    ; body = []
    ; target_params = Hashtbl.create 32
    }
  in
  let blocks = ref Addr.Map.empty in
  IntSet.iter
    (fun pc ->
      let blk = process_block state pc starts addr_map in
      blocks := Addr.Map.add pc blk !blocks)
    starts;
  { start = start_pc; blocks = !blocks; free_pc = end_pc }

let parse_function instrs ~start_pc ~end_pc ~nargs ~ncaps =
  Var.reset ();
  let arg_vars = List.init nargs (fun _ -> Var.fresh ()) in
  let cap_vars = List.init ncaps (fun _ -> Var.fresh ()) in
  let params = arg_vars @ cap_vars in
  (* OCaml bytecode enters a function body with args on the OCaml
     stack: arg[nargs-1] at bottom, arg[0] on top (ACC0 reads the
     first argument). The caller hands us [arg_vars] in declaration
     order (arg[0] first), so we reverse-then-push to leave arg[0]
     at the top. *)
  let prog =
    let initial_stack = List.rev arg_vars in
    parse_generic_with_stack instrs ~start_pc ~end_pc ~initial_stack
  in
  (prog, params)

let parse_main instrs ~start_pc ~end_pc =
  Var.reset ();
  parse_generic_with_stack instrs ~start_pc ~end_pc ~initial_stack:[]
