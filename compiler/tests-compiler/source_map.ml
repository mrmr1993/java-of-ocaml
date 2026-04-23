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
          line 659: 79
          line 29: 162
          line 24: 214
          line 23: 234
          line 29: 270
          line 30: 291
          line 32: 349
          line 74: 614
          line 75: 636
          line 98: 658
          line 104: 680
          line 180: 756
          line 182: 790
          line 184: 824
          line 186: 858
          line 188: 892
          line 190: 926
          line 212: 948
          line 223: 972
          line 253: 994
          line 255: 1018
          line 260: 1040
          line 265: 1062
          line 270: 1086
          line 277: 1110
          line 287: 1134
          line 291: 1158
          line 314: 1294
          line 315: 1319
          line 316: 1344
          line 330: 1366
          line 335: 1390
          line 338: 1414
          line 346: 1438
          line 365: 1460
          line 368: 1482
          line 371: 1506
          line 376: 1530
          line 386: 1552
          line 392: 1574
          line 393: 1596
          line 404: 1618
          line 409: 1642
          line 412: 1666
          line 420: 1690
          line 433: 1740
          line 438: 1764
          line 445: 1788
          line 480: 1810
          line 486: 1834
          line 487: 1860
          line 488: 1886
          line 489: 1914
          line 490: 1942
          line 491: 1968
          line 493: 1992
          line 497: 2016
          line 498: 2042
          line 499: 2068
          line 500: 2096
          line 501: 2124
          line 502: 2150
          line 504: 2174
          line 508: 2202
          line 509: 2226
          line 510: 2252
          line 511: 2276
          line 517: 2302
          line 538: 2324
          line 544: 2348
          line 559: 2367
          line 572: 2400
          line 574: 2458
          line 578: 2482
          line 582: 2502
          line 481: 2678
          line 479: 2700
          line 478: 2722
          line 477: 2744
          line 476: 2766
          line 475: 2788
          line 474: 2810
          line 473: 2832
          line 415: 2854
          line 396: 2876
          line 390: 2898
          line 389: 2920
          line 388: 2942
          line 382: 2964
          line 381: 2986
          line 363: 3008
          line 341: 3030
          line 2: 3066
          line 18: 3131
    }
    |}]
