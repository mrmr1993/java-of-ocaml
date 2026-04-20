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
          line 23: 203
          line 29: 209
          line 30: 245
          line 32: 269
          line 74: 341
          line 75: 586
          line 98: 608
          line 104: 630
          line 180: 652
          line 182: 734
          line 184: 768
          line 186: 802
          line 188: 836
          line 190: 870
          line 212: 896
          line 223: 918
          line 253: 942
          line 255: 964
          line 260: 988
          line 265: 1010
          line 270: 1032
          line 277: 1056
          line 287: 1080
          line 291: 1104
          line 314: 1128
          line 315: 1261
          line 316: 1284
          line 330: 1304
          line 335: 1326
          line 338: 1350
          line 346: 1374
          line 365: 1398
          line 368: 1420
          line 371: 1442
          line 376: 1466
          line 386: 1490
          line 392: 1512
          line 393: 1534
          line 404: 1556
          line 409: 1578
          line 412: 1602
          line 420: 1626
          line 433: 1650
          line 438: 1700
          line 445: 1724
          line 480: 1748
          line 486: 1770
          line 487: 1794
          line 488: 1820
          line 489: 1846
          line 490: 1874
          line 491: 1902
          line 493: 1928
          line 497: 1952
          line 498: 1976
          line 499: 2002
          line 500: 2028
          line 501: 2056
          line 502: 2084
          line 504: 2110
          line 508: 2134
          line 509: 2162
          line 510: 2186
          line 511: 2212
          line 512: 2236
          line 538: 2262
          line 544: 2284
          line 559: 2308
          line 572: 2327
          line 574: 2392
          line 578: 2418
          line 582: 2442
          line 481: 2456
          line 479: 2632
          line 478: 2654
          line 477: 2676
          line 476: 2698
          line 475: 2720
          line 474: 2742
          line 473: 2764
          line 415: 2786
          line 396: 2808
          line 390: 2830
          line 389: 2852
          line 388: 2874
          line 382: 2896
          line 381: 2918
          line 363: 2940
          line 341: 2962
          line 2: 2984
          line 18: 3016
    }
    |}]
