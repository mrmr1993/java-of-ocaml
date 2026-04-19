(* The [compile] subcommand: lower an OCaml bytecode executable to JVM
   class files. *)

open Cmdliner

let run input output_dir debug_flags =
  List.iter Java_of_ocaml_compiler.Debug.enable debug_flags;
  match input, output_dir with
  | None, _ -> `Error (true, "missing input file")
  | _, None -> `Error (true, "missing -o <output_directory>")
  | Some bc, Some out_dir ->
    (try
       Java_of_ocaml_compiler.Compile.compile ~bc ~out_dir;
       `Ok ()
     with
     | Failure msg -> `Error (false, msg))

let input_arg =
  let doc =
    "Path to the input OCaml bytecode executable (as produced by \
     $(b,ocamlc -o foo.bc))."
  in
  Arg.(value & pos 0 (some file) None & info [] ~docv:"INPUT" ~doc)

let output_arg =
  let doc = "Directory to write $(b,Main.class) and runtime classes into." in
  Arg.(
    value & opt (some string) None & info [ "o"; "output" ] ~docv:"DIR" ~doc)

let debug_arg =
  let doc =
    "Enable the named debug trace (may be repeated). Equivalent to \
     adding the name to $(b,JAVA_OF_OCAML_DEBUG). Available traces \
     include: $(i,times), $(i,primitives), $(i,functions), \
     $(i,ir_emit), $(i,ir_trace), $(i,ir_gen_trace), $(i,dbug)."
  in
  Arg.(value & opt_all string [] & info [ "debug" ] ~docv:"FLAG" ~doc)

let term = Term.(ret (const run $ input_arg $ output_arg $ debug_arg))

let info =
  let doc = "Compile OCaml bytecode to JVM class files." in
  let man =
    [ `S Manpage.s_description
    ; `P
        "$(iname) reads an OCaml bytecode executable (from \
         $(b,ocamlc -o foo.bc)) and writes $(b,Main.class) plus the \
         runtime support classes ($(b,Block), $(b,Closure), \
         $(b,CamlException), ...) into the directory given by \
         $(b,-o)."
    ; `S Manpage.s_environment
    ; `P
        "$(b,JAVA_OF_OCAML_DEBUG) - comma-separated list of debug \
         traces to enable."
    ]
  in
  Cmd.info "compile" ~doc ~man

let command = Cmd.v info term
