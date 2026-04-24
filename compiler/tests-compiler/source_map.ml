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
          line 659: 90
          line 29: 182
          line 24: 234
          line 23: 254
          line 29: 290
          line 30: 311
          line 32: 369
          line 74: 634
          line 75: 656
          line 98: 678
          line 104: 700
          line 180: 776
          line 182: 810
          line 184: 844
          line 186: 878
          line 188: 912
          line 190: 946
          line 212: 968
          line 223: 992
          line 253: 1014
          line 255: 1038
          line 260: 1060
          line 265: 1082
          line 270: 1106
          line 277: 1130
          line 287: 1154
          line 291: 1178
          line 314: 1314
          line 315: 1339
          line 316: 1364
          line 330: 1386
          line 335: 1410
          line 338: 1434
          line 346: 1458
          line 365: 1480
          line 368: 1502
          line 371: 1526
          line 376: 1550
          line 386: 1572
          line 392: 1594
          line 393: 1616
          line 404: 1638
          line 409: 1662
          line 412: 1686
          line 420: 1710
          line 433: 1760
          line 438: 1784
          line 445: 1808
          line 480: 1830
          line 486: 1854
          line 487: 1880
          line 488: 1906
          line 489: 1934
          line 490: 1962
          line 491: 1988
          line 493: 2012
          line 497: 2036
          line 498: 2062
          line 499: 2088
          line 500: 2116
          line 501: 2144
          line 502: 2170
          line 504: 2194
          line 508: 2222
          line 509: 2246
          line 510: 2272
          line 511: 2296
          line 517: 2322
          line 538: 2344
          line 544: 2368
          line 559: 2387
          line 572: 2420
          line 574: 2478
          line 578: 2502
          line 582: 2522
          line 481: 2698
          line 479: 2720
          line 478: 2742
          line 477: 2764
          line 476: 2786
          line 475: 2808
          line 474: 2830
          line 473: 2852
          line 415: 2874
          line 396: 2896
          line 390: 2918
          line 389: 2940
          line 388: 2962
          line 382: 2984
          line 381: 3006
          line 363: 3028
          line 341: 3050
          line 2: 3102
          line 18: 3183
    }
    |}]
