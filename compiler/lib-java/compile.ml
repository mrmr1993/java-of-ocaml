(* -------------------------------------------------------------------------- *)
(* Supported primitives. Each has a known JVM emission pattern. *)

type prim_handler =
  | P_println_int
  | P_println_string
  | P_array_get
  | P_array_set
  | P_obj_dup

let primitives : (string * prim_handler) list =
  [ "caml_java_print_endline", P_println_string
  ; "caml_java_print_int", P_println_int
  ; "caml_array_get_addr", P_array_get
  ; "caml_array_set_addr", P_array_set
  ; "caml_obj_dup", P_obj_dup
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
  || is_cmp_jump op
  || is_c_call op
  || op = closurerec_op
  || op = closure_op
  || op = offsetclosure0_op
  || op = pushoffsetclosure0_op
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

(* -------------------------------------------------------------------------- *)
(* Globals. *)

(* Classification of a global's value so GETGLOBAL can produce the right
   JVM representation. *)
type global_view =
  | G_string of string
  | G_int_block of int list (* all fields are small ints *)
  | G_unsupported

let inspect_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith
      (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then G_unsupported
  else if Obj.tag v = Obj.string_tag
  then G_string (Obj.magic v : string)
  else if Obj.tag v < Obj.no_scan_tag
  then (
    let size = Obj.size v in
    let rec gather i acc =
      if i >= size
      then Some (List.rev acc)
      else (
        let f = Obj.field v i in
        if Obj.is_block f
        then None
        else gather (i + 1) ((Obj.magic f : int) :: acc))
    in
    match gather 0 [] with
    | None -> G_unsupported
    | Some ints -> G_int_block ints)
  else G_unsupported

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

(* Every OCaml value flows through the JVM as either:
     - a primitive [int] (for monomorphic int-valued contexts), or
     - a reference: either a [Block] object (all non-int OCaml values that
       our compiler currently models — tuples, records, arrays, ref cells)
       or a closure sentinel (still an int at runtime; K_closure is a
       compile-time phantom we plan to replace with a real Closure class
       in a later step).

   Per-block field kinds let GETFIELD / SETFIELD / array primitives emit
   the right cast + box/unbox at each use. *)
type kind =
  | K_int
  | K_block of kind list
  | K_closure of closure_ref

and closure_ref =
  { name : string
  ; captures : (int * kind) list
      (* JVM local + kind, in closure-field order (index 0 = ENVACC 2). *)
  }

let jvm_type_of_kind = function
  | K_int | K_closure _ -> "I"
  | K_block _ -> "LBlock;"

let emit_store_for_kind code local kind =
  match kind with
  | K_int | K_closure _ -> Jvm.Code.istore code local
  | K_block _ -> Jvm.Code.astore code local

let emit_load_for_kind code local kind =
  match kind with
  | K_int | K_closure _ -> Jvm.Code.iload code local
  | K_block _ -> Jvm.Code.aload code local

(* Boxing / unboxing helpers for crossing the int ↔ Object boundary. *)
let emit_box_int code =
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/Integer"
    ~method_:"valueOf"
    ~descriptor:"(I)Ljava/lang/Integer;"

let emit_unbox_to_kind code kind =
  match kind with
  | K_int ->
    Jvm.Code.checkcast code "java/lang/Integer";
    Jvm.Code.invokevirtual
      code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | K_block _ -> Jvm.Code.checkcast code "Block"
  | K_closure _ ->
    (* No runtime representation yet for closures-as-values. *)
    failwith
      "java_of_ocaml: reading a K_closure field is not supported yet — \
       closures need a runtime representation before they can live in a \
       block"

(* If [kind] is an int-kind, emit [Integer.valueOf] to box it to an
   Object. Otherwise, the value is already a reference. *)
let box_if_int code kind =
  match kind with
  | K_int -> emit_box_int code
  | _ -> ()

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
  ; ncaps : int
  ; capture_kinds : kind list ref
      (* Kinds of the captures passed to this method, in closure-field
         order. Length [ncaps]. Filled in when [emit_closure_creation]
         runs on this function's closure-creation site; used when emitting
         the body to pick ENVACC load opcodes and to synthesise the method
         descriptor. *)
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
type slot_info = { kind : kind; local : int }

type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slots : slot_info list
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; supported_prims : (int, string * prim_handler) Hashtbl.t
  ; functions : (int, function_info) Hashtbl.t
      (* closure{,rec}_pc -> function_info *)
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
      (* Target PC -> state to restore when we mark that target's label. *)
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slots : slot_info list
      (* most-recently-pushed first; head of list is the top of the OCaml
         stack. Length always equals [oc_stack_depth]. Each element records
         both the value's kind and the JVM local holding it. *)
  ; mutable oc_stack_depth : int
  ; mutable next_local : int
      (* Monotonically-increasing counter of allocated JVM locals for
         OCaml-stack values. Never decremented — once a local has held a
         pushed value, we don't reuse it (closure captures rely on locals
         surviving past slot-pop events). *)
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
      (* Number of OCaml arguments for this method. 0 for [main]. N for a
         function with N args. *)
  ; ncaps : int
      (* Number of captures in this method. Captures occupy JVM locals
         0..ncaps-1; args then occupy ncaps..ncaps+nargs-1. *)
  ; capture_kinds : kind list [@warning "-69"]
      (* Kinds of the captures, in closure-field order (index 0 = first
         ENVACC-visible capture). Used to emit the right load opcode for
         ENVACC and to propagate to self-closures via OFFSETCLOSURE0. *)
  ; enclosing_function_name : string option
      (* [None] when emitting [main]; [Some name] inside a function body.
         OFFSETCLOSURE0 uses this to tag acc as the self-closure. *)
  }

(* Slot lookups go through [state.slots], which records per-slot the kind
   and the JVM local that was assigned at push time. *)

let record_branch_target state target_pc =
  if not (Hashtbl.mem state.branch_target_state target_pc)
  then
    Hashtbl.add
      state.branch_target_state
      target_pc
      { s_oc_stack_depth = state.oc_stack_depth
      ; s_slots = state.slots
      }

let stack_slot_local ~state k =
  if k < 0 || k >= state.oc_stack_depth
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: stack slot %d out of range (depth %d, nargs %d, \
          ncaps %d, in_fn=%s)"
         k
         state.oc_stack_depth
         state.nargs
         state.ncaps
         (match state.enclosing_function_name with
          | Some n -> n
          | None -> "<main>"));
  (List.nth state.slots k).local

let top_slot_local ~state = stack_slot_local ~state 0

let allocate_local state =
  let l = state.next_local in
  state.next_local <- l + 1;
  l

let kind_of_slot_from_top ~state k =
  (List.nth state.slots k).kind

let push_slot state kind local =
  state.slots <- { kind; local } :: state.slots;
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
  state.slots <- drop state.slots n;
  state.oc_stack_depth <- state.oc_stack_depth - n

let find_supported_prims bc =
  let table = Hashtbl.create 4 in
  List.iter
    (fun (name, handler) ->
      match Bytecode.prim_index bc name with
      | Some idx -> Hashtbl.add table idx (name, handler)
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
    let local = allocate_local state in
    Jvm.Code.dup state.code;
    emit_store_for_kind state.code local state.acc_kind;
    push_slot state state.acc_kind local)

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
    emit_load_for_kind state.code slot new_kind;
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

let self_closure_ref state =
  match state.enclosing_function_name with
  | None ->
    failwith
      "java_of_ocaml: OFFSETCLOSURE0/PUSHOFFSETCLOSURE0 outside a function"
  | Some fname ->
    (* A function can pass itself as a closure by name: its captures are the
         captures the caller handed to it, currently in JVM locals 0..ncaps-1,
         with their kinds taken from [state.capture_kinds]. *)
    let rec loop i acc =
      if i >= state.ncaps then List.rev acc
      else (
        let k = List.nth state.capture_kinds i in
        loop (i + 1) ((i, k) :: acc))
    in
    { name = fname; captures = loop 0 [] }

let emit_offsetclosure0 state =
  let cref = self_closure_ref state in
  overwrite_acc
    state
    (K_closure cref)
    (fun () -> Jvm.Code.ldc_int state.code 0)

let emit_pushoffsetclosure0 state =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure (self_closure_ref state)

(* ENVACC k accesses the k-th field of the closure's environment. OCaml 5.x
   closure layout: field 0 = code, field 1 = closinfo, fields 2..ncaps+1 =
   captures in order. ENVACC k for k >= 2 = capture (k-2), at JVM local
   (k-2); its kind comes from [state.capture_kinds]. *)
let capture_kind_at state cap_index =
  try List.nth state.capture_kinds cap_index with
  | _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC capture index %d out of range (ncaps=%d)"
         cap_index
         state.ncaps)

let emit_envacc state k =
  if k < 2
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC %d (field <2) not supported — closure \
          info fields aren't modelled"
         k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  if state.acc_live then Jvm.Code.pop_top state.code;
  emit_load_for_kind state.code cap_index kind;
  state.acc_live <- true;
  state.acc_kind <- kind

let emit_pushenvacc state k =
  let was_live = state.acc_live in
  emit_push state;
  if k < 2
  then
    failwith
      (Printf.sprintf "java_of_ocaml: PUSHENVACC %d (field <2) not supported" k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  if was_live then Jvm.Code.pop_top state.code;
  emit_load_for_kind state.code cap_index kind;
  state.acc_live <- true;
  state.acc_kind <- kind

(* Shared closure-creation logic. For CLOSURE (non-rec), [is_rec = false]
   and the closure is just placed in acc. For CLOSUREREC, [is_rec = true]
   and the closure is also pushed onto the OCaml stack (matching the
   interpreter's trailing [*--sp = accu]).

   OCaml semantics for nvars > 0:
     if (nvars > 0) *--sp = accu;
     for i = 0..nvars-1: field(accu, i+2) = sp[i];
     sp += nvars;
   So the first capture (field 2) is the acc at closure time; captures
   1..nvars-1 come from the OCaml stack, top-first. After the instruction
   the captured stack slots are consumed, and acc is the closure.

   Our scheme: emit an [emit_push state] to stash acc into a fresh JVM
   local, then the top nvars OCaml-stack slots are exactly our captures
   (their JVM locals, in top-first order, give field-order). *)
let emit_closure_creation state (fn_info : function_info) ~nvars ~is_rec =
  let captures =
    if nvars = 0
    then []
    else (
      if not state.acc_live
      then
        failwith
          "java_of_ocaml: CLOSURE/CLOSUREREC with nvars>0 requires a \
           live acc";
      emit_push state;
      let rec loop k acc =
        if k >= nvars
        then List.rev acc
        else (
          let slot = List.nth state.slots k in
          loop (k + 1) ((slot.local, slot.kind) :: acc))
      in
      let caps = loop 0 [] in
      pop_slots state nvars;
      caps)
  in
  (* Record the capture kinds on the function_info so the later pass that
     emits its body can use them to generate the correct descriptor and
     ENVACC load opcodes. If captures have been seen already (a function
     whose closure is created at multiple sites), require consistency. *)
  let collected_kinds = List.map snd captures in
  (match !(fn_info.capture_kinds) with
   | [] -> fn_info.capture_kinds := collected_kinds
   | existing when List.length existing = List.length collected_kinds
     && List.for_all2
          (fun a b ->
            match a, b with
            | K_int, K_int | K_block _, K_block _ -> true
            | K_closure _, K_closure _ -> true
            | _ -> false)
          existing
          collected_kinds ->
     ()
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: inconsistent capture kinds for function %s"
          fn_info.name));
  let cref = { name = fn_info.name; captures } in
  overwrite_acc
    state
    (K_closure cref)
    (fun () -> Jvm.Code.ldc_int state.code 0);
  if is_rec
  then (
    let local = allocate_local state in
    Jvm.Code.dup state.code;
    Jvm.Code.istore state.code local;
    push_slot state state.acc_kind local)

let emit_closure state (ins : instr) =
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSURE at pc %d not registered"
           ins.pc)
  in
  let nvars = ins.args.(0) in
  emit_closure_creation state fn_info ~nvars ~is_rec:false

let emit_closurerec state (ins : instr) =
  let nfuncs = ins.args.(0) in
  if nfuncs <> 1
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: CLOSUREREC nfuncs=%d not yet supported (only 1)"
         nfuncs);
  let nvars = ins.args.(1) in
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSUREREC at pc %d not registered"
           ins.pc)
  in
  emit_closure_creation state fn_info ~nvars ~is_rec:true

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

let emit_println state ~int_arg =
  Jvm.Code.getstatic
    state.code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.swap state.code;
  let desc = if int_arg then "(I)V" else "(Ljava/lang/String;)V" in
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:desc;
  state.acc_live <- false;
  state.acc_kind <- K_int

(* For an array-like block accessed with a dynamic index (Array.get /
   Array.set), all fields should share a kind if the OCaml program is
   well-typed. Take the first field's kind as the element kind and check
   the rest match. *)
let element_kind_of_block field_kinds =
  match field_kinds with
  | [] -> K_int (* degenerate — shouldn't happen for a live array *)
  | k :: rest ->
    let compatible a b =
      match a, b with
      | K_int, K_int | K_block _, K_block _ -> true
      | K_closure _, K_closure _ -> true
      | _ -> false
    in
    if List.for_all (compatible k) rest
    then k
    else
      failwith
        "java_of_ocaml: dynamic array indexing on a heterogeneous block — \
         element kinds disagree across fields"

(* caml_array_get_addr: C_CALL2 — args acc=block, stack[0]=index, result=
   block.fields[index] (with cast + unbox to the element kind). *)
let emit_array_get state =
  let idx_slot = top_slot_local ~state in
  match state.acc_kind with
  | K_block field_kinds ->
    let ek = element_kind_of_block field_kinds in
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.iload state.code idx_slot;
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code ek;
    consume_top state;
    state.acc_live <- true;
    state.acc_kind <- ek
  | _ -> failwith "java_of_ocaml: caml_array_get_addr on non-block"

(* caml_obj_dup: C_CALL1, acc=block, result=shallow copy of block.
   Allocate a new Block(src.tag, Arrays.copyOf(src.fields, src.length)). *)
let emit_obj_dup state =
  (match state.acc_kind with
   | K_block _ -> ()
   | _ -> failwith "java_of_ocaml: caml_obj_dup on non-block");
  let src_local = allocate_local state in
  Jvm.Code.astore state.code src_local;
  (* Allocate new Block with (src.tag, Arrays.copyOf(src.fields, src.fields.length)). *)
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.aload state.code src_local;
  Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
  Jvm.Code.aload state.code src_local;
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.dup state.code;
  Jvm.Code.arraylength state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"copyOf"
    ~descriptor:"([Ljava/lang/Object;I)[Ljava/lang/Object;";
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"
  (* acc_kind unchanged *)

(* caml_array_set_addr: C_CALL3 — args acc=block, stack[0]=index,
   stack[1]=value, result=unit. *)
let emit_array_set state =
  let idx_slot = stack_slot_local ~state 0 in
  let val_slot_info = List.nth state.slots 1 in
  (match state.acc_kind with
   | K_block _ ->
     Jvm.Code.getfield
       state.code
       ~class_:"Block"
       ~field:"fields"
       ~descriptor:"[Ljava/lang/Object;";
     Jvm.Code.iload state.code idx_slot;
     emit_load_for_kind state.code val_slot_info.local val_slot_info.kind;
     box_if_int state.code val_slot_info.kind;
     Jvm.Code.aastore state.code
   | _ -> failwith "java_of_ocaml: caml_array_set_addr on non-block");
  pop_slots state 2;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* APPLY{1,2,3,N}: OCaml-stack slots [0..n-1] from top are the args in
   source order (stack[0 from top] = first source-order arg). The closure
   sentinel sits on top of the JVM operand stack in acc. Captures (if any)
   are loaded from the JVM locals the closure recorded when it was created,
   each using its kind's corresponding load opcode. We emit captures first,
   then args, then invokestatic. *)
let descriptor_of_capture_and_arg_kinds cap_kinds nargs =
  let buf = Buffer.create 8 in
  Buffer.add_char buf '(';
  List.iter (fun k -> Buffer.add_string buf (jvm_type_of_kind k)) cap_kinds;
  for _ = 1 to nargs do
    Buffer.add_char buf 'I'
  done;
  Buffer.add_char buf ')';
  Buffer.add_char buf 'I';
  Buffer.contents buf

let emit_apply state ~nargs =
  match state.acc_kind with
  | K_closure { name; captures } ->
    if state.acc_live then Jvm.Code.pop_top state.code;
    List.iter
      (fun (local, kind) -> emit_load_for_kind state.code local kind)
      captures;
    for k = 0 to nargs - 1 do
      let slot = stack_slot_local ~state k in
      Jvm.Code.iload state.code slot
    done;
    let cap_kinds = List.map snd captures in
    let desc = descriptor_of_capture_and_arg_kinds cap_kinds nargs in
    Jvm.Code.invokestatic
      state.code
      ~class_:"Main"
      ~method_:name
      ~descriptor:desc;
    pop_slots state nargs;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_int | K_block _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: APPLY%d called on a non-closure value. Closure \
          analysis lost the tag?"
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
  state.slots <- []

let emit_return state =
  (* We discard the OCaml frame's stack depth — the JVM method's locals are
     all dead once we return. Just emit ireturn. *)
  Jvm.Code.ireturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

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
        state.slots <- snap.s_slots
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
  else if op = Bytecode.Op.makeblock
       || op = Bytecode.Op.makeblock1
       || op = Bytecode.Op.makeblock2
       || op = Bytecode.Op.makeblock3
  then (
    (* MAKEBLOCK size tag / MAKEBLOCKi tag: allocate a Block whose
       field 0 = acc and fields 1..size-1 = the top (size-1) OCaml-stack
       entries (most-recently-pushed at the lowest non-zero index). Int
       fields are boxed as Integer; reference fields flow into the
       Object[] as-is.

       The module-init trailer also emits MAKEBLOCK to wrap the
       compilation unit, but by then acc is dead — ignore those. *)
    if not state.acc_live
    then ()
    else (
      let size, tag =
        if op = Bytecode.Op.makeblock1
        then 1, ins.args.(0)
        else if op = Bytecode.Op.makeblock2
        then 2, ins.args.(0)
        else if op = Bytecode.Op.makeblock3
        then 3, ins.args.(0)
        else ins.args.(0), ins.args.(1)
      in
      if size < 1 then failwith "java_of_ocaml: MAKEBLOCK with size < 1";
      let field_kinds =
        let k0 = state.acc_kind in
        let rec gather i acc =
          if i >= size
          then List.rev acc
          else
            let slot_kind = (List.nth state.slots (i - 1)).kind in
            gather (i + 1) (slot_kind :: acc)
        in
        gather 1 [ k0 ]
      in
      (* Stash acc to a local so we can freely build the fields array. *)
      let acc_local = allocate_local state in
      emit_store_for_kind state.code acc_local state.acc_kind;
      (* Build the Object[] of fields, pre-boxing ints. *)
      let fields_local = allocate_local state in
      Jvm.Code.ldc_int state.code size;
      Jvm.Code.anewarray state.code "java/lang/Object";
      Jvm.Code.astore state.code fields_local;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.ldc_int state.code 0;
      emit_load_for_kind state.code acc_local state.acc_kind;
      box_if_int state.code state.acc_kind;
      Jvm.Code.aastore state.code;
      for i = 1 to size - 1 do
        let slot = List.nth state.slots (i - 1) in
        Jvm.Code.aload state.code fields_local;
        Jvm.Code.ldc_int state.code i;
        emit_load_for_kind state.code slot.local slot.kind;
        box_if_int state.code slot.kind;
        Jvm.Code.aastore state.code
      done;
      (* Allocate the Block. *)
      Jvm.Code.new_ state.code "Block";
      Jvm.Code.dup state.code;
      Jvm.Code.ldc_int state.code tag;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.invokespecial
        state.code
        ~class_:"Block"
        ~method_:"<init>"
        ~descriptor:"(I[Ljava/lang/Object;)V";
      pop_slots state (size - 1);
      state.acc_kind <- K_block field_kinds))
  else if op = Bytecode.Op.getfield0
       || op = Bytecode.Op.getfield1
       || op = Bytecode.Op.getfield2
       || op = Bytecode.Op.getfield3
       || op = Bytecode.Op.getfield
  then (
    let field =
      if op = Bytecode.Op.getfield0
      then 0
      else if op = Bytecode.Op.getfield1
      then 1
      else if op = Bytecode.Op.getfield2
      then 2
      else if op = Bytecode.Op.getfield3
      then 3
      else ins.args.(0)
    in
    match state.acc_kind with
    | K_block field_kinds ->
      let fk =
        try List.nth field_kinds field with
        | _ ->
          failwith
            (Printf.sprintf
               "java_of_ocaml: GETFIELD %d out of range at pc %d"
               field
               ins.pc)
      in
      Jvm.Code.getfield
        state.code
        ~class_:"Block"
        ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code field;
      Jvm.Code.aaload state.code;
      emit_unbox_to_kind state.code fk;
      state.acc_kind <- fk
    | _ ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETFIELD on non-block at pc %d"
           ins.pc))
  else if op = Bytecode.Op.setfield0
       || op = Bytecode.Op.setfield1
       || op = Bytecode.Op.setfield2
       || op = Bytecode.Op.setfield3
       || op = Bytecode.Op.setfield
  then (
    let field =
      if op = Bytecode.Op.setfield0
      then 0
      else if op = Bytecode.Op.setfield1
      then 1
      else if op = Bytecode.Op.setfield2
      then 2
      else if op = Bytecode.Op.setfield3
      then 3
      else ins.args.(0)
    in
    let top = List.hd state.slots in
    (match state.acc_kind with
     | K_block _ ->
       Jvm.Code.getfield
         state.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int state.code field;
       emit_load_for_kind state.code top.local top.kind;
       box_if_int state.code top.kind;
       Jvm.Code.aastore state.code
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: SETFIELD on non-block at pc %d"
            ins.pc));
    consume_top state;
    Jvm.Code.ldc_int state.code 0;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.vectlength
  then (
    (match state.acc_kind with
     | K_block _ -> ()
     | _ ->
       failwith
         (Printf.sprintf "java_of_ocaml: VECTLENGTH on non-block at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.arraylength state.code;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.offsetref
  then (
    (* Field(acc, 0) += n; acc := unit. Load the Integer, unbox, add n,
       rebox, store back. *)
    let n = ins.args.(0) in
    (match state.acc_kind with
     | K_block _ -> ()
     | _ ->
       failwith
         (Printf.sprintf "java_of_ocaml: OFFSETREF on non-ref at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    (* Stack: [fields] *)
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code 0;
    (* Stack: [fields, fields, 0] *)
    Jvm.Code.dup2 state.code;
    (* Stack: [fields, fields, 0, fields, 0] *)
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code K_int;
    Jvm.Code.ldc_int state.code n;
    Jvm.Code.iadd state.code;
    emit_box_int state.code;
    (* Stack: [fields, fields, 0, new_integer] *)
    Jvm.Code.aastore state.code;
    (* Stack: [fields] *)
    Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 0;
    state.acc_kind <- K_int)
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
  else if op = Bytecode.Op.pop
  then (
    (* The module-init trailer emits POP 2 / POP N where N may exceed what
       we've tracked (we ignore MAKEBLOCK1 and other trailer ops). Clamp
       the pop to the available depth to stay robust. *)
    let n = min ins.args.(0) state.oc_stack_depth in
    pop_slots state n)
  else if op = Bytecode.Op.assign
  then (
    (* OCaml semantics: stack[k] := acc ; acc := unit. We store acc into
       the JVM local of a caller slot, then overwrite acc with 0 (our
       unit sentinel). *)
    let k = ins.args.(0) in
    if k < 0 || k >= state.oc_stack_depth
    then
      failwith
        (Printf.sprintf
           "java_of_ocaml: ASSIGN %d out of range (depth %d) at pc %d"
           k
           state.oc_stack_depth
           ins.pc);
    if not state.acc_live
    then
      failwith
        (Printf.sprintf "java_of_ocaml: ASSIGN with dead acc at pc %d" ins.pc);
    let target = (List.nth state.slots k).local in
    Jvm.Code.istore state.code target;
    Jvm.Code.ldc_int state.code 0;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.getglobal
  then (
    match inspect_global state.globals ins.args.(0) with
    | G_string s -> emit_string_const state s
    | G_int_block ints ->
      (* Materialise as a Block with boxed int fields. *)
      if state.acc_live then Jvm.Code.pop_top state.code;
      let size = List.length ints in
      let fields_local = allocate_local state in
      Jvm.Code.ldc_int state.code size;
      Jvm.Code.anewarray state.code "java/lang/Object";
      Jvm.Code.astore state.code fields_local;
      List.iteri
        (fun i v ->
          Jvm.Code.aload state.code fields_local;
          Jvm.Code.ldc_int state.code i;
          Jvm.Code.ldc_int state.code v;
          emit_box_int state.code;
          Jvm.Code.aastore state.code)
        ints;
      Jvm.Code.new_ state.code "Block";
      Jvm.Code.dup state.code;
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.invokespecial
        state.code
        ~class_:"Block"
        ~method_:"<init>"
        ~descriptor:"(I[Ljava/lang/Object;)V";
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map (fun _ -> K_int) ints)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETGLOBAL %d at pc %d — global is neither a \
            string nor an int-block"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.pushgetglobal
  then (
    match inspect_global state.globals ins.args.(0) with
    | G_string s -> emit_string_push state s
    | G_int_block ints ->
      let was_live = state.acc_live in
      emit_push state;
      if was_live then Jvm.Code.pop_top state.code;
      let size = List.length ints in
      let fields_local = allocate_local state in
      Jvm.Code.ldc_int state.code size;
      Jvm.Code.anewarray state.code "java/lang/Object";
      Jvm.Code.astore state.code fields_local;
      List.iteri
        (fun i v ->
          Jvm.Code.aload state.code fields_local;
          Jvm.Code.ldc_int state.code i;
          Jvm.Code.ldc_int state.code v;
          emit_box_int state.code;
          Jvm.Code.aastore state.code)
        ints;
      Jvm.Code.new_ state.code "Block";
      Jvm.Code.dup state.code;
      Jvm.Code.ldc_int state.code 0;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.invokespecial
        state.code
        ~class_:"Block"
        ~method_:"<init>"
        ~descriptor:"(I[Ljava/lang/Object;)V";
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map (fun _ -> K_int) ints)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: PUSHGETGLOBAL %d at pc %d — global is neither \
            a string nor an int-block"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.branch
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target);
    record_branch_target state target)
  else if is_cmp_jump op then emit_cmp_jump state ins
  else if op = closurerec_op then emit_closurerec state ins
  else if op = closure_op then emit_closure state ins
  else if op = Bytecode.Op.envacc1 then emit_envacc state 1
  else if op = Bytecode.Op.envacc2 then emit_envacc state 2
  else if op = Bytecode.Op.envacc3 then emit_envacc state 3
  else if op = Bytecode.Op.envacc4 then emit_envacc state 4
  else if op = Bytecode.Op.envacc then emit_envacc state ins.args.(0)
  else if op = Bytecode.Op.pushenvacc1 then emit_pushenvacc state 1
  else if op = Bytecode.Op.pushenvacc2 then emit_pushenvacc state 2
  else if op = Bytecode.Op.pushenvacc3 then emit_pushenvacc state 3
  else if op = Bytecode.Op.pushenvacc4 then emit_pushenvacc state 4
  else if op = Bytecode.Op.pushenvacc then emit_pushenvacc state ins.args.(0)
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
  else if op = 92 then
    (* CHECK_SIGNALS — OCaml bytecode polls for signals at loop headers.
       We don't model OCaml's signal machinery, so this is a no-op. *)
    ()
  else if is_c_call op
  then (
    match Hashtbl.find_opt state.supported_prims ins.args.(0) with
    | Some (_name, handler) ->
      (match handler with
       | P_println_int -> emit_println state ~int_arg:true
       | P_println_string -> emit_println state ~int_arg:false
       | P_array_get -> emit_array_get state
       | P_array_set -> emit_array_set state
       | P_obj_dup -> emit_obj_dup state)
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
      let body_pc, ncaps =
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
          let nvars = ins.args.(0) in
          ins.pc + ins.args.(1) + 2, nvars)
      in
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
        ; ncaps
        ; capture_kinds = ref []
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
  (* Emit main first so that CLOSURE/CLOSUREREC sites can fill in each
     function's [capture_kinds] from the kinds of values captured at the
     call site. Function bodies are then emitted with that information. *)
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
    ; slots = []
    ; oc_stack_depth = 0
    ; next_local = 1 (* local 0 reserved for [String[] args] *)
    ; pending_cmp = None
    ; nargs = 0
    ; ncaps = 0
    ; capture_kinds = []
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
  (* Now emit each function body, using the [capture_kinds] populated by
     main's CLOSURE/CLOSUREREC emissions. *)
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
        let initial_slots =
          let rec make i =
            if i >= fn_info.nargs
            then []
            else { kind = K_int; local = fn_info.ncaps + i } :: make (i + 1)
          in
          make 0
        in
        (* Reserve max_locals for the declared parameters even if the body
           doesn't touch all of them (otherwise the JVM class-format loader
           rejects the method with "Arguments can't fit into locals"). *)
        Jvm.Code.set_min_locals fn_code (fn_info.ncaps + fn_info.nargs);
        let state =
          { code = fn_code
          ; globals = parsed.globals
          ; supported_prims = prim_table
          ; functions
          ; pc_to_label
          ; branch_target_state = Hashtbl.create 4
          ; acc_live = false
          ; acc_kind = K_int
          ; slots = initial_slots
          ; oc_stack_depth = fn_info.nargs
          ; next_local = fn_info.ncaps + fn_info.nargs
          ; pending_cmp = None
          ; nargs = fn_info.nargs
          ; ncaps = fn_info.ncaps
          ; capture_kinds = !(fn_info.capture_kinds)
          ; enclosing_function_name = Some fn_info.name
          }
        in
        emit_range
          state
          arr
          (fn_info.body_start_idx, fn_info.body_end_idx)
          ~skip_pcs:(Hashtbl.create 0);
        let desc =
          descriptor_of_capture_and_arg_kinds
            !(fn_info.capture_kinds)
            fn_info.nargs
        in
        { Jvm.name = fn_info.name
        ; descriptor = desc
        ; access_flags = 0x000A (* ACC_PRIVATE | ACC_STATIC *)
        ; code = fn_code
        })
      !func_list
  in
  let class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[]
      ~methods:(main_method :: fn_methods)
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
  in
  let write_class name bytes =
    let path = Filename.concat out_dir (name ^ ".class") in
    let oc = open_out_bin path in
    output_string oc bytes;
    close_out oc
  in
  write_class "Main" class_bytes;
  write_class "Block" (Jvm.block_class_bytes ())
