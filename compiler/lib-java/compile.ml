open Global_view
open Instr
open Kind
open Function_info
open Prim
open State

(* Debug flags. Enable via [JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit]. *)
let debug_times = Debug.find "times"
let debug_primitives = Debug.find "primitives"
let debug_functions = Debug.find "functions"
let debug_emit = Debug.find "emit"

let time_phase name f =
  if not (debug_times ())
  then f ()
  else
    let t = Timer.make () in
    let r = f () in
    Format.eprintf "[times] %s: %a s@." name Timer.print t;
    r

let rec string_of_kind = function
  | K_int -> "int"
  | K_string -> "string"
  | K_block ks ->
    Printf.sprintf "block[%s]" (String.concat "," (List.map string_of_kind ks))
  | K_closure { name; _ } -> Printf.sprintf "closure<%s>" name
  | K_obj -> "obj"

let emit_instr state (ins : instr) =
  if debug_emit ()
  then
    Format.eprintf
      "[emit] pc=%d op=%s%s depth=%d acc=%s%s@."
      ins.pc
      (Bytecode.opcode_name ins.opcode)
      (if Array.length ins.args = 0
       then ""
       else
         " "
         ^ (Array.to_list ins.args
            |> List.map string_of_int
            |> String.concat ","))
      state.oc_stack_depth
      (if state.acc_live then "live:" else "dead:")
      (string_of_kind state.acc_kind);
  (match Hashtbl.find_opt state.pc_to_label ins.pc with
   | Some lbl ->
     (* If this PC is a try/with handler target, emit the JVM-level
        prelude first (unwrap the caught [CamlException] into its
        [value]). The JVM exception handler's handler_pc points at the
        prelude label, not at the OCaml handler label directly — the
        prelude converts the handler-entry state (one [Throwable] on
        the op stack) into our acc-live convention. *)
     (match Hashtbl.find_opt state.pending_handlers ins.pc with
      | Some prelude_lbl ->
        Jvm.Code.mark_label state.code prelude_lbl;
        Jvm.Code.handler_stack_prelude state.code;
        Jvm.Code.checkcast state.code "CamlException";
        Jvm.Code.getfield
          state.code
          ~class_:"CamlException"
          ~field:"value"
          ~descriptor:"Ljava/lang/Object;"
      | None -> ());
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
     (* A handler target arrives with acc live (the caught value on the
        JVM op stack) — don't clobber it. For normal branch targets acc
        is always consumed before the branch, so it's dead on entry. *)
     if Hashtbl.mem state.pending_handlers ins.pc
     then (
       state.acc_live <- true;
       state.acc_kind <- K_obj)
     else (
       state.acc_live <- false;
       state.acc_kind <- K_int);
     state.pending_cmp <- None
   | None -> ());
  let op = ins.opcode in
  if is_cmp_nullary op
  then state.pending_cmp <- Some (Emit_branch.cmp_of_opcode op)
  else if op = Bytecode.Op.branchifnot
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Emit_branch.emit_fused_branch state ~cmp ~target_pc ~branch_if_true:false;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      (match state.acc_kind with
       | K_int ->
         Jvm.Code.ldc_int state.code 0;
         Jvm.Code.if_icmpeq state.code (label_at state target_pc)
       | K_obj ->
         Emit_branch.emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:true
       | K_block _ | K_closure _ | K_string ->
         (* A statically-known reference kind is never [Val_int(0)];
            the branchifnot can't fire. Discard acc. *)
         Jvm.Code.pop_top state.code
       );
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
  else if op = Bytecode.Op.branchif
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      Emit_branch.emit_fused_branch state ~cmp ~target_pc ~branch_if_true:true;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      (match state.acc_kind with
       | K_int ->
         Jvm.Code.ldc_int state.code 0;
         Jvm.Code.if_icmpne state.code (label_at state target_pc)
       | K_obj ->
         Emit_branch.emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:false
       | K_block _ | K_closure _ | K_string ->
         (* Statically-known reference — always "truthy"; the branch
            always fires. Drop acc and goto. *)
         Jvm.Code.pop_top state.code;
         Jvm.Code.goto state.code (label_at state target_pc)
       );
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
  else if op = Bytecode.Op.switch
  then Emit_branch.emit_switch state ins
  else if op = Bytecode.Op.pushtrap
  then Emit_exception.emit_pushtrap state ins
  else if op = Bytecode.Op.poptrap
  then Emit_exception.emit_poptrap state
  else if op = Bytecode.Op.raise_
       || op = Bytecode.Op.reraise
       || op = Bytecode.Op.raise_notrace
  then Emit_exception.emit_raise state
  else if op = Bytecode.Op.isint
  then Emit_primitive.emit_isint state
  else if op = Bytecode.Op.push_retaddr
  then Emit_apply.emit_push_retaddr state
  else if op = Bytecode.Op.boolnot
  then (
    (* OCaml bool is Val_int(0) / Val_int(1). Flip via XOR with 1. *)
    ensure_kind state K_int;
    Jvm.Code.ldc_int state.code 1;
    (* XOR opcode not exposed; synthesise via [(1 - x)] with iconst_1;
       swap; isub — but [Code.swap] + [isub] is what we have.
       Actually simpler: [ixor] is opcode 0x82, not yet in [Jvm.Code].
       Use subtraction instead. *)
    Jvm.Code.swap state.code;
    Jvm.Code.isub state.code;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.const0 then Emit_stack.emit_int_const state 0
  else if op = Bytecode.Op.const1 then Emit_stack.emit_int_const state 1
  else if op = Bytecode.Op.const2 then Emit_stack.emit_int_const state 2
  else if op = Bytecode.Op.const3 then Emit_stack.emit_int_const state 3
  else if op = Bytecode.Op.constint then Emit_stack.emit_int_const state ins.args.(0)
  else if op = Bytecode.Op.pushconst0 then Emit_stack.emit_int_push state 0
  else if op = Bytecode.Op.pushconst1 then Emit_stack.emit_int_push state 1
  else if op = Bytecode.Op.pushconst2 then Emit_stack.emit_int_push state 2
  else if op = Bytecode.Op.pushconst3 then Emit_stack.emit_int_push state 3
  else if op = Bytecode.Op.pushconstint
  then Emit_stack.emit_int_push state ins.args.(0)
  else if op = Bytecode.Op.offsetint then Emit_arith.emit_offsetint state ins.args.(0)
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
    | K_obj ->
      (* Variant value whose shape is only knowable at runtime. We already
         dispatched past the immediate-constructor case via BRANCHIFNOT, so
         the value must be a [Block]. Cast it, pluck the field, and leave
         the result as K_obj (its kind is inferred lazily by the next op). *)
      Jvm.Code.checkcast state.code "Block";
      Jvm.Code.getfield
        state.code
        ~class_:"Block"
        ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code field;
      Jvm.Code.aaload state.code;
      state.acc_kind <- K_obj
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
     | K_obj ->
       (* Record / mutable block arrived as an opaque Object (e.g. a
          function arg). Cast and proceed. *)
       Jvm.Code.checkcast state.code "Block";
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
     | K_obj -> Jvm.Code.checkcast state.code "Block"
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
     | K_obj -> Jvm.Code.checkcast state.code "Block"
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
  else if op = Bytecode.Op.addint then Emit_arith.emit_addint state
  else if op = Bytecode.Op.subint then Emit_arith.emit_subint state
  else if op = Bytecode.Op.mulint then Emit_arith.emit_mulint state
  else if op = Bytecode.Op.divint then Emit_arith.emit_divint state
  else if op = Bytecode.Op.modint then Emit_arith.emit_modint state
  else if op = Bytecode.Op.push then Emit_stack.emit_push state
  else if op = Bytecode.Op.acc0 then Emit_stack.emit_acc state 0
  else if op = Bytecode.Op.acc1 then Emit_stack.emit_acc state 1
  else if op = Bytecode.Op.acc2 then Emit_stack.emit_acc state 2
  else if op = Bytecode.Op.acc3 then Emit_stack.emit_acc state 3
  else if op = Bytecode.Op.acc4 then Emit_stack.emit_acc state 4
  else if op = Bytecode.Op.acc5 then Emit_stack.emit_acc state 5
  else if op = Bytecode.Op.acc6 then Emit_stack.emit_acc state 6
  else if op = Bytecode.Op.acc7 then Emit_stack.emit_acc state 7
  else if op = Bytecode.Op.acc then Emit_stack.emit_acc state ins.args.(0)
  else if op = Bytecode.Op.pushacc0 then Emit_stack.emit_pushacc state 0
  else if op = Bytecode.Op.pushacc1 then Emit_stack.emit_pushacc state 1
  else if op = Bytecode.Op.pushacc2 then Emit_stack.emit_pushacc state 2
  else if op = Bytecode.Op.pushacc3 then Emit_stack.emit_pushacc state 3
  else if op = Bytecode.Op.pushacc4 then Emit_stack.emit_pushacc state 4
  else if op = Bytecode.Op.pushacc5 then Emit_stack.emit_pushacc state 5
  else if op = Bytecode.Op.pushacc6 then Emit_stack.emit_pushacc state 6
  else if op = Bytecode.Op.pushacc7 then Emit_stack.emit_pushacc state 7
  else if op = Bytecode.Op.pushacc then Emit_stack.emit_pushacc state ins.args.(0)
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
    | G_string s -> Emit_stack.emit_string_const state s
    | G_block (tag, fields) ->
      if state.acc_live then Jvm.Code.pop_top state.code;
      Emit_stack.emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETGLOBAL %d at pc %d — global has an \
            unsupported shape (nested blocks / abstract values aren't \
            materialised yet)"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.pushgetglobal
  then (
    match inspect_global state.globals ins.args.(0) with
    | G_string s -> Emit_stack.emit_string_push state s
    | G_block (tag, fields) ->
      let was_live = state.acc_live in
      Emit_stack.emit_push state;
      if was_live then Jvm.Code.pop_top state.code;
      Emit_stack.emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: PUSHGETGLOBAL %d at pc %d — global has an \
            unsupported shape"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.branch
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target);
    record_branch_target state target)
  else if is_cmp_jump op then Emit_branch.emit_cmp_jump state ins
  else if op = closurerec_op then Emit_closure.emit_closurerec state ins
  else if op = closure_op then Emit_closure.emit_closure state ins
  else if op = Bytecode.Op.envacc1 then Emit_closure.emit_envacc state 1
  else if op = Bytecode.Op.envacc2 then Emit_closure.emit_envacc state 2
  else if op = Bytecode.Op.envacc3 then Emit_closure.emit_envacc state 3
  else if op = Bytecode.Op.envacc4 then Emit_closure.emit_envacc state 4
  else if op = Bytecode.Op.envacc then Emit_closure.emit_envacc state ins.args.(0)
  else if op = Bytecode.Op.pushenvacc1 then Emit_closure.emit_pushenvacc state 1
  else if op = Bytecode.Op.pushenvacc2 then Emit_closure.emit_pushenvacc state 2
  else if op = Bytecode.Op.pushenvacc3 then Emit_closure.emit_pushenvacc state 3
  else if op = Bytecode.Op.pushenvacc4 then Emit_closure.emit_pushenvacc state 4
  else if op = Bytecode.Op.pushenvacc then Emit_closure.emit_pushenvacc state ins.args.(0)
  else if op = offsetclosure0_op then Emit_closure.emit_offsetclosure0 state
  else if op = pushoffsetclosure0_op then Emit_closure.emit_pushoffsetclosure0 state
  else if op = offsetclosurem3_op then Emit_closure.emit_offsetclosure state (-3)
  else if op = offsetclosure3_op then Emit_closure.emit_offsetclosure state 3
  else if op = offsetclosure_op then Emit_closure.emit_offsetclosure state ins.args.(0)
  else if op = pushoffsetclosurem3_op then Emit_closure.emit_pushoffsetclosure state (-3)
  else if op = pushoffsetclosure3_op then Emit_closure.emit_pushoffsetclosure state 3
  else if op = pushoffsetclosure_op
  then Emit_closure.emit_pushoffsetclosure state ins.args.(0)
  else if op = apply1_op then Emit_apply.emit_apply1 state
  else if op = apply2_op then Emit_apply.emit_apply state ~nargs:2
  else if op = apply3_op then Emit_apply.emit_apply state ~nargs:3
  else if op = apply_op then Emit_apply.emit_apply state ~nargs:ins.args.(0)
  else if op = appterm1_op then Emit_apply.emit_appterm state ~nargs:1
  else if op = appterm2_op then Emit_apply.emit_appterm state ~nargs:2
  else if op = appterm3_op then Emit_apply.emit_appterm state ~nargs:3
  else if op = appterm_op then Emit_apply.emit_appterm state ~nargs:ins.args.(0)
  else if op = return_op then Emit_apply.emit_return state
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
    | Some (_name, handler, _seed) ->
      (match handler with
       | P_println_int -> Emit_primitive.emit_println state ~int_arg:true
       | P_println_string -> Emit_primitive.emit_println state ~int_arg:false
       | P_array_get -> Emit_primitive.emit_array_get state
       | P_array_set -> Emit_primitive.emit_array_set state
       | P_obj_dup -> Emit_primitive.emit_obj_dup state
       | P_fresh_oo_id -> Emit_primitive.emit_fresh_oo_id state
       | P_alloc_dummy -> Emit_primitive.emit_alloc_dummy state
       | P_update_dummy -> Emit_primitive.emit_update_dummy state)
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

(* -------------------------------------------------------------------------- *)
(* Compile-wide driver. *)

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
      List.iter
        (fun target_pc ->
          if target_pc >= tgt_lo_pc
             && target_pc <= tgt_hi_pc
             && not (Hashtbl.mem tbl target_pc)
          then Hashtbl.add tbl target_pc (Jvm.Code.fresh_label code))
        (branch_targets arr.(i))
  done;
  tbl

let emit_range state arr (lo, hi) ~skip_pcs =
  for i = lo to hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then emit_instr state arr.(i)
  done

let compile ~bc ~out_dir =
  let total = if debug_times () then Some (Timer.make ()) else None in
  let parsed = time_phase "parse-bytecode" (fun () -> Bytecode.read_exe bc) in
  let prim_table = Prim.find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int).";
  if debug_primitives ()
  then (
    Format.eprintf "[primitives] resolved %d:@." (Hashtbl.length prim_table);
    Hashtbl.iter
      (fun idx (name, _, seed) ->
        Format.eprintf "  %d -> %s%s@." idx name (if seed then " (seed)" else ""))
      prim_table);
  let instrs = time_phase "decode" (fun () -> decode_all parsed) in
  let arr = Array.of_list instrs in
  let first_idx, last_idx =
    match Inference.supported_call_indices arr ~prim_table with
    | Some p -> p
    | None ->
      failwith "java_of_ocaml: no supported primitive calls found"
  in
  let start_idx = Inference.walk_back_user_start arr first_idx in
  let end_idx = Inference.walk_forward_user_end arr last_idx in
  if debug_functions ()
  then
    Format.eprintf
      "[functions] user range: idx %d..%d (pc %d..%d)@."
      start_idx
      end_idx
      arr.(start_idx).pc
      arr.(end_idx).pc;
  (* Pre-scan for CLOSUREREC within the user range. *)
  let functions = Hashtbl.create 2 in
  let func_list = ref [] in
  let fn_body_pcs = Hashtbl.create 4 in
  let fn_count = ref 0 in
  let fn_scan_timer = if debug_times () then Some (Timer.make ()) else None in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op || ins.opcode = closure_op
    then (
      let recursive = ins.opcode = closurerec_op in
      let nfuncs, nvars, body_pc_of =
        if recursive
        then (
          let nf = ins.args.(0) in
          let nv = ins.args.(1) in
          nf, nv, fun k -> ins.pc + 3 + ins.args.(2 + k))
        else (
          let nv = ins.args.(0) in
          1, nv, fun _ -> ins.pc + ins.args.(1) + 2)
      in
      let group = Array.make nfuncs (Obj.magic () : function_info) in
      for k = 0 to nfuncs - 1 do
        let body_pc = body_pc_of k in
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
          ; ncaps = nvars
          ; return_kind = ref K_int
          ; arg_kinds = ref (List.init nargs (fun _ -> K_int))
          ; capture_kinds = ref []
          ; recursive
          ; group_idx = k
          ; group = [||] (* filled in below *)
          }
        in
        group.(k) <- info;
        (* Main dispatch uses [functions] keyed by closurerec pc to look
           up the group's first function; nested [OFFSETCLOSURE] uses the
           [group] field to navigate to siblings. *)
        if k = 0 then Hashtbl.add functions ins.pc info;
        func_list := info :: !func_list;
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
        done
      done;
      Array.iter (fun info -> info.group <- group) group)
  done;
  (match fn_scan_timer with
   | Some t ->
     Format.eprintf
       "[times] function-scan (%d fns): %a s@."
       !fn_count
       Timer.print
       t
   | None -> ());
  (* Build a name -> function_info index for APPLY return-kind lookup, and
     run a quick pre-pass to seed each function's return_kind from the
     instruction preceding its RETURN / APPTERM. *)
  let fn_by_name = Hashtbl.create 4 in
  List.iter
    (fun (fi : function_info) -> Hashtbl.add fn_by_name fi.name fi)
    !func_list;
  time_phase "kind-inference" (fun () ->
    List.iter
      (fun (fi : function_info) ->
        fi.return_kind := Inference.infer_return_kind arr !func_list fi;
        fi.arg_kinds := Inference.infer_arg_kinds arr prim_table fi)
      !func_list);
  if debug_functions ()
  then
    List.iter
      (fun (fi : function_info) ->
        Format.eprintf
          "[functions] %s: nargs=%d ncaps=%d pc=%d body=[%d..%d] return=%s \
           args=[%s]@."
          fi.name
          fi.nargs
          fi.ncaps
          fi.body_pc
          fi.body_start_idx
          fi.body_end_idx
          (string_of_kind !(fi.return_kind))
          (String.concat "," (List.map string_of_kind !(fi.arg_kinds))))
      !func_list;
  let cp = Jvm.Cp.create () in
  (* Emit main first so that CLOSURE/CLOSUREREC sites can fill in each
     function's [capture_kinds] from the kinds of values captured at the
     call site. Function bodies are then emitted with that information. *)
  let main_code = Jvm.Code.create cp in
  let fresh_oo_id_counter = ref 0 in
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
    ; fn_by_name
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
    ; pending_handlers = Hashtbl.create 2
    ; open_traps = []
    ; fresh_oo_id_counter
    ; pending_retaddrs = 0
    }
  in
  time_phase "emit-main" (fun () ->
    emit_range state arr (start_idx, end_idx) ~skip_pcs:fn_body_pcs;
    (match Hashtbl.find_opt pc_to_label post_end_pc with
     | Some lbl -> Jvm.Code.mark_label main_code lbl
     | None -> ());
    Jvm.Code.return_void main_code);
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code = main_code
    }
  in
  let main_class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[]
      ~methods:[ main_method ]
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
  in
  (* Now emit each function as its own concrete [Closure] subclass. Each
     closure class has:
       - one instance field per capture, named [capN] (field order).
       - a constructor taking the captures as args, assigning them to the
         fields after calling [Closure.<init>()].
       - an [applyN] method whose body is the OCaml function's bytecode,
         with a prologue that unboxes [K_int] args from their [Object]
         parameters, and RETURN/APPTERM that box the result before
         [areturn]. *)
  let closure_class_files = time_phase "emit-closures" (fun () ->
    List.map
      (fun (fn_info : function_info) ->
        let cap_kinds = !(fn_info.capture_kinds) in
        let ncaps = List.length cap_kinds in
        let fn_cp = Jvm.Cp.create () in
        (* --- Constructor --- *)
        let ctor_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals ctor_code (1 + ncaps);
        Jvm.Code.aload ctor_code 0;
        Jvm.Code.invokespecial
          ctor_code
          ~class_:"Closure"
          ~method_:"<init>"
          ~descriptor:"()V";
        List.iteri
          (fun i k ->
            Jvm.Code.aload ctor_code 0;
            emit_load_for_kind ctor_code (i + 1) k;
            Jvm.Code.putfield
              ctor_code
              ~class_:fn_info.name
              ~field:(Printf.sprintf "cap%d" i)
              ~descriptor:(jvm_type_of_kind k))
          cap_kinds;
        Jvm.Code.return_void ctor_code;
        (* --- apply method body --- *)
        let apply_code = Jvm.Code.create fn_cp in
        (* Reserve max_locals: [this] + N args. *)
        Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
        (* No prologue: apply method args arrive as [Object], and we keep
           them that way in their locals. Each op that needs a specific
           kind (arithmetic → int; println(string) → String; etc.) casts
           or unboxes on first use via [ensure_kind]. This avoids static
           arg-kind inference and handles transitive cases like
           mkgreeter, where the arg's kind is only determined by where
           it ends up (in this case, a closure capture). *)
        let initial_slots =
          let rec make k =
            if k >= fn_info.nargs
            then []
            else { kind = K_obj; local = k + 1 } :: make (k + 1)
          in
          make 0
        in
        let pc_to_label =
          collect_pc_to_label
            apply_code
            ~arr
            ~scan_range:(fn_info.body_start_idx, fn_info.body_end_idx)
            ~target_range:
              (arr.(fn_info.body_start_idx).pc, arr.(fn_info.body_end_idx).pc)
            ~skip_pcs:(Hashtbl.create 0)
        in
        let state =
          { code = apply_code
          ; globals = parsed.globals
          ; supported_prims = prim_table
          ; functions
          ; fn_by_name
          ; pc_to_label
          ; branch_target_state = Hashtbl.create 4
          ; acc_live = false
          ; acc_kind = K_int
          ; slots = initial_slots
          ; oc_stack_depth = fn_info.nargs
          ; next_local = 1 + fn_info.nargs
          ; pending_cmp = None
          ; nargs = fn_info.nargs
          ; ncaps
          ; capture_kinds = cap_kinds
          ; enclosing_function_name = Some fn_info.name
          ; pending_handlers = Hashtbl.create 2
          ; open_traps = []
          ; fresh_oo_id_counter
          ; pending_retaddrs = 0
          }
        in
        emit_range
          state
          arr
          (fn_info.body_start_idx, fn_info.body_end_idx)
          ~skip_pcs:(Hashtbl.create 0);
        let cap_fields =
          List.mapi
            (fun i k ->
              { Jvm.name = Printf.sprintf "cap%d" i
              ; descriptor = jvm_type_of_kind k
              ; access_flags = 0x0011 (* ACC_PUBLIC | ACC_FINAL *)
              })
            cap_kinds
        in
        (* Sibling fields for CLOSUREREC groups > 1 function. Each
           function in the group holds [Closure]-typed refs to the
           others so [OFFSETCLOSURE N] can resolve statically to a
           [getfield sibling_K]. Mutable so the [CLOSUREREC] emission
           can allocate all group members and then patch cross-refs. *)
        let sibling_fields =
          let n = Array.length fn_info.group in
          if n <= 1
          then []
          else
            List.init n (fun i ->
              { Jvm.name = Printf.sprintf "sibling_%d" i
              ; descriptor = "LClosure;"
              ; access_flags = 0x0001 (* ACC_PUBLIC, mutable *)
              })
        in
        let fields = cap_fields @ sibling_fields in
        let ctor =
          { Jvm.name = "<init>"
          ; descriptor = Emit_closure.ctor_descriptor_for_captures cap_kinds
          ; access_flags = 0x0001 (* ACC_PUBLIC *)
          ; code = ctor_code
          }
        in
        let apply_method =
          { Jvm.name = Printf.sprintf "apply%d" fn_info.nargs
          ; descriptor = Emit_apply.apply_descriptor_for_nargs fn_info.nargs
          ; access_flags = 0x0001 (* ACC_PUBLIC *)
          ; code = apply_code
          }
        in
        (* [arity()] override so the base [Closure]'s dispatch (and
           [PartialClosure]'s saturation check) sees this subclass's
           actual arity. *)
        let arity_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals arity_code 1;
        Jvm.Code.ldc_int arity_code fn_info.nargs;
        Jvm.Code.ireturn arity_code;
        let arity_method =
          { Jvm.name = "arity"
          ; descriptor = "()I"
          ; access_flags = 0x0001
          ; code = arity_code
          }
        in
        let bytes =
          Jvm.assemble_class
            ~class_name:fn_info.name
            ~super_name:"Closure"
            ~cp:fn_cp
            ~fields
            ~methods:[ ctor; arity_method; apply_method ]
            ~access_flags:0x0031 (* ACC_PUBLIC | ACC_SUPER | ACC_FINAL *)
        in
        fn_info.name, bytes)
      !func_list)
  in
  let write_class name bytes =
    let path = Filename.concat out_dir (name ^ ".class") in
    let oc = open_out_bin path in
    output_string oc bytes;
    close_out oc
  in
  time_phase "write-classes" (fun () ->
    write_class "Main" main_class_bytes;
    write_class "Block" (Jvm.block_class_bytes ());
    write_class "Closure" (Jvm.closure_class_bytes ());
    write_class "CamlException" (Jvm.camlexception_class_bytes ());
    write_class "PartialClosure" (Jvm.partial_closure_class_bytes ());
    List.iter (fun (name, bytes) -> write_class name bytes) closure_class_files);
  match total with
  | Some t -> Format.eprintf "[times] total: %a s@." Timer.print t
  | None -> ()
