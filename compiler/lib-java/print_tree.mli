(** [print fmt ~arr ~fn_info_of_body ~main_start_pc ~pc] parses the
    function body at [pc] into a [Code.program], builds its
    [Split_tree], and pretty-prints the tree. Same PC-lookup
    convention as [Print_ir] — pass [main_start_pc] for the top-level
    init code or any registered function body PC. *)

val print
  :  Format.formatter
  -> arr:Instr.instr array
  -> fn_info_of_body:(int -> Function_info.function_info option)
  -> main_start_pc:int
  -> pc:int
  -> unit
