(** The [compile] subcommand. *)

val term : unit Cmdliner.Term.t
(** Wraps the compile action with [Cmdliner.Term.ret] so missing /
    invalid args surface as cmdliner diagnostics. Exposed for use
    as the default command of the top-level group. *)

val info : Cmdliner.Cmd.info

val command : unit Cmdliner.Cmd.t
