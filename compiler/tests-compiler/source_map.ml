(* Source-map emission.

   Pins the [SourceFile] class attribute and the per-method
   [LineNumberTable] entries produced from the bytecode's DBUG
   section. Stack traces from a compiled program surface the OCaml
   source file and line via these JVM debug attributes; if we stop
   emitting them, this test diffs. *)

open Util

let%expect_test "SourceFile attribute names the user's .ml file" =
  compile_and_javap_lines
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int 42 |};
  [%expect
    {|
    Compiled from "test.ml"
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        LineNumberTable:
          line 528: 55
          line 299: 62
          line 24: 145
          line 23: 205
          line 29: 212
          line 30: 248
          line 32: 273
          line 74: 346
          line 75: 591
          line 98: 613
          line 104: 635
          line 180: 657
          line 182: 741
          line 184: 775
          line 186: 809
          line 188: 843
          line 190: 877
          line 212: 903
          line 223: 925
          line 253: 949
          line 255: 971
          line 260: 995
          line 265: 1017
          line 270: 1039
          line 277: 1063
          line 287: 1087
          line 291: 1111
          line 314: 1135
          line 315: 1275
          line 316: 1300
          line 330: 1321
          line 335: 1343
          line 338: 1367
          line 346: 1391
          line 365: 1415
          line 368: 1437
          line 371: 1459
          line 376: 1483
          line 386: 1507
          line 392: 1529
          line 393: 1551
          line 404: 1573
          line 409: 1595
          line 412: 1619
          line 420: 1643
          line 433: 1667
          line 438: 1717
          line 445: 1741
          line 480: 1765
          line 486: 1787
          line 487: 1811
          line 488: 1837
          line 489: 1863
          line 490: 1891
          line 491: 1919
          line 493: 1945
          line 497: 1969
          line 498: 1993
          line 499: 2019
          line 500: 2045
          line 501: 2073
          line 502: 2101
          line 504: 2127
          line 508: 2151
          line 509: 2179
          line 510: 2203
          line 511: 2229
          line 512: 2253
          line 538: 2279
          line 544: 2301
          line 559: 2325
          line 572: 2344
          line 574: 2409
          line 578: 2435
          line 582: 2459
          line 481: 2474
          line 479: 2650
          line 478: 2672
          line 477: 2694
          line 476: 2716
          line 475: 2738
          line 474: 2760
          line 473: 2782
          line 415: 2804
          line 396: 2826
          line 390: 2848
          line 389: 2870
          line 388: 2892
          line 382: 2914
          line 381: 2936
          line 363: 2958
          line 341: 2980
          line 2: 3002
          line 18: 3038
    }
    |}]
