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
          line 528: 1071
          line 299: 1078
          line 24: 1161
          line 23: 1219
          line 29: 1225
          line 30: 1234
          line 32: 1246
          line 74: 1294
          line 75: 1385
          line 98: 1394
          line 104: 1403
          line 180: 1412
          line 182: 1452
          line 184: 1476
          line 186: 1500
          line 188: 1524
          line 190: 1548
          line 212: 1564
          line 223: 1573
          line 253: 1584
          line 255: 1593
          line 260: 1604
          line 265: 1613
          line 270: 1622
          line 277: 1633
          line 287: 1644
          line 291: 1655
          line 314: 1666
          line 315: 1773
          line 316: 1783
          line 330: 1790
          line 335: 1799
          line 338: 1810
          line 346: 1821
          line 365: 1832
          line 368: 1841
          line 371: 1850
          line 376: 1861
          line 386: 1872
          line 392: 1881
          line 393: 1890
          line 404: 1899
          line 409: 1908
          line 412: 1919
          line 420: 1930
          line 433: 1941
          line 438: 1965
          line 445: 1976
          line 480: 1987
          line 486: 1996
          line 487: 2007
          line 488: 2020
          line 489: 2033
          line 490: 2048
          line 491: 2063
          line 493: 2076
          line 497: 2087
          line 498: 2098
          line 499: 2111
          line 500: 2124
          line 501: 2139
          line 502: 2154
          line 504: 2167
          line 508: 2178
          line 509: 2193
          line 510: 2204
          line 511: 2217
          line 512: 2228
          line 538: 2241
          line 544: 2250
          line 559: 2261
          line 572: 2280
          line 574: 2319
          line 578: 2332
          line 582: 2343
          line 481: 2357
          line 479: 2465
          line 478: 2474
          line 477: 2483
          line 476: 2492
          line 475: 2501
          line 474: 2510
          line 473: 2519
          line 415: 2528
          line 396: 2537
          line 390: 2546
          line 389: 2555
          line 388: 2564
          line 382: 2573
          line 381: 2582
          line 363: 2591
          line 341: 2600
          line 2: 2609
          line 18: 3280
    }
    |}]
