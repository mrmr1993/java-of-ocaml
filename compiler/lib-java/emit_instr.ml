open Global_view
open Instr
open Kind
open Prim
open State

let debug_emit = Debug.find "emit"

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
     (* Label prologue: restore the full emitter context from the
        snapshot taken at the first branch to this target. The
        pending-handler path is special — the handler starts with
        the [CamlException.value] on the JVM stack (already pushed
        above), so acc_live=true / acc_kind=K_obj regardless of
        what any snapshot says. *)
     if Hashtbl.mem state.pending_handlers ins.pc
     then (
       (match Hashtbl.find_opt state.branch_target_state ins.pc with
        | Some snap ->
          state.oc_stack_depth <- snap.s_oc_stack_depth;
          state.slots <- snap.s_slots
        | None -> ());
       state.acc_live <- true;
       state.acc_kind <- K_obj)
     else (
       match Hashtbl.find_opt state.branch_target_state ins.pc with
       | Some snap ->
         state.oc_stack_depth <- snap.s_oc_stack_depth;
         state.slots <- snap.s_slots;
         state.acc_live <- snap.s_acc_live;
         state.acc_kind <- snap.s_acc_kind
       | None ->
         (* Label reached only via fall-through — no snapshot, state
            is already whatever the previous instruction left it. *)
         ());
     state.pending_cmp <- None
   | None -> ());
  let op = ins.opcode in
  if not (is_cmp_nullary op)
  then Emit_branch.flush_pending_cmp state;
  if is_cmp_nullary op
  then state.pending_cmp <- Some (Emit_branch.cmp_of_opcode op)
  else if op = Bytecode.Op.branchifnot
  then (
    let target_pc = ins.pc + ins.args.(0) + 1 in
    if not state.acc_live
    then
      (* Dead-acc branch — usually unreachable after a terminator;
         just record and skip. *)
      record_branch_target state target_pc
    else (
      (* BRANCHIFNOT preserves acc per OCaml semantics. Box
         primitives to [Object] first so every edge leaves a
         uniform JVM stack type. *)
      Emit_branch.normalize_acc_for_branch state;
      (match state.acc_kind with
       | K_obj ->
         Emit_branch.emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:true
       | K_block _ | K_closure _ | K_string ->
         (* Reference kinds are never [Val_false] (= Integer 0),
            so BRANCHIFNOT never takes; fall through keeping acc
            on the stack. *)
         ()
       | K_int | K_float ->
         failwith
           "java_of_ocaml: BRANCHIFNOT: normalize should have \
            boxed to K_obj");
      record_branch_target state target_pc))
  else if op = Bytecode.Op.branchif
  then (
    let target_pc = ins.pc + ins.args.(0) + 1 in
    if not state.acc_live
    then record_branch_target state target_pc
    else (
      Emit_branch.normalize_acc_for_branch state;
      (match state.acc_kind with
       | K_obj ->
         Emit_branch.emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:false
       | K_block _ | K_closure _ | K_string ->
         (* Reference kinds are never Val_false; BRANCHIF always
            takes. *)
         Jvm.Code.goto state.code (label_at state target_pc)
       | K_int | K_float ->
         failwith
           "java_of_ocaml: BRANCHIF: normalize should have boxed \
            to K_obj");
      record_branch_target state target_pc))
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
    (* OCaml bool is Val_int(0) / Val_int(1). Flip via [1 - acc]. *)
    ensure_kind state K_int;
    Jvm.Code.ldc_int state.code 1;
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
      let acc_local = allocate_local_for_kind state state.acc_kind in
      emit_store_for_kind state.code acc_local state.acc_kind;
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
  else if op = Bytecode.Op.getvectitem then Emit_primitive.emit_array_get state
  else if op = Bytecode.Op.setvectitem then Emit_primitive.emit_array_set state
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
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.dup2 state.code;
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code K_int;
    Jvm.Code.ldc_int state.code n;
    Jvm.Code.iadd state.code;
    emit_box_int state.code;
    Jvm.Code.aastore state.code;
    Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 0;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.negint then Emit_arith.emit_negint state
  else if op = Bytecode.Op.addint then Emit_arith.emit_addint state
  else if op = Bytecode.Op.subint then Emit_arith.emit_subint state
  else if op = Bytecode.Op.mulint then Emit_arith.emit_mulint state
  else if op = Bytecode.Op.divint then Emit_arith.emit_divint state
  else if op = Bytecode.Op.modint then Emit_arith.emit_modint state
  else if op = Bytecode.Op.andint then Emit_arith.emit_andint state
  else if op = Bytecode.Op.orint then Emit_arith.emit_orint state
  else if op = Bytecode.Op.xorint then Emit_arith.emit_xorint state
  else if op = Bytecode.Op.lslint then Emit_arith.emit_lslint state
  else if op = Bytecode.Op.lsrint then Emit_arith.emit_lsrint state
  else if op = Bytecode.Op.asrint then Emit_arith.emit_asrint state
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
    let n = min ins.args.(0) state.oc_stack_depth in
    pop_slots state n)
  else if op = Bytecode.Op.assign
  then (
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
    let n = ins.args.(0) in
    match inspect_global state.globals n with
    | G_string s -> Emit_stack.emit_string_const state s
    | G_float d ->
      drop_live_acc state;
      Jvm.Code.ldc_double state.code d;
      state.acc_live <- true;
      state.acc_kind <- K_float
    | G_block (tag, fields) ->
      drop_live_acc state;
      Emit_stack.emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      (* Fall back to the runtime [Main.GLOBALS] table — the value
         will be whatever module-init's SETGLOBAL stored, or whatever
         the DATA section materialiser put there at startup. *)
      drop_live_acc state;
      Jvm.Code.getstatic
        state.code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code n;
      Jvm.Code.aaload state.code;
      state.acc_live <- true;
      state.acc_kind <- K_obj)
  else if op = Bytecode.Op.pushgetglobal
  then (
    let n = ins.args.(0) in
    match inspect_global state.globals n with
    | G_string s -> Emit_stack.emit_string_push state s
    | G_float d ->
      Emit_stack.emit_push state;
      drop_live_acc state;
      Jvm.Code.ldc_double state.code d;
      state.acc_live <- true;
      state.acc_kind <- K_float
    | G_block (tag, fields) ->
      Emit_stack.emit_push state;
      drop_live_acc state;
      Emit_stack.emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      Emit_stack.emit_push state;
      drop_live_acc state;
      Jvm.Code.getstatic
        state.code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code n;
      Jvm.Code.aaload state.code;
      state.acc_live <- true;
      state.acc_kind <- K_obj)
  else if op = Bytecode.Op.getglobalfield || op = Bytecode.Op.pushgetglobalfield
  then (
    let g = ins.args.(0) in
    let f = ins.args.(1) in
    let static_field =
      match inspect_global state.globals g with
      | G_block (_, fields) when f >= 0 && f < List.length fields ->
        Some (List.nth fields f)
      | _ -> None
    in
    let push_first = op = Bytecode.Op.pushgetglobalfield in
    if push_first then Emit_stack.emit_push state;
    let drop_old () = drop_live_acc state in
    match static_field with
    | Some (Gv_int n) ->
      drop_old ();
      Jvm.Code.ldc_int state.code n;
      state.acc_live <- true;
      state.acc_kind <- K_int
    | Some (Gv_string s) ->
      drop_old ();
      Jvm.Code.ldc_string state.code s;
      state.acc_live <- true;
      state.acc_kind <- K_string
    | Some (Gv_float d) ->
      drop_old ();
      Jvm.Code.ldc_double state.code d;
      state.acc_live <- true;
      state.acc_kind <- K_float
    | Some (Gv_block (tag, sub_fields)) ->
      drop_old ();
      Emit_stack.emit_materialise_block_constant state tag sub_fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field sub_fields)
    | None ->
      (* Runtime lookup: GLOBALS[g].fields[f]. For the common case
         (module record = Block), this is one getfield + aaload. *)
      drop_old ();
      Jvm.Code.getstatic
        state.code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code g;
      Jvm.Code.aaload state.code;
      Jvm.Code.checkcast state.code "Block";
      Jvm.Code.getfield
        state.code
        ~class_:"Block"
        ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code f;
      Jvm.Code.aaload state.code;
      state.acc_live <- true;
      state.acc_kind <- K_obj)
  else if op = Bytecode.Op.branch
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Emit_branch.normalize_acc_for_branch state;
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
  else if op = Bytecode.Op.pushenvacc
  then Emit_closure.emit_pushenvacc state ins.args.(0)
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
  else if op = restart_op || op = grab_op then ()
  else if op = event_op || op = break_op then ()
  else if op = 92 then () (* CHECK_SIGNALS *)
  else if op = Bytecode.Op.stop
  then (
    Jvm.Code.return_void state.code;
    state.acc_live <- false;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.setglobal
  then (
    let n = ins.args.(0) in
    box_acc_to_object state;
    let v_local = allocate_local state in
    Jvm.Code.astore state.code v_local;
    Jvm.Code.getstatic
      state.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int state.code n;
    Jvm.Code.aload state.code v_local;
    Jvm.Code.aastore state.code;
    Jvm.Code.ldc_int state.code 0;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.atom0 || op = Bytecode.Op.atom
  then (
    let tag = if op = Bytecode.Op.atom0 then 0 else ins.args.(0) in
    drop_live_acc state;
    Jvm.Code.new_ state.code "Block";
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code tag;
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.anewarray state.code "java/lang/Object";
    Jvm.Code.invokespecial
      state.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    state.acc_live <- true;
    state.acc_kind <- K_block [])
  else if op = Bytecode.Op.pushatom0 || op = Bytecode.Op.pushatom
  then (
    let tag = if op = Bytecode.Op.pushatom0 then 0 else ins.args.(0) in
    Emit_stack.emit_push state;
    drop_live_acc state;
    Jvm.Code.new_ state.code "Block";
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code tag;
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.anewarray state.code "java/lang/Object";
    Jvm.Code.invokespecial
      state.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    state.acc_live <- true;
    state.acc_kind <- K_block [])
  else if op = Bytecode.Op.makefloatblock
  then (
    let size = ins.args.(0) in
    if size < 1 then failwith "java_of_ocaml: MAKEFLOATBLOCK with size < 1";
    (* Layout matches MAKEBLOCK: acc is field 0, stack[0..] are fields
       1..size-1. All fields are floats, so each needs boxing to
       Double on the way in. *)
    ensure_kind state K_float;
    let acc_local = allocate_local_for_kind state K_float in
    Jvm.Code.dstore state.code acc_local;
    let fields_local = allocate_local state in
    Jvm.Code.ldc_int state.code size;
    Jvm.Code.anewarray state.code "java/lang/Object";
    Jvm.Code.astore state.code fields_local;
    Jvm.Code.aload state.code fields_local;
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.dload state.code acc_local;
    emit_box_float state.code;
    Jvm.Code.aastore state.code;
    for i = 1 to size - 1 do
      let slot = List.nth state.slots (i - 1) in
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.ldc_int state.code i;
      emit_load_for_kind state.code slot.local slot.kind;
      box_if_int state.code slot.kind;
      Jvm.Code.aastore state.code
    done;
    Jvm.Code.new_ state.code "Block";
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code 253 (* Double_tag *);
    Jvm.Code.aload state.code fields_local;
    Jvm.Code.invokespecial
      state.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    pop_slots state (size - 1);
    state.acc_live <- true;
    state.acc_kind <- K_obj)
  else if op = Bytecode.Op.getfloatfield
  then (
    let field = ins.args.(0) in
    (match state.acc_kind with
     | K_block _ -> ()
     | K_obj -> Jvm.Code.checkcast state.code "Block"
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: GETFLOATFIELD on non-block at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int state.code field;
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code K_float;
    state.acc_kind <- K_float)
  else if op = Bytecode.Op.setfloatfield
  then (
    let field = ins.args.(0) in
    (match state.acc_kind with
     | K_block _ -> ()
     | K_obj -> Jvm.Code.checkcast state.code "Block"
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: SETFLOATFIELD on non-block at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int state.code field;
    let top = List.hd state.slots in
    emit_load_for_kind state.code top.local top.kind;
    (match top.kind with
     | K_float -> emit_box_float state.code
     | K_obj -> ()
     | _ ->
       failwith "java_of_ocaml: SETFLOATFIELD value must be a float");
    Jvm.Code.aastore state.code;
    consume_top state;
    Jvm.Code.ldc_int state.code 0;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.ultint || op = Bytecode.Op.ugeint
  then (
    (* Unsigned compare via sign-bit flip: a <u b  <=>  (a^MIN) <s (b^MIN). *)
    ensure_kind state K_int;
    Jvm.Code.ldc_int state.code min_int;
    Jvm.Code.ixor state.code;
    let top = List.hd state.slots in
    emit_load_for_kind state.code top.local top.kind;
    (match top.kind with
     | K_int -> ()
     | K_obj -> emit_unbox_to_kind state.code K_int
     | _ -> failwith "java_of_ocaml: unsigned compare on non-int slot");
    Jvm.Code.ldc_int state.code min_int;
    Jvm.Code.ixor state.code;
    let lbl_true = Jvm.Code.fresh_label state.code in
    let lbl_end = Jvm.Code.fresh_label state.code in
    if op = Bytecode.Op.ultint
    then Jvm.Code.if_icmplt state.code lbl_true
    else Jvm.Code.if_icmpge state.code lbl_true;
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.goto state.code lbl_end;
    Jvm.Code.mark_label state.code lbl_true;
    Jvm.Code.ldc_int state.code 1;
    Jvm.Code.mark_label state.code lbl_end;
    consume_top state;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.getstringchar || op = Bytecode.Op.getbyteschar
  then (
    (* acc is string/bytes, stack[0] is index; result is char code (int). *)
    (match state.acc_kind with
     | K_string -> ()
     | K_obj -> Jvm.Code.checkcast state.code "java/lang/String"
     | _ ->
       emit_throw_unsupported
         state
         "GETSTRINGCHAR/GETBYTESCHAR on non-string (Bytes not yet a distinct type)");
    let idx_slot = List.hd state.slots in
    emit_load_for_kind state.code idx_slot.local idx_slot.kind;
    (match idx_slot.kind with
     | K_int -> ()
     | K_obj -> emit_unbox_to_kind state.code K_int
     | _ ->
       failwith
         "java_of_ocaml: GETSTRINGCHAR index must be int");
    Jvm.Code.invokevirtual
      state.code
      ~class_:"java/lang/String"
      ~method_:"charAt"
      ~descriptor:"(I)C";
    consume_top state;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.setbyteschar
  then
    (* Writing to a String is impossible — needs K_bytes (Phase 2). *)
    emit_throw_unsupported
      state
      "SETBYTESCHAR requires Bytes support (Phase 2)"
  else if op = Bytecode.Op.getmethod
       || op = Bytecode.Op.getpubmet
       || op = Bytecode.Op.getdynmet
  then
    emit_throw_unsupported state "OCaml objects / methods are not supported"
  else if op = Bytecode.Op.perform
       || op = Bytecode.Op.resume
       || op = Bytecode.Op.resumeterm
       || op = Bytecode.Op.reperformterm
  then emit_throw_unsupported state "OCaml 5 effect handlers are not supported"
  else if op = Bytecode.Op.bultint || op = Bytecode.Op.bugeint
  then (
    (* Fused unsigned compare-and-branch with an int immediate.
       OCaml preserves acc across the branch; box to [Object] up
       front, then [dup; checkcast; intValue] to pull out a copy
       for the [ixor]-based unsigned compare, leaving acc itself
       on the stack at both outgoing edges. *)
    let imm = ins.args.(0) in
    let target_pc = ins.pc + ins.args.(1) + 2 in
    Emit_branch.normalize_acc_for_branch state;
    Jvm.Code.dup state.code;
    Jvm.Code.checkcast state.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      state.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I";
    Jvm.Code.ldc_int state.code min_int;
    Jvm.Code.ixor state.code;
    Jvm.Code.ldc_int state.code (imm lxor min_int);
    let lbl = label_at state target_pc in
    (if op = Bytecode.Op.bultint
     then Jvm.Code.if_icmplt state.code lbl
     else Jvm.Code.if_icmpge state.code lbl);
    record_branch_target state target_pc)
  else if is_c_call op
  then (
    let prim_idx, consumed_on_stack =
      if op = Bytecode.Op.c_calln
      then
        let nargs = ins.args.(0) in
        (* C_CALLN: args.(0) = nargs, args.(1) = prim. nargs-1 slots
           come off the OCaml stack (the rest is in acc). *)
        ins.args.(1), nargs - 1
      else
        (* C_CALL1..5 → prim idx in args.(0); stack arg count is op-1 from the opcode number. *)
        ins.args.(0), op - Bytecode.Op.c_call1
    in
    match Hashtbl.find_opt state.supported_prims prim_idx with
    | Some (_name, handler, _seed) ->
      ignore consumed_on_stack;
      (match handler with
       | P_println_int -> Emit_primitive.emit_println state ~int_arg:true
       | P_println_string -> Emit_primitive.emit_println state ~int_arg:false
       | P_array_get -> Emit_primitive.emit_array_get state
       | P_array_set -> Emit_primitive.emit_array_set state
       | P_obj_dup -> Emit_primitive.emit_obj_dup state
       | P_obj_tag -> Emit_primitive.emit_obj_tag state
       | P_obj_block -> Emit_primitive.emit_obj_block state
       | P_obj_with_tag -> Emit_primitive.emit_obj_with_tag state
       | P_fresh_oo_id -> Emit_primitive.emit_fresh_oo_id state
       | P_alloc_dummy -> Emit_primitive.emit_alloc_dummy state
       | P_update_dummy -> Emit_primitive.emit_update_dummy state
       | P_println_float -> Emit_primitive.emit_float_print state
       | P_float_add -> Emit_primitive.emit_float_binop state Jvm.Code.dadd
       | P_float_sub -> Emit_primitive.emit_float_binop state Jvm.Code.dsub
       | P_float_mul -> Emit_primitive.emit_float_binop state Jvm.Code.dmul
       | P_float_div -> Emit_primitive.emit_float_binop state Jvm.Code.ddiv
       | P_float_neg -> Emit_primitive.emit_float_neg state
       | P_float_abs -> Emit_primitive.emit_float_abs state
       | P_float_eq -> Emit_primitive.emit_float_cmp state ~cmp:Eq
       | P_float_neq -> Emit_primitive.emit_float_cmp state ~cmp:Ne
       | P_float_lt -> Emit_primitive.emit_float_cmp state ~cmp:Lt
       | P_float_le -> Emit_primitive.emit_float_cmp state ~cmp:Le
       | P_float_gt -> Emit_primitive.emit_float_cmp state ~cmp:Gt
       | P_float_ge -> Emit_primitive.emit_float_cmp state ~cmp:Ge
       | P_int_of_float -> Emit_primitive.emit_int_of_float state
       | P_float_of_int -> Emit_primitive.emit_float_of_int state
       | P_array_make -> Emit_primitive.emit_array_make state
       | P_array_sub -> Emit_primitive.emit_array_sub state
       | P_array_blit -> Emit_primitive.emit_array_blit state
       | P_array_fill -> Emit_primitive.emit_array_fill state
       | P_array_append -> Emit_primitive.emit_array_append state
       | P_int_of_string -> Emit_primitive.emit_int_of_string state
       | P_format_int -> Emit_primitive.emit_format_int state
       | P_float_of_string -> Emit_primitive.emit_float_of_string state
       | P_format_float -> Emit_primitive.emit_format_float state
       | P_string_length -> Emit_primitive.emit_string_length state
       | P_string_equal -> Emit_primitive.emit_string_equal state ~invert:false
       | P_string_notequal -> Emit_primitive.emit_string_equal state ~invert:true
       | P_string_compare -> Emit_primitive.emit_string_compare state
       | P_noop1 -> Emit_primitive.emit_noop state ~nargs:1
       | P_noop2 -> Emit_primitive.emit_noop state ~nargs:2
       | P_noop_float1 -> Emit_primitive.emit_noop_float1 state
       | P_noop_null1 -> Emit_primitive.emit_noop_null state ~nargs:1
       | P_noop_null2 -> Emit_primitive.emit_noop_null state ~nargs:2
       | P_atomic_load -> Emit_primitive.emit_atomic_load state
       | P_atomic_cas -> Emit_primitive.emit_atomic_cas state
       | P_atomic_exchange -> Emit_primitive.emit_atomic_exchange state
       | P_atomic_fetch_add -> Emit_primitive.emit_atomic_fetch_add state
       | P_int_compare -> Emit_primitive.emit_int_compare state
       | P_poly_compare ->
         Emit_primitive.emit_poly_cmp state ~method_name:"compare"
       | P_poly_equal ->
         Emit_primitive.emit_poly_cmp state ~method_name:"equal"
       | P_poly_notequal ->
         Emit_primitive.emit_poly_cmp state ~method_name:"notequal"
       | P_poly_lessthan ->
         Emit_primitive.emit_poly_cmp state ~method_name:"lessthan"
       | P_poly_lessequal ->
         Emit_primitive.emit_poly_cmp state ~method_name:"lessequal"
       | P_poly_greaterthan ->
         Emit_primitive.emit_poly_cmp state ~method_name:"greaterthan"
       | P_poly_greaterequal ->
         Emit_primitive.emit_poly_cmp state ~method_name:"greaterequal")
    | None ->
      let name =
        if prim_idx >= 0 && prim_idx < Array.length state.prims
        then state.prims.(prim_idx)
        else Printf.sprintf "#%d" prim_idx
      in
      emit_throw_unsupported
        state
        (Printf.sprintf "C primitive %s is not implemented" name))
  else
    failwith
      (Printf.sprintf
         "java_of_ocaml: unsupported opcode %s (%d) at pc %d"
         (Bytecode.opcode_name op)
         op
         ins.pc)
