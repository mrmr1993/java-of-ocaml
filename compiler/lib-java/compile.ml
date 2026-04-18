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

(* Closure-related. *)
let closurerec_op = Bytecode.Op.closurerec
let closure_op = Bytecode.Op.closure
let offsetclosure0_op = Bytecode.Op.offsetclosure0
let pushoffsetclosure0_op = Bytecode.Op.pushoffsetclosure0
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

(* Debug-info no-ops. Emitted by [ocamlc -g] between real instructions. *)
let event_op = Bytecode.Op.event
let break_op = Bytecode.Op.break

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
  || op = Bytecode.Op.divint
  || op = Bytecode.Op.modint
  || is_cmp_nullary op
  || op = Bytecode.Op.getglobal
  || op = Bytecode.Op.pushgetglobal
  || op = Bytecode.Op.branch
  || op = Bytecode.Op.branchif
  || op = Bytecode.Op.branchifnot
  || is_cmp_jump op
  || is_c_call op
  || op = closurerec_op
  || op = closure_op
  || op = offsetclosure0_op
  || op = pushoffsetclosure0_op
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
(* Branch-target arithmetic. *)

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
(* Value kinds: tracked compile-time so we know whether a JVM int slot holds
   a genuine integer or a placeholder for a closure reference. *)

type kind =
  | K_int
  | K_closure of string

(* -------------------------------------------------------------------------- *)
(* Function discovery + body range.

   A CLOSUREREC instruction references one or more function bodies by PC;
   we treat each as a JVM static method. For the walk, we compute each
   function body's instruction-array range by linear scan starting at the
   body's PC and tracking outstanding forward branches: a RETURN ends the
   function only when no forward branches are still outstanding within it. *)

type function_info =
  { name : string
  ; closurerec_pc : int [@warning "-69"]
  ; body_pc : int [@warning "-69"]
  ; body_start_idx : int
  ; body_end_idx : int
  ; nargs : int
  ; recursive : bool [@warning "-69"]
  }

module Int_set = Set.Make (Int)

let find_function_body_range arr body_pc =
  let n = Array.length arr in
  let start_idx = ref (-1) in
  for i = 0 to n - 1 do
    if !start_idx < 0 && arr.(i).pc = body_pc then start_idx := i
  done;
  if !start_idx < 0
  then failwith (Printf.sprintf "java_of_ocaml: no instruction at body_pc %d" body_pc);
  (* The function's entry is RESTART (multi-arg with GRAB coming) or a
     direct nullary op for a 1-arg function. Skip a leading RESTART so the
     enclosed body starts at its first "real" instruction. *)
  let real_start = ref !start_idx in
  if arr.(!real_start).opcode = restart_op
  then incr real_start;
  let nargs =
    if arr.(!real_start).opcode = grab_op
    then (
      let n = arr.(!real_start).args.(0) + 1 in
      (* The GRAB itself is also part of the entry sequence; skip it so the
         body range we return starts at the first statement proper. *)
      incr real_start;
      n)
    else 1
  in
  let outstanding = ref Int_set.empty in
  let rec loop i =
    if i >= n
    then failwith "java_of_ocaml: walked past end of code while tracing function body"
    else
      let ins = arr.(i) in
      outstanding := Int_set.remove ins.pc !outstanding;
      (match branch_target ins with
       | Some t when t <> ins.pc ->
         outstanding := Int_set.add t !outstanding
       | _ -> ());
      let ends_here =
        (ins.opcode = return_op
         || ins.opcode = appterm_op
         || ins.opcode = appterm1_op
         || ins.opcode = appterm2_op
         || ins.opcode = appterm3_op
         || ins.opcode = Bytecode.Op.stop)
        && Int_set.is_empty !outstanding
      in
      if ends_here then i else loop (i + 1)
  in
  let end_idx = loop !real_start in
  !real_start, end_idx, nargs

(* -------------------------------------------------------------------------- *)
(* Forward emitter. *)

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

(* Snapshot of the emitter's OCaml-side state at a branch target. We capture
   it at each branch emission and restore it when we mark a caller
   label, so that the linear instruction walk doesn't carry state from the
   [RETURN] / fall-through path into a caller's emission. *)
type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slot_kinds : kind list
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; supported_prims : (int, string * arg_kind) Hashtbl.t
  ; functions : (int, function_info) Hashtbl.t
      (* closure{,rec}_pc -> function_info *)
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
      (* Target PC -> state to restore when we mark that target's label. *)
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slot_kinds : kind list
      (* most-recently-pushed first; head of list is the top of the OCaml
         stack. Length always equals [oc_stack_depth]. *)
  ; mutable oc_stack_depth : int
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
      (* Number of JVM method parameters. 0 for [main] (where local 0 holds
         [String[] args]). N for a function with N args, where JVM locals
         0..N-1 hold those args in source order. *)
  ; enclosing_function_name : string option
      (* [None] when emitting [main]; [Some name] inside a function body.
         OFFSETCLOSURE0 uses this to tag acc as the self-closure. *)
  }

(* Mapping from an OCaml-stack slot index (counted from the bottom of the
   OCaml stack, 0-indexed) to the JVM local that holds its value.

   - In [main]: local 0 is the [String[] args] parameter, so OCaml stack
     slots start at local 1. Formula: [1 + k].
   - In a function with N args: JVM locals 0..N-1 are the parameters in
     source order, but the OCaml calling convention puts the first arg at
     the TOP of the stack (= slot N-1 from bottom) and the last arg at the
     BOTTOM (= slot 0). The args therefore occupy locals 0..N-1 in reverse
     of OCaml stack-slot order: slot k (k < N) -> local (N-1-k). OCaml
     pushes past the initial stack depth go to locals N, N+1, ... which
     matches [local = k] for k >= N. *)
let slot_to_local ~state k =
  match state.enclosing_function_name with
  | None -> 1 + k
  | Some _ -> if k < state.nargs then state.nargs - 1 - k else k

let record_branch_target state target_pc =
  if not (Hashtbl.mem state.branch_target_state target_pc)
  then
    Hashtbl.add
      state.branch_target_state
      target_pc
      { s_oc_stack_depth = state.oc_stack_depth
      ; s_slot_kinds = state.slot_kinds
      }

let stack_slot_local ~state k =
  if k < 0 || k >= state.oc_stack_depth
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: stack slot %d out of range (depth %d, nargs %d, \
          in_fn=%s)"
         k
         state.oc_stack_depth
         state.nargs
         (match state.enclosing_function_name with
          | Some n -> n
          | None -> "<main>"));
  slot_to_local ~state (state.oc_stack_depth - 1 - k)

let top_slot_local ~state = stack_slot_local ~state 0

let next_free_local ~state =
  (* The local where a new OCaml stack push would land: it's the local for
     the slot one beyond the current top. *)
  slot_to_local ~state state.oc_stack_depth

let kind_of_slot_from_top ~state k =
  List.nth state.slot_kinds k

let push_slot state kind =
  state.slot_kinds <- kind :: state.slot_kinds;
  state.oc_stack_depth <- state.oc_stack_depth + 1

let pop_slots state n =
  let rec drop lst n =
    if n <= 0 then lst
    else
      match lst with
      | _ :: rest -> drop rest (n - 1)
      | [] ->
        failwith "java_of_ocaml: tried to pop beyond the OCaml stack bottom"
  in
  state.slot_kinds <- drop state.slot_kinds n;
  state.oc_stack_depth <- state.oc_stack_depth - n

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

(* Replace acc (pop any live value, push new). *)
let overwrite_acc state kind emit =
  if state.acc_live then Jvm.Code.pop_top state.code;
  emit ();
  state.acc_live <- true;
  state.acc_kind <- kind

let emit_int_const state n =
  overwrite_acc state K_int (fun () -> Jvm.Code.ldc_int state.code n)

let emit_string_const state s =
  overwrite_acc state K_int (* treated as plain reference-as-int for now *)
    (fun () -> Jvm.Code.ldc_string state.code s)

(* OCaml PUSH: stack := stack++[acc]; acc unchanged. On JVM, dup acc so the
   operand stack still has acc on top; the dup'd copy becomes a named local
   for later ACC access. *)
let emit_push state =
  if not state.acc_live
  then
    (* A PUSH immediately after a C_CALL is a save-PUSH for its return value.
       Our compile stops before anything would read it back, so skip. *)
    ()
  else (
    let slot = next_free_local ~state in
    Jvm.Code.dup state.code;
    Jvm.Code.istore state.code slot;
    push_slot state state.acc_kind)

let emit_acc state k =
  if k >= state.oc_stack_depth
  then
    (* ACC past the end of our tracked OCaml stack — the compiler emits such
       an access in the module-init trailer to fetch the top-level binding
       for MAKEBLOCK. Our emission stops before MAKEBLOCK, so this access
       is dead; skip it. *)
    ()
  else (
    let slot = stack_slot_local ~state k in
    let new_kind = kind_of_slot_from_top ~state k in
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.iload state.code slot;
    state.acc_live <- true;
    state.acc_kind <- new_kind)

let emit_pushacc state k =
  if not state.acc_live
  then
    (* A PUSHACC at a "dead" point — the most common example is right after
       a C_CALL returning unit, used by the module-init trailer to stash
       the return value and then load a binding for MAKEBLOCK. We don't
       emit MAKEBLOCK, so skipping this is correct. *)
    ()
  else (
    emit_push state;
    emit_acc state k)

let emit_int_push state n =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true;
  state.acc_kind <- K_int

let emit_string_push state s =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true;
  state.acc_kind <- K_int

let emit_offsetclosure0 state =
  match state.enclosing_function_name with
  | None ->
    failwith
      "java_of_ocaml: OFFSETCLOSURE0 outside a function body — \
       top-level closure references aren't supported yet"
  | Some fname ->
    overwrite_acc
      state
      (K_closure fname)
      (fun () -> Jvm.Code.ldc_int state.code 0 (* sentinel *))

let emit_pushoffsetclosure0 state =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <-
    (match state.enclosing_function_name with
     | None ->
       failwith
         "java_of_ocaml: PUSHOFFSETCLOSURE0 outside a function body"
     | Some n -> K_closure n)

(* CLOSURE: acc := new closure. No stack push (the source program emits its
   own PUSH after if it wants to save the closure). *)
let emit_closure state (ins : instr) =
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSURE at pc %d not registered"
           ins.pc)
  in
  overwrite_acc
    state
    (K_closure fn_info.name)
    (fun () -> Jvm.Code.ldc_int state.code 0)

(* CLOSUREREC: create (nfuncs) closures. For nfuncs=1, nvars=0 we just push a
   sentinel and tag acc as the single closure. *)
let emit_closurerec state (ins : instr) =
  let nfuncs = ins.args.(0) in
  let nvars = ins.args.(1) in
  if nfuncs <> 1 || nvars <> 0
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: CLOSUREREC nfuncs=%d nvars=%d not yet supported"
         nfuncs
         nvars);
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSUREREC at pc %d not registered"
           ins.pc)
  in
  (* Semantics mirror [push acc; acc := closure]. We reach this with
     [acc_live] meaningful only for save-PUSH handling; CLOSUREREC
     unconditionally pushes, so we dup+istore whatever acc currently is (if
     live), then overwrite with the closure sentinel. *)
  if state.acc_live
  then (
    let slot = next_free_local ~state in
    Jvm.Code.dup state.code;
    Jvm.Code.istore state.code slot;
    push_slot state state.acc_kind;
    Jvm.Code.pop_top state.code);
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure fn_info.name;
  (* And then push acc onto the OCaml stack (CLOSUREREC's own push). *)
  let slot = next_free_local ~state in
  Jvm.Code.dup state.code;
  Jvm.Code.istore state.code slot;
  push_slot state state.acc_kind

let consume_top state =
  pop_slots state 1

let emit_addint state =
  let slot = top_slot_local ~state in
  Jvm.Code.iload state.code slot;
  Jvm.Code.iadd state.code;
  consume_top state

let emit_subint state =
  let slot = top_slot_local ~state in
  Jvm.Code.iload state.code slot;
  Jvm.Code.isub state.code;
  consume_top state

let emit_mulint state =
  let slot = top_slot_local ~state in
  Jvm.Code.iload state.code slot;
  Jvm.Code.imul state.code;
  consume_top state

let emit_divint state =
  let slot = top_slot_local ~state in
  Jvm.Code.iload state.code slot;
  Jvm.Code.idiv state.code;
  consume_top state

let emit_modint state =
  let slot = top_slot_local ~state in
  Jvm.Code.iload state.code slot;
  Jvm.Code.irem state.code;
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
  state.acc_live <- false;
  state.acc_kind <- K_int

let descriptor_for_nargs nargs =
  let buf = Buffer.create 8 in
  Buffer.add_char buf '(';
  for _ = 1 to nargs do
    Buffer.add_char buf 'I'
  done;
  Buffer.add_char buf ')';
  Buffer.add_char buf 'I';
  Buffer.contents buf

(* APPLY{1,2,3,N}: args are at stack[0..n-1 from top] in locals, in source
   order (stack[0 from top] = first source-order arg). Closure sentinel is
   on top of JVM operand stack in acc. Dispatch to the known function. *)
let emit_apply state ~nargs =
  match state.acc_kind with
  | K_closure name ->
    if state.acc_live then Jvm.Code.pop_top state.code;
    for k = 0 to nargs - 1 do
      let slot = stack_slot_local ~state k in
      Jvm.Code.iload state.code slot
    done;
    Jvm.Code.invokestatic
      state.code
      ~class_:"Main"
      ~method_:name
      ~descriptor:(descriptor_for_nargs nargs);
    pop_slots state nargs;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_int ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: APPLY%d called on a non-closure value (K_int). \
          Did the closure analysis lose its tag?"
         nargs)

let emit_apply1 state = emit_apply state ~nargs:1

(* APPTERM_N: tail call — same as APPLY followed by return. Since our
   method is about to return anyway, drop-slots (S) is a no-op for us. *)
let emit_appterm state ~nargs =
  emit_apply state ~nargs;
  Jvm.Code.ireturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slot_kinds <- []

let emit_return state =
  (* We discard the OCaml frame's stack depth — the JVM method's locals are
     all dead once we return. Just emit ireturn. *)
  Jvm.Code.ireturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slot_kinds <- []

let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  Jvm.Code.ldc_int state.code imm;
  (match ins.opcode with
   | 131 -> Jvm.Code.if_icmpeq state.code lbl
   | 132 -> Jvm.Code.if_icmpne state.code lbl
   | 133 -> Jvm.Code.if_icmpgt state.code lbl
   | 134 -> Jvm.Code.if_icmpge state.code lbl
   | 135 -> Jvm.Code.if_icmplt state.code lbl
   | 136 -> Jvm.Code.if_icmple state.code lbl
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: unexpected cmp_jump opcode %d"
          other));
  (* Cmp_jump reads acc (= accu of [acc TST imm]) but doesn't touch the
     OCaml stack; a caller sees the same stack as the branch point. *)
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int

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
  let slot = top_slot_local ~state in
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
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int

let emit_instr state (ins : instr) =
  (match Hashtbl.find_opt state.pc_to_label ins.pc with
   | Some lbl ->
     Jvm.Code.mark_label state.code lbl;
     (* Reset state to the snapshot taken at the first branch into this
        target. Any linear-walk mutations between here and the preceding
        [RETURN] / fall-through are effectively dead code from the JVM's
        point of view; we just need consistent state going forward. *)
     (match Hashtbl.find_opt state.branch_target_state ins.pc with
      | Some snap ->
        state.oc_stack_depth <- snap.s_oc_stack_depth;
        state.slot_kinds <- snap.s_slot_kinds
      | None -> ());
     state.acc_live <- false;
     state.acc_kind <- K_int;
     state.pending_cmp <- None
   | None -> ());
  let op = ins.opcode in
  if is_cmp_nullary op
  then state.pending_cmp <- Some (cmp_of_opcode op)
  else if op = Bytecode.Op.branchifnot
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:false;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.if_icmpeq state.code (label_at state target_pc);
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
  else if op = Bytecode.Op.branchif
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:true;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.if_icmpne state.code (label_at state target_pc);
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
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
  else if op = Bytecode.Op.divint then emit_divint state
  else if op = Bytecode.Op.modint then emit_modint state
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
  else if op = Bytecode.Op.pop then pop_slots state ins.args.(0)
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
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target);
    record_branch_target state target)
  else if is_cmp_jump op then emit_cmp_jump state ins
  else if op = closurerec_op then emit_closurerec state ins
  else if op = closure_op then emit_closure state ins
  else if op = offsetclosure0_op then emit_offsetclosure0 state
  else if op = pushoffsetclosure0_op then emit_pushoffsetclosure0 state
  else if op = apply1_op then emit_apply1 state
  else if op = apply2_op then emit_apply state ~nargs:2
  else if op = apply3_op then emit_apply state ~nargs:3
  else if op = apply_op then emit_apply state ~nargs:ins.args.(0)
  else if op = appterm1_op then emit_appterm state ~nargs:1
  else if op = appterm2_op then emit_appterm state ~nargs:2
  else if op = appterm3_op then emit_appterm state ~nargs:3
  else if op = appterm_op then emit_appterm state ~nargs:ins.args.(0)
  else if op = return_op then emit_return state
  else if op = restart_op || op = grab_op then
    (* Function-entry prologue. We already extracted [nargs] up-front and
       the JVM convention puts args in locals 0..nargs-1; nothing to emit. *)
    ()
  else if op = event_op || op = break_op then
    (* Debug markers from [ocamlc -g]. Nothing to emit; they're there for
       the OCaml debugger only. *)
    ()
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
(* Compile-wide driver. *)

let find_supported_prims_map = find_supported_prims

let collect_pc_to_label
    code
    ~arr
    ~scan_range:(scan_lo, scan_hi)
    ~target_range:(tgt_lo_pc, tgt_hi_pc)
    ~skip_pcs
  =
  let tbl = Hashtbl.create 4 in
  for i = scan_lo to scan_hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then
      match branch_target arr.(i) with
      | None -> ()
      | Some target_pc ->
        if target_pc >= tgt_lo_pc
           && target_pc <= tgt_hi_pc
           && not (Hashtbl.mem tbl target_pc)
        then Hashtbl.add tbl target_pc (Jvm.Code.fresh_label code)
  done;
  tbl

let emit_range state arr (lo, hi) ~skip_pcs =
  for i = lo to hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then emit_instr state arr.(i)
  done

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let prim_table = find_supported_prims_map parsed in
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
  (* Pre-scan for CLOSUREREC within the user range. *)
  let functions = Hashtbl.create 2 in
  let func_list = ref [] in
  let fn_body_pcs = Hashtbl.create 4 in
  let fn_count = ref 0 in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op || ins.opcode = closure_op
    then (
      let recursive = ins.opcode = closurerec_op in
      let body_pc, nvars =
        if recursive
        then (
          let nfuncs = ins.args.(0) in
          let nvars = ins.args.(1) in
          if nfuncs <> 1
          then
            failwith
              (Printf.sprintf
                 "java_of_ocaml: CLOSUREREC nfuncs=%d at pc %d — only 1 \
                  is currently supported"
                 nfuncs
                 ins.pc);
          ins.pc + 3 + ins.args.(2), nvars)
        else (
          (* CLOSURE args: nvars, offset (from pc+1? Check parse_bytecode). *)
          let nvars = ins.args.(0) in
          ins.pc + ins.args.(1) + 2, nvars)
      in
      if nvars <> 0
      then
        failwith
          (Printf.sprintf
             "java_of_ocaml: CLOSURE/CLOSUREREC nvars=%d at pc %d — only \
              0 is currently supported (non-capturing closures)"
             nvars
             ins.pc);
      let body_start_idx, body_end_idx, nargs =
        find_function_body_range arr body_pc
      in
      let name = Printf.sprintf "ocaml_fn_%d" !fn_count in
      incr fn_count;
      let info =
        { name
        ; closurerec_pc = ins.pc
        ; body_pc
        ; body_start_idx
        ; body_end_idx
        ; nargs
        ; recursive
        }
      in
      Hashtbl.add functions ins.pc info;
      func_list := info :: !func_list;
      (* Mark ALL instruction PCs between the original body_pc (including
         the RESTART / GRAB we skipped) and body_end as part of the
         function — those should not be re-emitted in main. *)
      let pre_start =
        let rec find i =
          if i >= Array.length arr then i
          else if arr.(i).pc = body_pc then i
          else find (i + 1)
        in
        find 0
      in
      for j = pre_start to body_end_idx do
        Hashtbl.replace fn_body_pcs arr.(j).pc ()
      done)
  done;
  let cp = Jvm.Cp.create () in
  (* Emit each function body as a static method. *)
  let fn_methods =
    List.map
      (fun fn_info ->
        let fn_code = Jvm.Code.create cp in
        let pc_to_label =
          collect_pc_to_label
            fn_code
            ~arr
            ~scan_range:(fn_info.body_start_idx, fn_info.body_end_idx)
            ~target_range:
              (arr.(fn_info.body_start_idx).pc, arr.(fn_info.body_end_idx).pc)
            ~skip_pcs:(Hashtbl.create 0)
        in
        let initial_kinds =
          let rec make n =
            if n <= 0 then [] else K_int :: make (n - 1)
          in
          make fn_info.nargs
        in
        let state =
          { code = fn_code
          ; globals = parsed.globals
          ; supported_prims = prim_table
          ; functions
          ; pc_to_label
          ; branch_target_state = Hashtbl.create 4
          ; acc_live = false
          ; acc_kind = K_int
          ; slot_kinds = initial_kinds
          ; oc_stack_depth = fn_info.nargs
          ; pending_cmp = None
          ; nargs = fn_info.nargs
          ; enclosing_function_name = Some fn_info.name
          }
        in
        emit_range
          state
          arr
          (fn_info.body_start_idx, fn_info.body_end_idx)
          ~skip_pcs:(Hashtbl.create 0);
        { Jvm.name = fn_info.name
        ; descriptor = descriptor_for_nargs fn_info.nargs
        ; access_flags = 0x000A (* ACC_PRIVATE | ACC_STATIC *)
        ; code = fn_code
        })
      !func_list
  in
  (* Emit main, skipping function-body PCs. *)
  let main_code = Jvm.Code.create cp in
  let post_end_pc =
    if end_idx + 1 < Array.length arr then arr.(end_idx + 1).pc else max_int
  in
  let pc_to_label =
    collect_pc_to_label
      main_code
      ~arr
      ~scan_range:(start_idx, end_idx)
      ~target_range:(arr.(start_idx).pc, post_end_pc)
      ~skip_pcs:fn_body_pcs
  in
  let state =
    { code = main_code
    ; globals = parsed.globals
    ; supported_prims = prim_table
    ; functions
    ; pc_to_label
    ; branch_target_state = Hashtbl.create 4
    ; acc_live = false
    ; acc_kind = K_int
    ; slot_kinds = []
    ; oc_stack_depth = 0
    ; pending_cmp = None
    ; nargs = 0
    ; enclosing_function_name = None
    }
  in
  emit_range state arr (start_idx, end_idx) ~skip_pcs:fn_body_pcs;
  (match Hashtbl.find_opt pc_to_label post_end_pc with
   | Some lbl -> Jvm.Code.mark_label main_code lbl
   | None -> ());
  Jvm.Code.return_void main_code;
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code = main_code
    }
  in
  let class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~cp
      ~methods:(main_method :: fn_methods)
  in
  let out_path = Filename.concat out_dir "Main.class" in
  let oc = open_out_bin out_path in
  output_string oc class_bytes;
  close_out oc
