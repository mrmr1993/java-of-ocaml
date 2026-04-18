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
