val compile : bc:string -> out_dir:string -> unit
(** Read [bc] (executable, [.cmo], or [.cma]; detected via magic
    number) and emit [out_dir/Main.class] plus runtime support
    classes. [.cmo] / [.cma] inputs go through {!Linker.link}
    first; {!compile_t} can be called directly by callers that
    have a linked [Bytecode.t] in hand. *)

val compile_t : parsed:Bytecode.t -> out_dir:string -> unit
(** Compile an already-loaded [Bytecode.t] (as produced by
    [Bytecode.read_exe] or [Linker.link]). Same output as
    {!compile}. Exposed so the CLI sub-commands can share the
    pipeline without re-parsing. *)
