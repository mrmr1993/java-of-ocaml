open Util

let%expect_test "unary negation" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         caml_java_print_int (Int.neg 7);
         caml_java_print_int (- (3 + 4));
         caml_java_print_int (Int.succ 41);
         caml_java_print_int (Int.pred 43) |};
  [%expect {|
    -7
    -7
    42
    42 |}]

let%expect_test "bitwise and / or / xor" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         caml_java_print_int (Int.logand 12 10);
         caml_java_print_int (12 land 10);
         caml_java_print_int (Int.logor 12 10);
         caml_java_print_int (12 lor 10);
         caml_java_print_int (Int.logxor 12 10);
         caml_java_print_int (12 lxor 10) |};
  [%expect {|
    8
    8
    14
    14
    6
    6 |}]

let%expect_test "shift left / arithmetic right / logical right" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         caml_java_print_int (Int.shift_left 1 4);
         caml_java_print_int (1 lsl 4);
         caml_java_print_int (Int.shift_right 16 2);
         caml_java_print_int (16 asr 2);
         caml_java_print_int (Int.shift_right (-16) 2);
         caml_java_print_int (Int.shift_right_logical 255 4);
         caml_java_print_int (255 lsr 4) |};
  [%expect {|
    16
    16
    4
    4
    -4
    15
    15 |}]

let%expect_test "bitwise on negatives / masking idioms" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let byte x = x land 0xff
       let is_set flags bit = flags land (1 lsl bit) <> 0
       let pack hi lo = (hi lsl 8) lor (lo land 0xff)
       let () =
         caml_java_print_int (byte (-1));
         caml_java_print_int (if is_set 0b1010 1 then 1 else 0);
         caml_java_print_int (if is_set 0b1010 0 then 1 else 0);
         caml_java_print_int (pack 0x12 0x34) |};
  [%expect {|
    255
    1
    0
    4660 |}]
