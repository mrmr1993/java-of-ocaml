(* The [compile] subcommand: lower an OCaml bytecode executable to JVM
   class files. *)

open Cmdliner

let run inputs output_dir debug_flags print_functions print_ir =
  List.iter Java_of_ocaml_compiler.Debug.enable debug_flags;
  match inputs, output_dir with
  | [], _ -> `Error (true, "missing input file(s)")
  | _, None -> `Error (true, "missing -o <output_directory>")
  | bcs, Some out_dir ->
    (try
       Java_of_ocaml_compiler.Compile.compile
         ~print_functions
         ~print_ir
         ~bcs
         ~out_dir
         ();
       `Ok ()
     with
     | Failure msg -> `Error (false, msg))

let input_arg =
  let doc =
    "Input file(s). Either a single OCaml bytecode executable \
     (from $(b,ocamlc -o foo.bc)), or one or more $(b,.cmo) / \
     $(b,.cma) files to be linked together (e.g. \
     $(i,stdlib.cma user.cmo))."
  in
  Arg.(value & pos_all file [] & info [] ~docv:"INPUT..." ~doc)

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

let print_function_arg =
  let doc =
    "Dump the decoded bytecode for the function body starting at \
     $(b,PC) to stderr, showing each instruction's pc / opcode / args \
     / branch targets / outstanding-forward-target set. Useful for \
     diagnosing $(i,no terminator in function body) failures. May be \
     repeated."
  in
  Arg.(
    value
    & opt_all int []
    & info [ "print-function" ] ~docv:"PC" ~doc)

let print_ir_arg =
  let doc =
    "Dump the IR ([Code.program]) produced by $(b,Parse_bytecode) \
     for the function body starting at $(b,PC), or the \
     [Not_supported] message if lowering fails. Pass $(b,0) (or \
     the program's first pc) to target the main init code. May be \
     repeated."
  in
  Arg.(
    value
    & opt_all int []
    & info [ "print-ir" ] ~docv:"PC" ~doc)

let term =
  Term.(
    ret
      (const run
       $ input_arg
       $ output_arg
       $ debug_arg
       $ print_function_arg
       $ print_ir_arg))

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
