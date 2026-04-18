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
     (match Hashtbl.find_opt state.branch_target_state ins.pc with
      | Some snap ->
        state.oc_stack_depth <- snap.s_oc_stack_depth;
        state.slots <- snap.s_slots
      | None -> ());
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
  if not (is_cmp_nullary op || op = Bytecode.Op.branchif || op = Bytecode.Op.branchifnot)
  then Emit_branch.flush_pending_cmp state;
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
         Jvm.Code.pop_top state.code);
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
         Jvm.Code.pop_top state.code;
         Jvm.Code.goto state.code (label_at state target_pc));
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
      let acc_local = allocate_local state in
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
  else if op = Bytecode.Op.getglobalfield || op = Bytecode.Op.pushgetglobalfield
  then (
    let g = ins.args.(0) in
    let f = ins.args.(1) in
    let field =
      match inspect_global state.globals g with
      | G_block (_, fields) when f >= 0 && f < List.length fields ->
        List.nth fields f
      | _ ->
        failwith
          (Printf.sprintf
             "java_of_ocaml: %s %d %d at pc %d — global has an \
              unsupported shape or field index out of range"
             (Bytecode.opcode_name op)
             g
             f
             ins.pc)
    in
    let push_first = op = Bytecode.Op.pushgetglobalfield in
    let was_live = state.acc_live in
    if push_first then Emit_stack.emit_push state;
    let drop_old () = if was_live then Jvm.Code.pop_top state.code in
    match field with
    | Gv_int n ->
      drop_old ();
      Jvm.Code.ldc_int state.code n;
      state.acc_live <- true;
      state.acc_kind <- K_int
    | Gv_string s ->
      drop_old ();
      Jvm.Code.ldc_string state.code s;
      state.acc_live <- true;
      state.acc_kind <- K_string
    | Gv_block (tag, sub_fields) ->
      drop_old ();
      Emit_stack.emit_materialise_block_constant state tag sub_fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field sub_fields))
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
       | P_obj_tag -> Emit_primitive.emit_obj_tag state
       | P_obj_block -> Emit_primitive.emit_obj_block state
       | P_obj_with_tag -> Emit_primitive.emit_obj_with_tag state
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
