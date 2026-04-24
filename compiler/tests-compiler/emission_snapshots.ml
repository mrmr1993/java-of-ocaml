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
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
    }
    |}]

let%expect_test "emission: arithmetic ops" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int ((3 * 4) - (10 / 2) + (9 mod 4)) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
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
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
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
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
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
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
    }
    |}]

let%expect_test "emission: if/else with int compare" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (if 1 < 2 then 10 else 20) |};
  [%expect
    {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: new           #8                  // class Block
          84: dup
          85: iconst_0
          86: iconst_0
          87: anewarray     #10                 // class java/lang/Object
          90: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          93: astore_1
          94: aload_1
          95: invokestatic  #57                 // Method Main$init_CamlinternalFormatBasics.init_CamlinternalFormatBasics:(Ljava/lang/Object;)Ljava/lang/Object;
          98: astore_1
          99: aload_1
         100: invokestatic  #62                 // Method Main$init_Stdlib.init_Stdlib:(Ljava/lang/Object;)Ljava/lang/Object;
         103: astore_1
         104: aload_1
         105: invokestatic  #67                 // Method Main$init_Test.init_Test:(Ljava/lang/Object;)Ljava/lang/Object;
         108: astore_1
         109: aload_1
         110: invokestatic  #72                 // Method Main$init_Std_exit.init_Std_exit:(Ljava/lang/Object;)Ljava/lang/Object;
         113: astore_1
         114: return
    }
    |}]
