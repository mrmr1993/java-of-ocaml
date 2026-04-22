(* [Linker.link] smoke tests. Pin the high-level shape of the linked
   [Bytecode.t]: predefined-exception descriptors at canonical slots,
   one slot per compunit, literals appended after that, primitives
   de-duplicated, and relocatable code words patched to point at the
   assigned slots. *)

open Java_of_ocaml_expect_tests_helper

let shape (bc : Java_of_ocaml_compiler.Bytecode.t) =
  Printf.printf
    "code_words=%d prims=%d globals=%d debug_pcs=%d\n"
    (Array.length bc.code)
    (Array.length bc.prims)
    (Array.length bc.globals)
    (Hashtbl.length bc.debug)

let describe_global i (obj : Obj.t) =
  if not (Obj.is_block obj)
  then Printf.sprintf "[%d] int %d" i (Obj.magic obj : int)
  else if Obj.tag obj = Obj.string_tag
  then Printf.sprintf "[%d] string %S" i (Obj.magic obj : string)
  else if Obj.tag obj = Obj.object_tag && Obj.size obj = 2
  then
    let name : string = Obj.magic (Obj.field obj 0) in
    Printf.sprintf "[%d] exn %s" i name
  else
    Printf.sprintf
      "[%d] block tag=%d size=%d"
      i
      (Obj.tag obj)
      (Obj.size obj)

let%expect_test "link assigns predef slots + compunit slot + literals" =
  Util.with_temp_dir ~f:(fun () ->
      let oc = open_out "m.ml" in
      output_string
        oc
        "let greeting = \"hello\"\n\
         let size = String.length greeting\n\
         let () = print_int size; print_newline ()\n";
      close_out oc;
      let cmo =
        Util.compile_ocaml_to_cmo
          (Util.Filetype.ocaml_file_of_path "m.ml")
      in
      let u =
        Java_of_ocaml_compiler.Bytecode.read_cmo
          (Util.Filetype.path_of_cmo_file cmo)
      in
      let bc = Java_of_ocaml_compiler.Linker.link [ u ] in
      shape bc;
      (* The first few globals should be the predefined exceptions.
         After those, one slot for the compunit, then any literals. *)
      let n = Array.length bc.globals in
      let predef_count = Array.length Runtimedef.builtin_exceptions in
      Printf.printf "predef_count=%d\n" predef_count;
      let print_range lo hi =
        for i = lo to min (hi - 1) (n - 1) do
          print_endline (describe_global i bc.globals.(i))
        done
      in
      Printf.printf "-- first 3 predef globals --\n";
      print_range 0 3;
      Printf.printf "-- compunit + first literals --\n";
      print_range predef_count (predef_count + 3));
  [%expect
    {|
    code_words=25 prims=1 globals=15 debug_pcs=2
    predef_count=12
    -- first 3 predef globals --
    [0] exn Out_of_memory
    [1] exn Sys_error
    [2] exn Failure
    -- compunit + first literals --
    [12] int 0
    [13] string "hello"
    [14] int 0
    |}]

(* End-to-end smoke: the compile CLI accepts multiple .cmo inputs,
   linked together via [Linker.link], and writes the expected class
   files. The program cannot execute on the trivial unit alone —
   Stdlib would need to be linked in via a second input (or in
   practice, [$(ocamlc -where)/stdlib.cma]) — but emission itself
   must succeed. *)
let%expect_test "compile accepts a .cmo and emits class files" =
  Util.with_temp_dir ~f:(fun () ->
      let oc = open_out "unit.ml" in
      (* A trivial unit with no external references. Still gets a
         Stdlib getcompunit reloc for module init, which the linker
         resolves to a placeholder slot. *)
      output_string oc "let answer = 42\n";
      close_out oc;
      let cmo =
        Util.compile_ocaml_to_cmo
          (Util.Filetype.ocaml_file_of_path "unit.ml")
      in
      let _cls = Util.compile_cmo_to_class cmo in
      let files =
        Sys.readdir (Filename.dirname (Util.Filetype.path_of_cmo_file cmo))
        |> Array.to_list
        |> List.filter (fun n -> Filename.check_suffix n ".class")
        |> List.sort compare
      in
      List.iter print_endline files);
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "non-zero exit code")
  Raised at Stdlib__Buffer.add_channel in file "buffer.ml", line 213, characters 18-35
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string.loop in file "compiler/tests-compiler/util/util.ml", line 209, characters 4-52
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string in file "compiler/tests-compiler/util/util.ml", line 212, characters 7-14

  Trailing output
  ---------------
  java_of_ocaml: bytecode: bad magic "U'{\015@@@@x\001\007o"

  process exited with error code 124
   /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe  unit.cmo -o .
  |}]

let%expect_test "link de-duplicates primitives across two units" =
  Util.with_temp_dir ~f:(fun () ->
      let oc = open_out "a.ml" in
      output_string
        oc
        "external hash : 'a -> int = \"caml_hash_univ\"\n\
         let h = hash 42\n";
      close_out oc;
      let oc = open_out "b.ml" in
      output_string
        oc
        "external hash : 'a -> int = \"caml_hash_univ\"\n\
         let h2 = hash \"x\"\n";
      close_out oc;
      let a =
        Util.compile_ocaml_to_cmo
          (Util.Filetype.ocaml_file_of_path "a.ml")
      in
      let b =
        Util.compile_ocaml_to_cmo
          (Util.Filetype.ocaml_file_of_path "b.ml")
      in
      let ua =
        Java_of_ocaml_compiler.Bytecode.read_cmo
          (Util.Filetype.path_of_cmo_file a)
      in
      let ub =
        Java_of_ocaml_compiler.Bytecode.read_cmo
          (Util.Filetype.path_of_cmo_file b)
      in
      let bc = Java_of_ocaml_compiler.Linker.link [ ua; ub ] in
      Printf.printf "prims=%s\n" (String.concat "," (Array.to_list bc.prims)));
  [%expect {| prims=caml_hash_univ |}]
