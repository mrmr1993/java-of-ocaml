(** Lower OCaml bytecode for a single function body (or top-level
    init) into the structural IR [Code.program].

    Partitions the PC range into basic blocks (boundaries = branch
    targets, PCs after terminators, PUSHTRAP handler entries). For
    each block, walks the instruction stream with a parser [State]
    (accu + operand stack + env) and emits [Code.instr]s + a
    terminator. Every block's [params] list carries the entry state
    (accu, then stack top-down) as fresh [Var.t]s; branch edges pass
    the outgoing state through [cont] args, keeping the IR SSA-ish.

    Only the opcode subset currently supported by the forward-walk
    emitter is handled — unknown opcodes raise [Not_supported]. *)

exception Not_supported of string

(** [parse_function instrs ~start_pc ~end_pc ~nargs ~ncaps] lowers the
    half-open PC range [start_pc..end_pc) into a program.

    - [nargs] : apply-method arity. Args are bound to fresh Vars and
      form the [params] of the entry block.
    - [ncaps] : capture count. Captures are also bound to fresh Vars;
      ENVACC references read them directly. *)
val parse_function :
     ?extra_starts:int list
  -> Instr.instr list
  -> start_pc:int
  -> end_pc:int
  -> nargs:int
  -> ncaps:int
  -> Code.program
     * Code.Var.t list (* params (args then captures) *)
     * Code.Var.t (* env Var — the closure self-ref used by ENVACC /
                      OFFSETCLOSURE *)

(** [parse_main ?extra_starts instrs ~start_pc ~end_pc] is for the
    top-level init code (no args, no captures). [extra_starts], if
    given, is a list of extra PCs to treat as block boundaries;
    callers pass debug-event PCs here to get a per-source-line
    block split. *)
val parse_main :
     ?extra_starts:int list
  -> Instr.instr list
  -> start_pc:int
  -> end_pc:int
  -> Code.program
