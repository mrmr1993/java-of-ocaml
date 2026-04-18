open Kind
open State

let emit_raise state =
  box_acc_to_object state;
  let exc_val_local = allocate_local state in
  Jvm.Code.astore state.code exc_val_local;
  Jvm.Code.new_ state.code "CamlException";
  Jvm.Code.dup state.code;
  Jvm.Code.aload state.code exc_val_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"CamlException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/Object;)V";
  Jvm.Code.athrow state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

(* PUSHTRAP L: open a try region whose handler lives at bytecode PC L.

   Structural approach, mirroring jsoo's [Pushtrap] IR node: the
   handler edge is known at PUSHTRAP time (from the instruction's
   argument), so install the JVM exception-table entry eagerly
   here with a forward-allocated [end_lbl]. POPTRAP (or the handler-
   label prelude, if POPTRAP was elided because the try body always
   raises) just marks [end_lbl] at its byte position — the class-
   file writer resolves both label positions at write time.

   Side effects:
   - Mark [start_lbl] at the current byte offset (start of the
     protected region for the JVM exception table).
   - Allocate [end_lbl] and record it in [open_traps]; whichever
     of POPTRAP / handler-prelude comes first pins it to a byte
     position.
   - Allocate [prelude_lbl] and register it in [pending_handlers]
     keyed by the bytecode PC L so [emit_instr] emits the JVM
     handler prelude (CamlException unwrap) when it reaches L.
   - Install the exception-table entry [start_lbl..end_lbl →
     prelude_lbl] catching [CamlException].
   - Record a branch-target snapshot at L so the handler prelude
     can restore [state.slots] etc. to its pre-pushtrap shape.
   - Inflate [oc_stack_depth] by 4 with dummy slots so any
     following [acc K] / [push] in the protected body resolves
     to the right index (OCaml's interpreter pushes 4 trap-frame
     words at PUSHTRAP). *)
let emit_pushtrap state (ins : Instr.instr) =
  let handler_pc = ins.pc + ins.args.(0) + 1 in
  record_branch_target state handler_pc;
  let prelude_lbl =
    match Hashtbl.find_opt state.pending_handlers handler_pc with
    | Some lbl -> lbl
    | None ->
      let lbl = Jvm.Code.fresh_label state.code in
      Hashtbl.add state.pending_handlers handler_pc lbl;
      lbl
  in
  let start_lbl = Jvm.Code.fresh_label state.code in
  let end_lbl = Jvm.Code.fresh_label state.code in
  Jvm.Code.mark_label state.code start_lbl;
  Jvm.Code.add_exception_handler
    state.code
    ~start_lbl
    ~end_lbl
    ~handler_lbl:prelude_lbl
    ~catch_class:(Some "CamlException");
  for _ = 1 to 4 do
    let local = allocate_local state in
    push_slot state K_obj local
  done;
  state.open_traps <- (start_lbl, end_lbl, prelude_lbl) :: state.open_traps

let emit_poptrap state =
  match state.open_traps with
  | [] ->
    failwith
      "java_of_ocaml: POPTRAP without a matching PUSHTRAP — \
       exception-scope tracking is broken"
  | (_, end_lbl, _) :: rest ->
    state.open_traps <- rest;
    Jvm.Code.mark_label state.code end_lbl;
    pop_slots state 4
