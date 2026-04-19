val compile : bcs:string list -> out_dir:string -> unit
(** Read each input (executable, [.cmo], or [.cma]; detected via
    magic number) and emit [out_dir/Main.class] plus runtime
    support classes. A single executable is accepted on its own;
    otherwise the inputs must all be [.cmo] / [.cma] files, which
    are flattened into a unit list and linked via {!Linker.link}
    in declaration order. Mixing an executable with other inputs
    is rejected. {!compile_t} can be called directly by callers
    that have a linked [Bytecode.t] in hand. *)

val compile_t : parsed:Bytecode.t -> out_dir:string -> unit
(** Compile an already-loaded [Bytecode.t] (as produced by
    [Bytecode.read_exe] or [Linker.link]). Same output as
    {!compile}. Exposed so the CLI sub-commands can share the
    pipeline without re-parsing. *)
