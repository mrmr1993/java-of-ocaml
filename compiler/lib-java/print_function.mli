(** Debug dump of a bytecode function's decoded instruction stream.

    Given a pc, walks forward through the decoded instructions and
    prints each one (pc, opcode name, args, branch targets, whether
    it's a terminator), along with the walker-state tracking that
    {!Function_info.find_function_body_range} uses — outstanding
    forward branch targets that have not yet been "closed" by being
    landed at. When the parser fails with "no terminator in function
    body", this lets the operator see the actual instruction
    sequence to understand why. *)

val print :
     Format.formatter
  -> Instr.instr array
  -> sorted_body_pcs:int array
  -> pc:int
  -> unit
(** [print fmt arr ~sorted_body_pcs ~pc] prints the function starting
    at bytecode pc [pc], bounded by either the next entry in
    [sorted_body_pcs] or the end of the instruction array. Each line
    shows: index, pc, opcode name, args, branch targets, the
    outstanding-targets set, and a "TERM" tag for recognised
    terminators. *)
