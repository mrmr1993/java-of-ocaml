val compile :
     ?print_functions:int list
  -> ?print_ir:int list
  -> bcs:string list
  -> out_dir:string
  -> unit
  -> unit
(** Read each input (executable, [.cmo], or [.cma]; detected via
    magic number) and emit [out_dir/Main.class] plus runtime
    support classes. A single executable is accepted on its own;
    otherwise the inputs must all be [.cmo] / [.cma] files, which
    are flattened into a unit list and linked via {!Linker.link}
    in declaration order. Mixing an executable with other inputs
    is rejected. {!compile_t} can be called directly by callers
    that have a linked [Bytecode.t] in hand.

    [print_functions] — bytecode pc values for which to dump the
    decoded function body to stderr before compilation proceeds.
    Useful when diagnosing "no terminator in function body"
    failures in {!Function_info.find_function_body_range}. *)

val compile_t :
     ?print_functions:int list
  -> ?print_ir:int list
  -> parsed:Bytecode.t
  -> out_dir:string
  -> unit
  -> unit
(** Compile an already-loaded [Bytecode.t] (as produced by
    [Bytecode.read_exe] or [Linker.link]). Same output as
    {!compile}. Exposed so the CLI sub-commands can share the
    pipeline without re-parsing. *)
