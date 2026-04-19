(** Debug dump of the IR produced (or attempted) for a given
    bytecode pc.

    Complementary to {!Print_function}: that one shows the decoded
    bytecode stream; this one shows the [Code.program] that
    {!Parse_bytecode} lowers it to, or — when lowering fails — the
    exception message explaining why. Intended for iterating on IR
    parser / codegen gaps, where the [ir_emit] debug trace tells
    you which functions failed but not the shape of the ones that
    succeed. *)

val print :
     Format.formatter
  -> arr:Instr.instr array
  -> fn_info_of_body:(int -> Function_info.function_info option)
  -> main_start_pc:int
  -> pc:int
  -> unit
(** [print fmt ~arr ~fn_info_of_body ~main_start_pc ~pc] attempts
    to parse the bytecode at [pc] as either the main init (when
    [pc = main_start_pc]) or a function body (via
    [fn_info_of_body], which returns the function's nargs / ncaps
    when [pc] is a registered CLOSURE / CLOSUREREC entry), and
    prints the resulting [Code.program] or the [Not_supported]
    message on failure. *)
