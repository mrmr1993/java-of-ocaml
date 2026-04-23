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
          line 32: 348
          line 74: 613
          line 75: 635
          line 98: 657
          line 104: 679
          line 180: 755
          line 182: 789
          line 184: 823
          line 186: 857
          line 188: 891
          line 190: 925
          line 212: 947
          line 223: 971
          line 253: 993
          line 255: 1017
          line 260: 1039
          line 265: 1061
          line 270: 1085
          line 277: 1109
          line 287: 1133
          line 291: 1157
          line 314: 1293
          line 315: 1318
          line 316: 1343
          line 330: 1365
          line 335: 1389
          line 338: 1413
          line 346: 1437
          line 365: 1459
          line 368: 1481
          line 371: 1505
          line 376: 1529
          line 386: 1551
          line 392: 1573
          line 393: 1595
          line 404: 1617
          line 409: 1641
          line 412: 1665
          line 420: 1689
          line 433: 1739
          line 438: 1763
          line 445: 1787
          line 480: 1809
          line 486: 1833
          line 487: 1859
          line 488: 1885
          line 489: 1913
          line 490: 1941
          line 491: 1967
          line 493: 1991
          line 497: 2015
          line 498: 2041
          line 499: 2067
          line 500: 2095
          line 501: 2123
          line 502: 2149
          line 504: 2173
          line 508: 2201
          line 509: 2225
          line 510: 2251
          line 511: 2275
          line 517: 2301
          line 538: 2323
          line 544: 2347
          line 559: 2366
          line 572: 2399
          line 574: 2457
          line 578: 2481
          line 582: 2501
          line 481: 2677
          line 479: 2699
          line 478: 2721
          line 477: 2743
          line 476: 2765
          line 475: 2787
          line 474: 2809
          line 473: 2831
          line 415: 2853
          line 396: 2875
          line 390: 2897
          line 389: 2919
          line 388: 2941
          line 382: 2963
          line 381: 2985
          line 363: 3007
          line 341: 3029
          line 2: 3065
          line 18: 3130
    }
    |}]
