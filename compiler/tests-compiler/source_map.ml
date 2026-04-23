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
          line 659: 70
          line 29: 153
          line 24: 205
          line 23: 220
          line 29: 256
          line 30: 277
          line 32: 334
          line 74: 599
          line 75: 621
          line 98: 643
          line 104: 665
          line 180: 741
          line 182: 775
          line 184: 809
          line 186: 843
          line 188: 877
          line 190: 911
          line 212: 933
          line 223: 957
          line 253: 979
          line 255: 1003
          line 260: 1025
          line 265: 1047
          line 270: 1071
          line 277: 1095
          line 287: 1119
          line 291: 1143
          line 314: 1279
          line 315: 1304
          line 316: 1329
          line 330: 1351
          line 335: 1375
          line 338: 1399
          line 346: 1423
          line 365: 1445
          line 368: 1467
          line 371: 1491
          line 376: 1515
          line 386: 1537
          line 392: 1559
          line 393: 1581
          line 404: 1603
          line 409: 1627
          line 412: 1651
          line 420: 1675
          line 433: 1725
          line 438: 1749
          line 445: 1773
          line 480: 1795
          line 486: 1819
          line 487: 1845
          line 488: 1871
          line 489: 1899
          line 490: 1927
          line 491: 1953
          line 493: 1977
          line 497: 2001
          line 498: 2027
          line 499: 2053
          line 500: 2081
          line 501: 2109
          line 502: 2135
          line 504: 2159
          line 508: 2187
          line 509: 2211
          line 510: 2237
          line 511: 2261
          line 517: 2287
          line 538: 2309
          line 544: 2333
          line 559: 2352
          line 572: 2385
          line 574: 2443
          line 578: 2467
          line 582: 2482
          line 481: 2658
          line 479: 2680
          line 478: 2702
          line 477: 2724
          line 476: 2746
          line 475: 2768
          line 474: 2790
          line 473: 2812
          line 415: 2834
          line 396: 2856
          line 390: 2878
          line 389: 2900
          line 388: 2922
          line 382: 2944
          line 381: 2966
          line 363: 2988
          line 341: 3010
          line 2: 3046
          line 18: 3111
    }
    |}]
