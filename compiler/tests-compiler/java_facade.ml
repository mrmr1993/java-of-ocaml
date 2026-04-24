(* Java-facade tests. Covers steps 2-3 of [docs/JAVA_FACADE.md §8]:
   the [.cmi] reader classifies value bindings into a small
   [facade_kind] enum; the emission pass turns them into real
   [.class] files that dispatch through [Main.GLOBALS] + [Closure]. *)

open Java_of_ocaml_expect_tests_helper
module Cmi_reader = Java_of_ocaml_compiler.Cmi_reader

let kind_to_string = function
  | Cmi_reader.K_int -> "int"
  | K_long -> "long"
  | K_string -> "string"
  | K_float -> "float"
  | K_bool -> "bool"
  | K_unit -> "unit"
  | K_other -> "other"
  | K_fun (args, ret) ->
    let arg_strs = List.map (function
      | Cmi_reader.K_int -> "int"
      | K_long -> "long"
      | K_string -> "string"
      | K_float -> "float"
      | K_bool -> "bool"
      | K_unit -> "unit"
      | K_other -> "other"
      | K_fun _ -> "fun(..)") args
    in
    let ret_str = match ret with
      | Cmi_reader.K_int -> "int"
      | K_long -> "long"
      | K_string -> "string"
      | K_float -> "float"
      | K_bool -> "bool"
      | K_unit -> "unit"
      | K_other -> "other"
      | K_fun _ -> "fun(..)"
    in
    Printf.sprintf "(%s) -> %s" (String.concat ", " arg_strs) ret_str

let print_bindings (t : Cmi_reader.t) =
  Printf.printf "module %s\n" t.modname;
  List.iter
    (fun (b : Cmi_reader.binding) ->
      Printf.printf "  [%d] %s : %s\n" b.field_index b.name
        (kind_to_string b.kind))
    t.bindings

let read_toy ~source ~modname =
  Util.with_temp_dir ~f:(fun () ->
    let ml_path = String.uncapitalize_ascii modname ^ ".ml" in
    let oc = open_out ml_path in
    output_string oc source;
    close_out oc;
    let _ : Util.Filetype.cmo_file =
      Util.compile_ocaml_to_cmo
        (Util.Filetype.ocaml_file_of_path ml_path)
    in
    Cmi_reader.read ~search_paths:[ Sys.getcwd () ] ~modname)

let%expect_test "cmi_reader classifies int/long/string/float/bool/unit" =
  let t =
    read_toy ~modname:"Basics" ~source:
      "let i = 42\n\
       let s = \"hi\"\n\
       let f = 1.5\n\
       let b = true\n\
       let u = ()\n\
       let l = Int64.of_int 3\n"
  in
  print_bindings t;
  [%expect
    {|
    module Basics
      [0] i : int
      [1] s : string
      [2] f : float
      [3] b : bool
      [4] u : unit
      [5] l : long
    |}]

let%expect_test "cmi_reader flattens curried first-order function types" =
  let t =
    read_toy ~modname:"Funcs" ~source:
      "let add x y = x + y\n\
       let greet s = \"hi \" ^ s\n\
       let of_str s = Int64.of_string s\n\
       let swallow x _ = x\n"
  in
  print_bindings t;
  [%expect
    {|
    module Funcs
      [0] add : (int, int) -> int
      [1] greet : (string) -> string
      [2] of_str : (string) -> long
      [3] swallow : (other, other) -> other
    |}]

let%expect_test "cmi_reader surfaces unknowns as K_other without erroring" =
  let t =
    read_toy ~modname:"Misc" ~source:
      "let lst = [ 1; 2; 3 ]\n\
       let pair = (1, \"x\")\n\
       type r = { a : int; b : int }\n\
       let r = { a = 1; b = 2 }\n\
       let arr = [| 1; 2 |]\n"
  in
  print_bindings t;
  [%expect
    {|
    module Misc
      [0] lst : other
      [1] pair : other
      [2] r : other
      [3] arr : other
    |}]

let%expect_test "cmi_reader descends into nested Sig_module with field_chain" =
  Util.with_temp_dir ~f:(fun () ->
    let oc = open_out "nested.ml" in
    output_string oc
      "let top = 1\n\
       module Inner = struct\n\
      \  let a = 10\n\
      \  let b s = \"hi \" ^ s\n\
      \  module Deep = struct\n\
      \    let x = 100\n\
      \    let mul y z = y * z\n\
      \  end\n\
       end\n\
       let post = 2\n";
    close_out oc;
    let _ =
      Util.compile_ocaml_to_cmo
        (Util.Filetype.ocaml_file_of_path "nested.ml")
    in
    let print t =
      Printf.printf "modname=%s field_chain=[%s]\n"
        t.Cmi_reader.modname
        (String.concat ";" (List.map string_of_int t.field_chain));
      List.iter
        (fun b ->
          Printf.printf "  [%d] %s : %s\n"
            b.Cmi_reader.field_index b.name (kind_to_string b.kind))
        t.bindings
    in
    print
      (Cmi_reader.read_path ~search_paths:[ Sys.getcwd () ]
         ~outer:"Nested" ~sub_path:[ "Inner" ]);
    print
      (Cmi_reader.read_path ~search_paths:[ Sys.getcwd () ]
         ~outer:"Nested" ~sub_path:[ "Inner"; "Deep" ]);
    print
      (Cmi_reader.read ~search_paths:[ Sys.getcwd () ] ~modname:"Nested"));
  [%expect
    {|
    modname=Nested.Inner field_chain=[1]
      [0] a : int
      [1] b : (string) -> string
    modname=Nested.Inner.Deep field_chain=[1;2]
      [0] x : int
      [1] mul : (int, int) -> int
    modname=Nested field_chain=[]
      [0] top : int
      [2] post : int
    |}]

let%expect_test "cmi_reader resolves Mty_ident local modtype paths" =
  (* `module Fee : Basic` pattern — submodule body is Mty_ident
     referring to a module type defined alongside it. The
     resolver walks the enclosing signature stack to find the
     modtype and keeps descending. *)
  Util.with_temp_dir ~f:(fun () ->
    let oc = open_out "mtyident.ml" in
    output_string oc
      "module type Basic = sig\n\
      \  val zero : int\n\
      \  val add : int -> int -> int\n\
       end\n\
       module Foo : Basic = struct let zero = 0 let add x y = x + y end\n\
       module Bar : Basic = struct let zero = 1 let add x y = x - y end\n";
    close_out oc;
    let _ =
      Util.compile_ocaml_to_cmo
        (Util.Filetype.ocaml_file_of_path "mtyident.ml")
    in
    let print t =
      Printf.printf "modname=%s field_chain=[%s]\n"
        t.Cmi_reader.modname
        (String.concat ";" (List.map string_of_int t.field_chain));
      List.iter
        (fun b ->
          Printf.printf "  [%d] %s : %s\n"
            b.Cmi_reader.field_index b.name (kind_to_string b.kind))
        t.bindings
    in
    print
      (Cmi_reader.read_path ~search_paths:[ Sys.getcwd () ]
         ~outer:"Mtyident" ~sub_path:[ "Foo" ]);
    print
      (Cmi_reader.read_path ~search_paths:[ Sys.getcwd () ]
         ~outer:"Mtyident" ~sub_path:[ "Bar" ]));
  [%expect
    {|
    modname=Mtyident.Foo field_chain=[0]
      [0] zero : int
      [1] add : (int, int) -> int
    modname=Mtyident.Bar field_chain=[1]
      [0] zero : int
      [1] add : (int, int) -> int
    |}]

let%expect_test "cmi_reader resolves Mty_ident across external .cmi" =
  Util.with_temp_dir ~f:(fun () ->
    let oc = open_out "mtypes.ml" in
    output_string oc
      "module type Basic = sig val zero : int val add : int -> int -> int end\n";
    close_out oc;
    let oc = open_out "wrapper.ml" in
    output_string oc
      "module Foo : Mtypes.Basic = \
       struct let zero = 7 let add x y = x * y end\n";
    close_out oc;
    let _ =
      Util.compile_ocaml_to_cmo
        (Util.Filetype.ocaml_file_of_path "mtypes.ml")
    in
    let _ =
      Util.compile_ocaml_to_cmo
        (Util.Filetype.ocaml_file_of_path "wrapper.ml")
    in
    let print t =
      Printf.printf "modname=%s field_chain=[%s]\n"
        t.Cmi_reader.modname
        (String.concat ";" (List.map string_of_int t.field_chain));
      List.iter
        (fun b ->
          Printf.printf "  [%d] %s : %s\n"
            b.Cmi_reader.field_index b.name (kind_to_string b.kind))
        t.bindings
    in
    print
      (Cmi_reader.read_path ~search_paths:[ Sys.getcwd () ]
         ~outer:"Wrapper" ~sub_path:[ "Foo" ]));
  [%expect
    {|
    modname=Wrapper.Foo field_chain=[0]
      [0] zero : int
      [1] add : (int, int) -> int
    |}]

let%expect_test "cmi_reader skips external primitives" =
  (* [Val_prim] bindings don't consume module-struct slots, so the
     field_index for [y] stays at 0. *)
  let t =
    read_toy ~modname:"Prims" ~source:
      "external raw_id : int -> int = \"%identity\"\n\
       let y = raw_id 7\n"
  in
  print_bindings t;
  [%expect
    {|
    module Prims
      [0] y : int
    |}]

(* --- End-to-end emission + dispatch test --------------------------
   Compile an OCaml toy library, emit a facade class for it, then
   javac + java a small driver that calls the facade. Exercises the
   full step-3 pipeline: .cmo linking, .cmi reading, bytecode
   emission, and the [Main.GLOBALS]+[Closure.applyN] dispatch
   shape. *)

(* Reuse [Util]'s resolver - it latches onto [_build/default] the
   first time it is evaluated (during [Java_of_ocaml_expect_tests_
   helper]'s module init, before any sandbox chdir), so it stays
   correct even when dune later runs the test from a sandbox
   directory that no longer contains a [_build] segment. *)
let java_of_ocaml_root_e2e = Util.java_of_ocaml_root

let ocaml_stdlib_cma_e2e =
  let ic = Unix.open_process_in "ocamlc -where" in
  let line = input_line ic in
  ignore (Unix.close_process_in ic);
  Filename.concat line "stdlib.cma"

let slurp cmd =
  let ic = Unix.open_process_in cmd in
  let buf = Buffer.create 256 in
  (try
     while true do Buffer.add_channel buf ic 256 done
   with End_of_file -> ());
  let _ = Unix.close_process_in ic in
  Buffer.contents buf

let%expect_test "facade: int/long/string dispatch through Main.GLOBALS + Closure" =
  Util.with_temp_dir ~f:(fun () ->
    let ml_source =
      "let answer = 42\n\
       let add x y = x + y\n\
       let hello s = \"Hello, \" ^ s ^ \"!\"\n\
       let big (x : int64) (y : int64) = Int64.add x y\n\
       module Nested = struct\n\
      \  let greet s = \"Nested says hi, \" ^ s\n\
      \  let mul x y = x * y\n\
       end\n"
    in
    let ml_path =
      Util.Filetype.ocaml_text_of_string ml_source
      |> Util.Filetype.write_ocaml ~name:"mylib.ml"
    in
    let cmo = Util.compile_ocaml_to_cmo ml_path in
    let out_dir =
      Filename.concat
        (Filename.get_temp_dir_name ())
        ("jobr-facade-" ^ string_of_int (Unix.getpid ()))
    in
    (try
       Array.iter
         (fun f -> try Unix.unlink (Filename.concat out_dir f) with _ -> ())
         (Sys.readdir out_dir);
       Unix.rmdir out_dir
     with _ -> ());
    Unix.mkdir out_dir 0o755;
    let compiler_exe =
      Filename.concat java_of_ocaml_root_e2e
        "compiler/bin-java_of_ocaml/java_of_ocaml.exe"
    in
    let cmi_dir = Filename.dirname (Util.Filetype.path_of_cmo_file cmo) in
    let compile_cmd =
      Printf.sprintf
        "%s %s %s --export-module Mylib=com.example.Mylib \
         --export-module Mylib.Nested=com.example.MylibNested \
         -I %s -o %s 2>&1"
        compiler_exe
        ocaml_stdlib_cma_e2e
        (Util.Filetype.path_of_cmo_file cmo)
        cmi_dir
        out_dir
    in
    let compile_out = slurp compile_cmd in
    let facade_class =
      Filename.concat out_dir "com/example/Mylib.class"
    in
    Printf.printf "facade_class_exists=%b\n" (Sys.file_exists facade_class);
    (* Any compiler output (usually just "skipping …" warnings for
       the parser's auto-generated bindings) is forwarded so the
       expect can pin it. *)
    if compile_out <> "" then print_string compile_out;
    (* Sanity: structural shape of the class via javap -p. *)
    let javap_for cls =
      slurp
        (Printf.sprintf
           "javap -p -cp %s %s 2>&1"
           (Filename.quote out_dir) cls)
    in
    let strip_compiled_from s =
      String.split_on_char '\n' s
      |> List.filter (fun l ->
        let l = String.trim l in
        l <> ""
        && not (String.length l >= 12 && String.sub l 0 12 = "Compiled fro"))
    in
    List.iter print_endline (strip_compiled_from (javap_for "com.example.Mylib"));
    List.iter print_endline (strip_compiled_from (javap_for "com.example.MylibNested"));
    (* Write a tiny Java driver that uses the facade and print its
       stdout. *)
    let driver_src =
      "import com.example.Mylib;\n\
       import com.example.MylibNested;\n\
       public class Driver {\n\
      \  public static void main(String[] args) {\n\
      \    System.out.println(\"answer=\" + Mylib.answer());\n\
      \    System.out.println(\"add=\" + Mylib.add(3, 4));\n\
      \    System.out.println(Mylib.hello(\"world\"));\n\
      \    System.out.println(MylibNested.greet(\"Java\"));\n\
      \    System.out.println(\"nested_mul=\" + MylibNested.mul(6, 7));\n\
      \    System.out.println(\"big=\" + Mylib.big(1000000000000L, 2000000000000L));\n\
      \  }\n\
       }\n"
    in
    let drv_path = Filename.concat out_dir "Driver.java" in
    let oc = open_out drv_path in
    output_string oc driver_src;
    close_out oc;
    let javac_out =
      slurp
        (Printf.sprintf "javac -cp %s -d %s %s 2>&1"
           (Filename.quote out_dir)
           (Filename.quote out_dir)
           (Filename.quote drv_path))
    in
    if javac_out <> "" then Printf.printf "[javac] %s" javac_out;
    let run_out =
      slurp
        (Printf.sprintf "java -cp %s Driver 2>&1"
           (Filename.quote out_dir))
    in
    print_string run_out;
    (* Clean up. *)
    let rec rm_rf d =
      if Sys.is_directory d
      then (
        Array.iter
          (fun f -> rm_rf (Filename.concat d f))
          (Sys.readdir d);
        try Unix.rmdir d with _ -> ())
      else try Unix.unlink d with _ -> ()
    in
    rm_rf out_dir);
  [%expect {|
    facade_class_exists=true
    public final class com.example.Mylib {
      private static volatile boolean $initialised;
      private com.example.Mylib();
      public static synchronized void init();
      public static int answer();
      public static int add(int, int);
      public static java.lang.String hello(java.lang.String);
      public static long big(long, long);
    }
    public final class com.example.MylibNested {
      private static volatile boolean $initialised;
      private com.example.MylibNested();
      public static synchronized void init();
      public static java.lang.String greet(java.lang.String);
      public static int mul(int, int);
    }
    answer=42
    add=7
    Hello, world!
    Nested says hi, Java
    nested_mul=42
    big=3000000000000
    |}]

