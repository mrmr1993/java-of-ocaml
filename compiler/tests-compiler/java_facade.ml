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

let java_of_ocaml_root_e2e =
  try
    let d = Sys.getenv "PROJECT_ROOT" in
    if Filename.is_relative d then Filename.concat (Sys.getcwd ()) d else d
  with Not_found ->
    let cwd = Sys.getcwd () in
    match Str.split (Str.regexp "_build") cwd with
    | left :: _ :: _ ->
      Filename.concat (Filename.concat left "_build") "default"
    | _ -> cwd

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
       let big (x : int64) (y : int64) = Int64.add x y\n"
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
        "%s %s %s --export-module Mylib=com.example.Mylib -I %s -o %s 2>&1"
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
    let javap_out =
      slurp
        (Printf.sprintf
           "javap -p -cp %s com.example.Mylib 2>&1"
           (Filename.quote out_dir))
    in
    (* Strip the "Compiled from" line which varies by JDK. *)
    let javap_lines =
      String.split_on_char '\n' javap_out
      |> List.filter (fun l ->
        let l = String.trim l in
        l <> ""
        && not (String.length l >= 12 && String.sub l 0 12 = "Compiled fro"))
    in
    List.iter print_endline javap_lines;
    (* Write a tiny Java driver that uses the facade and print its
       stdout. *)
    let driver_src =
      "import com.example.Mylib;\n\
       public class Driver {\n\
      \  public static void main(String[] args) {\n\
      \    System.out.println(\"answer=\" + Mylib.answer());\n\
      \    System.out.println(\"add=\" + Mylib.add(3, 4));\n\
      \    System.out.println(Mylib.hello(\"world\"));\n\
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
    answer=42
    add=7
    Hello, world!
    big=3000000000000
    |}]

