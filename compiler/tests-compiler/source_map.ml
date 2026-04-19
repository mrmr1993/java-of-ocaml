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
          line 182: 1449
          line 184: 1470
          line 186: 1491
          line 188: 1512
          line 190: 1533
          line 212: 1546
          line 223: 1555
          line 253: 1566
          line 255: 1575
          line 260: 1586
          line 265: 1595
          line 270: 1604
          line 277: 1615
          line 287: 1626
          line 291: 1637
          line 314: 1648
          line 315: 1755
          line 316: 1765
          line 330: 1772
          line 335: 1781
          line 338: 1792
          line 346: 1803
          line 365: 1814
          line 368: 1823
          line 371: 1832
          line 376: 1843
          line 386: 1854
          line 392: 1863
          line 393: 1872
          line 404: 1881
          line 409: 1890
          line 412: 1901
          line 420: 1912
          line 433: 1923
          line 438: 1947
          line 445: 1958
          line 480: 1969
          line 486: 1978
          line 487: 1989
          line 488: 2002
          line 489: 2015
          line 490: 2030
          line 491: 2045
          line 493: 2058
          line 497: 2069
          line 498: 2080
          line 499: 2093
          line 500: 2106
          line 501: 2121
          line 502: 2136
          line 504: 2149
          line 508: 2160
          line 509: 2175
          line 510: 2186
          line 511: 2199
          line 512: 2210
          line 538: 2223
          line 544: 2232
          line 559: 2243
          line 572: 2262
          line 574: 2301
          line 578: 2314
          line 582: 2325
          line 481: 2339
          line 479: 2447
          line 478: 2456
          line 477: 2465
          line 476: 2474
          line 475: 2483
          line 474: 2492
          line 473: 2501
          line 415: 2510
          line 396: 2519
          line 390: 2528
          line 389: 2537
          line 388: 2546
          line 382: 2555
          line 381: 2564
          line 363: 2573
          line 341: 2582
          line 2: 2591
          line 18: 3262
    }
    |}]
