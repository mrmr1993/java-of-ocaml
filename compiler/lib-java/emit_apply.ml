open Kind
open Function_info
open State

let apply_descriptor_for_nargs nargs =
  let buf = Buffer.create 16 in
  Buffer.add_char buf '(';
  for _ = 1 to nargs do
    Buffer.add_string buf "Ljava/lang/Object;"
  done;
  Buffer.add_string buf ")Ljava/lang/Object;";
  Buffer.contents buf

let emit_apply_invoke state ~nargs =
  (match state.acc_kind with
   | K_closure _ -> ()
   | K_obj | K_int | K_float | K_string | K_block _ ->
     (* Inference on realistic Stdlib code (CamlinternalMod's
        module-update path, indirect dispatch through module
        records) still lands at APPLY sites with acc_kind that
        isn't K_closure — path-unioning return-kind inference
        closes most but not all. Box + checkcast defers the
        mismatch to a runtime ClassCastException if the value
        genuinely isn't a closure. *)
     box_if_int state.code state.acc_kind;
     Jvm.Code.checkcast state.code "Closure";
     state.acc_kind <- K_closure { name = "Closure"; captures = [] });
  for k = 0 to nargs - 1 do
    let slot = List.nth state.slots k in
    (* Slot locals are Object-typed; aload and pass directly — no
       unbox/rebox, since apply wants [Object] args anyway. *)
    Jvm.Code.aload state.code slot.local
  done;
  if nargs > 7
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: APPLY%d — the base Closure class only \
          declares apply1..apply7 right now"
         nargs);
  Jvm.Code.invokevirtual
    state.code
    ~class_:"Closure"
    ~method_:(Printf.sprintf "apply%d" nargs)
    ~descriptor:(apply_descriptor_for_nargs nargs);
  pop_slots state nargs;
  if state.pending_retaddrs > 0
  then (
    state.pending_retaddrs <- state.pending_retaddrs - 1;
    pop_slots state 3);
  state.acc_live <- true

let emit_apply state ~nargs =
  let callee_info =
    match state.acc_kind with
    | K_closure { name; _ } -> Hashtbl.find_opt state.fn_by_name name
    | _ -> None
  in
  emit_apply_invoke state ~nargs;
  let return_kind =
    match callee_info with
    | Some (fi : function_info) when nargs < fi.nargs ->
      (* Undersupplied call — the JVM Closure.apply<nargs> stub built a
         PartialClosure from the passed args. The result is a closure,
         not the function's final return. *)
      K_obj
    | Some (fi : function_info) -> !(fi.return_kind)
    | None ->
      (* Calling through an opaque closure (e.g. a function arg, or a
         capture whose kind we lost). We can't know the callee's return
         kind without more analysis, so stay on the lazy K_obj path and
         let the next op unbox via ensure_kind at point of use. *)
      K_obj
  in
  emit_unbox_to_kind state.code return_kind;
  state.acc_kind <- return_kind

let emit_apply1 state = emit_apply state ~nargs:1

(* OCaml PUSH_RETADDR L: push three retaddr words onto the OCaml stack
   (return PC, env, extra_args). The callee's RETURN pops them along
   with its own locals. At the JVM level we don't need any of this
   information (Java's native return takes care of it); we only need to
   track that the OCaml stack got 3 slots deeper so later ACC k
   resolves to the right slot. After the matching APPLY those slots
   are "popped" by the callee's RETURN — since nothing in our JVM-level
   emission pushed them, we reconcile by popping 3 slots post-apply. *)
let emit_push_retaddr state =
  (* Initialise the 3 sentinel slots with [null] so the JVM verifier
     sees them as typed [Object] rather than TOP. OCaml ignores the
     slot values (APPLY pops them with the callee's RETURN), but the
     JVM verifier rejects [aload] of an uninitialised local. Use the
     fixed depth→local mapping so these slots share the same JVM
     locals as any control-flow path that arrives at the same
     depth. *)
  for _ = 1 to 3 do
    let local = State.slot_obj_local state state.oc_stack_depth in
    Jvm.Code.aconst_null state.code;
    Jvm.Code.astore state.code local;
    push_slot state K_obj local
  done;
  state.pending_retaddrs <- state.pending_retaddrs + 1

let emit_appterm state ~nargs =
  emit_apply_invoke state ~nargs;
  Jvm.Code.areturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

let emit_return state =
  if state.acc_live
  then box_acc_to_object state
  else (
    Jvm.Code.ldc_int state.code 0;
    emit_box_int state.code);
  Jvm.Code.areturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []
