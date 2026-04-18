(* Emission snapshots.

   Unlike the rest of this directory, these tests do NOT run the emitted
   JVM program. They [javap -c] the compiled [Main.class] and pin the
   disassembly. The goal is to catch silent emission regressions:
   behaviour-level tests would still pass if we accidentally started
   emitting extra boxing ops or a different branch encoding, but those
   would diff visibly here.

   Kept small and representative — pick the simplest program that
   exercises a feature and let the listing speak for it. Grow the set
   when a refactor needs a safety net. *)

open Util

let%expect_test "emission: println of a string literal" =
  compile_and_javap
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "hi" |};
  [%expect
    {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: ldc           #2                  // String hi
           2: getstatic     #8                  // Field java/lang/System.out:Ljava/io/PrintStream;
           5: swap
           6: invokevirtual #14                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
           9: iconst_0
          10: dup
          11: istore_1
          12: return
    }
    |}]

let%expect_test "emission: arithmetic ops" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int ((3 * 4) - (10 / 2) + (9 mod 4)) |};
  [%expect {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: iconst_4
           1: dup
           2: istore_1
           3: pop
           4: bipush        9
           6: iload_1
           7: irem
           8: dup
           9: istore_2
          10: pop
          11: iconst_2
          12: dup
          13: istore_3
          14: pop
          15: bipush        10
          17: iload_3
          18: idiv
          19: dup
          20: istore        4
          22: pop
          23: iconst_4
          24: dup
          25: istore        5
          27: pop
          28: iconst_3
          29: iload         5
          31: imul
          32: iload         4
          34: isub
          35: iload_2
          36: iadd
          37: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
          40: swap
          41: invokevirtual #12                 // Method java/io/PrintStream.println:(I)V
          44: iconst_0
          45: dup
          46: istore        6
          48: return
    }
    |}]

let%expect_test "emission: closure with a captured int" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkadder n = fun x -> x + n
       let () =
         let add10 = mkadder 10 in
         caml_java_print_int (add10 32) |};
  [%expect {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: goto          3
           3: new           #2                  // class ocaml_fn_1
           6: dup
           7: invokespecial #6                  // Method ocaml_fn_1."<init>":()V
          10: dup
          11: astore_1
          12: pop
          13: bipush        10
          15: dup
          16: istore_2
          17: pop
          18: aload_1
          19: iload_2
          20: invokestatic  #12                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          23: invokevirtual #18                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
          26: checkcast     #20                 // class ocaml_fn_0
          29: dup
          30: astore_3
          31: pop
          32: bipush        32
          34: dup
          35: istore        4
          37: pop
          38: aload_3
          39: iload         4
          41: invokestatic  #12                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          44: invokevirtual #18                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
          47: checkcast     #8                  // class java/lang/Integer
          50: invokevirtual #24                 // Method java/lang/Integer.intValue:()I
          53: getstatic     #30                 // Field java/lang/System.out:Ljava/io/PrintStream;
          56: swap
          57: invokevirtual #36                 // Method java/io/PrintStream.println:(I)V
          60: iconst_0
          61: dup
          62: istore        5
          64: pop
          65: aload_1
          66: astore        6
          68: iconst_1
          69: anewarray     #38                 // class java/lang/Object
          72: astore        7
          74: aload         7
          76: iconst_0
          77: aload         6
          79: aastore
          80: new           #40                 // class Block
          83: dup
          84: iconst_0
          85: aload         7
          87: invokespecial #43                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          90: return
    }
    |}]

let%expect_test "emission: variant match via switch" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type t = A | B of int | C
       let get = function A -> 0 | B n -> n | C -> -1
       let () = caml_java_print_int (get (B 42)) |};
  [%expect {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: goto          3
           3: new           #2                  // class ocaml_fn_0
           6: dup
           7: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
          10: dup
          11: astore_1
          12: pop
          13: iconst_1
          14: anewarray     #8                  // class java/lang/Object
          17: astore_2
          18: aload_2
          19: iconst_0
          20: bipush        42
          22: invokestatic  #14                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          25: aastore
          26: new           #16                 // class Block
          29: dup
          30: iconst_0
          31: aload_2
          32: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          35: dup
          36: astore_3
          37: pop
          38: aload_1
          39: aload_3
          40: invokevirtual #25                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
          43: checkcast     #10                 // class java/lang/Integer
          46: invokevirtual #29                 // Method java/lang/Integer.intValue:()I
          49: getstatic     #35                 // Field java/lang/System.out:Ljava/io/PrintStream;
          52: swap
          53: invokevirtual #41                 // Method java/io/PrintStream.println:(I)V
          56: iconst_0
          57: dup
          58: istore        4
          60: pop
          61: aload_1
          62: astore        5
          64: iconst_1
          65: anewarray     #8                  // class java/lang/Object
          68: astore        6
          70: aload         6
          72: iconst_0
          73: aload         5
          75: aastore
          76: new           #16                 // class Block
          79: dup
          80: iconst_0
          81: aload         6
          83: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          86: return
    }
    |}]

let%expect_test "emission: try/with catchall" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception Oops
       let safe x = try if x = 0 then raise Oops else 100 / x with _ -> -1
       let () = caml_java_print_int (safe 0) |};
  [%expect {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: goto          3
           3: iconst_0
           4: pop
           5: iconst_0
           6: dup
           7: istore_1
           8: pop
           9: ldc           #2                  // String Test.Oops
          11: astore_2
          12: iconst_2
          13: anewarray     #4                  // class java/lang/Object
          16: astore_3
          17: aload_3
          18: iconst_0
          19: aload_2
          20: aastore
          21: aload_3
          22: iconst_1
          23: iload_1
          24: invokestatic  #10                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          27: aastore
          28: new           #12                 // class Block
          31: dup
          32: sipush        248
          35: aload_3
          36: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: dup
          40: astore        4
          42: pop
          43: aload         4
          45: dup
          46: astore        5
          48: pop
          49: new           #18                 // class ocaml_fn_0
          52: dup
          53: aload         5
          55: invokespecial #21                 // Method ocaml_fn_0."<init>":(LBlock;)V
          58: dup
          59: astore        6
          61: pop
          62: iconst_0
          63: dup
          64: istore        7
          66: pop
          67: aload         6
          69: iload         7
          71: invokestatic  #10                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          74: invokevirtual #27                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
          77: checkcast     #6                  // class java/lang/Integer
          80: invokevirtual #31                 // Method java/lang/Integer.intValue:()I
          83: getstatic     #37                 // Field java/lang/System.out:Ljava/io/PrintStream;
          86: swap
          87: invokevirtual #43                 // Method java/io/PrintStream.println:(I)V
          90: iconst_0
          91: dup
          92: istore        8
          94: pop
          95: aload         6
          97: dup
          98: astore        9
         100: pop
         101: aload         4
         103: astore        10
         105: iconst_2
         106: anewarray     #4                  // class java/lang/Object
         109: astore        11
         111: aload         11
         113: iconst_0
         114: aload         10
         116: aastore
         117: aload         11
         119: iconst_1
         120: aload         9
         122: aastore
         123: new           #12                 // class Block
         126: dup
         127: iconst_0
         128: aload         11
         130: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         133: return
    }
    |}]

let%expect_test "emission: if/else with int compare" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (if 1 < 2 then 10 else 20) |};
  [%expect
    {|
    public class Main {
      public static void main(java.lang.String[]);
        Code:
           0: iconst_1
           1: iconst_2
           2: if_icmpge     10
           5: bipush        10
           7: goto          12
          10: bipush        20
          12: getstatic     #6                  // Field java/lang/System.out:Ljava/io/PrintStream;
          15: swap
          16: invokevirtual #12                 // Method java/io/PrintStream.println:(I)V
          19: iconst_0
          20: dup
          21: istore_1
          22: return
    }
    |}]
