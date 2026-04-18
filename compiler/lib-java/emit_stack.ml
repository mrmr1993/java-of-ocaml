open Global_view
open Kind
open State

let emit_int_const state n =
  overwrite_acc state K_int (fun () -> Jvm.Code.ldc_int state.code n)

let emit_string_const state s =
  overwrite_acc state K_string (fun () ->
    Jvm.Code.ldc_string state.code s)

(* Materialise a block constant (from the DATA section) as a Block instance
   on top of the op stack. Each field that's an int gets boxed as Integer;
   string fields are loaded via ldc and stored as-is. Does not modify
   state.acc_live / acc_kind; callers handle those. *)
let rec emit_materialise_value state = function
  | Gv_int n ->
    Jvm.Code.ldc_int state.code n;
    emit_box_int state.code
  | Gv_string s -> Jvm.Code.ldc_string state.code s
  | Gv_float d ->
    Jvm.Code.ldc_double state.code d;
    emit_box_float state.code
  | Gv_block (tag, fields) -> emit_materialise_block_constant state tag fields

and emit_materialise_block_constant state tag fields =
  let fields_local = allocate_local state in
  let size = List.length fields in
  Jvm.Code.ldc_int state.code size;
  Jvm.Code.anewarray state.code "java/lang/Object";
  Jvm.Code.astore state.code fields_local;
  List.iteri
    (fun i fv ->
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.ldc_int state.code i;
      emit_materialise_value state fv;
      Jvm.Code.aastore state.code)
    fields;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code tag;
  Jvm.Code.aload state.code fields_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"

let emit_push state =
  if not state.acc_live
  then
    (* A PUSH immediately after a C_CALL is a save-PUSH for its return
       value. Our compile stops before anything would read it back, so
       skip. *)
    ()
  else (
    (* Push to the slot that will sit at [oc_stack_depth] from the
       bottom of the OCaml stack after this push. Box acc to Object
       first so every slot local is [Object]-typed — depth-indexed
       and stable across every control-flow path, per the fixed
       slot→local scheme. Acc stays live on the operand stack. *)
    let local = slot_obj_local state state.oc_stack_depth in
    (match state.acc_kind with
     | K_float -> Jvm.Code.dup2 state.code
     | _ -> Jvm.Code.dup state.code);
    (match state.acc_kind with
     | K_int -> emit_box_int state.code
     | K_float -> emit_box_float state.code
     | K_string | K_block _ | K_closure _ | K_obj -> ());
    Jvm.Code.astore state.code local;
    push_slot state state.acc_kind local)

let emit_acc state k =
  if k >= state.oc_stack_depth
  then
    (* ACC past the end of our tracked OCaml stack — the compiler emits
       such an access in the module-init trailer to fetch the top-level
       binding for MAKEBLOCK. Our emission stops before MAKEBLOCK, so
       this access is dead; skip it. *)
    ()
  else (
    let slot = List.nth state.slots k in
    drop_live_acc state;
    Jvm.Code.aload state.code slot.local;
    emit_unbox_on_top state.code slot.kind;
    state.acc_live <- true;
    state.acc_kind <- slot.kind)

let emit_pushacc state k =
  if not state.acc_live
  then
    (* A PUSHACC at a dead point — most common example is right after a
       C_CALL returning unit. Skipping is correct since we don't emit
       MAKEBLOCK. *)
    ()
  else (
    emit_push state;
    emit_acc state k)

let emit_int_push state n =
  emit_push state;
  drop_live_acc state;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true;
  state.acc_kind <- K_int

let emit_string_push state s =
  emit_push state;
  drop_live_acc state;
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true;
  state.acc_kind <- K_string
