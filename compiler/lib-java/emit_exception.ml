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

   - Snapshot the current OCaml-side state so when we later materialise
     the handler label we can restore [slots] / [oc_stack_depth] to their
     pre-pushtrap values (OCaml's RAISE unwinds the trap frame and
     resumes at the handler with the stack it had before PUSHTRAP).
   - Inflate [oc_stack_depth] by 4 with dummy slots so any following
     [acc K] / [push] in the protected body resolves to the right index
     (OCaml's interpreter pushes 4 trap-frame words at PUSHTRAP).
   - Mark a fresh JVM label at the current byte offset: this is the
     [start_pc] of the JVM exception-table entry the matching POPTRAP
     will install.
   - Allocate a fresh JVM label [prelude_lbl] and record it in
     [pending_handlers] keyed by the bytecode PC L. When emit_instr
     reaches that PC it will emit the JVM-side prelude (unwrap the
     caught CamlException) at [prelude_lbl] before continuing into the
     OCaml handler's own bytecode. *)
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
  Jvm.Code.mark_label state.code start_lbl;
  for _ = 1 to 4 do
    let local = allocate_local state in
    push_slot state K_obj local
  done;
  state.open_traps <- (start_lbl, prelude_lbl) :: state.open_traps

let emit_poptrap state =
  match state.open_traps with
  | [] ->
    failwith
      "java_of_ocaml: POPTRAP without a matching PUSHTRAP — \
       exception-scope tracking is broken"
  | (start_lbl, prelude_lbl) :: rest ->
    state.open_traps <- rest;
    let end_lbl = Jvm.Code.fresh_label state.code in
    Jvm.Code.mark_label state.code end_lbl;
    Jvm.Code.add_exception_handler
      state.code
      ~start_lbl
      ~end_lbl
      ~handler_lbl:prelude_lbl
      ~catch_class:(Some "CamlException");
    pop_slots state 4
