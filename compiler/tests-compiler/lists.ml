open Util

let%expect_test "list sum and length" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec sum = function
         | [] -> 0
         | h :: t -> h + sum t
       let rec length = function
         | [] -> 0
         | _ :: t -> 1 + length t
       let () =
         caml_java_print_int (sum [1; 2; 3; 4; 5]);
         caml_java_print_int (length [10; 20; 30]);
         caml_java_print_int (sum []) |};
  [%expect {|
    15
    3
    0 |}]

let%expect_test "list iter with external primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec iter f = function
         | [] -> ()
         | h :: t -> f h; iter f t
       let () = iter caml_java_print_int [1; 2; 3] |};
  [%expect {|
    1
    2
    3 |}]

let%expect_test "list map returning a new list" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec map f = function
         | [] -> []
         | h :: t -> f h :: map f t
       let rec iter f = function
         | [] -> ()
         | h :: t -> f h; iter f t
       let () =
         let doubled = map (fun x -> x * 2) [1; 2; 3; 4] in
         iter caml_java_print_int doubled |};
  [%expect {|
    2
    4
    6
    8 |}]

let%expect_test "list nth with sentinel fallback" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec nth xs i = match xs with
         | [] -> -1
         | h :: t -> if i = 0 then h else nth t (i - 1)
       let () =
         caml_java_print_int (nth [100; 200; 300; 400] 2);
         caml_java_print_int (nth [100; 200; 300; 400] 0);
         caml_java_print_int (nth [] 5) |};
  [%expect {|
    300
    100
    -1 |}]

