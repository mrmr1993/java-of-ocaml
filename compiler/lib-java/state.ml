open Kind
open Function_info

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

type slot_info = { kind : kind; local : int }

type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slots : slot_info list
  ; s_acc_live : bool
  ; s_acc_kind : kind
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; prims : string array
  ; supported_prims : Prim.table
  ; functions : (int, function_info) Hashtbl.t
  ; fn_by_name : (string, function_info) Hashtbl.t
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slots : slot_info list
  ; mutable oc_stack_depth : int
  ; mutable next_local : int
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
  ; ncaps : int
  ; capture_kinds : kind list [@warning "-69"]
  ; enclosing_function_name : string option
  ; pending_handlers : (int, Jvm.Code.label) Hashtbl.t
  ; mutable open_traps : (Jvm.Code.label * Jvm.Code.label) list
  ; fresh_oo_id_counter : int ref
  ; mutable pending_retaddrs : int
  }

let ensure_kind state target =
  let compatible a b =
    match a, b with
    | K_int, K_int -> true
    | K_string, K_string -> true
    | K_float, K_float -> true
    | K_block _, K_block _ -> true
    | K_closure _, K_closure _ -> true
    | K_obj, K_obj -> true
    | _ -> false
  in
  if compatible state.acc_kind target
  then ()
  else
    match state.acc_kind with
    | K_obj ->
      emit_unbox_to_kind state.code target;
      state.acc_kind <- target
    | _ ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: kind mismatch — have %s, need %s"
           (jvm_type_of_kind state.acc_kind)
           (jvm_type_of_kind target))

(* First-write-wins: subsequent branches to the same label must agree
   with the snapshot we've already recorded. Capturing [acc_live] /
   [acc_kind] alongside the OCaml-stack state means the label
   prologue can restore the full emitter context, not just the stack
   half — necessary for code that reaches a label with a live acc
   (e.g. [CLOSURE] with nvars>0 uses acc as its first capture). *)
let record_branch_target state target_pc =
  if not (Hashtbl.mem state.branch_target_state target_pc)
  then
    Hashtbl.add
      state.branch_target_state
      target_pc
      { s_oc_stack_depth = state.oc_stack_depth
      ; s_slots = state.slots
      ; s_acc_live = state.acc_live
      ; s_acc_kind = state.acc_kind
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

(* For [K_float] a JVM local takes 2 adjacent slots (N and N+1).
   Callers that know the value's kind should use this instead of
   [allocate_local] to avoid clobbering the second half. *)
let allocate_local_for_kind state kind =
  let l = state.next_local in
  state.next_local <- l + Kind.local_slots_for_kind kind;
  l

let kind_of_slot_from_top ~state k = (List.nth state.slots k).kind

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

let consume_top state = pop_slots state 1

let label_at state pc = Hashtbl.find state.pc_to_label pc

(* Discard the current live acc from the JVM stack — one [pop] for
   most kinds, [pop2] for [K_float] (which occupies 2 operand-stack
   slots). *)
let drop_live_acc state =
  if state.acc_live
  then
    match state.acc_kind with
    | K_float -> Jvm.Code.pop2 state.code
    | _ -> Jvm.Code.pop_top state.code

let overwrite_acc state kind emit =
  drop_live_acc state;
  emit ();
  state.acc_live <- true;
  state.acc_kind <- kind

let box_acc_to_object state =
  match state.acc_kind with
  | K_int -> emit_box_int state.code
  | K_float -> emit_box_float state.code
  | K_string | K_block _ | K_closure _ | K_obj -> ()

(* Emit [throw new java.lang.UnsupportedOperationException(msg)].
   Used as a placeholder for opcodes we haven't implemented yet; the
   JVM verifier still accepts unreachable code after [athrow], so
   surrounding emission can continue as if nothing happened beyond
   invalidating acc. Callers that take a branch target or otherwise
   fall through must update [state.acc_*] appropriately afterwards. *)
let emit_throw_unsupported state msg =
  Jvm.Code.new_ state.code "java/lang/UnsupportedOperationException";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_string state.code msg;
  Jvm.Code.invokespecial
    state.code
    ~class_:"java/lang/UnsupportedOperationException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/String;)V";
  Jvm.Code.athrow state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int
