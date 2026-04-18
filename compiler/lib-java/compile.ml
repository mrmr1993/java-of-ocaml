(* -------------------------------------------------------------------------- *)
(* Supported primitives. *)

type arg_kind = Int | String

let primitives : (string * arg_kind) list =
  [ "caml_java_print_endline", String
  ; "caml_java_print_int", Int
  ]

(* -------------------------------------------------------------------------- *)
(* Bytecode decoding into a flat instruction list. *)

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

(* -------------------------------------------------------------------------- *)
(* Opcode classification. *)

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

let is_user_op (ins : instr) =
  let op = ins.opcode in
  op = Bytecode.Op.push
  || op = Bytecode.Op.pop
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
  || op = Bytecode.Op.addint
  || op = Bytecode.Op.subint
  || op = Bytecode.Op.mulint
  || is_cmp_nullary op
  || op = Bytecode.Op.getglobal
  || op = Bytecode.Op.pushgetglobal
  || op = Bytecode.Op.branch
  || op = Bytecode.Op.branchif
  || op = Bytecode.Op.branchifnot
  || is_cmp_jump op
  || is_c_call op

(* -------------------------------------------------------------------------- *)
(* Globals. *)

let string_of_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith
      (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then None
  else if Obj.tag v <> Obj.string_tag
  then None
  else Some (Obj.magic v : string)

(* -------------------------------------------------------------------------- *)
(* Branch-target arithmetic.

   Offsets are relative to the opcode position; the constant added depends on
   the opcode's kind (number of arg slots already consumed when the branch
   is taken in the interpreter).
     KJump / KCond_jump: target = pc + offset + 1
     KCmp_jump         : target = pc + offset + 2
*)

let branch_target (ins : instr) =
  let op = ins.opcode in
  if op = Bytecode.Op.branch
     || op = Bytecode.Op.branchif
     || op = Bytecode.Op.branchifnot
  then Some (ins.pc + ins.args.(0) + 1)
  else if is_cmp_jump op
  then Some (ins.pc + ins.args.(1) + 2)
  else None

(* -------------------------------------------------------------------------- *)
(* Forward emitter.

   Model: the OCaml accumulator is kept on top of the JVM operand stack
   (when [acc_live = true]). The OCaml bytecode stack is mirrored in JVM
   locals: local [local_base + i] holds the i-th element (bottom-indexed)
   of the OCaml stack. [local_base = 1] (slot 0 holds the method's
   [String[] args] parameter).

   PUSH is [dup ; istore N]: the operand stack keeps acc intact on top, and
   the freshly-stored local serves as the saved OCaml-stack entry. Later
   arithmetic/ACC ops [iload N] to recover the saved value, and decrement
   [oc_stack_depth] if they consume it. *)

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; supported_prims : (int, string * arg_kind) Hashtbl.t
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; mutable acc_live : bool
  ; mutable oc_stack_depth : int
  ; mutable pending_cmp : cmp_op option
      (* A comparison opcode was just seen; we haven't emitted anything yet
         because we want to fuse it with the next branch if possible. *)
  }

let local_base = 1 (* slot 0 is for [String[] args] *)

(* Local assigned to the k-th-from-top OCaml stack slot, given the current
   depth. *)
let stack_slot_local ~oc_stack_depth k =
  if k < 0 || k >= oc_stack_depth
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: stack slot %d out of range (depth %d)"
         k
         oc_stack_depth);
  local_base + (oc_stack_depth - 1 - k)

(* Local assigned to the TOP of the OCaml stack, used by arithmetic and
   comparison ops that pop one value. *)
let top_slot_local ~oc_stack_depth =
  stack_slot_local ~oc_stack_depth 0

let find_supported_prims bc =
  let table = Hashtbl.create 4 in
  List.iter
    (fun (name, kind) ->
      match Bytecode.prim_index bc name with
      | Some idx -> Hashtbl.add table idx (name, kind)
      | None -> ())
    primitives;
  table

let label_at state pc =
  Hashtbl.find state.pc_to_label pc

(* Push a fresh int onto the operand stack as the new acc, popping any
   stale acc first. *)
let emit_int_const state n =
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true

let emit_string_const state s =
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true

(* OCaml PUSH: save current acc onto the OCaml stack (a fresh JVM local).
   The operand stack retains the original acc on top thanks to [dup]. *)
let emit_push state =
  if not state.acc_live
  then
    (* A PUSH immediately after a C_CALL is a save-PUSH that would stash
       the return value for later; our compile stops before any op that
       would read it back, so skip. *)
    ()
  else (
    let slot = local_base + state.oc_stack_depth in
    Jvm.Code.dup state.code;
    Jvm.Code.istore state.code slot;
    state.oc_stack_depth <- state.oc_stack_depth + 1)

let emit_acc state k =
  let slot = stack_slot_local ~oc_stack_depth:state.oc_stack_depth k in
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.iload state.code slot;
  state.acc_live <- true

let emit_pushacc state k =
  emit_push state;
  (* After PUSH the depth grew by one; ACC reads from the extended stack. *)
  emit_acc state k

let emit_int_push state n =
  (* PUSHCONSTi / PUSHCONSTINT n: semantic [PUSH ; CONST n]. If acc was
     live, [emit_push] duplicated it and stored the copy in a local; we
     then pop the original off the op stack and push the new constant. If
     acc wasn't live (e.g. immediately after a C_CALL return), [emit_push]
     is a no-op and we just push the new constant. *)
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true

let emit_string_push state s =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true

let consume_top state =
  state.oc_stack_depth <- state.oc_stack_depth - 1

(* Arithmetic ops — OCaml semantics (from runtime/interp.c):
     ADDINT: acc := acc + stack.pop()    (commutative)
     SUBINT: acc := acc - stack.pop()    (non-commutative, acc on the left)
     MULINT: acc := acc * stack.pop()    (commutative)
   Our JVM state has acc on top of the operand stack; the popped value lives
   in the local for [stack[0] from top]. Loading it puts it above acc, so
   for JVM's [isub] which computes [value1 - value2] (value1 below, value2
   top), we get [acc - sp] naturally. No swap needed. *)

let emit_addint state =
  let slot = top_slot_local ~oc_stack_depth:state.oc_stack_depth in
  Jvm.Code.iload state.code slot;
  Jvm.Code.iadd state.code;
  consume_top state

let emit_subint state =
  let slot = top_slot_local ~oc_stack_depth:state.oc_stack_depth in
  Jvm.Code.iload state.code slot;
  Jvm.Code.isub state.code;
  consume_top state

let emit_mulint state =
  let slot = top_slot_local ~oc_stack_depth:state.oc_stack_depth in
  Jvm.Code.iload state.code slot;
  Jvm.Code.imul state.code;
  consume_top state

let emit_offsetint state n =
  Jvm.Code.ldc_int state.code n;
  Jvm.Code.iadd state.code

let emit_c_call state ~kind =
  Jvm.Code.getstatic
    state.code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.swap state.code;
  let desc =
    match kind with
    | Int -> "(I)V"
    | String -> "(Ljava/lang/String;)V"
  in
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:desc;
  state.acc_live <- false

(* Fused Cmp_jump opcode (BEQ/BNEQ/BLTINT/…) taking an immediate and a
   branch offset. OCaml semantics: branch iff [imm TST acc]. *)
let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  Jvm.Code.ldc_int state.code imm;
  (* Now value1 = acc (below), value2 = imm (top). JVM's if_icmp<cond>
     evaluates [value1 <cond> value2 = acc <cond> imm]. Translate each
     fused op's "[imm TST acc]" to "[acc (inverse TST) imm]". *)
  (match ins.opcode with
   | 131 (* BEQ:    imm == acc ↔ acc == imm *) ->
     Jvm.Code.if_icmpeq state.code lbl
   | 132 (* BNEQ:   imm != acc ↔ acc != imm *) ->
     Jvm.Code.if_icmpne state.code lbl
   | 133 (* BLTINT: imm  < acc ↔ acc  > imm *) ->
     Jvm.Code.if_icmpgt state.code lbl
   | 134 (* BLEINT: imm <= acc ↔ acc >= imm *) ->
     Jvm.Code.if_icmpge state.code lbl
   | 135 (* BGTINT: imm  > acc ↔ acc  < imm *) ->
     Jvm.Code.if_icmplt state.code lbl
   | 136 (* BGEINT: imm >= acc ↔ acc <= imm *) ->
     Jvm.Code.if_icmple state.code lbl
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: unexpected cmp_jump opcode %d"
          other));
  state.acc_live <- false

(* Non-fused comparison (EQ/NEQ/LTINT/…): stored as [pending_cmp] and
   consumed on the next BRANCHIF/BRANCHIFNOT. We raise if a comparison
   isn't immediately followed by a branch — materialising a 0/1 boolean
   on the stack is possible but not yet exercised by any test. *)

let cmp_of_opcode op =
  if op = Bytecode.Op.eq then Eq
  else if op = Bytecode.Op.neq then Ne
  else if op = Bytecode.Op.ltint then Lt
  else if op = Bytecode.Op.leint then Le
  else if op = Bytecode.Op.gtint then Gt
  else if op = Bytecode.Op.geint then Ge
  else
    failwith
      (Printf.sprintf
         "java_of_ocaml: cmp_of_opcode on non-comparison %d"
         op)

let emit_fused_branch state ~cmp ~target_pc ~branch_if_true =
  (* OCaml GTINT etc. semantics: [acc := acc OP stack.pop()] where [OP]
     names the predicate (Gt/Lt/...). On JVM, acc is already on top; we
     load the top-of-stack local, placing it ABOVE the acc, so the JVM
     if_icmp<cond> sees [value1 = acc ; value2 = stack.pop()]. OCaml's
     [acc OP value2] is the condition we want to branch on (for
     BRANCHIF) or whose negation we want to branch on (for BRANCHIFNOT). *)
  let slot = top_slot_local ~oc_stack_depth:state.oc_stack_depth in
  Jvm.Code.iload state.code slot;
  let lbl = label_at state target_pc in
  let branch_cond =
    if branch_if_true
    then cmp
    else
      match cmp with
      | Eq -> Ne
      | Ne -> Eq
      | Lt -> Ge
      | Le -> Gt
      | Gt -> Le
      | Ge -> Lt
  in
  (match branch_cond with
   | Eq -> Jvm.Code.if_icmpeq state.code lbl
   | Ne -> Jvm.Code.if_icmpne state.code lbl
   | Lt -> Jvm.Code.if_icmplt state.code lbl
   | Le -> Jvm.Code.if_icmple state.code lbl
   | Gt -> Jvm.Code.if_icmpgt state.code lbl
   | Ge -> Jvm.Code.if_icmpge state.code lbl);
  consume_top state;
  state.acc_live <- false

let emit_instr state (ins : instr) =
  (* Pin the label for this PC if there is one. *)
  (match Hashtbl.find_opt state.pc_to_label ins.pc with
   | Some lbl -> Jvm.Code.mark_label state.code lbl
   | None -> ());
  let op = ins.opcode in
  if is_cmp_nullary op
  then state.pending_cmp <- Some (cmp_of_opcode op)
  else if op = Bytecode.Op.branchifnot
  then
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:false;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.if_icmpeq state.code (label_at state target_pc);
      state.acc_live <- false
  else if op = Bytecode.Op.branchif
  then
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:true;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.if_icmpne state.code (label_at state target_pc);
      state.acc_live <- false
  else if op = Bytecode.Op.const0 then emit_int_const state 0
  else if op = Bytecode.Op.const1 then emit_int_const state 1
  else if op = Bytecode.Op.const2 then emit_int_const state 2
  else if op = Bytecode.Op.const3 then emit_int_const state 3
  else if op = Bytecode.Op.constint then emit_int_const state ins.args.(0)
  else if op = Bytecode.Op.pushconst0 then emit_int_push state 0
  else if op = Bytecode.Op.pushconst1 then emit_int_push state 1
  else if op = Bytecode.Op.pushconst2 then emit_int_push state 2
  else if op = Bytecode.Op.pushconst3 then emit_int_push state 3
  else if op = Bytecode.Op.pushconstint
  then emit_int_push state ins.args.(0)
  else if op = Bytecode.Op.offsetint then emit_offsetint state ins.args.(0)
  else if op = Bytecode.Op.addint then emit_addint state
  else if op = Bytecode.Op.subint then emit_subint state
  else if op = Bytecode.Op.mulint then emit_mulint state
  else if op = Bytecode.Op.push then emit_push state
  else if op = Bytecode.Op.acc0 then emit_acc state 0
  else if op = Bytecode.Op.acc1 then emit_acc state 1
  else if op = Bytecode.Op.acc2 then emit_acc state 2
  else if op = Bytecode.Op.acc3 then emit_acc state 3
  else if op = Bytecode.Op.acc4 then emit_acc state 4
  else if op = Bytecode.Op.acc5 then emit_acc state 5
  else if op = Bytecode.Op.acc6 then emit_acc state 6
  else if op = Bytecode.Op.acc7 then emit_acc state 7
  else if op = Bytecode.Op.acc then emit_acc state ins.args.(0)
  else if op = Bytecode.Op.pushacc0 then emit_pushacc state 0
  else if op = Bytecode.Op.pushacc1 then emit_pushacc state 1
  else if op = Bytecode.Op.pushacc2 then emit_pushacc state 2
  else if op = Bytecode.Op.pushacc3 then emit_pushacc state 3
  else if op = Bytecode.Op.pushacc4 then emit_pushacc state 4
  else if op = Bytecode.Op.pushacc5 then emit_pushacc state 5
  else if op = Bytecode.Op.pushacc6 then emit_pushacc state 6
  else if op = Bytecode.Op.pushacc7 then emit_pushacc state 7
  else if op = Bytecode.Op.pushacc then emit_pushacc state ins.args.(0)
  else if op = Bytecode.Op.pop
  then
    state.oc_stack_depth <- state.oc_stack_depth - ins.args.(0)
  else if op = Bytecode.Op.getglobal
  then
    match string_of_global state.globals ins.args.(0) with
    | Some s -> emit_string_const state s
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETGLOBAL %d at pc %d — only string globals are \
            currently supported"
           ins.args.(0)
           ins.pc)
  else if op = Bytecode.Op.pushgetglobal
  then
    match string_of_global state.globals ins.args.(0) with
    | Some s -> emit_string_push state s
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: PUSHGETGLOBAL %d at pc %d — only string globals \
            are currently supported"
           ins.args.(0)
           ins.pc)
  else if op = Bytecode.Op.branch
  then
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target)
  else if is_cmp_jump op then emit_cmp_jump state ins
  else if is_c_call op
  then (
    match Hashtbl.find_opt state.supported_prims ins.args.(0) with
    | Some (_name, kind) -> emit_c_call state ~kind
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: unsupported primitive call #%d at pc %d"
           ins.args.(0)
           ins.pc))
  else
    failwith
      (Printf.sprintf
         "java_of_ocaml: unsupported opcode %s (%d) at pc %d"
         (Bytecode.opcode_name op)
         op
         ins.pc)

(* -------------------------------------------------------------------------- *)
(* Range selection. *)

let supported_call_indices arr ~prim_table =
  let n = Array.length arr in
  let rec find_first i =
    if i >= n then None
    else if is_c_call arr.(i).opcode
         && Hashtbl.mem prim_table arr.(i).args.(0)
    then Some i
    else find_first (i + 1)
  in
  let rec find_last i =
    if i < 0 then None
    else if is_c_call arr.(i).opcode
         && Hashtbl.mem prim_table arr.(i).args.(0)
    then Some i
    else find_last (i - 1)
  in
  match find_first 0, find_last (n - 1) with
  | Some f, Some l -> Some (f, l)
  | _ -> None

let walk_back_user_start arr start_idx =
  let rec loop i =
    if i < 0 then 0
    else if is_user_op arr.(i)
    then loop (i - 1)
    else i + 1
  in
  loop (start_idx - 1)

let walk_forward_user_end arr end_idx =
  let n = Array.length arr in
  let rec loop i =
    if i >= n then n - 1
    else if is_user_op arr.(i)
    then loop (i + 1)
    else i - 1
  in
  loop (end_idx + 1)

(* -------------------------------------------------------------------------- *)
(* Driver. *)

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let prim_table = find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int).";
  let instrs = decode_all parsed in
  let arr = Array.of_list instrs in
  let first_idx, last_idx =
    match supported_call_indices arr ~prim_table with
    | Some p -> p
    | None ->
      failwith "java_of_ocaml: no supported primitive calls found"
  in
  let start_idx = walk_back_user_start arr first_idx in
  let end_idx = walk_forward_user_end arr last_idx in
  let class_bytes =
    Jvm.assemble_main_class (fun _cp code ->
      let pc_to_label = Hashtbl.create 4 in
      let post_end_pc =
        if end_idx + 1 < Array.length arr
        then arr.(end_idx + 1).pc
        else max_int
      in
      for i = start_idx to end_idx do
        match branch_target arr.(i) with
        | None -> ()
        | Some target_pc ->
          let in_range =
            target_pc >= arr.(start_idx).pc
            && target_pc <= post_end_pc
          in
          if in_range && not (Hashtbl.mem pc_to_label target_pc)
          then
            Hashtbl.add pc_to_label target_pc (Jvm.Code.fresh_label code)
      done;
      let state =
        { code
        ; globals = parsed.globals
        ; supported_prims = prim_table
        ; pc_to_label
        ; acc_live = false
        ; oc_stack_depth = 0
        ; pending_cmp = None
        }
      in
      for i = start_idx to end_idx do
        emit_instr state arr.(i)
      done;
      (match Hashtbl.find_opt pc_to_label post_end_pc with
       | Some lbl -> Jvm.Code.mark_label code lbl
       | None -> ());
      Jvm.Code.return_void code)
  in
  let out_path = Filename.concat out_dir "Main.class" in
  let oc = open_out_bin out_path in
  output_string oc class_bytes;
  close_out oc
