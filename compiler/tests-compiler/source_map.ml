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
          line 30: 218
          line 32: 230
          line 74: 278
          line 75: 369
          line 98: 378
          line 104: 387
          line 180: 396
          line 182: 433
          line 184: 454
          line 186: 475
          line 188: 496
          line 190: 517
          line 212: 530
          line 223: 539
          line 253: 550
          line 255: 559
          line 260: 570
          line 265: 579
          line 270: 588
          line 277: 599
          line 287: 610
          line 291: 621
          line 314: 632
          line 315: 739
          line 316: 749
          line 330: 756
          line 335: 765
          line 338: 776
          line 346: 787
          line 365: 798
          line 368: 807
          line 371: 816
          line 376: 827
          line 386: 838
          line 392: 847
          line 393: 856
          line 404: 865
          line 409: 874
          line 412: 885
          line 420: 896
          line 433: 907
          line 438: 931
          line 445: 942
          line 480: 953
          line 486: 962
          line 487: 973
          line 488: 986
          line 489: 999
          line 490: 1014
          line 491: 1029
          line 493: 1042
          line 497: 1053
          line 498: 1064
          line 499: 1077
          line 500: 1090
          line 501: 1105
          line 502: 1120
          line 504: 1133
          line 508: 1144
          line 509: 1159
          line 510: 1170
          line 511: 1183
          line 512: 1194
          line 538: 1207
          line 544: 1216
          line 559: 1227
          line 572: 1246
          line 574: 1285
          line 578: 1298
          line 582: 1309
          line 481: 1323
          line 479: 1431
          line 478: 1440
          line 477: 1449
          line 476: 1458
          line 475: 1467
          line 474: 1476
          line 473: 1485
          line 415: 1494
          line 396: 1503
          line 390: 1512
          line 389: 1521
          line 388: 1530
          line 382: 1539
          line 381: 1548
          line 363: 1557
          line 341: 1566
          line 2: 1575
          line 18: 2246
    }
    |}]
