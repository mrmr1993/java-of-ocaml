open Util

let%expect_test "local ref with := and !" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 5 in
         caml_java_print_int !r;
         r := 10;
         caml_java_print_int !r;
         r := !r + 7;
         caml_java_print_int !r |};
  [%expect {|
    5
    10
    17 |}]

let%expect_test "ref captured in a closure (counter)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let counter = ref 0 in
         let bump () = counter := !counter + 1 in
         bump (); bump (); bump (); bump ();
         caml_java_print_int !counter |};
  [%expect {| 4 |}]

let%expect_test "incr/decr on a captured ref" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 100 in
         let inc () = incr r in
         let dec () = decr r in
         inc (); inc (); inc (); dec ();
         caml_java_print_int !r |};
  [%expect {| 102 |}]
