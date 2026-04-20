(* The [compile] subcommand: lower an OCaml bytecode executable to JVM
   class files. *)

open Cmdliner

let run
    inputs
    output_dir
    debug_flags
    print_functions
    print_ir
    print_tree
    list_missing =
  List.iter Java_of_ocaml_compiler.Debug.enable debug_flags;
  match inputs, output_dir, list_missing with
  | [], _, _ -> `Error (true, "missing input file(s)")
  | bcs, _, true ->
    (try
       let missing =
         Java_of_ocaml_compiler.Compile.list_missing_prims ~bcs
       in
       (match missing with
        | [] ->
          print_endline "(all primitives referenced by the input are handled)";
          `Ok ()
        | _ ->
          List.iter print_endline missing;
          (* Non-zero exit so CI / dune rules notice missing
             primitives without having to grep stdout. The listing
             still prints, so no output regression. *)
          `Error (false, Printf.sprintf "%d primitive(s) missing" (List.length missing)))
     with
     | Failure msg -> `Error (false, msg))
  | _, None, _ -> `Error (true, "missing -o <output_directory>")
  | bcs, Some out_dir, _ ->
    (try
       Java_of_ocaml_compiler.Compile.compile
         ~print_functions
         ~print_ir
         ~print_tree
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

let print_tree_arg =
  let doc =
    "Dump the [Split_tree] structure produced from the IR for the \
     function body starting at $(b,PC). Shows Seq chains, If / \
     Switch / Loop / Try_region structural nodes, and leaves with \
     their body sizes — intended for investigating why a function \
     is failing to split. Pass $(b,0) for the main init code."
  in
  Arg.(
    value
    & opt_all int []
    & info [ "print-tree" ] ~docv:"PC" ~doc)

let list_missing_arg =
  let doc =
    "Don't compile; instead list every C primitive that the input \
     bytecode references but that the JVM backend has no explicit \
     handler for (those would compile to a runtime-throwing \"C \
     primitive not implemented\" stub). Useful for planning runtime \
     coverage work without waiting for a full compile."
  in
  Arg.(value & flag & info [ "list-missing-prims" ] ~doc)

let term =
  Term.(
    ret
      (const run
       $ input_arg
       $ output_arg
       $ debug_arg
       $ print_function_arg
       $ print_ir_arg
       $ print_tree_arg
       $ list_missing_arg))

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
