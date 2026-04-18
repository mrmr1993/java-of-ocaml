(** The per-opcode dispatcher.

    [emit_instr state ins] dispatches on [ins.opcode] to the right
    [Emit_*] emitter, handling the inline opcodes (MAKEBLOCK, GETFIELD,
    SETFIELD, VECTLENGTH, OFFSETREF, BRANCH, BRANCH(IF/NOT), ASSIGN,
    GETGLOBAL, PUSHGETGLOBAL, BOOLNOT, POP) directly.

    On entry: if [ins.pc] is a branch target, marks the JVM label and
    restores [state] from the snapshot taken at the branching PC. If
    the PC is a try/with handler target, emits the CamlException
    unwrap prelude first. *)

val emit_instr : State.state -> Instr.instr -> unit
