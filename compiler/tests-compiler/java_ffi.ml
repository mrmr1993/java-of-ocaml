(* End-to-end tests for the Java FFI.

   User code declares [external]s with structured primitive names of
   the form [java:<op>:<class>:<member>:<descriptor>] that the
   java_of_ocaml backend recognises in [Jvm_generate.emit_java_ffi].
   The external is compiled by [ocamlc] into a normal [CCALL]; the
   primitive index resolves back to the structured name at emit time;
   the emitter produces a direct [invoke* / getfield / new / ...]
   without going through any runtime-reflection helper.

   These tests use [compile_and_run] so they skip the [ocamlrun]
   byte-mode check (which doesn't know about the [java:*]
   primitives). *)

open Util

let%expect_test "java:static call — Integer.parseInt" =
  compile_and_run
    {|
      external caml_java_print_int : int -> unit = "caml_java_print_int"
      external parse_int : string -> int
        = "java:static:java/lang/Integer:parseInt:(Ljava/lang/String;)I"
      let () = caml_java_print_int (parse_int "42")
    |};
  [%expect {| 42 |}]

let%expect_test "java:getstatic + java:virtual — System.out.println(int)" =
  compile_and_run
    {|
      external system_out : unit -> Obj.t
        = "java:getstatic:java/lang/System:out:Ljava/io/PrintStream;"
      external println_int : Obj.t -> int -> unit
        = "java:virtual:java/io/PrintStream:println:(I)V"
      let () =
        let out = system_out () in
        println_int out 7
    |};
  [%expect {| 7 |}]

let%expect_test "java:new + java:virtual — java.util.ArrayList round-trip" =
  compile_and_run
    {|
      external caml_java_print_int : int -> unit = "caml_java_print_int"
      external arraylist_new : unit -> Obj.t
        = "java:new:java/util/ArrayList:()V"
      external arraylist_add : Obj.t -> Obj.t -> bool
        = "java:virtual:java/util/ArrayList:add:(Ljava/lang/Object;)Z"
      external arraylist_size : Obj.t -> int
        = "java:virtual:java/util/ArrayList:size:()I"
      let () =
        let xs = arraylist_new () in
        let _ : bool = arraylist_add xs (Obj.repr 10) in
        let _ : bool = arraylist_add xs (Obj.repr 20) in
        let _ : bool = arraylist_add xs (Obj.repr 30) in
        caml_java_print_int (arraylist_size xs)
    |};
  [%expect {| 3 |}]

let%expect_test "java:static with String arg — String.valueOf(int)" =
  compile_and_run
    {|
      external system_out : unit -> Obj.t
        = "java:getstatic:java/lang/System:out:Ljava/io/PrintStream;"
      external println : Obj.t -> string -> unit
        = "java:virtual:java/io/PrintStream:println:(Ljava/lang/String;)V"
      external value_of_int : int -> string
        = "java:static:java/lang/String:valueOf:(I)Ljava/lang/String;"
      let () = println (system_out ()) (value_of_int 123)
    |};
  [%expect {| 123 |}]

let%expect_test "java:instanceof returns bool" =
  compile_and_run
    {|
      external caml_java_print_int : int -> unit = "caml_java_print_int"
      external arraylist_new : unit -> Obj.t
        = "java:new:java/util/ArrayList:()V"
      external is_list : Obj.t -> bool
        = "java:instanceof:java/util/List"
      external is_map : Obj.t -> bool
        = "java:instanceof:java/util/Map"
      let () =
        let xs = arraylist_new () in
        caml_java_print_int (if is_list xs then 1 else 0);
        caml_java_print_int (if is_map xs then 1 else 0)
    |};
  [%expect {|
    1
    0 |}]
