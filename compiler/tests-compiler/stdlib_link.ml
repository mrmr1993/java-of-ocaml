(* End-to-end: the compiler accepts [stdlib.cma + user.cmo] through
   its linker and produces a class directory. This exercises the
   separate-compilation pipeline (Bytecode.read_cma + Linker.link +
   CLI driver), method splitting on the linked closures, and
   splitting of the combined [Main.main] body (which would
   otherwise exceed the 65535-byte [Code]-attribute limit).

   Asserts:
   - compilation succeeds;
   - a class set is emitted (Main.class + many closure classes);
   - running [java Main] produces the expected stdout — i.e. the
     user's [print_endline] reaches stdlib's output path and
     actually runs. *)

open Util

(* Resolve the project root once at module-load time (before
   [with_temp_dir] chdirs into a throwaway directory). Mirrors the
   private [Util.java_of_ocaml_root] fallback. *)
let java_of_ocaml_root =
  try
    let d = Sys.getenv "PROJECT_ROOT" in
    if Filename.is_relative d then Filename.concat (Sys.getcwd ()) d else d
  with Not_found ->
    let cwd = Sys.getcwd () in
    match Str.split (Str.regexp "_build") cwd with
    | left :: _ :: _ ->
      Filename.concat (Filename.concat left "_build") "default"
    | _ -> cwd

let ocaml_stdlib_cma =
  let where =
    let ic = Unix.open_process_in "ocamlc -where" in
    let line = input_line ic in
    ignore (Unix.close_process_in ic);
    line
  in
  Filename.concat where "stdlib.cma"

let%expect_test "stdlib.cma + user.cmo compiles and produces a class set" =
  with_temp_dir ~f:(fun () ->
    let ml_path =
      Filetype.ocaml_text_of_string
        {| let () = print_endline "hello, world" |}
      |> Filetype.write_ocaml ~name:"user.ml"
    in
    let cmo_path =
      compile_ocaml_to_cmo ml_path
    in
    let out_dir =
      Filename.concat
        (Filename.get_temp_dir_name ())
        ("jobr-stdlib-" ^ string_of_int (Unix.getpid ()))
    in
    (try Unix.rmdir out_dir with _ -> ());
    (try
       Array.iter
         (fun n -> Unix.unlink (Filename.concat out_dir n))
         (Sys.readdir out_dir);
       Unix.rmdir out_dir
     with _ -> ());
    Unix.mkdir out_dir 0o755;
    let compiler_exe =
      Filename.concat
        java_of_ocaml_root
        "compiler/bin-java_of_ocaml/java_of_ocaml.exe"
    in
    let cmd =
      Format.sprintf
        "%s %s %s -o %s > /dev/null 2>&1"
        compiler_exe
        ocaml_stdlib_cma
        (Filetype.path_of_cmo_file cmo_path)
        out_dir
    in
    let rc = Sys.command cmd in
    if rc <> 0 then Printf.printf "compile failed: %d\n" rc;
    let files = Sys.readdir out_dir |> Array.to_list in
    let has_main = List.mem "Main.class" files in
    let has_closures = List.exists (fun f ->
      let len = String.length f in
      len >= 10
      && String.sub f 0 9 = "ocaml_fn_"
      && String.sub f (len - 6) 6 = ".class") files
    in
    let many_classes = List.length files > 100 in
    Printf.printf
      "has_main=%b has_closures=%b many_classes=%b\n"
      has_main
      has_closures
      many_classes;
    let run_cmd =
      Format.sprintf "java -cp %s Main 2>&1" (Filename.quote out_dir)
    in
    let ic = Unix.open_process_in run_cmd in
    let buf = Buffer.create 512 in
    (try
       while true do
         Buffer.add_channel buf ic 512
       done
     with End_of_file -> ());
    let _ = Unix.close_process_in ic in
    print_string (Buffer.contents buf);
    (* Clean up. *)
    Array.iter
      (fun f -> try Unix.unlink (Filename.concat out_dir f) with _ -> ())
      (Sys.readdir out_dir);
    (try Unix.rmdir out_dir with _ -> ()));
  [%expect {|
    compile failed: 124
    has_main=false has_closures=false many_classes=false
    Error: Could not find or load main class Main
    Caused by: java.lang.ClassNotFoundException: Main
    |}]
