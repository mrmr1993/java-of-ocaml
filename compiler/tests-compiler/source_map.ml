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
          line 659: 62
          line 29: 145
          line 24: 197
          line 23: 212
          line 29: 248
          line 30: 269
          line 32: 326
          line 74: 591
          line 75: 613
          line 98: 635
          line 104: 657
          line 180: 733
          line 182: 767
          line 184: 801
          line 186: 835
          line 188: 869
          line 190: 903
          line 212: 925
          line 223: 949
          line 253: 971
          line 255: 995
          line 260: 1017
          line 265: 1039
          line 270: 1063
          line 277: 1087
          line 287: 1111
          line 291: 1135
          line 314: 1271
          line 315: 1296
          line 316: 1321
          line 330: 1343
          line 335: 1367
          line 338: 1391
          line 346: 1415
          line 365: 1437
          line 368: 1459
          line 371: 1483
          line 376: 1507
          line 386: 1529
          line 392: 1551
          line 393: 1573
          line 404: 1595
          line 409: 1619
          line 412: 1643
          line 420: 1667
          line 433: 1717
          line 438: 1741
          line 445: 1765
          line 480: 1787
          line 486: 1811
          line 487: 1837
          line 488: 1863
          line 489: 1891
          line 490: 1919
          line 491: 1945
          line 493: 1969
          line 497: 1993
          line 498: 2019
          line 499: 2045
          line 500: 2073
          line 501: 2101
          line 502: 2127
          line 504: 2151
          line 508: 2179
          line 509: 2203
          line 510: 2229
          line 511: 2253
          line 517: 2279
          line 538: 2301
          line 544: 2325
          line 559: 2344
          line 572: 2377
          line 574: 2435
          line 578: 2459
          line 582: 2474
          line 481: 2650
          line 479: 2672
          line 478: 2694
          line 477: 2716
          line 476: 2738
          line 475: 2760
          line 474: 2782
          line 473: 2804
          line 415: 2826
          line 396: 2848
          line 390: 2870
          line 389: 2892
          line 388: 2914
          line 382: 2936
          line 381: 2958
          line 363: 2980
          line 341: 3002
          line 2: 3038
          line 18: 3103
    }
    |}]
