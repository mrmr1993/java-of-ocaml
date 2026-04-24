(* Java-facade tests. Covers step 2 of [docs/JAVA_FACADE.md §8]:
   the [.cmi] reader classifies value bindings into a small
   [facade_kind] enum. Step 1 (CLI plumbing for --export-module /
   --cmi-path) is covered by the CLI help text and argument-parse
   errors; no emission yet. *)

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
