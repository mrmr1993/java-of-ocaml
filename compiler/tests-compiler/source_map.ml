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
          line 29: 173
          line 24: 225
          line 23: 245
          line 29: 281
          line 30: 302
          line 32: 360
          line 74: 625
          line 75: 647
          line 98: 669
          line 104: 691
          line 180: 767
          line 182: 801
          line 184: 835
          line 186: 869
          line 188: 903
          line 190: 937
          line 212: 959
          line 223: 983
          line 253: 1005
          line 255: 1029
          line 260: 1051
          line 265: 1073
          line 270: 1097
          line 277: 1121
          line 287: 1145
          line 291: 1169
          line 314: 1305
          line 315: 1330
          line 316: 1355
          line 330: 1377
          line 335: 1401
          line 338: 1425
          line 346: 1449
          line 365: 1471
          line 368: 1493
          line 371: 1517
          line 376: 1541
          line 386: 1563
          line 392: 1585
          line 393: 1607
          line 404: 1629
          line 409: 1653
          line 412: 1677
          line 420: 1701
          line 433: 1751
          line 438: 1775
          line 445: 1799
          line 480: 1821
          line 486: 1845
          line 487: 1871
          line 488: 1897
          line 489: 1925
          line 490: 1953
          line 491: 1979
          line 493: 2003
          line 497: 2027
          line 498: 2053
          line 499: 2079
          line 500: 2107
          line 501: 2135
          line 502: 2161
          line 504: 2185
          line 508: 2213
          line 509: 2237
          line 510: 2263
          line 511: 2287
          line 517: 2313
          line 538: 2335
          line 544: 2359
          line 559: 2378
          line 572: 2411
          line 574: 2469
          line 578: 2493
          line 582: 2513
          line 481: 2689
          line 479: 2711
          line 478: 2733
          line 477: 2755
          line 476: 2777
          line 475: 2799
          line 474: 2821
          line 473: 2843
          line 415: 2865
          line 396: 2887
          line 390: 2909
          line 389: 2931
          line 388: 2953
          line 382: 2975
          line 381: 2997
          line 363: 3019
          line 341: 3041
          line 2: 3077
          line 18: 3142
    }
    |}]
