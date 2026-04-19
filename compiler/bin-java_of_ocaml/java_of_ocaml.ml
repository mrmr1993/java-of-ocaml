(* Entry point for the [java_of_ocaml] CLI.

   Modelled after [js_of_ocaml]: a Cmdliner [Cmd.group] with [compile]
   as the default subcommand, plus auxiliary commands ([print-runtime],
   ...). For backwards compatibility with the pre-Cmdliner invocation
   [java_of_ocaml foo.bc -o out], we sniff [Sys.argv] and inject the
   [compile] subcommand name when the first non-option argument doesn't
   match any known subcommand. *)

let subcommands =
  [ Compile.command; Print_runtime.command ]

let like_arg s = String.length s > 0 && s.[0] = '-'

let adjust_argv argv =
  let subcommand_names =
    List.map (fun c -> Cmdliner.Cmd.name c) subcommands
  in
  match Array.to_list argv with
  | exe :: first :: rest
    when (not (like_arg first)) && not (List.mem first subcommand_names) ->
    (* Legacy: [java_of_ocaml foo.bc -o out] - the first arg isn't
       a known subcommand and isn't a flag, so it's presumably the
       input file for the default [compile]. Inject the subcommand
       name so Cmdliner routes through the [compile] info block. *)
    Array.of_list (exe :: Cmdliner.Cmd.name Compile.command :: first :: rest)
  | _ -> argv

let tool_info =
  let doc = "Compile OCaml bytecode to JVM bytecode." in
  let man =
    [ `S Cmdliner.Manpage.s_description
    ; `P
        "$(iname) is a compiler from OCaml bytecode (as produced by \
         $(b,ocamlc)) to JVM class files. The default subcommand is \
         $(b,compile); running $(iname) without a subcommand is \
         equivalent to $(iname) $(b,compile)."
    ; `S Cmdliner.Manpage.s_commands
    ; `S Cmdliner.Manpage.s_bugs
    ; `P "Report bugs at https://github.com/mrmr1993/java_of_ocaml/issues."
    ]
  in
  Cmdliner.Cmd.info "java_of_ocaml" ~doc ~man

let () =
  let argv = adjust_argv Sys.argv in
  let group =
    Cmdliner.Cmd.group ~default:Compile.term tool_info subcommands
  in
  exit (Cmdliner.Cmd.eval ~argv group)
