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
          line 23: 229
          line 29: 265
          line 30: 286
          line 32: 343
          line 74: 608
          line 75: 630
          line 98: 652
          line 104: 674
          line 180: 750
          line 182: 784
          line 184: 818
          line 186: 852
          line 188: 886
          line 190: 920
          line 212: 942
          line 223: 966
          line 253: 988
          line 255: 1012
          line 260: 1034
          line 265: 1056
          line 270: 1080
          line 277: 1104
          line 287: 1128
          line 291: 1152
          line 314: 1288
          line 315: 1313
          line 316: 1338
          line 330: 1360
          line 335: 1384
          line 338: 1408
          line 346: 1432
          line 365: 1454
          line 368: 1476
          line 371: 1500
          line 376: 1524
          line 386: 1546
          line 392: 1568
          line 393: 1590
          line 404: 1612
          line 409: 1636
          line 412: 1660
          line 420: 1684
          line 433: 1734
          line 438: 1758
          line 445: 1782
          line 480: 1804
          line 486: 1828
          line 487: 1854
          line 488: 1880
          line 489: 1908
          line 490: 1936
          line 491: 1962
          line 493: 1986
          line 497: 2010
          line 498: 2036
          line 499: 2062
          line 500: 2090
          line 501: 2118
          line 502: 2144
          line 504: 2168
          line 508: 2196
          line 509: 2220
          line 510: 2246
          line 511: 2270
          line 517: 2296
          line 538: 2318
          line 544: 2342
          line 559: 2361
          line 572: 2394
          line 574: 2452
          line 578: 2476
          line 582: 2491
          line 481: 2667
          line 479: 2689
          line 478: 2711
          line 477: 2733
          line 476: 2755
          line 475: 2777
          line 474: 2799
          line 473: 2821
          line 415: 2843
          line 396: 2865
          line 390: 2887
          line 389: 2909
          line 388: 2931
          line 382: 2953
          line 381: 2975
          line 363: 2997
          line 341: 3019
          line 2: 3055
          line 18: 3120
    }
    |}]
