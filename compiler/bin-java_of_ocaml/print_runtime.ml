(* The [print-runtime] subcommand: write the embedded runtime support
   classes ([Block], [Closure], [CamlException], ...) to a directory.
   Useful for inspecting the runtime without running a full compile,
   and for separate-compilation workflows where someone wants to ship
   the runtime independently. *)

open Cmdliner
module Jvm = Java_of_ocaml_compiler.Jvm

let runtime_classes =
  [ "Block", Jvm.block_class_bytes
  ; "Closure", Jvm.closure_class_bytes
  ; "PartialClosure", Jvm.partial_closure_class_bytes
  ; "CamlException", Jvm.camlexception_class_bytes
  ; "Compare", Jvm.compare_class_bytes
  ; "Channel", Jvm.channel_class_bytes
  ; "Bytes", Jvm.bytes_class_bytes
  ; "Format", Jvm.format_class_bytes
  ; "Ephemeron", Jvm.ephemeron_class_bytes
  ]

let run output_dir list_only =
  if list_only
  then (
    List.iter (fun (name, _) -> print_endline name) runtime_classes;
    `Ok ())
  else
    match output_dir with
    | None -> `Error (true, "missing -o <output_directory>")
    | Some dir ->
      (try
         List.iter
           (fun (name, bytes_fn) ->
             let path = Filename.concat dir (name ^ ".class") in
             let oc = open_out_bin path in
             output_string oc (bytes_fn ());
             close_out oc)
           runtime_classes;
         `Ok ()
       with
       | Sys_error msg -> `Error (false, msg))

let output_arg =
  let doc = "Directory to write the runtime class files into." in
  Arg.(
    value & opt (some string) None & info [ "o"; "output" ] ~docv:"DIR" ~doc)

let list_arg =
  let doc = "List the runtime class names instead of writing them." in
  Arg.(value & flag & info [ "list" ] ~doc)

let term = Term.(ret (const run $ output_arg $ list_arg))

let info =
  let doc = "Write the embedded JVM runtime classes to a directory." in
  let man =
    [ `S Manpage.s_description
    ; `P
        "$(iname) dumps the bundled runtime support classes \
         ($(b,Block), $(b,Closure), $(b,PartialClosure), \
         $(b,CamlException), $(b,Compare), $(b,Channel), \
         $(b,Bytes), $(b,Format)) into the directory given by \
         $(b,-o). Pass $(b,--list) to print the class names on \
         stdout instead."
    ]
  in
  Cmd.info "print-runtime" ~doc ~man

let command = Cmd.v info term
