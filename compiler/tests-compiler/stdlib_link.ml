(* End-to-end: the compiler accepts [stdlib.cma + user.cmo] through
   its linker and produces a class directory. This exercises the
   separate-compilation pipeline (Bytecode.read_cma + Linker.link +
   CLI driver), method splitting on the linked closures, and
   splitting of the combined [Main.main] body (which would
   otherwise exceed the 65535-byte [Code]-attribute limit).

   Asserts:
   - compilation succeeds;
   - a class set is emitted (Main.class + many closure classes);
   - running [java Main] loads [Main] without a JVM verifier error
     — i.e. the splitter produced a self-consistent main + helper
     call chain. We reach stdlib's [Domain] init, which currently
     hits an unimplemented C primitive ([caml_array_blit]); the
     test captures that as stderr rather than a clean stdout.
     Flipping to a full stdout assertion is blocked on
     C-primitive coverage, not on splitting correctness. *)

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
    (* Run the resulting class set. We only care that the JVM
       successfully loaded [Main] (no verifier error) and started
       executing — the actual program reaches an unimplemented C
       primitive before completing, so we summarise the run
       outcome as either "verifier error" or "runtime error". *)
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
    let output = Buffer.contents buf in
    let has_verify_error =
      try
        let _ = Str.search_forward (Str.regexp_string "VerifyError") output 0 in
        true
      with Not_found -> false
    in
    let reaches_runtime =
      try
        let _ =
          Str.search_forward
            (Str.regexp_string "C primitive")
            output
            0
        in
        true
      with Not_found -> false
    in
    Printf.printf
      "verify_error=%b reaches_runtime=%b\n"
      has_verify_error
      reaches_runtime;
    (* Clean up. *)
    Array.iter
      (fun f -> try Unix.unlink (Filename.concat out_dir f) with _ -> ())
      (Sys.readdir out_dir);
    (try Unix.rmdir out_dir with _ -> ()));
  [%expect {|
    has_main=true has_closures=true many_classes=true
    verify_error=false reaches_runtime=true
    |}]
