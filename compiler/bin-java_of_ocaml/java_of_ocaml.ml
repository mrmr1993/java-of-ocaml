let usage =
  "java_of_ocaml: compile OCaml bytecode to JVM bytecode.\n\n\
   Usage: java_of_ocaml <input.bc|input.cmo> -o <output_directory>\n\
   \n\
   The current Phase 0 compiler recognises a single bytecode pattern:\n\
   calls to the primitive `caml_java_print_endline`. Programs that use\n\
   other operations will be rejected with a clear error."

let () =
  let input = ref None in
  let out_dir = ref None in
  let speclist =
    [ ( "-o"
      , Arg.String (fun s -> out_dir := Some s)
      , "<dir> Directory to write Main.class into" )
    ]
  in
  let anon f =
    match !input with
    | None -> input := Some f
    | Some _ ->
      prerr_endline "java_of_ocaml: expected a single input file";
      exit 2
  in
  Arg.parse speclist anon usage;
  let input =
    match !input with
    | Some p -> p
    | None ->
      prerr_endline "java_of_ocaml: missing input file";
      prerr_endline usage;
      exit 2
  in
  let out_dir =
    match !out_dir with
    | Some p -> p
    | None ->
      prerr_endline "java_of_ocaml: missing -o <output_directory>";
      prerr_endline usage;
      exit 2
  in
  try Java_of_ocaml_compiler.Compile.compile ~bc:input ~out_dir with
  | Failure msg ->
    prerr_endline msg;
    exit 1
