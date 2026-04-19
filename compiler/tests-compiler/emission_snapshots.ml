(* Emission snapshots.

   Unlike the rest of this directory, these tests do NOT run the emitted
   JVM program. They [javap -c] the compiled [Main.class] and pin the
   disassembly. The goal is to catch silent emission regressions:
   behaviour-level tests would still pass if we accidentally started
   emitting extra boxing ops or a different branch encoding, but those
   would diff visibly here.

   Kept small and representative — pick the simplest program that
   exercises a feature and let the listing speak for it. Grow the set
   when a refactor needs a safety net. *)

open Util

let%expect_test "emission: println of a string literal" =
  compile_and_javap
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "hi" |};
  [%expect
    {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        49
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: ldc           #94                 // String hi
        1042: aastore
        1043: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1046: bipush        47
        1048: iconst_0
        1049: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1052: aastore
        1053: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1056: bipush        48
        1058: iconst_0
        1059: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1062: aastore
        1063: aconst_null
        1064: astore_1
        1065: aload_1
        1066: astore_2
        1067: goto_w        1072
        1072: new           #96                 // class ocaml_fn_0
        1075: dup
        1076: invokespecial #99                 // Method ocaml_fn_0."<init>":()V
        1079: astore_3
        1080: new           #101                // class ocaml_fn_1
        1083: dup
        1084: invokespecial #102                // Method ocaml_fn_1."<init>":()V
        1087: astore        4
        1089: new           #104                // class ocaml_fn_2
        1092: dup
        1093: invokespecial #105                // Method ocaml_fn_2."<init>":()V
        1096: astore        5
        1098: new           #2                  // class Block
        1101: dup
        1102: iconst_0
        1103: iconst_3
        1104: anewarray     #4                  // class java/lang/Object
        1107: dup
        1108: iconst_0
        1109: aload         4
        1111: aastore
        1112: dup
        1113: iconst_1
        1114: aload_3
        1115: aastore
        1116: dup
        1117: iconst_2
        1118: aload         5
        1120: aastore
        1121: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1124: astore        6
        1126: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1129: bipush        12
        1131: aload         6
        1133: aastore
        1134: iconst_0
        1135: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1138: astore        7
        1140: iconst_0
        1141: istore        8
        1143: iload         8
        1145: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1148: astore        9
        1150: goto_w        1155
        1155: sipush        199
        1158: istore        10
        1160: iconst_0
        1161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1164: astore        11
        1166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1169: bipush        35
        1171: aaload
        1172: astore        12
        1174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1177: iconst_3
        1178: aaload
        1179: astore        13
        1181: new           #2                  // class Block
        1184: dup
        1185: iconst_0
        1186: iconst_2
        1187: anewarray     #4                  // class java/lang/Object
        1190: dup
        1191: iconst_0
        1192: aload         13
        1194: aastore
        1195: dup
        1196: iconst_1
        1197: aload         12
        1199: aastore
        1200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1203: astore        14
        1205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1208: bipush        36
        1210: aaload
        1211: astore        15
        1213: iconst_0
        1214: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1217: astore        16
        1219: new           #107                // class ocaml_fn_8
        1222: dup
        1223: invokespecial #108                // Method ocaml_fn_8."<init>":()V
        1226: astore        17
        1228: new           #110                // class ocaml_fn_9
        1231: dup
        1232: invokespecial #111                // Method ocaml_fn_9."<init>":()V
        1235: astore        18
        1237: iconst_0
        1238: istore        19
        1240: iconst_0
        1241: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1244: astore        20
        1246: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        37
        1251: aaload
        1252: astore        21
        1254: new           #2                  // class Block
        1257: dup
        1258: sipush        248
        1261: iconst_2
        1262: anewarray     #4                  // class java/lang/Object
        1265: dup
        1266: iconst_0
        1267: aload         21
        1269: aastore
        1270: dup
        1271: iconst_1
        1272: aload         20
        1274: aastore
        1275: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1278: astore        22
        1280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1283: bipush        7
        1285: aaload
        1286: astore        23
        1288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1291: bipush        10
        1293: aaload
        1294: astore        24
        1296: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1299: iconst_3
        1300: aaload
        1301: astore        25
        1303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1306: iconst_2
        1307: aaload
        1308: astore        26
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: bipush        6
        1315: aaload
        1316: astore        27
        1318: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1321: iconst_0
        1322: aaload
        1323: astore        28
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: bipush        8
        1330: aaload
        1331: astore        29
        1333: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1336: iconst_1
        1337: aaload
        1338: astore        30
        1340: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1343: iconst_4
        1344: aaload
        1345: astore        31
        1347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1350: iconst_5
        1351: aaload
        1352: astore        32
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: bipush        9
        1359: aaload
        1360: astore        33
        1362: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1365: bipush        11
        1367: aaload
        1368: astore        34
        1370: new           #113                // class ocaml_fn_10
        1373: dup
        1374: invokespecial #114                // Method ocaml_fn_10."<init>":()V
        1377: astore        35
        1379: new           #116                // class ocaml_fn_11
        1382: dup
        1383: invokespecial #117                // Method ocaml_fn_11."<init>":()V
        1386: astore        36
        1388: new           #119                // class ocaml_fn_12
        1391: dup
        1392: invokespecial #120                // Method ocaml_fn_12."<init>":()V
        1395: astore        37
        1397: new           #122                // class ocaml_fn_13
        1400: dup
        1401: invokespecial #123                // Method ocaml_fn_13."<init>":()V
        1404: astore        38
        1406: ldc           #124                // int 2147483647
        1408: istore        39
        1410: ldc           #125                // int -2147483648
        1412: istore        40
        1414: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1417: bipush        38
        1419: aaload
        1420: astore        41
        1422: ldc2_w        #126                // double 0.0d
        1425: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1428: astore        42
        1430: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1433: bipush        39
        1435: aaload
        1436: astore        43
        1438: ldc2_w        #126                // double 0.0d
        1441: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1444: astore        44
        1446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1449: bipush        40
        1451: aaload
        1452: astore        45
        1454: ldc2_w        #126                // double 0.0d
        1457: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        46
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        41
        1467: aaload
        1468: astore        47
        1470: ldc2_w        #126                // double 0.0d
        1473: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1476: astore        48
        1478: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1481: bipush        42
        1483: aaload
        1484: astore        49
        1486: ldc2_w        #126                // double 0.0d
        1489: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1492: astore        50
        1494: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1497: bipush        43
        1499: aaload
        1500: astore        51
        1502: ldc2_w        #126                // double 0.0d
        1505: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1508: astore        52
        1510: new           #134                // class ocaml_fn_14
        1513: dup
        1514: invokespecial #135                // Method ocaml_fn_14."<init>":()V
        1517: astore        53
        1519: new           #137                // class ocaml_fn_15
        1522: dup
        1523: aload         18
        1525: invokespecial #140                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1528: astore        54
        1530: new           #142                // class ocaml_fn_16
        1533: dup
        1534: invokespecial #143                // Method ocaml_fn_16."<init>":()V
        1537: astore        55
        1539: new           #145                // class ocaml_fn_17
        1542: dup
        1543: aload         18
        1545: invokespecial #146                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1548: astore        56
        1550: new           #148                // class ocaml_fn_18
        1553: dup
        1554: invokespecial #149                // Method ocaml_fn_18."<init>":()V
        1557: astore        57
        1559: new           #151                // class ocaml_fn_19
        1562: dup
        1563: invokespecial #152                // Method ocaml_fn_19."<init>":()V
        1566: astore        58
        1568: new           #154                // class ocaml_fn_20
        1571: dup
        1572: aload         26
        1574: invokespecial #155                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1577: astore        59
        1579: new           #157                // class ocaml_fn_21
        1582: dup
        1583: aload         53
        1585: invokespecial #158                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1588: astore        60
        1590: new           #160                // class ocaml_fn_22
        1593: dup
        1594: aload         60
        1596: invokespecial #161                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1599: astore        61
        1601: new           #163                // class ocaml_fn_23
        1604: dup
        1605: aload         26
        1607: invokespecial #164                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1610: astore        62
        1612: new           #166                // class ocaml_fn_24
        1615: dup
        1616: invokespecial #167                // Method ocaml_fn_24."<init>":()V
        1619: astore        63
        1621: new           #169                // class ocaml_fn_25
        1624: dup
        1625: invokespecial #170                // Method ocaml_fn_25."<init>":()V
        1628: astore        64
        1630: aload         63
        1632: checkcast     #166                // class ocaml_fn_24
        1635: aload         63
        1637: checkcast     #172                // class Closure
        1640: putfield      #176                // Field ocaml_fn_24.sibling_0:LClosure;
        1643: iconst_0
        1644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1647: astore        65
        1649: aload         63
        1651: checkcast     #166                // class ocaml_fn_24
        1654: aload         64
        1656: checkcast     #172                // class Closure
        1659: putfield      #179                // Field ocaml_fn_24.sibling_1:LClosure;
        1662: iconst_0
        1663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1666: astore        66
        1668: aload         64
        1670: checkcast     #169                // class ocaml_fn_25
        1673: aload         63
        1675: checkcast     #172                // class Closure
        1678: putfield      #180                // Field ocaml_fn_25.sibling_0:LClosure;
        1681: iconst_0
        1682: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1685: astore        67
        1687: aload         64
        1689: checkcast     #169                // class ocaml_fn_25
        1692: aload         64
        1694: checkcast     #172                // class Closure
        1697: putfield      #181                // Field ocaml_fn_25.sibling_1:LClosure;
        1700: iconst_0
        1701: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: astore        68
        1706: iconst_0
        1707: istore        69
        1709: aconst_null
        1710: astore        70
        1712: iconst_1
        1713: istore        71
        1715: iload         71
        1717: invokestatic  #187                // Method Channel.forDescriptor:(I)LChannel;
        1720: astore        72
        1722: iconst_2
        1723: istore        73
        1725: iload         73
        1727: invokestatic  #187                // Method Channel.forDescriptor:(I)LChannel;
        1730: astore        74
        1732: new           #189                // class ocaml_fn_26
        1735: dup
        1736: invokespecial #190                // Method ocaml_fn_26."<init>":()V
        1739: astore        75
        1741: new           #192                // class ocaml_fn_27
        1744: dup
        1745: aload         75
        1747: invokespecial #193                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1750: astore        76
        1752: new           #195                // class ocaml_fn_28
        1755: dup
        1756: aload         75
        1758: invokespecial #196                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1761: astore        77
        1763: new           #198                // class ocaml_fn_29
        1766: dup
        1767: aload         30
        1769: invokespecial #199                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1772: astore        78
        1774: new           #201                // class ocaml_fn_30
        1777: dup
        1778: invokespecial #202                // Method ocaml_fn_30."<init>":()V
        1781: astore        79
        1783: new           #204                // class ocaml_fn_31
        1786: dup
        1787: invokespecial #205                // Method ocaml_fn_31."<init>":()V
        1790: astore        80
        1792: new           #207                // class ocaml_fn_32
        1795: dup
        1796: aload         18
        1798: invokespecial #208                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1801: astore        81
        1803: new           #210                // class ocaml_fn_33
        1806: dup
        1807: aload         18
        1809: invokespecial #211                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1812: astore        82
        1814: new           #213                // class ocaml_fn_34
        1817: dup
        1818: invokespecial #214                // Method ocaml_fn_34."<init>":()V
        1821: astore        83
        1823: new           #216                // class ocaml_fn_35
        1826: dup
        1827: invokespecial #217                // Method ocaml_fn_35."<init>":()V
        1830: astore        84
        1832: new           #219                // class ocaml_fn_36
        1835: dup
        1836: invokespecial #220                // Method ocaml_fn_36."<init>":()V
        1839: astore        85
        1841: new           #222                // class ocaml_fn_37
        1844: dup
        1845: invokespecial #223                // Method ocaml_fn_37."<init>":()V
        1848: astore        86
        1850: new           #225                // class ocaml_fn_38
        1853: dup
        1854: aload         86
        1856: invokespecial #226                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1859: astore        87
        1861: new           #228                // class ocaml_fn_39
        1864: dup
        1865: aload         86
        1867: invokespecial #229                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1870: astore        88
        1872: new           #231                // class ocaml_fn_40
        1875: dup
        1876: aload         18
        1878: invokespecial #232                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1881: astore        89
        1883: new           #234                // class ocaml_fn_41
        1886: dup
        1887: aload         31
        1889: invokespecial #235                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1892: astore        90
        1894: new           #237                // class ocaml_fn_42
        1897: dup
        1898: aload         18
        1900: aload         90
        1902: invokespecial #240                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1905: astore        91
        1907: new           #242                // class ocaml_fn_43
        1910: dup
        1911: aload         91
        1913: invokespecial #243                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1916: astore        92
        1918: new           #245                // class ocaml_fn_44
        1921: dup
        1922: aload         31
        1924: invokespecial #246                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1927: astore        93
        1929: new           #248                // class ocaml_fn_45
        1932: dup
        1933: invokespecial #249                // Method ocaml_fn_45."<init>":()V
        1936: astore        94
        1938: new           #251                // class ocaml_fn_46
        1941: dup
        1942: aload         72
        1944: invokespecial #252                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1947: astore        95
        1949: new           #254                // class ocaml_fn_47
        1952: dup
        1953: aload         72
        1955: aload         80
        1957: invokespecial #255                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1960: astore        96
        1962: new           #257                // class ocaml_fn_48
        1965: dup
        1966: aload         72
        1968: aload         79
        1970: invokespecial #258                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        97
        1975: new           #260                // class ocaml_fn_49
        1978: dup
        1979: aload         58
        1981: aload         72
        1983: aload         80
        1985: invokespecial #263                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1988: astore        98
        1990: new           #265                // class ocaml_fn_50
        1993: dup
        1994: aload         61
        1996: aload         72
        1998: aload         80
        2000: invokespecial #266                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2003: astore        99
        2005: new           #268                // class ocaml_fn_51
        2008: dup
        2009: aload         72
        2011: aload         80
        2013: invokespecial #269                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2016: astore        100
        2018: new           #271                // class ocaml_fn_52
        2021: dup
        2022: aload         72
        2024: invokespecial #272                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2027: astore        101
        2029: new           #274                // class ocaml_fn_53
        2032: dup
        2033: aload         74
        2035: invokespecial #275                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2038: astore        102
        2040: new           #277                // class ocaml_fn_54
        2043: dup
        2044: aload         74
        2046: aload         80
        2048: invokespecial #278                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2051: astore        103
        2053: new           #280                // class ocaml_fn_55
        2056: dup
        2057: aload         74
        2059: aload         79
        2061: invokespecial #281                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        104
        2066: new           #283                // class ocaml_fn_56
        2069: dup
        2070: aload         58
        2072: aload         74
        2074: aload         80
        2076: invokespecial #284                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2079: astore        105
        2081: new           #286                // class ocaml_fn_57
        2084: dup
        2085: aload         61
        2087: aload         74
        2089: aload         80
        2091: invokespecial #287                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        106
        2096: new           #289                // class ocaml_fn_58
        2099: dup
        2100: aload         74
        2102: aload         80
        2104: invokespecial #290                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2107: astore        107
        2109: new           #292                // class ocaml_fn_59
        2112: dup
        2113: aload         74
        2115: invokespecial #293                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2118: astore        108
        2120: new           #295                // class ocaml_fn_60
        2123: dup
        2124: aload         70
        2126: aload         72
        2128: aload         93
        2130: invokespecial #296                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2133: astore        109
        2135: new           #298                // class ocaml_fn_61
        2138: dup
        2139: aload         109
        2141: invokespecial #299                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2144: astore        110
        2146: new           #301                // class ocaml_fn_62
        2149: dup
        2150: aload         59
        2152: aload         109
        2154: invokespecial #302                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2157: astore        111
        2159: new           #304                // class ocaml_fn_63
        2162: dup
        2163: aload         109
        2165: invokespecial #305                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2168: astore        112
        2170: new           #307                // class ocaml_fn_64
        2173: dup
        2174: aload         62
        2176: aload         109
        2178: invokespecial #308                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        113
        2183: new           #310                // class ocaml_fn_65
        2186: dup
        2187: invokespecial #311                // Method ocaml_fn_65."<init>":()V
        2190: astore        114
        2192: new           #313                // class ocaml_fn_66
        2195: dup
        2196: aload         53
        2198: invokespecial #314                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2201: astore        115
        2203: new           #2                  // class Block
        2206: dup
        2207: iconst_0
        2208: iconst_1
        2209: anewarray     #4                  // class java/lang/Object
        2212: dup
        2213: iconst_0
        2214: aload         78
        2216: aastore
        2217: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2220: astore        116
        2222: new           #316                // class ocaml_fn_67
        2225: dup
        2226: aload         116
        2228: invokespecial #317                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2231: astore        117
        2233: new           #319                // class ocaml_fn_68
        2236: dup
        2237: invokespecial #320                // Method ocaml_fn_68."<init>":()V
        2240: astore        118
        2242: new           #2                  // class Block
        2245: dup
        2246: iconst_0
        2247: iconst_1
        2248: anewarray     #4                  // class java/lang/Object
        2251: dup
        2252: iconst_0
        2253: aload         118
        2255: aastore
        2256: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2259: astore        119
        2261: new           #322                // class ocaml_fn_69
        2264: dup
        2265: aload         116
        2267: aload         119
        2269: invokespecial #323                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        120
        2274: new           #325                // class ocaml_fn_70
        2277: dup
        2278: aload         120
        2280: invokespecial #326                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2283: astore        121
        2285: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2288: bipush        44
        2290: aaload
        2291: astore        122
        2293: iconst_0
        2294: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2297: astore        123
        2299: new           #328                // class ocaml_fn_71
        2302: dup
        2303: invokespecial #329                // Method ocaml_fn_71."<init>":()V
        2306: astore        124
        2308: new           #331                // class ocaml_fn_72
        2311: dup
        2312: invokespecial #332                // Method ocaml_fn_72."<init>":()V
        2315: astore        125
        2317: new           #334                // class ocaml_fn_73
        2320: dup
        2321: invokespecial #335                // Method ocaml_fn_73."<init>":()V
        2324: astore        126
        2326: new           #337                // class ocaml_fn_74
        2329: dup
        2330: invokespecial #338                // Method ocaml_fn_74."<init>":()V
        2333: astore        127
        2335: new           #340                // class ocaml_fn_75
        2338: dup
        2339: invokespecial #341                // Method ocaml_fn_75."<init>":()V
        2342: astore        128
        2344: new           #343                // class ocaml_fn_76
        2347: dup
        2348: invokespecial #344                // Method ocaml_fn_76."<init>":()V
        2351: astore        129
        2353: new           #2                  // class Block
        2356: dup
        2357: iconst_0
        2358: bipush        6
        2360: anewarray     #4                  // class java/lang/Object
        2363: dup
        2364: iconst_0
        2365: aload         129
        2367: aastore
        2368: dup
        2369: iconst_1
        2370: aload         128
        2372: aastore
        2373: dup
        2374: iconst_2
        2375: aload         127
        2377: aastore
        2378: dup
        2379: iconst_3
        2380: aload         126
        2382: aastore
        2383: dup
        2384: iconst_4
        2385: aload         125
        2387: aastore
        2388: dup
        2389: iconst_5
        2390: aload         124
        2392: aastore
        2393: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2396: astore        130
        2398: new           #346                // class ocaml_fn_77
        2401: dup
        2402: invokespecial #347                // Method ocaml_fn_77."<init>":()V
        2405: astore        131
        2407: new           #349                // class ocaml_fn_78
        2410: dup
        2411: invokespecial #350                // Method ocaml_fn_78."<init>":()V
        2414: astore        132
        2416: new           #352                // class ocaml_fn_79
        2419: dup
        2420: invokespecial #353                // Method ocaml_fn_79."<init>":()V
        2423: astore        133
        2425: new           #355                // class ocaml_fn_80
        2428: dup
        2429: invokespecial #356                // Method ocaml_fn_80."<init>":()V
        2432: astore        134
        2434: new           #358                // class ocaml_fn_81
        2437: dup
        2438: invokespecial #359                // Method ocaml_fn_81."<init>":()V
        2441: astore        135
        2443: new           #361                // class ocaml_fn_82
        2446: dup
        2447: invokespecial #362                // Method ocaml_fn_82."<init>":()V
        2450: astore        136
        2452: new           #364                // class ocaml_fn_83
        2455: dup
        2456: invokespecial #365                // Method ocaml_fn_83."<init>":()V
        2459: astore        137
        2461: new           #367                // class ocaml_fn_84
        2464: dup
        2465: invokespecial #368                // Method ocaml_fn_84."<init>":()V
        2468: astore        138
        2470: new           #370                // class ocaml_fn_85
        2473: dup
        2474: invokespecial #371                // Method ocaml_fn_85."<init>":()V
        2477: astore        139
        2479: new           #373                // class ocaml_fn_86
        2482: dup
        2483: invokespecial #374                // Method ocaml_fn_86."<init>":()V
        2486: astore        140
        2488: new           #376                // class ocaml_fn_87
        2491: dup
        2492: invokespecial #377                // Method ocaml_fn_87."<init>":()V
        2495: astore        141
        2497: new           #379                // class ocaml_fn_88
        2500: dup
        2501: invokespecial #380                // Method ocaml_fn_88."<init>":()V
        2504: astore        142
        2506: new           #382                // class ocaml_fn_89
        2509: dup
        2510: invokespecial #383                // Method ocaml_fn_89."<init>":()V
        2513: astore        143
        2515: new           #385                // class ocaml_fn_90
        2518: dup
        2519: invokespecial #386                // Method ocaml_fn_90."<init>":()V
        2522: astore        144
        2524: new           #388                // class ocaml_fn_91
        2527: dup
        2528: invokespecial #389                // Method ocaml_fn_91."<init>":()V
        2531: astore        145
        2533: new           #391                // class ocaml_fn_92
        2536: dup
        2537: invokespecial #392                // Method ocaml_fn_92."<init>":()V
        2540: astore        146
        2542: new           #394                // class ocaml_fn_93
        2545: dup
        2546: invokespecial #395                // Method ocaml_fn_93."<init>":()V
        2549: astore        147
        2551: new           #2                  // class Block
        2554: dup
        2555: iconst_0
        2556: bipush        104
        2558: anewarray     #4                  // class java/lang/Object
        2561: dup
        2562: iconst_0
        2563: aload         18
        2565: aastore
        2566: dup
        2567: iconst_1
        2568: aload         17
        2570: aastore
        2571: dup
        2572: iconst_2
        2573: aload         22
        2575: aastore
        2576: dup
        2577: iconst_3
        2578: aload         23
        2580: aastore
        2581: dup
        2582: iconst_4
        2583: aload         24
        2585: aastore
        2586: dup
        2587: iconst_5
        2588: aload         25
        2590: aastore
        2591: dup
        2592: bipush        6
        2594: aload         26
        2596: aastore
        2597: dup
        2598: bipush        7
        2600: aload         27
        2602: aastore
        2603: dup
        2604: bipush        8
        2606: aload         28
        2608: aastore
        2609: dup
        2610: bipush        9
        2612: aload         29
        2614: aastore
        2615: dup
        2616: bipush        10
        2618: aload         30
        2620: aastore
        2621: dup
        2622: bipush        11
        2624: aload         31
        2626: aastore
        2627: dup
        2628: bipush        12
        2630: aload         32
        2632: aastore
        2633: dup
        2634: bipush        13
        2636: aload         33
        2638: aastore
        2639: dup
        2640: bipush        14
        2642: aload         34
        2644: aastore
        2645: dup
        2646: bipush        15
        2648: aload         35
        2650: aastore
        2651: dup
        2652: bipush        16
        2654: aload         36
        2656: aastore
        2657: dup
        2658: bipush        17
        2660: aload         37
        2662: aastore
        2663: dup
        2664: bipush        18
        2666: iload         39
        2668: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2671: aastore
        2672: dup
        2673: bipush        19
        2675: iload         40
        2677: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2680: aastore
        2681: dup
        2682: bipush        20
        2684: aload         38
        2686: aastore
        2687: dup
        2688: bipush        21
        2690: aload         42
        2692: aastore
        2693: dup
        2694: bipush        22
        2696: aload         44
        2698: aastore
        2699: dup
        2700: bipush        23
        2702: aload         46
        2704: aastore
        2705: dup
        2706: bipush        24
        2708: aload         48
        2710: aastore
        2711: dup
        2712: bipush        25
        2714: aload         50
        2716: aastore
        2717: dup
        2718: bipush        26
        2720: aload         52
        2722: aastore
        2723: dup
        2724: bipush        27
        2726: aload         53
        2728: aastore
        2729: dup
        2730: bipush        28
        2732: aload         54
        2734: aastore
        2735: dup
        2736: bipush        29
        2738: aload         55
        2740: aastore
        2741: dup
        2742: bipush        30
        2744: aload         57
        2746: aastore
        2747: dup
        2748: bipush        31
        2750: aload         56
        2752: aastore
        2753: dup
        2754: bipush        32
        2756: aload         58
        2758: aastore
        2759: dup
        2760: bipush        33
        2762: aload         59
        2764: aastore
        2765: dup
        2766: bipush        34
        2768: aload         61
        2770: aastore
        2771: dup
        2772: bipush        35
        2774: aload         62
        2776: aastore
        2777: dup
        2778: bipush        36
        2780: aload         63
        2782: aastore
        2783: dup
        2784: bipush        37
        2786: aload         70
        2788: aastore
        2789: dup
        2790: bipush        38
        2792: aload         72
        2794: aastore
        2795: dup
        2796: bipush        39
        2798: aload         74
        2800: aastore
        2801: dup
        2802: bipush        40
        2804: aload         95
        2806: aastore
        2807: dup
        2808: bipush        41
        2810: aload         96
        2812: aastore
        2813: dup
        2814: bipush        42
        2816: aload         97
        2818: aastore
        2819: dup
        2820: bipush        43
        2822: aload         98
        2824: aastore
        2825: dup
        2826: bipush        44
        2828: aload         99
        2830: aastore
        2831: dup
        2832: bipush        45
        2834: aload         100
        2836: aastore
        2837: dup
        2838: bipush        46
        2840: aload         101
        2842: aastore
        2843: dup
        2844: bipush        47
        2846: aload         102
        2848: aastore
        2849: dup
        2850: bipush        48
        2852: aload         103
        2854: aastore
        2855: dup
        2856: bipush        49
        2858: aload         104
        2860: aastore
        2861: dup
        2862: bipush        50
        2864: aload         105
        2866: aastore
        2867: dup
        2868: bipush        51
        2870: aload         106
        2872: aastore
        2873: dup
        2874: bipush        52
        2876: aload         107
        2878: aastore
        2879: dup
        2880: bipush        53
        2882: aload         108
        2884: aastore
        2885: dup
        2886: bipush        54
        2888: aload         109
        2890: aastore
        2891: dup
        2892: bipush        55
        2894: aload         111
        2896: aastore
        2897: dup
        2898: bipush        56
        2900: aload         110
        2902: aastore
        2903: dup
        2904: bipush        57
        2906: aload         113
        2908: aastore
        2909: dup
        2910: bipush        58
        2912: aload         112
        2914: aastore
        2915: dup
        2916: bipush        59
        2918: aload         76
        2920: aastore
        2921: dup
        2922: bipush        60
        2924: aload         77
        2926: aastore
        2927: dup
        2928: bipush        61
        2930: aload         75
        2932: aastore
        2933: dup
        2934: bipush        62
        2936: aload         147
        2938: aastore
        2939: dup
        2940: bipush        63
        2942: aload         78
        2944: aastore
        2945: dup
        2946: bipush        64
        2948: aload         146
        2950: aastore
        2951: dup
        2952: bipush        65
        2954: aload         80
        2956: aastore
        2957: dup
        2958: bipush        66
        2960: aload         79
        2962: aastore
        2963: dup
        2964: bipush        67
        2966: aload         81
        2968: aastore
        2969: dup
        2970: bipush        68
        2972: aload         82
        2974: aastore
        2975: dup
        2976: bipush        69
        2978: aload         145
        2980: aastore
        2981: dup
        2982: bipush        70
        2984: aload         144
        2986: aastore
        2987: dup
        2988: bipush        71
        2990: aload         83
        2992: aastore
        2993: dup
        2994: bipush        72
        2996: aload         143
        2998: aastore
        2999: dup
        3000: bipush        73
        3002: aload         142
        3004: aastore
        3005: dup
        3006: bipush        74
        3008: aload         141
        3010: aastore
        3011: dup
        3012: bipush        75
        3014: aload         84
        3016: aastore
        3017: dup
        3018: bipush        76
        3020: aload         85
        3022: aastore
        3023: dup
        3024: bipush        77
        3026: aload         140
        3028: aastore
        3029: dup
        3030: bipush        78
        3032: aload         87
        3034: aastore
        3035: dup
        3036: bipush        79
        3038: aload         88
        3040: aastore
        3041: dup
        3042: bipush        80
        3044: aload         86
        3046: aastore
        3047: dup
        3048: bipush        81
        3050: aload         139
        3052: aastore
        3053: dup
        3054: bipush        82
        3056: aload         93
        3058: aastore
        3059: dup
        3060: bipush        83
        3062: aload         89
        3064: aastore
        3065: dup
        3066: bipush        84
        3068: aload         91
        3070: aastore
        3071: dup
        3072: bipush        85
        3074: aload         92
        3076: aastore
        3077: dup
        3078: bipush        86
        3080: aload         138
        3082: aastore
        3083: dup
        3084: bipush        87
        3086: aload         137
        3088: aastore
        3089: dup
        3090: bipush        88
        3092: aload         136
        3094: aastore
        3095: dup
        3096: bipush        89
        3098: aload         135
        3100: aastore
        3101: dup
        3102: bipush        90
        3104: aload         134
        3106: aastore
        3107: dup
        3108: bipush        91
        3110: aload         133
        3112: aastore
        3113: dup
        3114: bipush        92
        3116: aload         132
        3118: aastore
        3119: dup
        3120: bipush        93
        3122: aload         94
        3124: aastore
        3125: dup
        3126: bipush        94
        3128: aload         131
        3130: aastore
        3131: dup
        3132: bipush        95
        3134: aload         130
        3136: aastore
        3137: dup
        3138: bipush        96
        3140: aload         114
        3142: aastore
        3143: dup
        3144: bipush        97
        3146: aload         115
        3148: aastore
        3149: dup
        3150: bipush        98
        3152: aload         121
        3154: aastore
        3155: dup
        3156: bipush        99
        3158: aload         117
        3160: aastore
        3161: dup
        3162: bipush        100
        3164: aload         60
        3166: aastore
        3167: dup
        3168: bipush        101
        3170: aload         90
        3172: aastore
        3173: dup
        3174: bipush        102
        3176: aload         120
        3178: aastore
        3179: dup
        3180: bipush        103
        3182: aload         119
        3184: aastore
        3185: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3188: astore        148
        3190: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3193: bipush        45
        3195: aload         148
        3197: aastore
        3198: iconst_0
        3199: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3202: astore        149
        3204: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3207: bipush        46
        3209: aaload
        3210: astore        150
        3212: getstatic     #399                // Field java/lang/System.out:Ljava/io/PrintStream;
        3215: aload         150
        3217: checkcast     #401                // class java/lang/String
        3220: invokevirtual #407                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3223: iconst_0
        3224: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3227: astore        151
        3229: new           #2                  // class Block
        3232: dup
        3233: iconst_0
        3234: iconst_0
        3235: anewarray     #4                  // class java/lang/Object
        3238: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3241: astore        152
        3243: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3246: bipush        47
        3248: aload         152
        3250: aastore
        3251: iconst_0
        3252: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3255: astore        153
        3257: iconst_0
        3258: istore        154
        3260: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3263: bipush        45
        3265: aaload
        3266: checkcast     #2                  // class Block
        3269: getfield      #410                // Field Block.fields:[Ljava/lang/Object;
        3272: bipush        102
        3274: aaload
        3275: astore        155
        3277: aload         155
        3279: checkcast     #172                // class Closure
        3282: iload         154
        3284: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3287: invokevirtual #414                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3290: astore        156
        3292: new           #2                  // class Block
        3295: dup
        3296: iconst_0
        3297: iconst_0
        3298: anewarray     #4                  // class java/lang/Object
        3301: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3304: astore        157
        3306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3309: bipush        48
        3311: aload         157
        3313: aastore
        3314: iconst_0
        3315: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3318: astore        158
        3320: return
    }
    |}]

let%expect_test "emission: arithmetic ops" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int ((3 * 4) - (10 / 2) + (9 mod 4)) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        48
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: iconst_0
        1041: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1044: aastore
        1045: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1048: bipush        47
        1050: iconst_0
        1051: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1054: aastore
        1055: aconst_null
        1056: astore_1
        1057: aload_1
        1058: astore_2
        1059: goto_w        1064
        1064: new           #94                 // class ocaml_fn_0
        1067: dup
        1068: invokespecial #97                 // Method ocaml_fn_0."<init>":()V
        1071: astore_3
        1072: new           #99                 // class ocaml_fn_1
        1075: dup
        1076: invokespecial #100                // Method ocaml_fn_1."<init>":()V
        1079: astore        4
        1081: new           #102                // class ocaml_fn_2
        1084: dup
        1085: invokespecial #103                // Method ocaml_fn_2."<init>":()V
        1088: astore        5
        1090: new           #2                  // class Block
        1093: dup
        1094: iconst_0
        1095: iconst_3
        1096: anewarray     #4                  // class java/lang/Object
        1099: dup
        1100: iconst_0
        1101: aload         4
        1103: aastore
        1104: dup
        1105: iconst_1
        1106: aload_3
        1107: aastore
        1108: dup
        1109: iconst_2
        1110: aload         5
        1112: aastore
        1113: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1116: astore        6
        1118: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1121: bipush        12
        1123: aload         6
        1125: aastore
        1126: iconst_0
        1127: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1130: astore        7
        1132: iconst_0
        1133: istore        8
        1135: iload         8
        1137: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1140: astore        9
        1142: goto_w        1147
        1147: sipush        199
        1150: istore        10
        1152: iconst_0
        1153: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1156: astore        11
        1158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1161: bipush        35
        1163: aaload
        1164: astore        12
        1166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1169: iconst_3
        1170: aaload
        1171: astore        13
        1173: new           #2                  // class Block
        1176: dup
        1177: iconst_0
        1178: iconst_2
        1179: anewarray     #4                  // class java/lang/Object
        1182: dup
        1183: iconst_0
        1184: aload         13
        1186: aastore
        1187: dup
        1188: iconst_1
        1189: aload         12
        1191: aastore
        1192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1195: astore        14
        1197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1200: bipush        36
        1202: aaload
        1203: astore        15
        1205: iconst_0
        1206: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1209: astore        16
        1211: new           #105                // class ocaml_fn_8
        1214: dup
        1215: invokespecial #106                // Method ocaml_fn_8."<init>":()V
        1218: astore        17
        1220: new           #108                // class ocaml_fn_9
        1223: dup
        1224: invokespecial #109                // Method ocaml_fn_9."<init>":()V
        1227: astore        18
        1229: iconst_0
        1230: istore        19
        1232: iconst_0
        1233: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1236: astore        20
        1238: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        37
        1243: aaload
        1244: astore        21
        1246: new           #2                  // class Block
        1249: dup
        1250: sipush        248
        1253: iconst_2
        1254: anewarray     #4                  // class java/lang/Object
        1257: dup
        1258: iconst_0
        1259: aload         21
        1261: aastore
        1262: dup
        1263: iconst_1
        1264: aload         20
        1266: aastore
        1267: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1270: astore        22
        1272: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1275: bipush        7
        1277: aaload
        1278: astore        23
        1280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1283: bipush        10
        1285: aaload
        1286: astore        24
        1288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1291: iconst_3
        1292: aaload
        1293: astore        25
        1295: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1298: iconst_2
        1299: aaload
        1300: astore        26
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        6
        1307: aaload
        1308: astore        27
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: iconst_0
        1314: aaload
        1315: astore        28
        1317: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1320: bipush        8
        1322: aaload
        1323: astore        29
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: iconst_1
        1329: aaload
        1330: astore        30
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: iconst_4
        1336: aaload
        1337: astore        31
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_5
        1343: aaload
        1344: astore        32
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: bipush        9
        1351: aaload
        1352: astore        33
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: bipush        11
        1359: aaload
        1360: astore        34
        1362: new           #111                // class ocaml_fn_10
        1365: dup
        1366: invokespecial #112                // Method ocaml_fn_10."<init>":()V
        1369: astore        35
        1371: new           #114                // class ocaml_fn_11
        1374: dup
        1375: invokespecial #115                // Method ocaml_fn_11."<init>":()V
        1378: astore        36
        1380: new           #117                // class ocaml_fn_12
        1383: dup
        1384: invokespecial #118                // Method ocaml_fn_12."<init>":()V
        1387: astore        37
        1389: new           #120                // class ocaml_fn_13
        1392: dup
        1393: invokespecial #121                // Method ocaml_fn_13."<init>":()V
        1396: astore        38
        1398: ldc           #122                // int 2147483647
        1400: istore        39
        1402: ldc           #123                // int -2147483648
        1404: istore        40
        1406: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1409: bipush        38
        1411: aaload
        1412: astore        41
        1414: ldc2_w        #124                // double 0.0d
        1417: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1420: astore        42
        1422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1425: bipush        39
        1427: aaload
        1428: astore        43
        1430: ldc2_w        #124                // double 0.0d
        1433: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1436: astore        44
        1438: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1441: bipush        40
        1443: aaload
        1444: astore        45
        1446: ldc2_w        #124                // double 0.0d
        1449: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1452: astore        46
        1454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1457: bipush        41
        1459: aaload
        1460: astore        47
        1462: ldc2_w        #124                // double 0.0d
        1465: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        48
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        42
        1475: aaload
        1476: astore        49
        1478: ldc2_w        #124                // double 0.0d
        1481: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1484: astore        50
        1486: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1489: bipush        43
        1491: aaload
        1492: astore        51
        1494: ldc2_w        #124                // double 0.0d
        1497: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1500: astore        52
        1502: new           #132                // class ocaml_fn_14
        1505: dup
        1506: invokespecial #133                // Method ocaml_fn_14."<init>":()V
        1509: astore        53
        1511: new           #135                // class ocaml_fn_15
        1514: dup
        1515: aload         18
        1517: invokespecial #138                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1520: astore        54
        1522: new           #140                // class ocaml_fn_16
        1525: dup
        1526: invokespecial #141                // Method ocaml_fn_16."<init>":()V
        1529: astore        55
        1531: new           #143                // class ocaml_fn_17
        1534: dup
        1535: aload         18
        1537: invokespecial #144                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1540: astore        56
        1542: new           #146                // class ocaml_fn_18
        1545: dup
        1546: invokespecial #147                // Method ocaml_fn_18."<init>":()V
        1549: astore        57
        1551: new           #149                // class ocaml_fn_19
        1554: dup
        1555: invokespecial #150                // Method ocaml_fn_19."<init>":()V
        1558: astore        58
        1560: new           #152                // class ocaml_fn_20
        1563: dup
        1564: aload         26
        1566: invokespecial #153                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1569: astore        59
        1571: new           #155                // class ocaml_fn_21
        1574: dup
        1575: aload         53
        1577: invokespecial #156                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1580: astore        60
        1582: new           #158                // class ocaml_fn_22
        1585: dup
        1586: aload         60
        1588: invokespecial #159                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1591: astore        61
        1593: new           #161                // class ocaml_fn_23
        1596: dup
        1597: aload         26
        1599: invokespecial #162                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1602: astore        62
        1604: new           #164                // class ocaml_fn_24
        1607: dup
        1608: invokespecial #165                // Method ocaml_fn_24."<init>":()V
        1611: astore        63
        1613: new           #167                // class ocaml_fn_25
        1616: dup
        1617: invokespecial #168                // Method ocaml_fn_25."<init>":()V
        1620: astore        64
        1622: aload         63
        1624: checkcast     #164                // class ocaml_fn_24
        1627: aload         63
        1629: checkcast     #170                // class Closure
        1632: putfield      #174                // Field ocaml_fn_24.sibling_0:LClosure;
        1635: iconst_0
        1636: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1639: astore        65
        1641: aload         63
        1643: checkcast     #164                // class ocaml_fn_24
        1646: aload         64
        1648: checkcast     #170                // class Closure
        1651: putfield      #177                // Field ocaml_fn_24.sibling_1:LClosure;
        1654: iconst_0
        1655: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        66
        1660: aload         64
        1662: checkcast     #167                // class ocaml_fn_25
        1665: aload         63
        1667: checkcast     #170                // class Closure
        1670: putfield      #178                // Field ocaml_fn_25.sibling_0:LClosure;
        1673: iconst_0
        1674: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        67
        1679: aload         64
        1681: checkcast     #167                // class ocaml_fn_25
        1684: aload         64
        1686: checkcast     #170                // class Closure
        1689: putfield      #179                // Field ocaml_fn_25.sibling_1:LClosure;
        1692: iconst_0
        1693: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        68
        1698: iconst_0
        1699: istore        69
        1701: aconst_null
        1702: astore        70
        1704: iconst_1
        1705: istore        71
        1707: iload         71
        1709: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1712: astore        72
        1714: iconst_2
        1715: istore        73
        1717: iload         73
        1719: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1722: astore        74
        1724: new           #187                // class ocaml_fn_26
        1727: dup
        1728: invokespecial #188                // Method ocaml_fn_26."<init>":()V
        1731: astore        75
        1733: new           #190                // class ocaml_fn_27
        1736: dup
        1737: aload         75
        1739: invokespecial #191                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1742: astore        76
        1744: new           #193                // class ocaml_fn_28
        1747: dup
        1748: aload         75
        1750: invokespecial #194                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1753: astore        77
        1755: new           #196                // class ocaml_fn_29
        1758: dup
        1759: aload         30
        1761: invokespecial #197                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1764: astore        78
        1766: new           #199                // class ocaml_fn_30
        1769: dup
        1770: invokespecial #200                // Method ocaml_fn_30."<init>":()V
        1773: astore        79
        1775: new           #202                // class ocaml_fn_31
        1778: dup
        1779: invokespecial #203                // Method ocaml_fn_31."<init>":()V
        1782: astore        80
        1784: new           #205                // class ocaml_fn_32
        1787: dup
        1788: aload         18
        1790: invokespecial #206                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1793: astore        81
        1795: new           #208                // class ocaml_fn_33
        1798: dup
        1799: aload         18
        1801: invokespecial #209                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1804: astore        82
        1806: new           #211                // class ocaml_fn_34
        1809: dup
        1810: invokespecial #212                // Method ocaml_fn_34."<init>":()V
        1813: astore        83
        1815: new           #214                // class ocaml_fn_35
        1818: dup
        1819: invokespecial #215                // Method ocaml_fn_35."<init>":()V
        1822: astore        84
        1824: new           #217                // class ocaml_fn_36
        1827: dup
        1828: invokespecial #218                // Method ocaml_fn_36."<init>":()V
        1831: astore        85
        1833: new           #220                // class ocaml_fn_37
        1836: dup
        1837: invokespecial #221                // Method ocaml_fn_37."<init>":()V
        1840: astore        86
        1842: new           #223                // class ocaml_fn_38
        1845: dup
        1846: aload         86
        1848: invokespecial #224                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1851: astore        87
        1853: new           #226                // class ocaml_fn_39
        1856: dup
        1857: aload         86
        1859: invokespecial #227                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1862: astore        88
        1864: new           #229                // class ocaml_fn_40
        1867: dup
        1868: aload         18
        1870: invokespecial #230                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1873: astore        89
        1875: new           #232                // class ocaml_fn_41
        1878: dup
        1879: aload         31
        1881: invokespecial #233                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1884: astore        90
        1886: new           #235                // class ocaml_fn_42
        1889: dup
        1890: aload         18
        1892: aload         90
        1894: invokespecial #238                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1897: astore        91
        1899: new           #240                // class ocaml_fn_43
        1902: dup
        1903: aload         91
        1905: invokespecial #241                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1908: astore        92
        1910: new           #243                // class ocaml_fn_44
        1913: dup
        1914: aload         31
        1916: invokespecial #244                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1919: astore        93
        1921: new           #246                // class ocaml_fn_45
        1924: dup
        1925: invokespecial #247                // Method ocaml_fn_45."<init>":()V
        1928: astore        94
        1930: new           #249                // class ocaml_fn_46
        1933: dup
        1934: aload         72
        1936: invokespecial #250                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1939: astore        95
        1941: new           #252                // class ocaml_fn_47
        1944: dup
        1945: aload         72
        1947: aload         80
        1949: invokespecial #253                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        96
        1954: new           #255                // class ocaml_fn_48
        1957: dup
        1958: aload         72
        1960: aload         79
        1962: invokespecial #256                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1965: astore        97
        1967: new           #258                // class ocaml_fn_49
        1970: dup
        1971: aload         58
        1973: aload         72
        1975: aload         80
        1977: invokespecial #261                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1980: astore        98
        1982: new           #263                // class ocaml_fn_50
        1985: dup
        1986: aload         61
        1988: aload         72
        1990: aload         80
        1992: invokespecial #264                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1995: astore        99
        1997: new           #266                // class ocaml_fn_51
        2000: dup
        2001: aload         72
        2003: aload         80
        2005: invokespecial #267                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        100
        2010: new           #269                // class ocaml_fn_52
        2013: dup
        2014: aload         72
        2016: invokespecial #270                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2019: astore        101
        2021: new           #272                // class ocaml_fn_53
        2024: dup
        2025: aload         74
        2027: invokespecial #273                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2030: astore        102
        2032: new           #275                // class ocaml_fn_54
        2035: dup
        2036: aload         74
        2038: aload         80
        2040: invokespecial #276                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        103
        2045: new           #278                // class ocaml_fn_55
        2048: dup
        2049: aload         74
        2051: aload         79
        2053: invokespecial #279                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        104
        2058: new           #281                // class ocaml_fn_56
        2061: dup
        2062: aload         58
        2064: aload         74
        2066: aload         80
        2068: invokespecial #282                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2071: astore        105
        2073: new           #284                // class ocaml_fn_57
        2076: dup
        2077: aload         61
        2079: aload         74
        2081: aload         80
        2083: invokespecial #285                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        106
        2088: new           #287                // class ocaml_fn_58
        2091: dup
        2092: aload         74
        2094: aload         80
        2096: invokespecial #288                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        107
        2101: new           #290                // class ocaml_fn_59
        2104: dup
        2105: aload         74
        2107: invokespecial #291                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2110: astore        108
        2112: new           #293                // class ocaml_fn_60
        2115: dup
        2116: aload         70
        2118: aload         72
        2120: aload         93
        2122: invokespecial #294                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        109
        2127: new           #296                // class ocaml_fn_61
        2130: dup
        2131: aload         109
        2133: invokespecial #297                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2136: astore        110
        2138: new           #299                // class ocaml_fn_62
        2141: dup
        2142: aload         59
        2144: aload         109
        2146: invokespecial #300                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2149: astore        111
        2151: new           #302                // class ocaml_fn_63
        2154: dup
        2155: aload         109
        2157: invokespecial #303                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2160: astore        112
        2162: new           #305                // class ocaml_fn_64
        2165: dup
        2166: aload         62
        2168: aload         109
        2170: invokespecial #306                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        113
        2175: new           #308                // class ocaml_fn_65
        2178: dup
        2179: invokespecial #309                // Method ocaml_fn_65."<init>":()V
        2182: astore        114
        2184: new           #311                // class ocaml_fn_66
        2187: dup
        2188: aload         53
        2190: invokespecial #312                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2193: astore        115
        2195: new           #2                  // class Block
        2198: dup
        2199: iconst_0
        2200: iconst_1
        2201: anewarray     #4                  // class java/lang/Object
        2204: dup
        2205: iconst_0
        2206: aload         78
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        116
        2214: new           #314                // class ocaml_fn_67
        2217: dup
        2218: aload         116
        2220: invokespecial #315                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2223: astore        117
        2225: new           #317                // class ocaml_fn_68
        2228: dup
        2229: invokespecial #318                // Method ocaml_fn_68."<init>":()V
        2232: astore        118
        2234: new           #2                  // class Block
        2237: dup
        2238: iconst_0
        2239: iconst_1
        2240: anewarray     #4                  // class java/lang/Object
        2243: dup
        2244: iconst_0
        2245: aload         118
        2247: aastore
        2248: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2251: astore        119
        2253: new           #320                // class ocaml_fn_69
        2256: dup
        2257: aload         116
        2259: aload         119
        2261: invokespecial #321                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        120
        2266: new           #323                // class ocaml_fn_70
        2269: dup
        2270: aload         120
        2272: invokespecial #324                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2275: astore        121
        2277: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2280: bipush        44
        2282: aaload
        2283: astore        122
        2285: iconst_0
        2286: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2289: astore        123
        2291: new           #326                // class ocaml_fn_71
        2294: dup
        2295: invokespecial #327                // Method ocaml_fn_71."<init>":()V
        2298: astore        124
        2300: new           #329                // class ocaml_fn_72
        2303: dup
        2304: invokespecial #330                // Method ocaml_fn_72."<init>":()V
        2307: astore        125
        2309: new           #332                // class ocaml_fn_73
        2312: dup
        2313: invokespecial #333                // Method ocaml_fn_73."<init>":()V
        2316: astore        126
        2318: new           #335                // class ocaml_fn_74
        2321: dup
        2322: invokespecial #336                // Method ocaml_fn_74."<init>":()V
        2325: astore        127
        2327: new           #338                // class ocaml_fn_75
        2330: dup
        2331: invokespecial #339                // Method ocaml_fn_75."<init>":()V
        2334: astore        128
        2336: new           #341                // class ocaml_fn_76
        2339: dup
        2340: invokespecial #342                // Method ocaml_fn_76."<init>":()V
        2343: astore        129
        2345: new           #2                  // class Block
        2348: dup
        2349: iconst_0
        2350: bipush        6
        2352: anewarray     #4                  // class java/lang/Object
        2355: dup
        2356: iconst_0
        2357: aload         129
        2359: aastore
        2360: dup
        2361: iconst_1
        2362: aload         128
        2364: aastore
        2365: dup
        2366: iconst_2
        2367: aload         127
        2369: aastore
        2370: dup
        2371: iconst_3
        2372: aload         126
        2374: aastore
        2375: dup
        2376: iconst_4
        2377: aload         125
        2379: aastore
        2380: dup
        2381: iconst_5
        2382: aload         124
        2384: aastore
        2385: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2388: astore        130
        2390: new           #344                // class ocaml_fn_77
        2393: dup
        2394: invokespecial #345                // Method ocaml_fn_77."<init>":()V
        2397: astore        131
        2399: new           #347                // class ocaml_fn_78
        2402: dup
        2403: invokespecial #348                // Method ocaml_fn_78."<init>":()V
        2406: astore        132
        2408: new           #350                // class ocaml_fn_79
        2411: dup
        2412: invokespecial #351                // Method ocaml_fn_79."<init>":()V
        2415: astore        133
        2417: new           #353                // class ocaml_fn_80
        2420: dup
        2421: invokespecial #354                // Method ocaml_fn_80."<init>":()V
        2424: astore        134
        2426: new           #356                // class ocaml_fn_81
        2429: dup
        2430: invokespecial #357                // Method ocaml_fn_81."<init>":()V
        2433: astore        135
        2435: new           #359                // class ocaml_fn_82
        2438: dup
        2439: invokespecial #360                // Method ocaml_fn_82."<init>":()V
        2442: astore        136
        2444: new           #362                // class ocaml_fn_83
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_83."<init>":()V
        2451: astore        137
        2453: new           #365                // class ocaml_fn_84
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_84."<init>":()V
        2460: astore        138
        2462: new           #368                // class ocaml_fn_85
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_85."<init>":()V
        2469: astore        139
        2471: new           #371                // class ocaml_fn_86
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_86."<init>":()V
        2478: astore        140
        2480: new           #374                // class ocaml_fn_87
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_87."<init>":()V
        2487: astore        141
        2489: new           #377                // class ocaml_fn_88
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_88."<init>":()V
        2496: astore        142
        2498: new           #380                // class ocaml_fn_89
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_89."<init>":()V
        2505: astore        143
        2507: new           #383                // class ocaml_fn_90
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_90."<init>":()V
        2514: astore        144
        2516: new           #386                // class ocaml_fn_91
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_91."<init>":()V
        2523: astore        145
        2525: new           #389                // class ocaml_fn_92
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_92."<init>":()V
        2532: astore        146
        2534: new           #392                // class ocaml_fn_93
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_93."<init>":()V
        2541: astore        147
        2543: new           #2                  // class Block
        2546: dup
        2547: iconst_0
        2548: bipush        104
        2550: anewarray     #4                  // class java/lang/Object
        2553: dup
        2554: iconst_0
        2555: aload         18
        2557: aastore
        2558: dup
        2559: iconst_1
        2560: aload         17
        2562: aastore
        2563: dup
        2564: iconst_2
        2565: aload         22
        2567: aastore
        2568: dup
        2569: iconst_3
        2570: aload         23
        2572: aastore
        2573: dup
        2574: iconst_4
        2575: aload         24
        2577: aastore
        2578: dup
        2579: iconst_5
        2580: aload         25
        2582: aastore
        2583: dup
        2584: bipush        6
        2586: aload         26
        2588: aastore
        2589: dup
        2590: bipush        7
        2592: aload         27
        2594: aastore
        2595: dup
        2596: bipush        8
        2598: aload         28
        2600: aastore
        2601: dup
        2602: bipush        9
        2604: aload         29
        2606: aastore
        2607: dup
        2608: bipush        10
        2610: aload         30
        2612: aastore
        2613: dup
        2614: bipush        11
        2616: aload         31
        2618: aastore
        2619: dup
        2620: bipush        12
        2622: aload         32
        2624: aastore
        2625: dup
        2626: bipush        13
        2628: aload         33
        2630: aastore
        2631: dup
        2632: bipush        14
        2634: aload         34
        2636: aastore
        2637: dup
        2638: bipush        15
        2640: aload         35
        2642: aastore
        2643: dup
        2644: bipush        16
        2646: aload         36
        2648: aastore
        2649: dup
        2650: bipush        17
        2652: aload         37
        2654: aastore
        2655: dup
        2656: bipush        18
        2658: iload         39
        2660: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2663: aastore
        2664: dup
        2665: bipush        19
        2667: iload         40
        2669: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2672: aastore
        2673: dup
        2674: bipush        20
        2676: aload         38
        2678: aastore
        2679: dup
        2680: bipush        21
        2682: aload         42
        2684: aastore
        2685: dup
        2686: bipush        22
        2688: aload         44
        2690: aastore
        2691: dup
        2692: bipush        23
        2694: aload         46
        2696: aastore
        2697: dup
        2698: bipush        24
        2700: aload         48
        2702: aastore
        2703: dup
        2704: bipush        25
        2706: aload         50
        2708: aastore
        2709: dup
        2710: bipush        26
        2712: aload         52
        2714: aastore
        2715: dup
        2716: bipush        27
        2718: aload         53
        2720: aastore
        2721: dup
        2722: bipush        28
        2724: aload         54
        2726: aastore
        2727: dup
        2728: bipush        29
        2730: aload         55
        2732: aastore
        2733: dup
        2734: bipush        30
        2736: aload         57
        2738: aastore
        2739: dup
        2740: bipush        31
        2742: aload         56
        2744: aastore
        2745: dup
        2746: bipush        32
        2748: aload         58
        2750: aastore
        2751: dup
        2752: bipush        33
        2754: aload         59
        2756: aastore
        2757: dup
        2758: bipush        34
        2760: aload         61
        2762: aastore
        2763: dup
        2764: bipush        35
        2766: aload         62
        2768: aastore
        2769: dup
        2770: bipush        36
        2772: aload         63
        2774: aastore
        2775: dup
        2776: bipush        37
        2778: aload         70
        2780: aastore
        2781: dup
        2782: bipush        38
        2784: aload         72
        2786: aastore
        2787: dup
        2788: bipush        39
        2790: aload         74
        2792: aastore
        2793: dup
        2794: bipush        40
        2796: aload         95
        2798: aastore
        2799: dup
        2800: bipush        41
        2802: aload         96
        2804: aastore
        2805: dup
        2806: bipush        42
        2808: aload         97
        2810: aastore
        2811: dup
        2812: bipush        43
        2814: aload         98
        2816: aastore
        2817: dup
        2818: bipush        44
        2820: aload         99
        2822: aastore
        2823: dup
        2824: bipush        45
        2826: aload         100
        2828: aastore
        2829: dup
        2830: bipush        46
        2832: aload         101
        2834: aastore
        2835: dup
        2836: bipush        47
        2838: aload         102
        2840: aastore
        2841: dup
        2842: bipush        48
        2844: aload         103
        2846: aastore
        2847: dup
        2848: bipush        49
        2850: aload         104
        2852: aastore
        2853: dup
        2854: bipush        50
        2856: aload         105
        2858: aastore
        2859: dup
        2860: bipush        51
        2862: aload         106
        2864: aastore
        2865: dup
        2866: bipush        52
        2868: aload         107
        2870: aastore
        2871: dup
        2872: bipush        53
        2874: aload         108
        2876: aastore
        2877: dup
        2878: bipush        54
        2880: aload         109
        2882: aastore
        2883: dup
        2884: bipush        55
        2886: aload         111
        2888: aastore
        2889: dup
        2890: bipush        56
        2892: aload         110
        2894: aastore
        2895: dup
        2896: bipush        57
        2898: aload         113
        2900: aastore
        2901: dup
        2902: bipush        58
        2904: aload         112
        2906: aastore
        2907: dup
        2908: bipush        59
        2910: aload         76
        2912: aastore
        2913: dup
        2914: bipush        60
        2916: aload         77
        2918: aastore
        2919: dup
        2920: bipush        61
        2922: aload         75
        2924: aastore
        2925: dup
        2926: bipush        62
        2928: aload         147
        2930: aastore
        2931: dup
        2932: bipush        63
        2934: aload         78
        2936: aastore
        2937: dup
        2938: bipush        64
        2940: aload         146
        2942: aastore
        2943: dup
        2944: bipush        65
        2946: aload         80
        2948: aastore
        2949: dup
        2950: bipush        66
        2952: aload         79
        2954: aastore
        2955: dup
        2956: bipush        67
        2958: aload         81
        2960: aastore
        2961: dup
        2962: bipush        68
        2964: aload         82
        2966: aastore
        2967: dup
        2968: bipush        69
        2970: aload         145
        2972: aastore
        2973: dup
        2974: bipush        70
        2976: aload         144
        2978: aastore
        2979: dup
        2980: bipush        71
        2982: aload         83
        2984: aastore
        2985: dup
        2986: bipush        72
        2988: aload         143
        2990: aastore
        2991: dup
        2992: bipush        73
        2994: aload         142
        2996: aastore
        2997: dup
        2998: bipush        74
        3000: aload         141
        3002: aastore
        3003: dup
        3004: bipush        75
        3006: aload         84
        3008: aastore
        3009: dup
        3010: bipush        76
        3012: aload         85
        3014: aastore
        3015: dup
        3016: bipush        77
        3018: aload         140
        3020: aastore
        3021: dup
        3022: bipush        78
        3024: aload         87
        3026: aastore
        3027: dup
        3028: bipush        79
        3030: aload         88
        3032: aastore
        3033: dup
        3034: bipush        80
        3036: aload         86
        3038: aastore
        3039: dup
        3040: bipush        81
        3042: aload         139
        3044: aastore
        3045: dup
        3046: bipush        82
        3048: aload         93
        3050: aastore
        3051: dup
        3052: bipush        83
        3054: aload         89
        3056: aastore
        3057: dup
        3058: bipush        84
        3060: aload         91
        3062: aastore
        3063: dup
        3064: bipush        85
        3066: aload         92
        3068: aastore
        3069: dup
        3070: bipush        86
        3072: aload         138
        3074: aastore
        3075: dup
        3076: bipush        87
        3078: aload         137
        3080: aastore
        3081: dup
        3082: bipush        88
        3084: aload         136
        3086: aastore
        3087: dup
        3088: bipush        89
        3090: aload         135
        3092: aastore
        3093: dup
        3094: bipush        90
        3096: aload         134
        3098: aastore
        3099: dup
        3100: bipush        91
        3102: aload         133
        3104: aastore
        3105: dup
        3106: bipush        92
        3108: aload         132
        3110: aastore
        3111: dup
        3112: bipush        93
        3114: aload         94
        3116: aastore
        3117: dup
        3118: bipush        94
        3120: aload         131
        3122: aastore
        3123: dup
        3124: bipush        95
        3126: aload         130
        3128: aastore
        3129: dup
        3130: bipush        96
        3132: aload         114
        3134: aastore
        3135: dup
        3136: bipush        97
        3138: aload         115
        3140: aastore
        3141: dup
        3142: bipush        98
        3144: aload         121
        3146: aastore
        3147: dup
        3148: bipush        99
        3150: aload         117
        3152: aastore
        3153: dup
        3154: bipush        100
        3156: aload         60
        3158: aastore
        3159: dup
        3160: bipush        101
        3162: aload         90
        3164: aastore
        3165: dup
        3166: bipush        102
        3168: aload         120
        3170: aastore
        3171: dup
        3172: bipush        103
        3174: aload         119
        3176: aastore
        3177: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3180: astore        148
        3182: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3185: bipush        45
        3187: aload         148
        3189: aastore
        3190: iconst_0
        3191: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3194: astore        149
        3196: bipush        8
        3198: istore        150
        3200: getstatic     #397                // Field java/lang/System.out:Ljava/io/PrintStream;
        3203: iload         150
        3205: invokevirtual #403                // Method java/io/PrintStream.println:(I)V
        3208: iconst_0
        3209: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3212: astore        151
        3214: new           #2                  // class Block
        3217: dup
        3218: iconst_0
        3219: iconst_0
        3220: anewarray     #4                  // class java/lang/Object
        3223: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3226: astore        152
        3228: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3231: bipush        46
        3233: aload         152
        3235: aastore
        3236: iconst_0
        3237: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3240: astore        153
        3242: iconst_0
        3243: istore        154
        3245: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3248: bipush        45
        3250: aaload
        3251: checkcast     #2                  // class Block
        3254: getfield      #406                // Field Block.fields:[Ljava/lang/Object;
        3257: bipush        102
        3259: aaload
        3260: astore        155
        3262: aload         155
        3264: checkcast     #170                // class Closure
        3267: iload         154
        3269: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3272: invokevirtual #410                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3275: astore        156
        3277: new           #2                  // class Block
        3280: dup
        3281: iconst_0
        3282: iconst_0
        3283: anewarray     #4                  // class java/lang/Object
        3286: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3289: astore        157
        3291: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3294: bipush        47
        3296: aload         157
        3298: aastore
        3299: iconst_0
        3300: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3303: astore        158
        3305: return
    }
    |}]

let%expect_test "emission: closure with a captured int" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkadder n = fun x -> x + n
       let () =
         let add10 = mkadder 10 in
         caml_java_print_int (add10 32) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        48
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: iconst_0
        1041: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1044: aastore
        1045: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1048: bipush        47
        1050: iconst_0
        1051: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1054: aastore
        1055: aconst_null
        1056: astore_1
        1057: aload_1
        1058: astore_2
        1059: goto_w        1064
        1064: new           #94                 // class ocaml_fn_0
        1067: dup
        1068: invokespecial #97                 // Method ocaml_fn_0."<init>":()V
        1071: astore_3
        1072: new           #99                 // class ocaml_fn_1
        1075: dup
        1076: invokespecial #100                // Method ocaml_fn_1."<init>":()V
        1079: astore        4
        1081: new           #102                // class ocaml_fn_2
        1084: dup
        1085: invokespecial #103                // Method ocaml_fn_2."<init>":()V
        1088: astore        5
        1090: new           #2                  // class Block
        1093: dup
        1094: iconst_0
        1095: iconst_3
        1096: anewarray     #4                  // class java/lang/Object
        1099: dup
        1100: iconst_0
        1101: aload         4
        1103: aastore
        1104: dup
        1105: iconst_1
        1106: aload_3
        1107: aastore
        1108: dup
        1109: iconst_2
        1110: aload         5
        1112: aastore
        1113: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1116: astore        6
        1118: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1121: bipush        12
        1123: aload         6
        1125: aastore
        1126: iconst_0
        1127: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1130: astore        7
        1132: iconst_0
        1133: istore        8
        1135: iload         8
        1137: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1140: astore        9
        1142: goto_w        1147
        1147: sipush        199
        1150: istore        10
        1152: iconst_0
        1153: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1156: astore        11
        1158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1161: bipush        35
        1163: aaload
        1164: astore        12
        1166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1169: iconst_3
        1170: aaload
        1171: astore        13
        1173: new           #2                  // class Block
        1176: dup
        1177: iconst_0
        1178: iconst_2
        1179: anewarray     #4                  // class java/lang/Object
        1182: dup
        1183: iconst_0
        1184: aload         13
        1186: aastore
        1187: dup
        1188: iconst_1
        1189: aload         12
        1191: aastore
        1192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1195: astore        14
        1197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1200: bipush        36
        1202: aaload
        1203: astore        15
        1205: iconst_0
        1206: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1209: astore        16
        1211: new           #105                // class ocaml_fn_8
        1214: dup
        1215: invokespecial #106                // Method ocaml_fn_8."<init>":()V
        1218: astore        17
        1220: new           #108                // class ocaml_fn_9
        1223: dup
        1224: invokespecial #109                // Method ocaml_fn_9."<init>":()V
        1227: astore        18
        1229: iconst_0
        1230: istore        19
        1232: iconst_0
        1233: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1236: astore        20
        1238: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        37
        1243: aaload
        1244: astore        21
        1246: new           #2                  // class Block
        1249: dup
        1250: sipush        248
        1253: iconst_2
        1254: anewarray     #4                  // class java/lang/Object
        1257: dup
        1258: iconst_0
        1259: aload         21
        1261: aastore
        1262: dup
        1263: iconst_1
        1264: aload         20
        1266: aastore
        1267: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1270: astore        22
        1272: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1275: bipush        7
        1277: aaload
        1278: astore        23
        1280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1283: bipush        10
        1285: aaload
        1286: astore        24
        1288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1291: iconst_3
        1292: aaload
        1293: astore        25
        1295: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1298: iconst_2
        1299: aaload
        1300: astore        26
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        6
        1307: aaload
        1308: astore        27
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: iconst_0
        1314: aaload
        1315: astore        28
        1317: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1320: bipush        8
        1322: aaload
        1323: astore        29
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: iconst_1
        1329: aaload
        1330: astore        30
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: iconst_4
        1336: aaload
        1337: astore        31
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_5
        1343: aaload
        1344: astore        32
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: bipush        9
        1351: aaload
        1352: astore        33
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: bipush        11
        1359: aaload
        1360: astore        34
        1362: new           #111                // class ocaml_fn_10
        1365: dup
        1366: invokespecial #112                // Method ocaml_fn_10."<init>":()V
        1369: astore        35
        1371: new           #114                // class ocaml_fn_11
        1374: dup
        1375: invokespecial #115                // Method ocaml_fn_11."<init>":()V
        1378: astore        36
        1380: new           #117                // class ocaml_fn_12
        1383: dup
        1384: invokespecial #118                // Method ocaml_fn_12."<init>":()V
        1387: astore        37
        1389: new           #120                // class ocaml_fn_13
        1392: dup
        1393: invokespecial #121                // Method ocaml_fn_13."<init>":()V
        1396: astore        38
        1398: ldc           #122                // int 2147483647
        1400: istore        39
        1402: ldc           #123                // int -2147483648
        1404: istore        40
        1406: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1409: bipush        38
        1411: aaload
        1412: astore        41
        1414: ldc2_w        #124                // double 0.0d
        1417: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1420: astore        42
        1422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1425: bipush        39
        1427: aaload
        1428: astore        43
        1430: ldc2_w        #124                // double 0.0d
        1433: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1436: astore        44
        1438: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1441: bipush        40
        1443: aaload
        1444: astore        45
        1446: ldc2_w        #124                // double 0.0d
        1449: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1452: astore        46
        1454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1457: bipush        41
        1459: aaload
        1460: astore        47
        1462: ldc2_w        #124                // double 0.0d
        1465: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        48
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        42
        1475: aaload
        1476: astore        49
        1478: ldc2_w        #124                // double 0.0d
        1481: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1484: astore        50
        1486: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1489: bipush        43
        1491: aaload
        1492: astore        51
        1494: ldc2_w        #124                // double 0.0d
        1497: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1500: astore        52
        1502: new           #132                // class ocaml_fn_14
        1505: dup
        1506: invokespecial #133                // Method ocaml_fn_14."<init>":()V
        1509: astore        53
        1511: new           #135                // class ocaml_fn_15
        1514: dup
        1515: aload         18
        1517: invokespecial #138                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1520: astore        54
        1522: new           #140                // class ocaml_fn_16
        1525: dup
        1526: invokespecial #141                // Method ocaml_fn_16."<init>":()V
        1529: astore        55
        1531: new           #143                // class ocaml_fn_17
        1534: dup
        1535: aload         18
        1537: invokespecial #144                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1540: astore        56
        1542: new           #146                // class ocaml_fn_18
        1545: dup
        1546: invokespecial #147                // Method ocaml_fn_18."<init>":()V
        1549: astore        57
        1551: new           #149                // class ocaml_fn_19
        1554: dup
        1555: invokespecial #150                // Method ocaml_fn_19."<init>":()V
        1558: astore        58
        1560: new           #152                // class ocaml_fn_20
        1563: dup
        1564: aload         26
        1566: invokespecial #153                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1569: astore        59
        1571: new           #155                // class ocaml_fn_21
        1574: dup
        1575: aload         53
        1577: invokespecial #156                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1580: astore        60
        1582: new           #158                // class ocaml_fn_22
        1585: dup
        1586: aload         60
        1588: invokespecial #159                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1591: astore        61
        1593: new           #161                // class ocaml_fn_23
        1596: dup
        1597: aload         26
        1599: invokespecial #162                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1602: astore        62
        1604: new           #164                // class ocaml_fn_24
        1607: dup
        1608: invokespecial #165                // Method ocaml_fn_24."<init>":()V
        1611: astore        63
        1613: new           #167                // class ocaml_fn_25
        1616: dup
        1617: invokespecial #168                // Method ocaml_fn_25."<init>":()V
        1620: astore        64
        1622: aload         63
        1624: checkcast     #164                // class ocaml_fn_24
        1627: aload         63
        1629: checkcast     #170                // class Closure
        1632: putfield      #174                // Field ocaml_fn_24.sibling_0:LClosure;
        1635: iconst_0
        1636: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1639: astore        65
        1641: aload         63
        1643: checkcast     #164                // class ocaml_fn_24
        1646: aload         64
        1648: checkcast     #170                // class Closure
        1651: putfield      #177                // Field ocaml_fn_24.sibling_1:LClosure;
        1654: iconst_0
        1655: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        66
        1660: aload         64
        1662: checkcast     #167                // class ocaml_fn_25
        1665: aload         63
        1667: checkcast     #170                // class Closure
        1670: putfield      #178                // Field ocaml_fn_25.sibling_0:LClosure;
        1673: iconst_0
        1674: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        67
        1679: aload         64
        1681: checkcast     #167                // class ocaml_fn_25
        1684: aload         64
        1686: checkcast     #170                // class Closure
        1689: putfield      #179                // Field ocaml_fn_25.sibling_1:LClosure;
        1692: iconst_0
        1693: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        68
        1698: iconst_0
        1699: istore        69
        1701: aconst_null
        1702: astore        70
        1704: iconst_1
        1705: istore        71
        1707: iload         71
        1709: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1712: astore        72
        1714: iconst_2
        1715: istore        73
        1717: iload         73
        1719: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1722: astore        74
        1724: new           #187                // class ocaml_fn_26
        1727: dup
        1728: invokespecial #188                // Method ocaml_fn_26."<init>":()V
        1731: astore        75
        1733: new           #190                // class ocaml_fn_27
        1736: dup
        1737: aload         75
        1739: invokespecial #191                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1742: astore        76
        1744: new           #193                // class ocaml_fn_28
        1747: dup
        1748: aload         75
        1750: invokespecial #194                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1753: astore        77
        1755: new           #196                // class ocaml_fn_29
        1758: dup
        1759: aload         30
        1761: invokespecial #197                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1764: astore        78
        1766: new           #199                // class ocaml_fn_30
        1769: dup
        1770: invokespecial #200                // Method ocaml_fn_30."<init>":()V
        1773: astore        79
        1775: new           #202                // class ocaml_fn_31
        1778: dup
        1779: invokespecial #203                // Method ocaml_fn_31."<init>":()V
        1782: astore        80
        1784: new           #205                // class ocaml_fn_32
        1787: dup
        1788: aload         18
        1790: invokespecial #206                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1793: astore        81
        1795: new           #208                // class ocaml_fn_33
        1798: dup
        1799: aload         18
        1801: invokespecial #209                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1804: astore        82
        1806: new           #211                // class ocaml_fn_34
        1809: dup
        1810: invokespecial #212                // Method ocaml_fn_34."<init>":()V
        1813: astore        83
        1815: new           #214                // class ocaml_fn_35
        1818: dup
        1819: invokespecial #215                // Method ocaml_fn_35."<init>":()V
        1822: astore        84
        1824: new           #217                // class ocaml_fn_36
        1827: dup
        1828: invokespecial #218                // Method ocaml_fn_36."<init>":()V
        1831: astore        85
        1833: new           #220                // class ocaml_fn_37
        1836: dup
        1837: invokespecial #221                // Method ocaml_fn_37."<init>":()V
        1840: astore        86
        1842: new           #223                // class ocaml_fn_38
        1845: dup
        1846: aload         86
        1848: invokespecial #224                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1851: astore        87
        1853: new           #226                // class ocaml_fn_39
        1856: dup
        1857: aload         86
        1859: invokespecial #227                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1862: astore        88
        1864: new           #229                // class ocaml_fn_40
        1867: dup
        1868: aload         18
        1870: invokespecial #230                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1873: astore        89
        1875: new           #232                // class ocaml_fn_41
        1878: dup
        1879: aload         31
        1881: invokespecial #233                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1884: astore        90
        1886: new           #235                // class ocaml_fn_42
        1889: dup
        1890: aload         18
        1892: aload         90
        1894: invokespecial #238                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1897: astore        91
        1899: new           #240                // class ocaml_fn_43
        1902: dup
        1903: aload         91
        1905: invokespecial #241                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1908: astore        92
        1910: new           #243                // class ocaml_fn_44
        1913: dup
        1914: aload         31
        1916: invokespecial #244                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1919: astore        93
        1921: new           #246                // class ocaml_fn_45
        1924: dup
        1925: invokespecial #247                // Method ocaml_fn_45."<init>":()V
        1928: astore        94
        1930: new           #249                // class ocaml_fn_46
        1933: dup
        1934: aload         72
        1936: invokespecial #250                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1939: astore        95
        1941: new           #252                // class ocaml_fn_47
        1944: dup
        1945: aload         72
        1947: aload         80
        1949: invokespecial #253                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        96
        1954: new           #255                // class ocaml_fn_48
        1957: dup
        1958: aload         72
        1960: aload         79
        1962: invokespecial #256                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1965: astore        97
        1967: new           #258                // class ocaml_fn_49
        1970: dup
        1971: aload         58
        1973: aload         72
        1975: aload         80
        1977: invokespecial #261                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1980: astore        98
        1982: new           #263                // class ocaml_fn_50
        1985: dup
        1986: aload         61
        1988: aload         72
        1990: aload         80
        1992: invokespecial #264                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1995: astore        99
        1997: new           #266                // class ocaml_fn_51
        2000: dup
        2001: aload         72
        2003: aload         80
        2005: invokespecial #267                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        100
        2010: new           #269                // class ocaml_fn_52
        2013: dup
        2014: aload         72
        2016: invokespecial #270                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2019: astore        101
        2021: new           #272                // class ocaml_fn_53
        2024: dup
        2025: aload         74
        2027: invokespecial #273                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2030: astore        102
        2032: new           #275                // class ocaml_fn_54
        2035: dup
        2036: aload         74
        2038: aload         80
        2040: invokespecial #276                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        103
        2045: new           #278                // class ocaml_fn_55
        2048: dup
        2049: aload         74
        2051: aload         79
        2053: invokespecial #279                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        104
        2058: new           #281                // class ocaml_fn_56
        2061: dup
        2062: aload         58
        2064: aload         74
        2066: aload         80
        2068: invokespecial #282                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2071: astore        105
        2073: new           #284                // class ocaml_fn_57
        2076: dup
        2077: aload         61
        2079: aload         74
        2081: aload         80
        2083: invokespecial #285                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        106
        2088: new           #287                // class ocaml_fn_58
        2091: dup
        2092: aload         74
        2094: aload         80
        2096: invokespecial #288                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        107
        2101: new           #290                // class ocaml_fn_59
        2104: dup
        2105: aload         74
        2107: invokespecial #291                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2110: astore        108
        2112: new           #293                // class ocaml_fn_60
        2115: dup
        2116: aload         70
        2118: aload         72
        2120: aload         93
        2122: invokespecial #294                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        109
        2127: new           #296                // class ocaml_fn_61
        2130: dup
        2131: aload         109
        2133: invokespecial #297                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2136: astore        110
        2138: new           #299                // class ocaml_fn_62
        2141: dup
        2142: aload         59
        2144: aload         109
        2146: invokespecial #300                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2149: astore        111
        2151: new           #302                // class ocaml_fn_63
        2154: dup
        2155: aload         109
        2157: invokespecial #303                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2160: astore        112
        2162: new           #305                // class ocaml_fn_64
        2165: dup
        2166: aload         62
        2168: aload         109
        2170: invokespecial #306                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        113
        2175: new           #308                // class ocaml_fn_65
        2178: dup
        2179: invokespecial #309                // Method ocaml_fn_65."<init>":()V
        2182: astore        114
        2184: new           #311                // class ocaml_fn_66
        2187: dup
        2188: aload         53
        2190: invokespecial #312                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2193: astore        115
        2195: new           #2                  // class Block
        2198: dup
        2199: iconst_0
        2200: iconst_1
        2201: anewarray     #4                  // class java/lang/Object
        2204: dup
        2205: iconst_0
        2206: aload         78
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        116
        2214: new           #314                // class ocaml_fn_67
        2217: dup
        2218: aload         116
        2220: invokespecial #315                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2223: astore        117
        2225: new           #317                // class ocaml_fn_68
        2228: dup
        2229: invokespecial #318                // Method ocaml_fn_68."<init>":()V
        2232: astore        118
        2234: new           #2                  // class Block
        2237: dup
        2238: iconst_0
        2239: iconst_1
        2240: anewarray     #4                  // class java/lang/Object
        2243: dup
        2244: iconst_0
        2245: aload         118
        2247: aastore
        2248: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2251: astore        119
        2253: new           #320                // class ocaml_fn_69
        2256: dup
        2257: aload         116
        2259: aload         119
        2261: invokespecial #321                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        120
        2266: new           #323                // class ocaml_fn_70
        2269: dup
        2270: aload         120
        2272: invokespecial #324                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2275: astore        121
        2277: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2280: bipush        44
        2282: aaload
        2283: astore        122
        2285: iconst_0
        2286: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2289: astore        123
        2291: new           #326                // class ocaml_fn_71
        2294: dup
        2295: invokespecial #327                // Method ocaml_fn_71."<init>":()V
        2298: astore        124
        2300: new           #329                // class ocaml_fn_72
        2303: dup
        2304: invokespecial #330                // Method ocaml_fn_72."<init>":()V
        2307: astore        125
        2309: new           #332                // class ocaml_fn_73
        2312: dup
        2313: invokespecial #333                // Method ocaml_fn_73."<init>":()V
        2316: astore        126
        2318: new           #335                // class ocaml_fn_74
        2321: dup
        2322: invokespecial #336                // Method ocaml_fn_74."<init>":()V
        2325: astore        127
        2327: new           #338                // class ocaml_fn_75
        2330: dup
        2331: invokespecial #339                // Method ocaml_fn_75."<init>":()V
        2334: astore        128
        2336: new           #341                // class ocaml_fn_76
        2339: dup
        2340: invokespecial #342                // Method ocaml_fn_76."<init>":()V
        2343: astore        129
        2345: new           #2                  // class Block
        2348: dup
        2349: iconst_0
        2350: bipush        6
        2352: anewarray     #4                  // class java/lang/Object
        2355: dup
        2356: iconst_0
        2357: aload         129
        2359: aastore
        2360: dup
        2361: iconst_1
        2362: aload         128
        2364: aastore
        2365: dup
        2366: iconst_2
        2367: aload         127
        2369: aastore
        2370: dup
        2371: iconst_3
        2372: aload         126
        2374: aastore
        2375: dup
        2376: iconst_4
        2377: aload         125
        2379: aastore
        2380: dup
        2381: iconst_5
        2382: aload         124
        2384: aastore
        2385: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2388: astore        130
        2390: new           #344                // class ocaml_fn_77
        2393: dup
        2394: invokespecial #345                // Method ocaml_fn_77."<init>":()V
        2397: astore        131
        2399: new           #347                // class ocaml_fn_78
        2402: dup
        2403: invokespecial #348                // Method ocaml_fn_78."<init>":()V
        2406: astore        132
        2408: new           #350                // class ocaml_fn_79
        2411: dup
        2412: invokespecial #351                // Method ocaml_fn_79."<init>":()V
        2415: astore        133
        2417: new           #353                // class ocaml_fn_80
        2420: dup
        2421: invokespecial #354                // Method ocaml_fn_80."<init>":()V
        2424: astore        134
        2426: new           #356                // class ocaml_fn_81
        2429: dup
        2430: invokespecial #357                // Method ocaml_fn_81."<init>":()V
        2433: astore        135
        2435: new           #359                // class ocaml_fn_82
        2438: dup
        2439: invokespecial #360                // Method ocaml_fn_82."<init>":()V
        2442: astore        136
        2444: new           #362                // class ocaml_fn_83
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_83."<init>":()V
        2451: astore        137
        2453: new           #365                // class ocaml_fn_84
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_84."<init>":()V
        2460: astore        138
        2462: new           #368                // class ocaml_fn_85
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_85."<init>":()V
        2469: astore        139
        2471: new           #371                // class ocaml_fn_86
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_86."<init>":()V
        2478: astore        140
        2480: new           #374                // class ocaml_fn_87
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_87."<init>":()V
        2487: astore        141
        2489: new           #377                // class ocaml_fn_88
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_88."<init>":()V
        2496: astore        142
        2498: new           #380                // class ocaml_fn_89
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_89."<init>":()V
        2505: astore        143
        2507: new           #383                // class ocaml_fn_90
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_90."<init>":()V
        2514: astore        144
        2516: new           #386                // class ocaml_fn_91
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_91."<init>":()V
        2523: astore        145
        2525: new           #389                // class ocaml_fn_92
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_92."<init>":()V
        2532: astore        146
        2534: new           #392                // class ocaml_fn_93
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_93."<init>":()V
        2541: astore        147
        2543: new           #2                  // class Block
        2546: dup
        2547: iconst_0
        2548: bipush        104
        2550: anewarray     #4                  // class java/lang/Object
        2553: dup
        2554: iconst_0
        2555: aload         18
        2557: aastore
        2558: dup
        2559: iconst_1
        2560: aload         17
        2562: aastore
        2563: dup
        2564: iconst_2
        2565: aload         22
        2567: aastore
        2568: dup
        2569: iconst_3
        2570: aload         23
        2572: aastore
        2573: dup
        2574: iconst_4
        2575: aload         24
        2577: aastore
        2578: dup
        2579: iconst_5
        2580: aload         25
        2582: aastore
        2583: dup
        2584: bipush        6
        2586: aload         26
        2588: aastore
        2589: dup
        2590: bipush        7
        2592: aload         27
        2594: aastore
        2595: dup
        2596: bipush        8
        2598: aload         28
        2600: aastore
        2601: dup
        2602: bipush        9
        2604: aload         29
        2606: aastore
        2607: dup
        2608: bipush        10
        2610: aload         30
        2612: aastore
        2613: dup
        2614: bipush        11
        2616: aload         31
        2618: aastore
        2619: dup
        2620: bipush        12
        2622: aload         32
        2624: aastore
        2625: dup
        2626: bipush        13
        2628: aload         33
        2630: aastore
        2631: dup
        2632: bipush        14
        2634: aload         34
        2636: aastore
        2637: dup
        2638: bipush        15
        2640: aload         35
        2642: aastore
        2643: dup
        2644: bipush        16
        2646: aload         36
        2648: aastore
        2649: dup
        2650: bipush        17
        2652: aload         37
        2654: aastore
        2655: dup
        2656: bipush        18
        2658: iload         39
        2660: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2663: aastore
        2664: dup
        2665: bipush        19
        2667: iload         40
        2669: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2672: aastore
        2673: dup
        2674: bipush        20
        2676: aload         38
        2678: aastore
        2679: dup
        2680: bipush        21
        2682: aload         42
        2684: aastore
        2685: dup
        2686: bipush        22
        2688: aload         44
        2690: aastore
        2691: dup
        2692: bipush        23
        2694: aload         46
        2696: aastore
        2697: dup
        2698: bipush        24
        2700: aload         48
        2702: aastore
        2703: dup
        2704: bipush        25
        2706: aload         50
        2708: aastore
        2709: dup
        2710: bipush        26
        2712: aload         52
        2714: aastore
        2715: dup
        2716: bipush        27
        2718: aload         53
        2720: aastore
        2721: dup
        2722: bipush        28
        2724: aload         54
        2726: aastore
        2727: dup
        2728: bipush        29
        2730: aload         55
        2732: aastore
        2733: dup
        2734: bipush        30
        2736: aload         57
        2738: aastore
        2739: dup
        2740: bipush        31
        2742: aload         56
        2744: aastore
        2745: dup
        2746: bipush        32
        2748: aload         58
        2750: aastore
        2751: dup
        2752: bipush        33
        2754: aload         59
        2756: aastore
        2757: dup
        2758: bipush        34
        2760: aload         61
        2762: aastore
        2763: dup
        2764: bipush        35
        2766: aload         62
        2768: aastore
        2769: dup
        2770: bipush        36
        2772: aload         63
        2774: aastore
        2775: dup
        2776: bipush        37
        2778: aload         70
        2780: aastore
        2781: dup
        2782: bipush        38
        2784: aload         72
        2786: aastore
        2787: dup
        2788: bipush        39
        2790: aload         74
        2792: aastore
        2793: dup
        2794: bipush        40
        2796: aload         95
        2798: aastore
        2799: dup
        2800: bipush        41
        2802: aload         96
        2804: aastore
        2805: dup
        2806: bipush        42
        2808: aload         97
        2810: aastore
        2811: dup
        2812: bipush        43
        2814: aload         98
        2816: aastore
        2817: dup
        2818: bipush        44
        2820: aload         99
        2822: aastore
        2823: dup
        2824: bipush        45
        2826: aload         100
        2828: aastore
        2829: dup
        2830: bipush        46
        2832: aload         101
        2834: aastore
        2835: dup
        2836: bipush        47
        2838: aload         102
        2840: aastore
        2841: dup
        2842: bipush        48
        2844: aload         103
        2846: aastore
        2847: dup
        2848: bipush        49
        2850: aload         104
        2852: aastore
        2853: dup
        2854: bipush        50
        2856: aload         105
        2858: aastore
        2859: dup
        2860: bipush        51
        2862: aload         106
        2864: aastore
        2865: dup
        2866: bipush        52
        2868: aload         107
        2870: aastore
        2871: dup
        2872: bipush        53
        2874: aload         108
        2876: aastore
        2877: dup
        2878: bipush        54
        2880: aload         109
        2882: aastore
        2883: dup
        2884: bipush        55
        2886: aload         111
        2888: aastore
        2889: dup
        2890: bipush        56
        2892: aload         110
        2894: aastore
        2895: dup
        2896: bipush        57
        2898: aload         113
        2900: aastore
        2901: dup
        2902: bipush        58
        2904: aload         112
        2906: aastore
        2907: dup
        2908: bipush        59
        2910: aload         76
        2912: aastore
        2913: dup
        2914: bipush        60
        2916: aload         77
        2918: aastore
        2919: dup
        2920: bipush        61
        2922: aload         75
        2924: aastore
        2925: dup
        2926: bipush        62
        2928: aload         147
        2930: aastore
        2931: dup
        2932: bipush        63
        2934: aload         78
        2936: aastore
        2937: dup
        2938: bipush        64
        2940: aload         146
        2942: aastore
        2943: dup
        2944: bipush        65
        2946: aload         80
        2948: aastore
        2949: dup
        2950: bipush        66
        2952: aload         79
        2954: aastore
        2955: dup
        2956: bipush        67
        2958: aload         81
        2960: aastore
        2961: dup
        2962: bipush        68
        2964: aload         82
        2966: aastore
        2967: dup
        2968: bipush        69
        2970: aload         145
        2972: aastore
        2973: dup
        2974: bipush        70
        2976: aload         144
        2978: aastore
        2979: dup
        2980: bipush        71
        2982: aload         83
        2984: aastore
        2985: dup
        2986: bipush        72
        2988: aload         143
        2990: aastore
        2991: dup
        2992: bipush        73
        2994: aload         142
        2996: aastore
        2997: dup
        2998: bipush        74
        3000: aload         141
        3002: aastore
        3003: dup
        3004: bipush        75
        3006: aload         84
        3008: aastore
        3009: dup
        3010: bipush        76
        3012: aload         85
        3014: aastore
        3015: dup
        3016: bipush        77
        3018: aload         140
        3020: aastore
        3021: dup
        3022: bipush        78
        3024: aload         87
        3026: aastore
        3027: dup
        3028: bipush        79
        3030: aload         88
        3032: aastore
        3033: dup
        3034: bipush        80
        3036: aload         86
        3038: aastore
        3039: dup
        3040: bipush        81
        3042: aload         139
        3044: aastore
        3045: dup
        3046: bipush        82
        3048: aload         93
        3050: aastore
        3051: dup
        3052: bipush        83
        3054: aload         89
        3056: aastore
        3057: dup
        3058: bipush        84
        3060: aload         91
        3062: aastore
        3063: dup
        3064: bipush        85
        3066: aload         92
        3068: aastore
        3069: dup
        3070: bipush        86
        3072: aload         138
        3074: aastore
        3075: dup
        3076: bipush        87
        3078: aload         137
        3080: aastore
        3081: dup
        3082: bipush        88
        3084: aload         136
        3086: aastore
        3087: dup
        3088: bipush        89
        3090: aload         135
        3092: aastore
        3093: dup
        3094: bipush        90
        3096: aload         134
        3098: aastore
        3099: dup
        3100: bipush        91
        3102: aload         133
        3104: aastore
        3105: dup
        3106: bipush        92
        3108: aload         132
        3110: aastore
        3111: dup
        3112: bipush        93
        3114: aload         94
        3116: aastore
        3117: dup
        3118: bipush        94
        3120: aload         131
        3122: aastore
        3123: dup
        3124: bipush        95
        3126: aload         130
        3128: aastore
        3129: dup
        3130: bipush        96
        3132: aload         114
        3134: aastore
        3135: dup
        3136: bipush        97
        3138: aload         115
        3140: aastore
        3141: dup
        3142: bipush        98
        3144: aload         121
        3146: aastore
        3147: dup
        3148: bipush        99
        3150: aload         117
        3152: aastore
        3153: dup
        3154: bipush        100
        3156: aload         60
        3158: aastore
        3159: dup
        3160: bipush        101
        3162: aload         90
        3164: aastore
        3165: dup
        3166: bipush        102
        3168: aload         120
        3170: aastore
        3171: dup
        3172: bipush        103
        3174: aload         119
        3176: aastore
        3177: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3180: astore        148
        3182: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3185: bipush        45
        3187: aload         148
        3189: aastore
        3190: iconst_0
        3191: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3194: astore        149
        3196: iconst_0
        3197: istore        150
        3199: iload         150
        3201: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3204: astore        151
        3206: goto_w        3211
        3211: new           #395                // class ocaml_fn_95
        3214: dup
        3215: invokespecial #396                // Method ocaml_fn_95."<init>":()V
        3218: astore        152
        3220: bipush        10
        3222: istore        153
        3224: aload         152
        3226: iload         153
        3228: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3231: invokevirtual #400                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3234: astore        154
        3236: bipush        32
        3238: istore        155
        3240: aload         154
        3242: checkcast     #170                // class Closure
        3245: iload         155
        3247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3250: invokevirtual #400                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3253: astore        156
        3255: getstatic     #404                // Field java/lang/System.out:Ljava/io/PrintStream;
        3258: aload         156
        3260: checkcast     #29                 // class java/lang/Integer
        3263: invokevirtual #408                // Method java/lang/Integer.intValue:()I
        3266: invokevirtual #414                // Method java/io/PrintStream.println:(I)V
        3269: iconst_0
        3270: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3273: astore        157
        3275: new           #2                  // class Block
        3278: dup
        3279: iconst_0
        3280: iconst_1
        3281: anewarray     #4                  // class java/lang/Object
        3284: dup
        3285: iconst_0
        3286: aload         152
        3288: aastore
        3289: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3292: astore        158
        3294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3297: bipush        46
        3299: aload         158
        3301: aastore
        3302: iconst_0
        3303: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3306: astore        159
        3308: iconst_0
        3309: istore        160
        3311: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3314: bipush        45
        3316: aaload
        3317: checkcast     #2                  // class Block
        3320: getfield      #417                // Field Block.fields:[Ljava/lang/Object;
        3323: bipush        102
        3325: aaload
        3326: astore        161
        3328: aload         161
        3330: checkcast     #170                // class Closure
        3333: iload         160
        3335: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3338: invokevirtual #400                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3341: astore        162
        3343: new           #2                  // class Block
        3346: dup
        3347: iconst_0
        3348: iconst_0
        3349: anewarray     #4                  // class java/lang/Object
        3352: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3355: astore        163
        3357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3360: bipush        47
        3362: aload         163
        3364: aastore
        3365: iconst_0
        3366: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3369: astore        164
        3371: return
    }
    |}]

let%expect_test "emission: variant match via switch" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type t = A | B of int | C
       let get = function A -> 0 | B n -> n | C -> -1
       let () = caml_java_print_int (get (B 42)) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        49
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: new           #2                  // class Block
        1043: dup
        1044: iconst_0
        1045: iconst_1
        1046: anewarray     #4                  // class java/lang/Object
        1049: dup
        1050: iconst_0
        1051: bipush        42
        1053: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1056: aastore
        1057: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1060: aastore
        1061: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1064: bipush        47
        1066: iconst_0
        1067: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1070: aastore
        1071: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1074: bipush        48
        1076: iconst_0
        1077: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1080: aastore
        1081: aconst_null
        1082: astore_1
        1083: aload_1
        1084: astore_2
        1085: goto_w        1090
        1090: new           #94                 // class ocaml_fn_0
        1093: dup
        1094: invokespecial #97                 // Method ocaml_fn_0."<init>":()V
        1097: astore_3
        1098: new           #99                 // class ocaml_fn_1
        1101: dup
        1102: invokespecial #100                // Method ocaml_fn_1."<init>":()V
        1105: astore        4
        1107: new           #102                // class ocaml_fn_2
        1110: dup
        1111: invokespecial #103                // Method ocaml_fn_2."<init>":()V
        1114: astore        5
        1116: new           #2                  // class Block
        1119: dup
        1120: iconst_0
        1121: iconst_3
        1122: anewarray     #4                  // class java/lang/Object
        1125: dup
        1126: iconst_0
        1127: aload         4
        1129: aastore
        1130: dup
        1131: iconst_1
        1132: aload_3
        1133: aastore
        1134: dup
        1135: iconst_2
        1136: aload         5
        1138: aastore
        1139: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1142: astore        6
        1144: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1147: bipush        12
        1149: aload         6
        1151: aastore
        1152: iconst_0
        1153: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1156: astore        7
        1158: iconst_0
        1159: istore        8
        1161: iload         8
        1163: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1166: astore        9
        1168: goto_w        1173
        1173: sipush        199
        1176: istore        10
        1178: iconst_0
        1179: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1182: astore        11
        1184: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1187: bipush        35
        1189: aaload
        1190: astore        12
        1192: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1195: iconst_3
        1196: aaload
        1197: astore        13
        1199: new           #2                  // class Block
        1202: dup
        1203: iconst_0
        1204: iconst_2
        1205: anewarray     #4                  // class java/lang/Object
        1208: dup
        1209: iconst_0
        1210: aload         13
        1212: aastore
        1213: dup
        1214: iconst_1
        1215: aload         12
        1217: aastore
        1218: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1221: astore        14
        1223: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1226: bipush        36
        1228: aaload
        1229: astore        15
        1231: iconst_0
        1232: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1235: astore        16
        1237: new           #105                // class ocaml_fn_8
        1240: dup
        1241: invokespecial #106                // Method ocaml_fn_8."<init>":()V
        1244: astore        17
        1246: new           #108                // class ocaml_fn_9
        1249: dup
        1250: invokespecial #109                // Method ocaml_fn_9."<init>":()V
        1253: astore        18
        1255: iconst_0
        1256: istore        19
        1258: iconst_0
        1259: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1262: astore        20
        1264: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1267: bipush        37
        1269: aaload
        1270: astore        21
        1272: new           #2                  // class Block
        1275: dup
        1276: sipush        248
        1279: iconst_2
        1280: anewarray     #4                  // class java/lang/Object
        1283: dup
        1284: iconst_0
        1285: aload         21
        1287: aastore
        1288: dup
        1289: iconst_1
        1290: aload         20
        1292: aastore
        1293: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1296: astore        22
        1298: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1301: bipush        7
        1303: aaload
        1304: astore        23
        1306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1309: bipush        10
        1311: aaload
        1312: astore        24
        1314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1317: iconst_3
        1318: aaload
        1319: astore        25
        1321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1324: iconst_2
        1325: aaload
        1326: astore        26
        1328: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1331: bipush        6
        1333: aaload
        1334: astore        27
        1336: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1339: iconst_0
        1340: aaload
        1341: astore        28
        1343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1346: bipush        8
        1348: aaload
        1349: astore        29
        1351: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1354: iconst_1
        1355: aaload
        1356: astore        30
        1358: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1361: iconst_4
        1362: aaload
        1363: astore        31
        1365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1368: iconst_5
        1369: aaload
        1370: astore        32
        1372: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1375: bipush        9
        1377: aaload
        1378: astore        33
        1380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1383: bipush        11
        1385: aaload
        1386: astore        34
        1388: new           #111                // class ocaml_fn_10
        1391: dup
        1392: invokespecial #112                // Method ocaml_fn_10."<init>":()V
        1395: astore        35
        1397: new           #114                // class ocaml_fn_11
        1400: dup
        1401: invokespecial #115                // Method ocaml_fn_11."<init>":()V
        1404: astore        36
        1406: new           #117                // class ocaml_fn_12
        1409: dup
        1410: invokespecial #118                // Method ocaml_fn_12."<init>":()V
        1413: astore        37
        1415: new           #120                // class ocaml_fn_13
        1418: dup
        1419: invokespecial #121                // Method ocaml_fn_13."<init>":()V
        1422: astore        38
        1424: ldc           #122                // int 2147483647
        1426: istore        39
        1428: ldc           #123                // int -2147483648
        1430: istore        40
        1432: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1435: bipush        38
        1437: aaload
        1438: astore        41
        1440: ldc2_w        #124                // double 0.0d
        1443: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1446: astore        42
        1448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1451: bipush        39
        1453: aaload
        1454: astore        43
        1456: ldc2_w        #124                // double 0.0d
        1459: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1462: astore        44
        1464: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1467: bipush        40
        1469: aaload
        1470: astore        45
        1472: ldc2_w        #124                // double 0.0d
        1475: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1478: astore        46
        1480: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1483: bipush        41
        1485: aaload
        1486: astore        47
        1488: ldc2_w        #124                // double 0.0d
        1491: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1494: astore        48
        1496: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1499: bipush        42
        1501: aaload
        1502: astore        49
        1504: ldc2_w        #124                // double 0.0d
        1507: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1510: astore        50
        1512: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1515: bipush        43
        1517: aaload
        1518: astore        51
        1520: ldc2_w        #124                // double 0.0d
        1523: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1526: astore        52
        1528: new           #132                // class ocaml_fn_14
        1531: dup
        1532: invokespecial #133                // Method ocaml_fn_14."<init>":()V
        1535: astore        53
        1537: new           #135                // class ocaml_fn_15
        1540: dup
        1541: aload         18
        1543: invokespecial #138                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1546: astore        54
        1548: new           #140                // class ocaml_fn_16
        1551: dup
        1552: invokespecial #141                // Method ocaml_fn_16."<init>":()V
        1555: astore        55
        1557: new           #143                // class ocaml_fn_17
        1560: dup
        1561: aload         18
        1563: invokespecial #144                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1566: astore        56
        1568: new           #146                // class ocaml_fn_18
        1571: dup
        1572: invokespecial #147                // Method ocaml_fn_18."<init>":()V
        1575: astore        57
        1577: new           #149                // class ocaml_fn_19
        1580: dup
        1581: invokespecial #150                // Method ocaml_fn_19."<init>":()V
        1584: astore        58
        1586: new           #152                // class ocaml_fn_20
        1589: dup
        1590: aload         26
        1592: invokespecial #153                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1595: astore        59
        1597: new           #155                // class ocaml_fn_21
        1600: dup
        1601: aload         53
        1603: invokespecial #156                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1606: astore        60
        1608: new           #158                // class ocaml_fn_22
        1611: dup
        1612: aload         60
        1614: invokespecial #159                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1617: astore        61
        1619: new           #161                // class ocaml_fn_23
        1622: dup
        1623: aload         26
        1625: invokespecial #162                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1628: astore        62
        1630: new           #164                // class ocaml_fn_24
        1633: dup
        1634: invokespecial #165                // Method ocaml_fn_24."<init>":()V
        1637: astore        63
        1639: new           #167                // class ocaml_fn_25
        1642: dup
        1643: invokespecial #168                // Method ocaml_fn_25."<init>":()V
        1646: astore        64
        1648: aload         63
        1650: checkcast     #164                // class ocaml_fn_24
        1653: aload         63
        1655: checkcast     #170                // class Closure
        1658: putfield      #174                // Field ocaml_fn_24.sibling_0:LClosure;
        1661: iconst_0
        1662: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1665: astore        65
        1667: aload         63
        1669: checkcast     #164                // class ocaml_fn_24
        1672: aload         64
        1674: checkcast     #170                // class Closure
        1677: putfield      #177                // Field ocaml_fn_24.sibling_1:LClosure;
        1680: iconst_0
        1681: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1684: astore        66
        1686: aload         64
        1688: checkcast     #167                // class ocaml_fn_25
        1691: aload         63
        1693: checkcast     #170                // class Closure
        1696: putfield      #178                // Field ocaml_fn_25.sibling_0:LClosure;
        1699: iconst_0
        1700: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1703: astore        67
        1705: aload         64
        1707: checkcast     #167                // class ocaml_fn_25
        1710: aload         64
        1712: checkcast     #170                // class Closure
        1715: putfield      #179                // Field ocaml_fn_25.sibling_1:LClosure;
        1718: iconst_0
        1719: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1722: astore        68
        1724: iconst_0
        1725: istore        69
        1727: aconst_null
        1728: astore        70
        1730: iconst_1
        1731: istore        71
        1733: iload         71
        1735: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1738: astore        72
        1740: iconst_2
        1741: istore        73
        1743: iload         73
        1745: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1748: astore        74
        1750: new           #187                // class ocaml_fn_26
        1753: dup
        1754: invokespecial #188                // Method ocaml_fn_26."<init>":()V
        1757: astore        75
        1759: new           #190                // class ocaml_fn_27
        1762: dup
        1763: aload         75
        1765: invokespecial #191                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1768: astore        76
        1770: new           #193                // class ocaml_fn_28
        1773: dup
        1774: aload         75
        1776: invokespecial #194                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1779: astore        77
        1781: new           #196                // class ocaml_fn_29
        1784: dup
        1785: aload         30
        1787: invokespecial #197                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1790: astore        78
        1792: new           #199                // class ocaml_fn_30
        1795: dup
        1796: invokespecial #200                // Method ocaml_fn_30."<init>":()V
        1799: astore        79
        1801: new           #202                // class ocaml_fn_31
        1804: dup
        1805: invokespecial #203                // Method ocaml_fn_31."<init>":()V
        1808: astore        80
        1810: new           #205                // class ocaml_fn_32
        1813: dup
        1814: aload         18
        1816: invokespecial #206                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1819: astore        81
        1821: new           #208                // class ocaml_fn_33
        1824: dup
        1825: aload         18
        1827: invokespecial #209                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1830: astore        82
        1832: new           #211                // class ocaml_fn_34
        1835: dup
        1836: invokespecial #212                // Method ocaml_fn_34."<init>":()V
        1839: astore        83
        1841: new           #214                // class ocaml_fn_35
        1844: dup
        1845: invokespecial #215                // Method ocaml_fn_35."<init>":()V
        1848: astore        84
        1850: new           #217                // class ocaml_fn_36
        1853: dup
        1854: invokespecial #218                // Method ocaml_fn_36."<init>":()V
        1857: astore        85
        1859: new           #220                // class ocaml_fn_37
        1862: dup
        1863: invokespecial #221                // Method ocaml_fn_37."<init>":()V
        1866: astore        86
        1868: new           #223                // class ocaml_fn_38
        1871: dup
        1872: aload         86
        1874: invokespecial #224                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1877: astore        87
        1879: new           #226                // class ocaml_fn_39
        1882: dup
        1883: aload         86
        1885: invokespecial #227                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1888: astore        88
        1890: new           #229                // class ocaml_fn_40
        1893: dup
        1894: aload         18
        1896: invokespecial #230                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1899: astore        89
        1901: new           #232                // class ocaml_fn_41
        1904: dup
        1905: aload         31
        1907: invokespecial #233                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1910: astore        90
        1912: new           #235                // class ocaml_fn_42
        1915: dup
        1916: aload         18
        1918: aload         90
        1920: invokespecial #238                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1923: astore        91
        1925: new           #240                // class ocaml_fn_43
        1928: dup
        1929: aload         91
        1931: invokespecial #241                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1934: astore        92
        1936: new           #243                // class ocaml_fn_44
        1939: dup
        1940: aload         31
        1942: invokespecial #244                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1945: astore        93
        1947: new           #246                // class ocaml_fn_45
        1950: dup
        1951: invokespecial #247                // Method ocaml_fn_45."<init>":()V
        1954: astore        94
        1956: new           #249                // class ocaml_fn_46
        1959: dup
        1960: aload         72
        1962: invokespecial #250                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1965: astore        95
        1967: new           #252                // class ocaml_fn_47
        1970: dup
        1971: aload         72
        1973: aload         80
        1975: invokespecial #253                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1978: astore        96
        1980: new           #255                // class ocaml_fn_48
        1983: dup
        1984: aload         72
        1986: aload         79
        1988: invokespecial #256                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1991: astore        97
        1993: new           #258                // class ocaml_fn_49
        1996: dup
        1997: aload         58
        1999: aload         72
        2001: aload         80
        2003: invokespecial #261                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2006: astore        98
        2008: new           #263                // class ocaml_fn_50
        2011: dup
        2012: aload         61
        2014: aload         72
        2016: aload         80
        2018: invokespecial #264                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        99
        2023: new           #266                // class ocaml_fn_51
        2026: dup
        2027: aload         72
        2029: aload         80
        2031: invokespecial #267                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2034: astore        100
        2036: new           #269                // class ocaml_fn_52
        2039: dup
        2040: aload         72
        2042: invokespecial #270                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2045: astore        101
        2047: new           #272                // class ocaml_fn_53
        2050: dup
        2051: aload         74
        2053: invokespecial #273                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2056: astore        102
        2058: new           #275                // class ocaml_fn_54
        2061: dup
        2062: aload         74
        2064: aload         80
        2066: invokespecial #276                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        103
        2071: new           #278                // class ocaml_fn_55
        2074: dup
        2075: aload         74
        2077: aload         79
        2079: invokespecial #279                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2082: astore        104
        2084: new           #281                // class ocaml_fn_56
        2087: dup
        2088: aload         58
        2090: aload         74
        2092: aload         80
        2094: invokespecial #282                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2097: astore        105
        2099: new           #284                // class ocaml_fn_57
        2102: dup
        2103: aload         61
        2105: aload         74
        2107: aload         80
        2109: invokespecial #285                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        106
        2114: new           #287                // class ocaml_fn_58
        2117: dup
        2118: aload         74
        2120: aload         80
        2122: invokespecial #288                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        107
        2127: new           #290                // class ocaml_fn_59
        2130: dup
        2131: aload         74
        2133: invokespecial #291                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        108
        2138: new           #293                // class ocaml_fn_60
        2141: dup
        2142: aload         70
        2144: aload         72
        2146: aload         93
        2148: invokespecial #294                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2151: astore        109
        2153: new           #296                // class ocaml_fn_61
        2156: dup
        2157: aload         109
        2159: invokespecial #297                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2162: astore        110
        2164: new           #299                // class ocaml_fn_62
        2167: dup
        2168: aload         59
        2170: aload         109
        2172: invokespecial #300                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2175: astore        111
        2177: new           #302                // class ocaml_fn_63
        2180: dup
        2181: aload         109
        2183: invokespecial #303                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2186: astore        112
        2188: new           #305                // class ocaml_fn_64
        2191: dup
        2192: aload         62
        2194: aload         109
        2196: invokespecial #306                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2199: astore        113
        2201: new           #308                // class ocaml_fn_65
        2204: dup
        2205: invokespecial #309                // Method ocaml_fn_65."<init>":()V
        2208: astore        114
        2210: new           #311                // class ocaml_fn_66
        2213: dup
        2214: aload         53
        2216: invokespecial #312                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2219: astore        115
        2221: new           #2                  // class Block
        2224: dup
        2225: iconst_0
        2226: iconst_1
        2227: anewarray     #4                  // class java/lang/Object
        2230: dup
        2231: iconst_0
        2232: aload         78
        2234: aastore
        2235: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2238: astore        116
        2240: new           #314                // class ocaml_fn_67
        2243: dup
        2244: aload         116
        2246: invokespecial #315                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2249: astore        117
        2251: new           #317                // class ocaml_fn_68
        2254: dup
        2255: invokespecial #318                // Method ocaml_fn_68."<init>":()V
        2258: astore        118
        2260: new           #2                  // class Block
        2263: dup
        2264: iconst_0
        2265: iconst_1
        2266: anewarray     #4                  // class java/lang/Object
        2269: dup
        2270: iconst_0
        2271: aload         118
        2273: aastore
        2274: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2277: astore        119
        2279: new           #320                // class ocaml_fn_69
        2282: dup
        2283: aload         116
        2285: aload         119
        2287: invokespecial #321                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2290: astore        120
        2292: new           #323                // class ocaml_fn_70
        2295: dup
        2296: aload         120
        2298: invokespecial #324                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2301: astore        121
        2303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2306: bipush        44
        2308: aaload
        2309: astore        122
        2311: iconst_0
        2312: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2315: astore        123
        2317: new           #326                // class ocaml_fn_71
        2320: dup
        2321: invokespecial #327                // Method ocaml_fn_71."<init>":()V
        2324: astore        124
        2326: new           #329                // class ocaml_fn_72
        2329: dup
        2330: invokespecial #330                // Method ocaml_fn_72."<init>":()V
        2333: astore        125
        2335: new           #332                // class ocaml_fn_73
        2338: dup
        2339: invokespecial #333                // Method ocaml_fn_73."<init>":()V
        2342: astore        126
        2344: new           #335                // class ocaml_fn_74
        2347: dup
        2348: invokespecial #336                // Method ocaml_fn_74."<init>":()V
        2351: astore        127
        2353: new           #338                // class ocaml_fn_75
        2356: dup
        2357: invokespecial #339                // Method ocaml_fn_75."<init>":()V
        2360: astore        128
        2362: new           #341                // class ocaml_fn_76
        2365: dup
        2366: invokespecial #342                // Method ocaml_fn_76."<init>":()V
        2369: astore        129
        2371: new           #2                  // class Block
        2374: dup
        2375: iconst_0
        2376: bipush        6
        2378: anewarray     #4                  // class java/lang/Object
        2381: dup
        2382: iconst_0
        2383: aload         129
        2385: aastore
        2386: dup
        2387: iconst_1
        2388: aload         128
        2390: aastore
        2391: dup
        2392: iconst_2
        2393: aload         127
        2395: aastore
        2396: dup
        2397: iconst_3
        2398: aload         126
        2400: aastore
        2401: dup
        2402: iconst_4
        2403: aload         125
        2405: aastore
        2406: dup
        2407: iconst_5
        2408: aload         124
        2410: aastore
        2411: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2414: astore        130
        2416: new           #344                // class ocaml_fn_77
        2419: dup
        2420: invokespecial #345                // Method ocaml_fn_77."<init>":()V
        2423: astore        131
        2425: new           #347                // class ocaml_fn_78
        2428: dup
        2429: invokespecial #348                // Method ocaml_fn_78."<init>":()V
        2432: astore        132
        2434: new           #350                // class ocaml_fn_79
        2437: dup
        2438: invokespecial #351                // Method ocaml_fn_79."<init>":()V
        2441: astore        133
        2443: new           #353                // class ocaml_fn_80
        2446: dup
        2447: invokespecial #354                // Method ocaml_fn_80."<init>":()V
        2450: astore        134
        2452: new           #356                // class ocaml_fn_81
        2455: dup
        2456: invokespecial #357                // Method ocaml_fn_81."<init>":()V
        2459: astore        135
        2461: new           #359                // class ocaml_fn_82
        2464: dup
        2465: invokespecial #360                // Method ocaml_fn_82."<init>":()V
        2468: astore        136
        2470: new           #362                // class ocaml_fn_83
        2473: dup
        2474: invokespecial #363                // Method ocaml_fn_83."<init>":()V
        2477: astore        137
        2479: new           #365                // class ocaml_fn_84
        2482: dup
        2483: invokespecial #366                // Method ocaml_fn_84."<init>":()V
        2486: astore        138
        2488: new           #368                // class ocaml_fn_85
        2491: dup
        2492: invokespecial #369                // Method ocaml_fn_85."<init>":()V
        2495: astore        139
        2497: new           #371                // class ocaml_fn_86
        2500: dup
        2501: invokespecial #372                // Method ocaml_fn_86."<init>":()V
        2504: astore        140
        2506: new           #374                // class ocaml_fn_87
        2509: dup
        2510: invokespecial #375                // Method ocaml_fn_87."<init>":()V
        2513: astore        141
        2515: new           #377                // class ocaml_fn_88
        2518: dup
        2519: invokespecial #378                // Method ocaml_fn_88."<init>":()V
        2522: astore        142
        2524: new           #380                // class ocaml_fn_89
        2527: dup
        2528: invokespecial #381                // Method ocaml_fn_89."<init>":()V
        2531: astore        143
        2533: new           #383                // class ocaml_fn_90
        2536: dup
        2537: invokespecial #384                // Method ocaml_fn_90."<init>":()V
        2540: astore        144
        2542: new           #386                // class ocaml_fn_91
        2545: dup
        2546: invokespecial #387                // Method ocaml_fn_91."<init>":()V
        2549: astore        145
        2551: new           #389                // class ocaml_fn_92
        2554: dup
        2555: invokespecial #390                // Method ocaml_fn_92."<init>":()V
        2558: astore        146
        2560: new           #392                // class ocaml_fn_93
        2563: dup
        2564: invokespecial #393                // Method ocaml_fn_93."<init>":()V
        2567: astore        147
        2569: new           #2                  // class Block
        2572: dup
        2573: iconst_0
        2574: bipush        104
        2576: anewarray     #4                  // class java/lang/Object
        2579: dup
        2580: iconst_0
        2581: aload         18
        2583: aastore
        2584: dup
        2585: iconst_1
        2586: aload         17
        2588: aastore
        2589: dup
        2590: iconst_2
        2591: aload         22
        2593: aastore
        2594: dup
        2595: iconst_3
        2596: aload         23
        2598: aastore
        2599: dup
        2600: iconst_4
        2601: aload         24
        2603: aastore
        2604: dup
        2605: iconst_5
        2606: aload         25
        2608: aastore
        2609: dup
        2610: bipush        6
        2612: aload         26
        2614: aastore
        2615: dup
        2616: bipush        7
        2618: aload         27
        2620: aastore
        2621: dup
        2622: bipush        8
        2624: aload         28
        2626: aastore
        2627: dup
        2628: bipush        9
        2630: aload         29
        2632: aastore
        2633: dup
        2634: bipush        10
        2636: aload         30
        2638: aastore
        2639: dup
        2640: bipush        11
        2642: aload         31
        2644: aastore
        2645: dup
        2646: bipush        12
        2648: aload         32
        2650: aastore
        2651: dup
        2652: bipush        13
        2654: aload         33
        2656: aastore
        2657: dup
        2658: bipush        14
        2660: aload         34
        2662: aastore
        2663: dup
        2664: bipush        15
        2666: aload         35
        2668: aastore
        2669: dup
        2670: bipush        16
        2672: aload         36
        2674: aastore
        2675: dup
        2676: bipush        17
        2678: aload         37
        2680: aastore
        2681: dup
        2682: bipush        18
        2684: iload         39
        2686: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2689: aastore
        2690: dup
        2691: bipush        19
        2693: iload         40
        2695: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2698: aastore
        2699: dup
        2700: bipush        20
        2702: aload         38
        2704: aastore
        2705: dup
        2706: bipush        21
        2708: aload         42
        2710: aastore
        2711: dup
        2712: bipush        22
        2714: aload         44
        2716: aastore
        2717: dup
        2718: bipush        23
        2720: aload         46
        2722: aastore
        2723: dup
        2724: bipush        24
        2726: aload         48
        2728: aastore
        2729: dup
        2730: bipush        25
        2732: aload         50
        2734: aastore
        2735: dup
        2736: bipush        26
        2738: aload         52
        2740: aastore
        2741: dup
        2742: bipush        27
        2744: aload         53
        2746: aastore
        2747: dup
        2748: bipush        28
        2750: aload         54
        2752: aastore
        2753: dup
        2754: bipush        29
        2756: aload         55
        2758: aastore
        2759: dup
        2760: bipush        30
        2762: aload         57
        2764: aastore
        2765: dup
        2766: bipush        31
        2768: aload         56
        2770: aastore
        2771: dup
        2772: bipush        32
        2774: aload         58
        2776: aastore
        2777: dup
        2778: bipush        33
        2780: aload         59
        2782: aastore
        2783: dup
        2784: bipush        34
        2786: aload         61
        2788: aastore
        2789: dup
        2790: bipush        35
        2792: aload         62
        2794: aastore
        2795: dup
        2796: bipush        36
        2798: aload         63
        2800: aastore
        2801: dup
        2802: bipush        37
        2804: aload         70
        2806: aastore
        2807: dup
        2808: bipush        38
        2810: aload         72
        2812: aastore
        2813: dup
        2814: bipush        39
        2816: aload         74
        2818: aastore
        2819: dup
        2820: bipush        40
        2822: aload         95
        2824: aastore
        2825: dup
        2826: bipush        41
        2828: aload         96
        2830: aastore
        2831: dup
        2832: bipush        42
        2834: aload         97
        2836: aastore
        2837: dup
        2838: bipush        43
        2840: aload         98
        2842: aastore
        2843: dup
        2844: bipush        44
        2846: aload         99
        2848: aastore
        2849: dup
        2850: bipush        45
        2852: aload         100
        2854: aastore
        2855: dup
        2856: bipush        46
        2858: aload         101
        2860: aastore
        2861: dup
        2862: bipush        47
        2864: aload         102
        2866: aastore
        2867: dup
        2868: bipush        48
        2870: aload         103
        2872: aastore
        2873: dup
        2874: bipush        49
        2876: aload         104
        2878: aastore
        2879: dup
        2880: bipush        50
        2882: aload         105
        2884: aastore
        2885: dup
        2886: bipush        51
        2888: aload         106
        2890: aastore
        2891: dup
        2892: bipush        52
        2894: aload         107
        2896: aastore
        2897: dup
        2898: bipush        53
        2900: aload         108
        2902: aastore
        2903: dup
        2904: bipush        54
        2906: aload         109
        2908: aastore
        2909: dup
        2910: bipush        55
        2912: aload         111
        2914: aastore
        2915: dup
        2916: bipush        56
        2918: aload         110
        2920: aastore
        2921: dup
        2922: bipush        57
        2924: aload         113
        2926: aastore
        2927: dup
        2928: bipush        58
        2930: aload         112
        2932: aastore
        2933: dup
        2934: bipush        59
        2936: aload         76
        2938: aastore
        2939: dup
        2940: bipush        60
        2942: aload         77
        2944: aastore
        2945: dup
        2946: bipush        61
        2948: aload         75
        2950: aastore
        2951: dup
        2952: bipush        62
        2954: aload         147
        2956: aastore
        2957: dup
        2958: bipush        63
        2960: aload         78
        2962: aastore
        2963: dup
        2964: bipush        64
        2966: aload         146
        2968: aastore
        2969: dup
        2970: bipush        65
        2972: aload         80
        2974: aastore
        2975: dup
        2976: bipush        66
        2978: aload         79
        2980: aastore
        2981: dup
        2982: bipush        67
        2984: aload         81
        2986: aastore
        2987: dup
        2988: bipush        68
        2990: aload         82
        2992: aastore
        2993: dup
        2994: bipush        69
        2996: aload         145
        2998: aastore
        2999: dup
        3000: bipush        70
        3002: aload         144
        3004: aastore
        3005: dup
        3006: bipush        71
        3008: aload         83
        3010: aastore
        3011: dup
        3012: bipush        72
        3014: aload         143
        3016: aastore
        3017: dup
        3018: bipush        73
        3020: aload         142
        3022: aastore
        3023: dup
        3024: bipush        74
        3026: aload         141
        3028: aastore
        3029: dup
        3030: bipush        75
        3032: aload         84
        3034: aastore
        3035: dup
        3036: bipush        76
        3038: aload         85
        3040: aastore
        3041: dup
        3042: bipush        77
        3044: aload         140
        3046: aastore
        3047: dup
        3048: bipush        78
        3050: aload         87
        3052: aastore
        3053: dup
        3054: bipush        79
        3056: aload         88
        3058: aastore
        3059: dup
        3060: bipush        80
        3062: aload         86
        3064: aastore
        3065: dup
        3066: bipush        81
        3068: aload         139
        3070: aastore
        3071: dup
        3072: bipush        82
        3074: aload         93
        3076: aastore
        3077: dup
        3078: bipush        83
        3080: aload         89
        3082: aastore
        3083: dup
        3084: bipush        84
        3086: aload         91
        3088: aastore
        3089: dup
        3090: bipush        85
        3092: aload         92
        3094: aastore
        3095: dup
        3096: bipush        86
        3098: aload         138
        3100: aastore
        3101: dup
        3102: bipush        87
        3104: aload         137
        3106: aastore
        3107: dup
        3108: bipush        88
        3110: aload         136
        3112: aastore
        3113: dup
        3114: bipush        89
        3116: aload         135
        3118: aastore
        3119: dup
        3120: bipush        90
        3122: aload         134
        3124: aastore
        3125: dup
        3126: bipush        91
        3128: aload         133
        3130: aastore
        3131: dup
        3132: bipush        92
        3134: aload         132
        3136: aastore
        3137: dup
        3138: bipush        93
        3140: aload         94
        3142: aastore
        3143: dup
        3144: bipush        94
        3146: aload         131
        3148: aastore
        3149: dup
        3150: bipush        95
        3152: aload         130
        3154: aastore
        3155: dup
        3156: bipush        96
        3158: aload         114
        3160: aastore
        3161: dup
        3162: bipush        97
        3164: aload         115
        3166: aastore
        3167: dup
        3168: bipush        98
        3170: aload         121
        3172: aastore
        3173: dup
        3174: bipush        99
        3176: aload         117
        3178: aastore
        3179: dup
        3180: bipush        100
        3182: aload         60
        3184: aastore
        3185: dup
        3186: bipush        101
        3188: aload         90
        3190: aastore
        3191: dup
        3192: bipush        102
        3194: aload         120
        3196: aastore
        3197: dup
        3198: bipush        103
        3200: aload         119
        3202: aastore
        3203: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3206: astore        148
        3208: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3211: bipush        45
        3213: aload         148
        3215: aastore
        3216: iconst_0
        3217: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3220: astore        149
        3222: iconst_0
        3223: istore        150
        3225: iload         150
        3227: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3230: astore        151
        3232: goto_w        3237
        3237: new           #395                // class ocaml_fn_94
        3240: dup
        3241: invokespecial #396                // Method ocaml_fn_94."<init>":()V
        3244: astore        152
        3246: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3249: bipush        46
        3251: aaload
        3252: astore        153
        3254: aload         152
        3256: aload         153
        3258: invokevirtual #400                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3261: astore        154
        3263: getstatic     #404                // Field java/lang/System.out:Ljava/io/PrintStream;
        3266: aload         154
        3268: checkcast     #29                 // class java/lang/Integer
        3271: invokevirtual #408                // Method java/lang/Integer.intValue:()I
        3274: invokevirtual #414                // Method java/io/PrintStream.println:(I)V
        3277: iconst_0
        3278: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3281: astore        155
        3283: new           #2                  // class Block
        3286: dup
        3287: iconst_0
        3288: iconst_1
        3289: anewarray     #4                  // class java/lang/Object
        3292: dup
        3293: iconst_0
        3294: aload         152
        3296: aastore
        3297: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3300: astore        156
        3302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3305: bipush        47
        3307: aload         156
        3309: aastore
        3310: iconst_0
        3311: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3314: astore        157
        3316: iconst_0
        3317: istore        158
        3319: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3322: bipush        45
        3324: aaload
        3325: checkcast     #2                  // class Block
        3328: getfield      #417                // Field Block.fields:[Ljava/lang/Object;
        3331: bipush        102
        3333: aaload
        3334: astore        159
        3336: aload         159
        3338: checkcast     #170                // class Closure
        3341: iload         158
        3343: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3346: invokevirtual #400                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3349: astore        160
        3351: new           #2                  // class Block
        3354: dup
        3355: iconst_0
        3356: iconst_0
        3357: anewarray     #4                  // class java/lang/Object
        3360: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3363: astore        161
        3365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3368: bipush        48
        3370: aload         161
        3372: aastore
        3373: iconst_0
        3374: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3377: astore        162
        3379: return
    }
    |}]

let%expect_test "emission: try/with catchall" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception Oops
       let safe x = try if x = 0 then raise Oops else 100 / x with _ -> -1
       let () = caml_java_print_int (safe 0) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        49
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: ldc           #94                 // String Test.Oops
        1042: aastore
        1043: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1046: bipush        47
        1048: iconst_0
        1049: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1052: aastore
        1053: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1056: bipush        48
        1058: iconst_0
        1059: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1062: aastore
        1063: aconst_null
        1064: astore_1
        1065: aload_1
        1066: astore_2
        1067: goto_w        1072
        1072: new           #96                 // class ocaml_fn_0
        1075: dup
        1076: invokespecial #99                 // Method ocaml_fn_0."<init>":()V
        1079: astore_3
        1080: new           #101                // class ocaml_fn_1
        1083: dup
        1084: invokespecial #102                // Method ocaml_fn_1."<init>":()V
        1087: astore        4
        1089: new           #104                // class ocaml_fn_2
        1092: dup
        1093: invokespecial #105                // Method ocaml_fn_2."<init>":()V
        1096: astore        5
        1098: new           #2                  // class Block
        1101: dup
        1102: iconst_0
        1103: iconst_3
        1104: anewarray     #4                  // class java/lang/Object
        1107: dup
        1108: iconst_0
        1109: aload         4
        1111: aastore
        1112: dup
        1113: iconst_1
        1114: aload_3
        1115: aastore
        1116: dup
        1117: iconst_2
        1118: aload         5
        1120: aastore
        1121: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1124: astore        6
        1126: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1129: bipush        12
        1131: aload         6
        1133: aastore
        1134: iconst_0
        1135: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1138: astore        7
        1140: iconst_0
        1141: istore        8
        1143: iload         8
        1145: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1148: astore        9
        1150: goto_w        1155
        1155: sipush        199
        1158: istore        10
        1160: iconst_0
        1161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1164: astore        11
        1166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1169: bipush        35
        1171: aaload
        1172: astore        12
        1174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1177: iconst_3
        1178: aaload
        1179: astore        13
        1181: new           #2                  // class Block
        1184: dup
        1185: iconst_0
        1186: iconst_2
        1187: anewarray     #4                  // class java/lang/Object
        1190: dup
        1191: iconst_0
        1192: aload         13
        1194: aastore
        1195: dup
        1196: iconst_1
        1197: aload         12
        1199: aastore
        1200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1203: astore        14
        1205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1208: bipush        36
        1210: aaload
        1211: astore        15
        1213: iconst_0
        1214: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1217: astore        16
        1219: new           #107                // class ocaml_fn_8
        1222: dup
        1223: invokespecial #108                // Method ocaml_fn_8."<init>":()V
        1226: astore        17
        1228: new           #110                // class ocaml_fn_9
        1231: dup
        1232: invokespecial #111                // Method ocaml_fn_9."<init>":()V
        1235: astore        18
        1237: iconst_0
        1238: istore        19
        1240: iconst_0
        1241: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1244: astore        20
        1246: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        37
        1251: aaload
        1252: astore        21
        1254: new           #2                  // class Block
        1257: dup
        1258: sipush        248
        1261: iconst_2
        1262: anewarray     #4                  // class java/lang/Object
        1265: dup
        1266: iconst_0
        1267: aload         21
        1269: aastore
        1270: dup
        1271: iconst_1
        1272: aload         20
        1274: aastore
        1275: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1278: astore        22
        1280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1283: bipush        7
        1285: aaload
        1286: astore        23
        1288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1291: bipush        10
        1293: aaload
        1294: astore        24
        1296: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1299: iconst_3
        1300: aaload
        1301: astore        25
        1303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1306: iconst_2
        1307: aaload
        1308: astore        26
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: bipush        6
        1315: aaload
        1316: astore        27
        1318: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1321: iconst_0
        1322: aaload
        1323: astore        28
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: bipush        8
        1330: aaload
        1331: astore        29
        1333: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1336: iconst_1
        1337: aaload
        1338: astore        30
        1340: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1343: iconst_4
        1344: aaload
        1345: astore        31
        1347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1350: iconst_5
        1351: aaload
        1352: astore        32
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: bipush        9
        1359: aaload
        1360: astore        33
        1362: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1365: bipush        11
        1367: aaload
        1368: astore        34
        1370: new           #113                // class ocaml_fn_10
        1373: dup
        1374: invokespecial #114                // Method ocaml_fn_10."<init>":()V
        1377: astore        35
        1379: new           #116                // class ocaml_fn_11
        1382: dup
        1383: invokespecial #117                // Method ocaml_fn_11."<init>":()V
        1386: astore        36
        1388: new           #119                // class ocaml_fn_12
        1391: dup
        1392: invokespecial #120                // Method ocaml_fn_12."<init>":()V
        1395: astore        37
        1397: new           #122                // class ocaml_fn_13
        1400: dup
        1401: invokespecial #123                // Method ocaml_fn_13."<init>":()V
        1404: astore        38
        1406: ldc           #124                // int 2147483647
        1408: istore        39
        1410: ldc           #125                // int -2147483648
        1412: istore        40
        1414: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1417: bipush        38
        1419: aaload
        1420: astore        41
        1422: ldc2_w        #126                // double 0.0d
        1425: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1428: astore        42
        1430: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1433: bipush        39
        1435: aaload
        1436: astore        43
        1438: ldc2_w        #126                // double 0.0d
        1441: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1444: astore        44
        1446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1449: bipush        40
        1451: aaload
        1452: astore        45
        1454: ldc2_w        #126                // double 0.0d
        1457: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        46
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        41
        1467: aaload
        1468: astore        47
        1470: ldc2_w        #126                // double 0.0d
        1473: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1476: astore        48
        1478: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1481: bipush        42
        1483: aaload
        1484: astore        49
        1486: ldc2_w        #126                // double 0.0d
        1489: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1492: astore        50
        1494: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1497: bipush        43
        1499: aaload
        1500: astore        51
        1502: ldc2_w        #126                // double 0.0d
        1505: invokestatic  #132                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1508: astore        52
        1510: new           #134                // class ocaml_fn_14
        1513: dup
        1514: invokespecial #135                // Method ocaml_fn_14."<init>":()V
        1517: astore        53
        1519: new           #137                // class ocaml_fn_15
        1522: dup
        1523: aload         18
        1525: invokespecial #140                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1528: astore        54
        1530: new           #142                // class ocaml_fn_16
        1533: dup
        1534: invokespecial #143                // Method ocaml_fn_16."<init>":()V
        1537: astore        55
        1539: new           #145                // class ocaml_fn_17
        1542: dup
        1543: aload         18
        1545: invokespecial #146                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1548: astore        56
        1550: new           #148                // class ocaml_fn_18
        1553: dup
        1554: invokespecial #149                // Method ocaml_fn_18."<init>":()V
        1557: astore        57
        1559: new           #151                // class ocaml_fn_19
        1562: dup
        1563: invokespecial #152                // Method ocaml_fn_19."<init>":()V
        1566: astore        58
        1568: new           #154                // class ocaml_fn_20
        1571: dup
        1572: aload         26
        1574: invokespecial #155                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1577: astore        59
        1579: new           #157                // class ocaml_fn_21
        1582: dup
        1583: aload         53
        1585: invokespecial #158                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1588: astore        60
        1590: new           #160                // class ocaml_fn_22
        1593: dup
        1594: aload         60
        1596: invokespecial #161                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1599: astore        61
        1601: new           #163                // class ocaml_fn_23
        1604: dup
        1605: aload         26
        1607: invokespecial #164                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1610: astore        62
        1612: new           #166                // class ocaml_fn_24
        1615: dup
        1616: invokespecial #167                // Method ocaml_fn_24."<init>":()V
        1619: astore        63
        1621: new           #169                // class ocaml_fn_25
        1624: dup
        1625: invokespecial #170                // Method ocaml_fn_25."<init>":()V
        1628: astore        64
        1630: aload         63
        1632: checkcast     #166                // class ocaml_fn_24
        1635: aload         63
        1637: checkcast     #172                // class Closure
        1640: putfield      #176                // Field ocaml_fn_24.sibling_0:LClosure;
        1643: iconst_0
        1644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1647: astore        65
        1649: aload         63
        1651: checkcast     #166                // class ocaml_fn_24
        1654: aload         64
        1656: checkcast     #172                // class Closure
        1659: putfield      #179                // Field ocaml_fn_24.sibling_1:LClosure;
        1662: iconst_0
        1663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1666: astore        66
        1668: aload         64
        1670: checkcast     #169                // class ocaml_fn_25
        1673: aload         63
        1675: checkcast     #172                // class Closure
        1678: putfield      #180                // Field ocaml_fn_25.sibling_0:LClosure;
        1681: iconst_0
        1682: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1685: astore        67
        1687: aload         64
        1689: checkcast     #169                // class ocaml_fn_25
        1692: aload         64
        1694: checkcast     #172                // class Closure
        1697: putfield      #181                // Field ocaml_fn_25.sibling_1:LClosure;
        1700: iconst_0
        1701: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: astore        68
        1706: iconst_0
        1707: istore        69
        1709: aconst_null
        1710: astore        70
        1712: iconst_1
        1713: istore        71
        1715: iload         71
        1717: invokestatic  #187                // Method Channel.forDescriptor:(I)LChannel;
        1720: astore        72
        1722: iconst_2
        1723: istore        73
        1725: iload         73
        1727: invokestatic  #187                // Method Channel.forDescriptor:(I)LChannel;
        1730: astore        74
        1732: new           #189                // class ocaml_fn_26
        1735: dup
        1736: invokespecial #190                // Method ocaml_fn_26."<init>":()V
        1739: astore        75
        1741: new           #192                // class ocaml_fn_27
        1744: dup
        1745: aload         75
        1747: invokespecial #193                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1750: astore        76
        1752: new           #195                // class ocaml_fn_28
        1755: dup
        1756: aload         75
        1758: invokespecial #196                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1761: astore        77
        1763: new           #198                // class ocaml_fn_29
        1766: dup
        1767: aload         30
        1769: invokespecial #199                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1772: astore        78
        1774: new           #201                // class ocaml_fn_30
        1777: dup
        1778: invokespecial #202                // Method ocaml_fn_30."<init>":()V
        1781: astore        79
        1783: new           #204                // class ocaml_fn_31
        1786: dup
        1787: invokespecial #205                // Method ocaml_fn_31."<init>":()V
        1790: astore        80
        1792: new           #207                // class ocaml_fn_32
        1795: dup
        1796: aload         18
        1798: invokespecial #208                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1801: astore        81
        1803: new           #210                // class ocaml_fn_33
        1806: dup
        1807: aload         18
        1809: invokespecial #211                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1812: astore        82
        1814: new           #213                // class ocaml_fn_34
        1817: dup
        1818: invokespecial #214                // Method ocaml_fn_34."<init>":()V
        1821: astore        83
        1823: new           #216                // class ocaml_fn_35
        1826: dup
        1827: invokespecial #217                // Method ocaml_fn_35."<init>":()V
        1830: astore        84
        1832: new           #219                // class ocaml_fn_36
        1835: dup
        1836: invokespecial #220                // Method ocaml_fn_36."<init>":()V
        1839: astore        85
        1841: new           #222                // class ocaml_fn_37
        1844: dup
        1845: invokespecial #223                // Method ocaml_fn_37."<init>":()V
        1848: astore        86
        1850: new           #225                // class ocaml_fn_38
        1853: dup
        1854: aload         86
        1856: invokespecial #226                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1859: astore        87
        1861: new           #228                // class ocaml_fn_39
        1864: dup
        1865: aload         86
        1867: invokespecial #229                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1870: astore        88
        1872: new           #231                // class ocaml_fn_40
        1875: dup
        1876: aload         18
        1878: invokespecial #232                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1881: astore        89
        1883: new           #234                // class ocaml_fn_41
        1886: dup
        1887: aload         31
        1889: invokespecial #235                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1892: astore        90
        1894: new           #237                // class ocaml_fn_42
        1897: dup
        1898: aload         18
        1900: aload         90
        1902: invokespecial #240                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1905: astore        91
        1907: new           #242                // class ocaml_fn_43
        1910: dup
        1911: aload         91
        1913: invokespecial #243                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1916: astore        92
        1918: new           #245                // class ocaml_fn_44
        1921: dup
        1922: aload         31
        1924: invokespecial #246                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1927: astore        93
        1929: new           #248                // class ocaml_fn_45
        1932: dup
        1933: invokespecial #249                // Method ocaml_fn_45."<init>":()V
        1936: astore        94
        1938: new           #251                // class ocaml_fn_46
        1941: dup
        1942: aload         72
        1944: invokespecial #252                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1947: astore        95
        1949: new           #254                // class ocaml_fn_47
        1952: dup
        1953: aload         72
        1955: aload         80
        1957: invokespecial #255                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1960: astore        96
        1962: new           #257                // class ocaml_fn_48
        1965: dup
        1966: aload         72
        1968: aload         79
        1970: invokespecial #258                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        97
        1975: new           #260                // class ocaml_fn_49
        1978: dup
        1979: aload         58
        1981: aload         72
        1983: aload         80
        1985: invokespecial #263                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1988: astore        98
        1990: new           #265                // class ocaml_fn_50
        1993: dup
        1994: aload         61
        1996: aload         72
        1998: aload         80
        2000: invokespecial #266                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2003: astore        99
        2005: new           #268                // class ocaml_fn_51
        2008: dup
        2009: aload         72
        2011: aload         80
        2013: invokespecial #269                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2016: astore        100
        2018: new           #271                // class ocaml_fn_52
        2021: dup
        2022: aload         72
        2024: invokespecial #272                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2027: astore        101
        2029: new           #274                // class ocaml_fn_53
        2032: dup
        2033: aload         74
        2035: invokespecial #275                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2038: astore        102
        2040: new           #277                // class ocaml_fn_54
        2043: dup
        2044: aload         74
        2046: aload         80
        2048: invokespecial #278                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2051: astore        103
        2053: new           #280                // class ocaml_fn_55
        2056: dup
        2057: aload         74
        2059: aload         79
        2061: invokespecial #281                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        104
        2066: new           #283                // class ocaml_fn_56
        2069: dup
        2070: aload         58
        2072: aload         74
        2074: aload         80
        2076: invokespecial #284                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2079: astore        105
        2081: new           #286                // class ocaml_fn_57
        2084: dup
        2085: aload         61
        2087: aload         74
        2089: aload         80
        2091: invokespecial #287                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        106
        2096: new           #289                // class ocaml_fn_58
        2099: dup
        2100: aload         74
        2102: aload         80
        2104: invokespecial #290                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2107: astore        107
        2109: new           #292                // class ocaml_fn_59
        2112: dup
        2113: aload         74
        2115: invokespecial #293                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2118: astore        108
        2120: new           #295                // class ocaml_fn_60
        2123: dup
        2124: aload         70
        2126: aload         72
        2128: aload         93
        2130: invokespecial #296                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2133: astore        109
        2135: new           #298                // class ocaml_fn_61
        2138: dup
        2139: aload         109
        2141: invokespecial #299                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2144: astore        110
        2146: new           #301                // class ocaml_fn_62
        2149: dup
        2150: aload         59
        2152: aload         109
        2154: invokespecial #302                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2157: astore        111
        2159: new           #304                // class ocaml_fn_63
        2162: dup
        2163: aload         109
        2165: invokespecial #305                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2168: astore        112
        2170: new           #307                // class ocaml_fn_64
        2173: dup
        2174: aload         62
        2176: aload         109
        2178: invokespecial #308                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        113
        2183: new           #310                // class ocaml_fn_65
        2186: dup
        2187: invokespecial #311                // Method ocaml_fn_65."<init>":()V
        2190: astore        114
        2192: new           #313                // class ocaml_fn_66
        2195: dup
        2196: aload         53
        2198: invokespecial #314                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2201: astore        115
        2203: new           #2                  // class Block
        2206: dup
        2207: iconst_0
        2208: iconst_1
        2209: anewarray     #4                  // class java/lang/Object
        2212: dup
        2213: iconst_0
        2214: aload         78
        2216: aastore
        2217: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2220: astore        116
        2222: new           #316                // class ocaml_fn_67
        2225: dup
        2226: aload         116
        2228: invokespecial #317                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2231: astore        117
        2233: new           #319                // class ocaml_fn_68
        2236: dup
        2237: invokespecial #320                // Method ocaml_fn_68."<init>":()V
        2240: astore        118
        2242: new           #2                  // class Block
        2245: dup
        2246: iconst_0
        2247: iconst_1
        2248: anewarray     #4                  // class java/lang/Object
        2251: dup
        2252: iconst_0
        2253: aload         118
        2255: aastore
        2256: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2259: astore        119
        2261: new           #322                // class ocaml_fn_69
        2264: dup
        2265: aload         116
        2267: aload         119
        2269: invokespecial #323                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        120
        2274: new           #325                // class ocaml_fn_70
        2277: dup
        2278: aload         120
        2280: invokespecial #326                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2283: astore        121
        2285: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2288: bipush        44
        2290: aaload
        2291: astore        122
        2293: iconst_0
        2294: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2297: astore        123
        2299: new           #328                // class ocaml_fn_71
        2302: dup
        2303: invokespecial #329                // Method ocaml_fn_71."<init>":()V
        2306: astore        124
        2308: new           #331                // class ocaml_fn_72
        2311: dup
        2312: invokespecial #332                // Method ocaml_fn_72."<init>":()V
        2315: astore        125
        2317: new           #334                // class ocaml_fn_73
        2320: dup
        2321: invokespecial #335                // Method ocaml_fn_73."<init>":()V
        2324: astore        126
        2326: new           #337                // class ocaml_fn_74
        2329: dup
        2330: invokespecial #338                // Method ocaml_fn_74."<init>":()V
        2333: astore        127
        2335: new           #340                // class ocaml_fn_75
        2338: dup
        2339: invokespecial #341                // Method ocaml_fn_75."<init>":()V
        2342: astore        128
        2344: new           #343                // class ocaml_fn_76
        2347: dup
        2348: invokespecial #344                // Method ocaml_fn_76."<init>":()V
        2351: astore        129
        2353: new           #2                  // class Block
        2356: dup
        2357: iconst_0
        2358: bipush        6
        2360: anewarray     #4                  // class java/lang/Object
        2363: dup
        2364: iconst_0
        2365: aload         129
        2367: aastore
        2368: dup
        2369: iconst_1
        2370: aload         128
        2372: aastore
        2373: dup
        2374: iconst_2
        2375: aload         127
        2377: aastore
        2378: dup
        2379: iconst_3
        2380: aload         126
        2382: aastore
        2383: dup
        2384: iconst_4
        2385: aload         125
        2387: aastore
        2388: dup
        2389: iconst_5
        2390: aload         124
        2392: aastore
        2393: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2396: astore        130
        2398: new           #346                // class ocaml_fn_77
        2401: dup
        2402: invokespecial #347                // Method ocaml_fn_77."<init>":()V
        2405: astore        131
        2407: new           #349                // class ocaml_fn_78
        2410: dup
        2411: invokespecial #350                // Method ocaml_fn_78."<init>":()V
        2414: astore        132
        2416: new           #352                // class ocaml_fn_79
        2419: dup
        2420: invokespecial #353                // Method ocaml_fn_79."<init>":()V
        2423: astore        133
        2425: new           #355                // class ocaml_fn_80
        2428: dup
        2429: invokespecial #356                // Method ocaml_fn_80."<init>":()V
        2432: astore        134
        2434: new           #358                // class ocaml_fn_81
        2437: dup
        2438: invokespecial #359                // Method ocaml_fn_81."<init>":()V
        2441: astore        135
        2443: new           #361                // class ocaml_fn_82
        2446: dup
        2447: invokespecial #362                // Method ocaml_fn_82."<init>":()V
        2450: astore        136
        2452: new           #364                // class ocaml_fn_83
        2455: dup
        2456: invokespecial #365                // Method ocaml_fn_83."<init>":()V
        2459: astore        137
        2461: new           #367                // class ocaml_fn_84
        2464: dup
        2465: invokespecial #368                // Method ocaml_fn_84."<init>":()V
        2468: astore        138
        2470: new           #370                // class ocaml_fn_85
        2473: dup
        2474: invokespecial #371                // Method ocaml_fn_85."<init>":()V
        2477: astore        139
        2479: new           #373                // class ocaml_fn_86
        2482: dup
        2483: invokespecial #374                // Method ocaml_fn_86."<init>":()V
        2486: astore        140
        2488: new           #376                // class ocaml_fn_87
        2491: dup
        2492: invokespecial #377                // Method ocaml_fn_87."<init>":()V
        2495: astore        141
        2497: new           #379                // class ocaml_fn_88
        2500: dup
        2501: invokespecial #380                // Method ocaml_fn_88."<init>":()V
        2504: astore        142
        2506: new           #382                // class ocaml_fn_89
        2509: dup
        2510: invokespecial #383                // Method ocaml_fn_89."<init>":()V
        2513: astore        143
        2515: new           #385                // class ocaml_fn_90
        2518: dup
        2519: invokespecial #386                // Method ocaml_fn_90."<init>":()V
        2522: astore        144
        2524: new           #388                // class ocaml_fn_91
        2527: dup
        2528: invokespecial #389                // Method ocaml_fn_91."<init>":()V
        2531: astore        145
        2533: new           #391                // class ocaml_fn_92
        2536: dup
        2537: invokespecial #392                // Method ocaml_fn_92."<init>":()V
        2540: astore        146
        2542: new           #394                // class ocaml_fn_93
        2545: dup
        2546: invokespecial #395                // Method ocaml_fn_93."<init>":()V
        2549: astore        147
        2551: new           #2                  // class Block
        2554: dup
        2555: iconst_0
        2556: bipush        104
        2558: anewarray     #4                  // class java/lang/Object
        2561: dup
        2562: iconst_0
        2563: aload         18
        2565: aastore
        2566: dup
        2567: iconst_1
        2568: aload         17
        2570: aastore
        2571: dup
        2572: iconst_2
        2573: aload         22
        2575: aastore
        2576: dup
        2577: iconst_3
        2578: aload         23
        2580: aastore
        2581: dup
        2582: iconst_4
        2583: aload         24
        2585: aastore
        2586: dup
        2587: iconst_5
        2588: aload         25
        2590: aastore
        2591: dup
        2592: bipush        6
        2594: aload         26
        2596: aastore
        2597: dup
        2598: bipush        7
        2600: aload         27
        2602: aastore
        2603: dup
        2604: bipush        8
        2606: aload         28
        2608: aastore
        2609: dup
        2610: bipush        9
        2612: aload         29
        2614: aastore
        2615: dup
        2616: bipush        10
        2618: aload         30
        2620: aastore
        2621: dup
        2622: bipush        11
        2624: aload         31
        2626: aastore
        2627: dup
        2628: bipush        12
        2630: aload         32
        2632: aastore
        2633: dup
        2634: bipush        13
        2636: aload         33
        2638: aastore
        2639: dup
        2640: bipush        14
        2642: aload         34
        2644: aastore
        2645: dup
        2646: bipush        15
        2648: aload         35
        2650: aastore
        2651: dup
        2652: bipush        16
        2654: aload         36
        2656: aastore
        2657: dup
        2658: bipush        17
        2660: aload         37
        2662: aastore
        2663: dup
        2664: bipush        18
        2666: iload         39
        2668: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2671: aastore
        2672: dup
        2673: bipush        19
        2675: iload         40
        2677: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2680: aastore
        2681: dup
        2682: bipush        20
        2684: aload         38
        2686: aastore
        2687: dup
        2688: bipush        21
        2690: aload         42
        2692: aastore
        2693: dup
        2694: bipush        22
        2696: aload         44
        2698: aastore
        2699: dup
        2700: bipush        23
        2702: aload         46
        2704: aastore
        2705: dup
        2706: bipush        24
        2708: aload         48
        2710: aastore
        2711: dup
        2712: bipush        25
        2714: aload         50
        2716: aastore
        2717: dup
        2718: bipush        26
        2720: aload         52
        2722: aastore
        2723: dup
        2724: bipush        27
        2726: aload         53
        2728: aastore
        2729: dup
        2730: bipush        28
        2732: aload         54
        2734: aastore
        2735: dup
        2736: bipush        29
        2738: aload         55
        2740: aastore
        2741: dup
        2742: bipush        30
        2744: aload         57
        2746: aastore
        2747: dup
        2748: bipush        31
        2750: aload         56
        2752: aastore
        2753: dup
        2754: bipush        32
        2756: aload         58
        2758: aastore
        2759: dup
        2760: bipush        33
        2762: aload         59
        2764: aastore
        2765: dup
        2766: bipush        34
        2768: aload         61
        2770: aastore
        2771: dup
        2772: bipush        35
        2774: aload         62
        2776: aastore
        2777: dup
        2778: bipush        36
        2780: aload         63
        2782: aastore
        2783: dup
        2784: bipush        37
        2786: aload         70
        2788: aastore
        2789: dup
        2790: bipush        38
        2792: aload         72
        2794: aastore
        2795: dup
        2796: bipush        39
        2798: aload         74
        2800: aastore
        2801: dup
        2802: bipush        40
        2804: aload         95
        2806: aastore
        2807: dup
        2808: bipush        41
        2810: aload         96
        2812: aastore
        2813: dup
        2814: bipush        42
        2816: aload         97
        2818: aastore
        2819: dup
        2820: bipush        43
        2822: aload         98
        2824: aastore
        2825: dup
        2826: bipush        44
        2828: aload         99
        2830: aastore
        2831: dup
        2832: bipush        45
        2834: aload         100
        2836: aastore
        2837: dup
        2838: bipush        46
        2840: aload         101
        2842: aastore
        2843: dup
        2844: bipush        47
        2846: aload         102
        2848: aastore
        2849: dup
        2850: bipush        48
        2852: aload         103
        2854: aastore
        2855: dup
        2856: bipush        49
        2858: aload         104
        2860: aastore
        2861: dup
        2862: bipush        50
        2864: aload         105
        2866: aastore
        2867: dup
        2868: bipush        51
        2870: aload         106
        2872: aastore
        2873: dup
        2874: bipush        52
        2876: aload         107
        2878: aastore
        2879: dup
        2880: bipush        53
        2882: aload         108
        2884: aastore
        2885: dup
        2886: bipush        54
        2888: aload         109
        2890: aastore
        2891: dup
        2892: bipush        55
        2894: aload         111
        2896: aastore
        2897: dup
        2898: bipush        56
        2900: aload         110
        2902: aastore
        2903: dup
        2904: bipush        57
        2906: aload         113
        2908: aastore
        2909: dup
        2910: bipush        58
        2912: aload         112
        2914: aastore
        2915: dup
        2916: bipush        59
        2918: aload         76
        2920: aastore
        2921: dup
        2922: bipush        60
        2924: aload         77
        2926: aastore
        2927: dup
        2928: bipush        61
        2930: aload         75
        2932: aastore
        2933: dup
        2934: bipush        62
        2936: aload         147
        2938: aastore
        2939: dup
        2940: bipush        63
        2942: aload         78
        2944: aastore
        2945: dup
        2946: bipush        64
        2948: aload         146
        2950: aastore
        2951: dup
        2952: bipush        65
        2954: aload         80
        2956: aastore
        2957: dup
        2958: bipush        66
        2960: aload         79
        2962: aastore
        2963: dup
        2964: bipush        67
        2966: aload         81
        2968: aastore
        2969: dup
        2970: bipush        68
        2972: aload         82
        2974: aastore
        2975: dup
        2976: bipush        69
        2978: aload         145
        2980: aastore
        2981: dup
        2982: bipush        70
        2984: aload         144
        2986: aastore
        2987: dup
        2988: bipush        71
        2990: aload         83
        2992: aastore
        2993: dup
        2994: bipush        72
        2996: aload         143
        2998: aastore
        2999: dup
        3000: bipush        73
        3002: aload         142
        3004: aastore
        3005: dup
        3006: bipush        74
        3008: aload         141
        3010: aastore
        3011: dup
        3012: bipush        75
        3014: aload         84
        3016: aastore
        3017: dup
        3018: bipush        76
        3020: aload         85
        3022: aastore
        3023: dup
        3024: bipush        77
        3026: aload         140
        3028: aastore
        3029: dup
        3030: bipush        78
        3032: aload         87
        3034: aastore
        3035: dup
        3036: bipush        79
        3038: aload         88
        3040: aastore
        3041: dup
        3042: bipush        80
        3044: aload         86
        3046: aastore
        3047: dup
        3048: bipush        81
        3050: aload         139
        3052: aastore
        3053: dup
        3054: bipush        82
        3056: aload         93
        3058: aastore
        3059: dup
        3060: bipush        83
        3062: aload         89
        3064: aastore
        3065: dup
        3066: bipush        84
        3068: aload         91
        3070: aastore
        3071: dup
        3072: bipush        85
        3074: aload         92
        3076: aastore
        3077: dup
        3078: bipush        86
        3080: aload         138
        3082: aastore
        3083: dup
        3084: bipush        87
        3086: aload         137
        3088: aastore
        3089: dup
        3090: bipush        88
        3092: aload         136
        3094: aastore
        3095: dup
        3096: bipush        89
        3098: aload         135
        3100: aastore
        3101: dup
        3102: bipush        90
        3104: aload         134
        3106: aastore
        3107: dup
        3108: bipush        91
        3110: aload         133
        3112: aastore
        3113: dup
        3114: bipush        92
        3116: aload         132
        3118: aastore
        3119: dup
        3120: bipush        93
        3122: aload         94
        3124: aastore
        3125: dup
        3126: bipush        94
        3128: aload         131
        3130: aastore
        3131: dup
        3132: bipush        95
        3134: aload         130
        3136: aastore
        3137: dup
        3138: bipush        96
        3140: aload         114
        3142: aastore
        3143: dup
        3144: bipush        97
        3146: aload         115
        3148: aastore
        3149: dup
        3150: bipush        98
        3152: aload         121
        3154: aastore
        3155: dup
        3156: bipush        99
        3158: aload         117
        3160: aastore
        3161: dup
        3162: bipush        100
        3164: aload         60
        3166: aastore
        3167: dup
        3168: bipush        101
        3170: aload         90
        3172: aastore
        3173: dup
        3174: bipush        102
        3176: aload         120
        3178: aastore
        3179: dup
        3180: bipush        103
        3182: aload         119
        3184: aastore
        3185: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3188: astore        148
        3190: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3193: bipush        45
        3195: aload         148
        3197: aastore
        3198: iconst_0
        3199: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3202: astore        149
        3204: iconst_0
        3205: istore        150
        3207: iload         150
        3209: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3212: astore        151
        3214: goto_w        3219
        3219: iconst_0
        3220: istore        152
        3222: iconst_1
        3223: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3226: astore        153
        3228: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3231: bipush        46
        3233: aaload
        3234: astore        154
        3236: new           #2                  // class Block
        3239: dup
        3240: sipush        248
        3243: iconst_2
        3244: anewarray     #4                  // class java/lang/Object
        3247: dup
        3248: iconst_0
        3249: aload         154
        3251: aastore
        3252: dup
        3253: iconst_1
        3254: aload         153
        3256: aastore
        3257: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3260: astore        155
        3262: new           #397                // class ocaml_fn_94
        3265: dup
        3266: aload         155
        3268: invokespecial #398                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3271: astore        156
        3273: iconst_0
        3274: istore        157
        3276: aload         156
        3278: iload         157
        3280: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3283: invokevirtual #402                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3286: astore        158
        3288: getstatic     #406                // Field java/lang/System.out:Ljava/io/PrintStream;
        3291: aload         158
        3293: checkcast     #29                 // class java/lang/Integer
        3296: invokevirtual #410                // Method java/lang/Integer.intValue:()I
        3299: invokevirtual #416                // Method java/io/PrintStream.println:(I)V
        3302: iconst_0
        3303: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3306: astore        159
        3308: new           #2                  // class Block
        3311: dup
        3312: iconst_0
        3313: iconst_2
        3314: anewarray     #4                  // class java/lang/Object
        3317: dup
        3318: iconst_0
        3319: aload         155
        3321: aastore
        3322: dup
        3323: iconst_1
        3324: aload         156
        3326: aastore
        3327: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3330: astore        160
        3332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3335: bipush        47
        3337: aload         160
        3339: aastore
        3340: iconst_0
        3341: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3344: astore        161
        3346: iconst_0
        3347: istore        162
        3349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3352: bipush        45
        3354: aaload
        3355: checkcast     #2                  // class Block
        3358: getfield      #419                // Field Block.fields:[Ljava/lang/Object;
        3361: bipush        102
        3363: aaload
        3364: astore        163
        3366: aload         163
        3368: checkcast     #172                // class Closure
        3371: iload         162
        3373: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3376: invokevirtual #402                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3379: astore        164
        3381: new           #2                  // class Block
        3384: dup
        3385: iconst_0
        3386: iconst_0
        3387: anewarray     #4                  // class java/lang/Object
        3390: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3393: astore        165
        3395: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3398: bipush        48
        3400: aload         165
        3402: aastore
        3403: iconst_0
        3404: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3407: astore        166
        3409: return
    }
    |}]

let%expect_test "emission: if/else with int compare" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (if 1 < 2 then 10 else 20) |};
  [%expect
    {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static java.lang.Object DLS_STATE;

      public static Block ARGV;

      public static void main(java.lang.String[]);
        Code:
           0: new           #2                  // class Block
           3: dup
           4: iconst_0
           5: aload_0
           6: arraylength
           7: iconst_1
           8: iadd
           9: anewarray     #4                  // class java/lang/Object
          12: astore_1
          13: aload_1
          14: iconst_0
          15: ldc           #6                  // String Main
          17: aastore
          18: aload_0
          19: iconst_0
          20: aload_1
          21: iconst_1
          22: aload_0
          23: arraylength
          24: invokestatic  #12                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          27: aload_1
          28: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          31: putstatic     #21                 // Field ARGV:LBlock;
          34: bipush        48
          36: anewarray     #4                  // class java/lang/Object
          39: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          42: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          45: iconst_0
          46: new           #2                  // class Block
          49: dup
          50: sipush        248
          53: iconst_2
          54: anewarray     #4                  // class java/lang/Object
          57: dup
          58: iconst_0
          59: ldc           #27                 // String Out_of_memory
          61: aastore
          62: dup
          63: iconst_1
          64: iconst_m1
          65: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: new           #2                  // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #4                  // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc           #35                 // String Sys_error
          92: aastore
          93: dup
          94: iconst_1
          95: bipush        -2
          97: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         100: aastore
         101: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         104: aastore
         105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         108: iconst_2
         109: new           #2                  // class Block
         112: dup
         113: sipush        248
         116: iconst_2
         117: anewarray     #4                  // class java/lang/Object
         120: dup
         121: iconst_0
         122: ldc           #37                 // String Failure
         124: aastore
         125: dup
         126: iconst_1
         127: bipush        -3
         129: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         132: aastore
         133: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         136: aastore
         137: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         140: iconst_3
         141: new           #2                  // class Block
         144: dup
         145: sipush        248
         148: iconst_2
         149: anewarray     #4                  // class java/lang/Object
         152: dup
         153: iconst_0
         154: ldc           #39                 // String Invalid_argument
         156: aastore
         157: dup
         158: iconst_1
         159: bipush        -4
         161: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         168: aastore
         169: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         172: iconst_4
         173: new           #2                  // class Block
         176: dup
         177: sipush        248
         180: iconst_2
         181: anewarray     #4                  // class java/lang/Object
         184: dup
         185: iconst_0
         186: ldc           #41                 // String End_of_file
         188: aastore
         189: dup
         190: iconst_1
         191: bipush        -5
         193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         196: aastore
         197: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         200: aastore
         201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         204: iconst_5
         205: new           #2                  // class Block
         208: dup
         209: sipush        248
         212: iconst_2
         213: anewarray     #4                  // class java/lang/Object
         216: dup
         217: iconst_0
         218: ldc           #43                 // String Division_by_zero
         220: aastore
         221: dup
         222: iconst_1
         223: bipush        -6
         225: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         228: aastore
         229: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: aastore
         233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         236: bipush        6
         238: new           #2                  // class Block
         241: dup
         242: sipush        248
         245: iconst_2
         246: anewarray     #4                  // class java/lang/Object
         249: dup
         250: iconst_0
         251: ldc           #45                 // String Not_found
         253: aastore
         254: dup
         255: iconst_1
         256: bipush        -7
         258: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         261: aastore
         262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         265: aastore
         266: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         269: bipush        7
         271: new           #2                  // class Block
         274: dup
         275: sipush        248
         278: iconst_2
         279: anewarray     #4                  // class java/lang/Object
         282: dup
         283: iconst_0
         284: ldc           #47                 // String Match_failure
         286: aastore
         287: dup
         288: iconst_1
         289: bipush        -8
         291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         294: aastore
         295: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         298: aastore
         299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         302: bipush        8
         304: new           #2                  // class Block
         307: dup
         308: sipush        248
         311: iconst_2
         312: anewarray     #4                  // class java/lang/Object
         315: dup
         316: iconst_0
         317: ldc           #49                 // String Stack_overflow
         319: aastore
         320: dup
         321: iconst_1
         322: bipush        -9
         324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         327: aastore
         328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         331: aastore
         332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         335: bipush        9
         337: new           #2                  // class Block
         340: dup
         341: sipush        248
         344: iconst_2
         345: anewarray     #4                  // class java/lang/Object
         348: dup
         349: iconst_0
         350: ldc           #51                 // String Sys_blocked_io
         352: aastore
         353: dup
         354: iconst_1
         355: bipush        -10
         357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         360: aastore
         361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         364: aastore
         365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         368: bipush        10
         370: new           #2                  // class Block
         373: dup
         374: sipush        248
         377: iconst_2
         378: anewarray     #4                  // class java/lang/Object
         381: dup
         382: iconst_0
         383: ldc           #53                 // String Assert_failure
         385: aastore
         386: dup
         387: iconst_1
         388: bipush        -11
         390: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         393: aastore
         394: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         397: aastore
         398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         401: bipush        11
         403: new           #2                  // class Block
         406: dup
         407: sipush        248
         410: iconst_2
         411: anewarray     #4                  // class java/lang/Object
         414: dup
         415: iconst_0
         416: ldc           #55                 // String Undefined_recursive_module
         418: aastore
         419: dup
         420: iconst_1
         421: bipush        -12
         423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         426: aastore
         427: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         430: aastore
         431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        12
         436: iconst_0
         437: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        13
         446: ldc           #57                 // String %,
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: bipush        14
         454: ldc           #59                 // String really_input
         456: aastore
         457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         460: bipush        15
         462: ldc           #61                 // String input
         464: aastore
         465: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         468: bipush        16
         470: new           #2                  // class Block
         473: dup
         474: iconst_0
         475: iconst_2
         476: anewarray     #4                  // class java/lang/Object
         479: dup
         480: iconst_0
         481: iconst_0
         482: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: new           #2                  // class Block
         491: dup
         492: iconst_0
         493: iconst_2
         494: anewarray     #4                  // class java/lang/Object
         497: dup
         498: iconst_0
         499: bipush        6
         501: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         504: aastore
         505: dup
         506: iconst_1
         507: iconst_0
         508: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         511: aastore
         512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         515: aastore
         516: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         519: aastore
         520: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         523: bipush        17
         525: new           #2                  // class Block
         528: dup
         529: iconst_0
         530: iconst_2
         531: anewarray     #4                  // class java/lang/Object
         534: dup
         535: iconst_0
         536: iconst_0
         537: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: new           #2                  // class Block
         546: dup
         547: iconst_0
         548: iconst_2
         549: anewarray     #4                  // class java/lang/Object
         552: dup
         553: iconst_0
         554: bipush        7
         556: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         559: aastore
         560: dup
         561: iconst_1
         562: iconst_0
         563: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         566: aastore
         567: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         570: aastore
         571: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         574: aastore
         575: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         578: bipush        18
         580: ldc           #63                 // String output_substring
         582: aastore
         583: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         586: bipush        19
         588: ldc           #65                 // String output
         590: aastore
         591: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        20
         596: new           #2                  // class Block
         599: dup
         600: iconst_0
         601: iconst_2
         602: anewarray     #4                  // class java/lang/Object
         605: dup
         606: iconst_0
         607: iconst_1
         608: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         611: aastore
         612: dup
         613: iconst_1
         614: new           #2                  // class Block
         617: dup
         618: iconst_0
         619: iconst_2
         620: anewarray     #4                  // class java/lang/Object
         623: dup
         624: iconst_0
         625: iconst_3
         626: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         629: aastore
         630: dup
         631: iconst_1
         632: new           #2                  // class Block
         635: dup
         636: iconst_0
         637: iconst_2
         638: anewarray     #4                  // class java/lang/Object
         641: dup
         642: iconst_0
         643: iconst_4
         644: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         647: aastore
         648: dup
         649: iconst_1
         650: new           #2                  // class Block
         653: dup
         654: iconst_0
         655: iconst_2
         656: anewarray     #4                  // class java/lang/Object
         659: dup
         660: iconst_0
         661: bipush        6
         663: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         666: aastore
         667: dup
         668: iconst_1
         669: iconst_0
         670: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         673: aastore
         674: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         677: aastore
         678: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         681: aastore
         682: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         685: aastore
         686: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: new           #2                  // class Block
         698: dup
         699: iconst_0
         700: iconst_2
         701: anewarray     #4                  // class java/lang/Object
         704: dup
         705: iconst_0
         706: iconst_1
         707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         710: aastore
         711: dup
         712: iconst_1
         713: new           #2                  // class Block
         716: dup
         717: iconst_0
         718: iconst_2
         719: anewarray     #4                  // class java/lang/Object
         722: dup
         723: iconst_0
         724: iconst_3
         725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         728: aastore
         729: dup
         730: iconst_1
         731: new           #2                  // class Block
         734: dup
         735: iconst_0
         736: iconst_2
         737: anewarray     #4                  // class java/lang/Object
         740: dup
         741: iconst_0
         742: iconst_4
         743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         746: aastore
         747: dup
         748: iconst_1
         749: new           #2                  // class Block
         752: dup
         753: iconst_0
         754: iconst_2
         755: anewarray     #4                  // class java/lang/Object
         758: dup
         759: iconst_0
         760: bipush        7
         762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         765: aastore
         766: dup
         767: iconst_1
         768: iconst_0
         769: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         772: aastore
         773: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         776: aastore
         777: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         784: aastore
         785: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        22
         794: ldc           #67                 // String %.12g
         796: aastore
         797: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         800: bipush        23
         802: ldc           #69                 // String .
         804: aastore
         805: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         808: bipush        24
         810: ldc           #71                 // String %d
         812: aastore
         813: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         816: bipush        25
         818: ldc           #73                 // String false
         820: aastore
         821: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         824: bipush        26
         826: ldc           #75                 // String true
         828: aastore
         829: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         832: bipush        27
         834: new           #2                  // class Block
         837: dup
         838: iconst_0
         839: iconst_1
         840: anewarray     #4                  // class java/lang/Object
         843: dup
         844: iconst_0
         845: iconst_1
         846: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         849: aastore
         850: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         853: aastore
         854: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         857: bipush        28
         859: new           #2                  // class Block
         862: dup
         863: iconst_0
         864: iconst_1
         865: anewarray     #4                  // class java/lang/Object
         868: dup
         869: iconst_0
         870: iconst_0
         871: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         874: aastore
         875: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         878: aastore
         879: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         882: bipush        29
         884: ldc           #73                 // String false
         886: aastore
         887: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         890: bipush        30
         892: ldc           #75                 // String true
         894: aastore
         895: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        31
         900: ldc           #77                 // String bool_of_string
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        32
         908: ldc           #75                 // String true
         910: aastore
         911: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        33
         916: ldc           #73                 // String false
         918: aastore
         919: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        34
         924: ldc           #79                 // String char_of_int
         926: aastore
         927: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        35
         932: ldc           #81                 // String index out of bounds
         934: aastore
         935: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        36
         940: ldc           #83                 // String Pervasives.array_bound_error
         942: aastore
         943: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        37
         948: ldc           #85                 // String Stdlib.Exit
         950: aastore
         951: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        38
         956: ldc           #86                 // int 0
         958: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         961: aastore
         962: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         965: bipush        39
         967: ldc           #86                 // int 0
         969: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         972: aastore
         973: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         976: bipush        40
         978: ldc           #87                 // int 1
         980: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc           #88                 // int -1
         991: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         994: aastore
         995: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         998: bipush        42
        1000: ldc           #89                 // int 0
        1002: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1005: aastore
        1006: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1009: bipush        43
        1011: ldc           #90                 // int 0
        1013: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1016: aastore
        1017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1020: bipush        44
        1022: ldc           #92                 // String Pervasives.do_at_exit
        1024: aastore
        1025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1028: bipush        45
        1030: iconst_0
        1031: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1034: aastore
        1035: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1038: bipush        46
        1040: iconst_0
        1041: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1044: aastore
        1045: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1048: bipush        47
        1050: iconst_0
        1051: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1054: aastore
        1055: aconst_null
        1056: astore_1
        1057: aload_1
        1058: astore_2
        1059: goto_w        1064
        1064: new           #94                 // class ocaml_fn_0
        1067: dup
        1068: invokespecial #97                 // Method ocaml_fn_0."<init>":()V
        1071: astore_3
        1072: new           #99                 // class ocaml_fn_1
        1075: dup
        1076: invokespecial #100                // Method ocaml_fn_1."<init>":()V
        1079: astore        4
        1081: new           #102                // class ocaml_fn_2
        1084: dup
        1085: invokespecial #103                // Method ocaml_fn_2."<init>":()V
        1088: astore        5
        1090: new           #2                  // class Block
        1093: dup
        1094: iconst_0
        1095: iconst_3
        1096: anewarray     #4                  // class java/lang/Object
        1099: dup
        1100: iconst_0
        1101: aload         4
        1103: aastore
        1104: dup
        1105: iconst_1
        1106: aload_3
        1107: aastore
        1108: dup
        1109: iconst_2
        1110: aload         5
        1112: aastore
        1113: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1116: astore        6
        1118: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1121: bipush        12
        1123: aload         6
        1125: aastore
        1126: iconst_0
        1127: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1130: astore        7
        1132: iconst_0
        1133: istore        8
        1135: iload         8
        1137: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1140: astore        9
        1142: goto_w        1147
        1147: sipush        199
        1150: istore        10
        1152: iconst_0
        1153: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1156: astore        11
        1158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1161: bipush        35
        1163: aaload
        1164: astore        12
        1166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1169: iconst_3
        1170: aaload
        1171: astore        13
        1173: new           #2                  // class Block
        1176: dup
        1177: iconst_0
        1178: iconst_2
        1179: anewarray     #4                  // class java/lang/Object
        1182: dup
        1183: iconst_0
        1184: aload         13
        1186: aastore
        1187: dup
        1188: iconst_1
        1189: aload         12
        1191: aastore
        1192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1195: astore        14
        1197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1200: bipush        36
        1202: aaload
        1203: astore        15
        1205: iconst_0
        1206: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1209: astore        16
        1211: new           #105                // class ocaml_fn_8
        1214: dup
        1215: invokespecial #106                // Method ocaml_fn_8."<init>":()V
        1218: astore        17
        1220: new           #108                // class ocaml_fn_9
        1223: dup
        1224: invokespecial #109                // Method ocaml_fn_9."<init>":()V
        1227: astore        18
        1229: iconst_0
        1230: istore        19
        1232: iconst_0
        1233: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1236: astore        20
        1238: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        37
        1243: aaload
        1244: astore        21
        1246: new           #2                  // class Block
        1249: dup
        1250: sipush        248
        1253: iconst_2
        1254: anewarray     #4                  // class java/lang/Object
        1257: dup
        1258: iconst_0
        1259: aload         21
        1261: aastore
        1262: dup
        1263: iconst_1
        1264: aload         20
        1266: aastore
        1267: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1270: astore        22
        1272: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1275: bipush        7
        1277: aaload
        1278: astore        23
        1280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1283: bipush        10
        1285: aaload
        1286: astore        24
        1288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1291: iconst_3
        1292: aaload
        1293: astore        25
        1295: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1298: iconst_2
        1299: aaload
        1300: astore        26
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        6
        1307: aaload
        1308: astore        27
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: iconst_0
        1314: aaload
        1315: astore        28
        1317: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1320: bipush        8
        1322: aaload
        1323: astore        29
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: iconst_1
        1329: aaload
        1330: astore        30
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: iconst_4
        1336: aaload
        1337: astore        31
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_5
        1343: aaload
        1344: astore        32
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: bipush        9
        1351: aaload
        1352: astore        33
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: bipush        11
        1359: aaload
        1360: astore        34
        1362: new           #111                // class ocaml_fn_10
        1365: dup
        1366: invokespecial #112                // Method ocaml_fn_10."<init>":()V
        1369: astore        35
        1371: new           #114                // class ocaml_fn_11
        1374: dup
        1375: invokespecial #115                // Method ocaml_fn_11."<init>":()V
        1378: astore        36
        1380: new           #117                // class ocaml_fn_12
        1383: dup
        1384: invokespecial #118                // Method ocaml_fn_12."<init>":()V
        1387: astore        37
        1389: new           #120                // class ocaml_fn_13
        1392: dup
        1393: invokespecial #121                // Method ocaml_fn_13."<init>":()V
        1396: astore        38
        1398: ldc           #122                // int 2147483647
        1400: istore        39
        1402: ldc           #123                // int -2147483648
        1404: istore        40
        1406: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1409: bipush        38
        1411: aaload
        1412: astore        41
        1414: ldc2_w        #124                // double 0.0d
        1417: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1420: astore        42
        1422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1425: bipush        39
        1427: aaload
        1428: astore        43
        1430: ldc2_w        #124                // double 0.0d
        1433: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1436: astore        44
        1438: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1441: bipush        40
        1443: aaload
        1444: astore        45
        1446: ldc2_w        #124                // double 0.0d
        1449: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1452: astore        46
        1454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1457: bipush        41
        1459: aaload
        1460: astore        47
        1462: ldc2_w        #124                // double 0.0d
        1465: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        48
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        42
        1475: aaload
        1476: astore        49
        1478: ldc2_w        #124                // double 0.0d
        1481: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1484: astore        50
        1486: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1489: bipush        43
        1491: aaload
        1492: astore        51
        1494: ldc2_w        #124                // double 0.0d
        1497: invokestatic  #130                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1500: astore        52
        1502: new           #132                // class ocaml_fn_14
        1505: dup
        1506: invokespecial #133                // Method ocaml_fn_14."<init>":()V
        1509: astore        53
        1511: new           #135                // class ocaml_fn_15
        1514: dup
        1515: aload         18
        1517: invokespecial #138                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1520: astore        54
        1522: new           #140                // class ocaml_fn_16
        1525: dup
        1526: invokespecial #141                // Method ocaml_fn_16."<init>":()V
        1529: astore        55
        1531: new           #143                // class ocaml_fn_17
        1534: dup
        1535: aload         18
        1537: invokespecial #144                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1540: astore        56
        1542: new           #146                // class ocaml_fn_18
        1545: dup
        1546: invokespecial #147                // Method ocaml_fn_18."<init>":()V
        1549: astore        57
        1551: new           #149                // class ocaml_fn_19
        1554: dup
        1555: invokespecial #150                // Method ocaml_fn_19."<init>":()V
        1558: astore        58
        1560: new           #152                // class ocaml_fn_20
        1563: dup
        1564: aload         26
        1566: invokespecial #153                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1569: astore        59
        1571: new           #155                // class ocaml_fn_21
        1574: dup
        1575: aload         53
        1577: invokespecial #156                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1580: astore        60
        1582: new           #158                // class ocaml_fn_22
        1585: dup
        1586: aload         60
        1588: invokespecial #159                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1591: astore        61
        1593: new           #161                // class ocaml_fn_23
        1596: dup
        1597: aload         26
        1599: invokespecial #162                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1602: astore        62
        1604: new           #164                // class ocaml_fn_24
        1607: dup
        1608: invokespecial #165                // Method ocaml_fn_24."<init>":()V
        1611: astore        63
        1613: new           #167                // class ocaml_fn_25
        1616: dup
        1617: invokespecial #168                // Method ocaml_fn_25."<init>":()V
        1620: astore        64
        1622: aload         63
        1624: checkcast     #164                // class ocaml_fn_24
        1627: aload         63
        1629: checkcast     #170                // class Closure
        1632: putfield      #174                // Field ocaml_fn_24.sibling_0:LClosure;
        1635: iconst_0
        1636: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1639: astore        65
        1641: aload         63
        1643: checkcast     #164                // class ocaml_fn_24
        1646: aload         64
        1648: checkcast     #170                // class Closure
        1651: putfield      #177                // Field ocaml_fn_24.sibling_1:LClosure;
        1654: iconst_0
        1655: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        66
        1660: aload         64
        1662: checkcast     #167                // class ocaml_fn_25
        1665: aload         63
        1667: checkcast     #170                // class Closure
        1670: putfield      #178                // Field ocaml_fn_25.sibling_0:LClosure;
        1673: iconst_0
        1674: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        67
        1679: aload         64
        1681: checkcast     #167                // class ocaml_fn_25
        1684: aload         64
        1686: checkcast     #170                // class Closure
        1689: putfield      #179                // Field ocaml_fn_25.sibling_1:LClosure;
        1692: iconst_0
        1693: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        68
        1698: iconst_0
        1699: istore        69
        1701: aconst_null
        1702: astore        70
        1704: iconst_1
        1705: istore        71
        1707: iload         71
        1709: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1712: astore        72
        1714: iconst_2
        1715: istore        73
        1717: iload         73
        1719: invokestatic  #185                // Method Channel.forDescriptor:(I)LChannel;
        1722: astore        74
        1724: new           #187                // class ocaml_fn_26
        1727: dup
        1728: invokespecial #188                // Method ocaml_fn_26."<init>":()V
        1731: astore        75
        1733: new           #190                // class ocaml_fn_27
        1736: dup
        1737: aload         75
        1739: invokespecial #191                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1742: astore        76
        1744: new           #193                // class ocaml_fn_28
        1747: dup
        1748: aload         75
        1750: invokespecial #194                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1753: astore        77
        1755: new           #196                // class ocaml_fn_29
        1758: dup
        1759: aload         30
        1761: invokespecial #197                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1764: astore        78
        1766: new           #199                // class ocaml_fn_30
        1769: dup
        1770: invokespecial #200                // Method ocaml_fn_30."<init>":()V
        1773: astore        79
        1775: new           #202                // class ocaml_fn_31
        1778: dup
        1779: invokespecial #203                // Method ocaml_fn_31."<init>":()V
        1782: astore        80
        1784: new           #205                // class ocaml_fn_32
        1787: dup
        1788: aload         18
        1790: invokespecial #206                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1793: astore        81
        1795: new           #208                // class ocaml_fn_33
        1798: dup
        1799: aload         18
        1801: invokespecial #209                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1804: astore        82
        1806: new           #211                // class ocaml_fn_34
        1809: dup
        1810: invokespecial #212                // Method ocaml_fn_34."<init>":()V
        1813: astore        83
        1815: new           #214                // class ocaml_fn_35
        1818: dup
        1819: invokespecial #215                // Method ocaml_fn_35."<init>":()V
        1822: astore        84
        1824: new           #217                // class ocaml_fn_36
        1827: dup
        1828: invokespecial #218                // Method ocaml_fn_36."<init>":()V
        1831: astore        85
        1833: new           #220                // class ocaml_fn_37
        1836: dup
        1837: invokespecial #221                // Method ocaml_fn_37."<init>":()V
        1840: astore        86
        1842: new           #223                // class ocaml_fn_38
        1845: dup
        1846: aload         86
        1848: invokespecial #224                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1851: astore        87
        1853: new           #226                // class ocaml_fn_39
        1856: dup
        1857: aload         86
        1859: invokespecial #227                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1862: astore        88
        1864: new           #229                // class ocaml_fn_40
        1867: dup
        1868: aload         18
        1870: invokespecial #230                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1873: astore        89
        1875: new           #232                // class ocaml_fn_41
        1878: dup
        1879: aload         31
        1881: invokespecial #233                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1884: astore        90
        1886: new           #235                // class ocaml_fn_42
        1889: dup
        1890: aload         18
        1892: aload         90
        1894: invokespecial #238                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1897: astore        91
        1899: new           #240                // class ocaml_fn_43
        1902: dup
        1903: aload         91
        1905: invokespecial #241                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1908: astore        92
        1910: new           #243                // class ocaml_fn_44
        1913: dup
        1914: aload         31
        1916: invokespecial #244                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1919: astore        93
        1921: new           #246                // class ocaml_fn_45
        1924: dup
        1925: invokespecial #247                // Method ocaml_fn_45."<init>":()V
        1928: astore        94
        1930: new           #249                // class ocaml_fn_46
        1933: dup
        1934: aload         72
        1936: invokespecial #250                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1939: astore        95
        1941: new           #252                // class ocaml_fn_47
        1944: dup
        1945: aload         72
        1947: aload         80
        1949: invokespecial #253                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        96
        1954: new           #255                // class ocaml_fn_48
        1957: dup
        1958: aload         72
        1960: aload         79
        1962: invokespecial #256                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1965: astore        97
        1967: new           #258                // class ocaml_fn_49
        1970: dup
        1971: aload         58
        1973: aload         72
        1975: aload         80
        1977: invokespecial #261                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1980: astore        98
        1982: new           #263                // class ocaml_fn_50
        1985: dup
        1986: aload         61
        1988: aload         72
        1990: aload         80
        1992: invokespecial #264                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1995: astore        99
        1997: new           #266                // class ocaml_fn_51
        2000: dup
        2001: aload         72
        2003: aload         80
        2005: invokespecial #267                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        100
        2010: new           #269                // class ocaml_fn_52
        2013: dup
        2014: aload         72
        2016: invokespecial #270                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2019: astore        101
        2021: new           #272                // class ocaml_fn_53
        2024: dup
        2025: aload         74
        2027: invokespecial #273                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2030: astore        102
        2032: new           #275                // class ocaml_fn_54
        2035: dup
        2036: aload         74
        2038: aload         80
        2040: invokespecial #276                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        103
        2045: new           #278                // class ocaml_fn_55
        2048: dup
        2049: aload         74
        2051: aload         79
        2053: invokespecial #279                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        104
        2058: new           #281                // class ocaml_fn_56
        2061: dup
        2062: aload         58
        2064: aload         74
        2066: aload         80
        2068: invokespecial #282                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2071: astore        105
        2073: new           #284                // class ocaml_fn_57
        2076: dup
        2077: aload         61
        2079: aload         74
        2081: aload         80
        2083: invokespecial #285                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        106
        2088: new           #287                // class ocaml_fn_58
        2091: dup
        2092: aload         74
        2094: aload         80
        2096: invokespecial #288                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        107
        2101: new           #290                // class ocaml_fn_59
        2104: dup
        2105: aload         74
        2107: invokespecial #291                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2110: astore        108
        2112: new           #293                // class ocaml_fn_60
        2115: dup
        2116: aload         70
        2118: aload         72
        2120: aload         93
        2122: invokespecial #294                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        109
        2127: new           #296                // class ocaml_fn_61
        2130: dup
        2131: aload         109
        2133: invokespecial #297                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2136: astore        110
        2138: new           #299                // class ocaml_fn_62
        2141: dup
        2142: aload         59
        2144: aload         109
        2146: invokespecial #300                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2149: astore        111
        2151: new           #302                // class ocaml_fn_63
        2154: dup
        2155: aload         109
        2157: invokespecial #303                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2160: astore        112
        2162: new           #305                // class ocaml_fn_64
        2165: dup
        2166: aload         62
        2168: aload         109
        2170: invokespecial #306                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        113
        2175: new           #308                // class ocaml_fn_65
        2178: dup
        2179: invokespecial #309                // Method ocaml_fn_65."<init>":()V
        2182: astore        114
        2184: new           #311                // class ocaml_fn_66
        2187: dup
        2188: aload         53
        2190: invokespecial #312                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2193: astore        115
        2195: new           #2                  // class Block
        2198: dup
        2199: iconst_0
        2200: iconst_1
        2201: anewarray     #4                  // class java/lang/Object
        2204: dup
        2205: iconst_0
        2206: aload         78
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        116
        2214: new           #314                // class ocaml_fn_67
        2217: dup
        2218: aload         116
        2220: invokespecial #315                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2223: astore        117
        2225: new           #317                // class ocaml_fn_68
        2228: dup
        2229: invokespecial #318                // Method ocaml_fn_68."<init>":()V
        2232: astore        118
        2234: new           #2                  // class Block
        2237: dup
        2238: iconst_0
        2239: iconst_1
        2240: anewarray     #4                  // class java/lang/Object
        2243: dup
        2244: iconst_0
        2245: aload         118
        2247: aastore
        2248: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2251: astore        119
        2253: new           #320                // class ocaml_fn_69
        2256: dup
        2257: aload         116
        2259: aload         119
        2261: invokespecial #321                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        120
        2266: new           #323                // class ocaml_fn_70
        2269: dup
        2270: aload         120
        2272: invokespecial #324                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2275: astore        121
        2277: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2280: bipush        44
        2282: aaload
        2283: astore        122
        2285: iconst_0
        2286: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2289: astore        123
        2291: new           #326                // class ocaml_fn_71
        2294: dup
        2295: invokespecial #327                // Method ocaml_fn_71."<init>":()V
        2298: astore        124
        2300: new           #329                // class ocaml_fn_72
        2303: dup
        2304: invokespecial #330                // Method ocaml_fn_72."<init>":()V
        2307: astore        125
        2309: new           #332                // class ocaml_fn_73
        2312: dup
        2313: invokespecial #333                // Method ocaml_fn_73."<init>":()V
        2316: astore        126
        2318: new           #335                // class ocaml_fn_74
        2321: dup
        2322: invokespecial #336                // Method ocaml_fn_74."<init>":()V
        2325: astore        127
        2327: new           #338                // class ocaml_fn_75
        2330: dup
        2331: invokespecial #339                // Method ocaml_fn_75."<init>":()V
        2334: astore        128
        2336: new           #341                // class ocaml_fn_76
        2339: dup
        2340: invokespecial #342                // Method ocaml_fn_76."<init>":()V
        2343: astore        129
        2345: new           #2                  // class Block
        2348: dup
        2349: iconst_0
        2350: bipush        6
        2352: anewarray     #4                  // class java/lang/Object
        2355: dup
        2356: iconst_0
        2357: aload         129
        2359: aastore
        2360: dup
        2361: iconst_1
        2362: aload         128
        2364: aastore
        2365: dup
        2366: iconst_2
        2367: aload         127
        2369: aastore
        2370: dup
        2371: iconst_3
        2372: aload         126
        2374: aastore
        2375: dup
        2376: iconst_4
        2377: aload         125
        2379: aastore
        2380: dup
        2381: iconst_5
        2382: aload         124
        2384: aastore
        2385: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2388: astore        130
        2390: new           #344                // class ocaml_fn_77
        2393: dup
        2394: invokespecial #345                // Method ocaml_fn_77."<init>":()V
        2397: astore        131
        2399: new           #347                // class ocaml_fn_78
        2402: dup
        2403: invokespecial #348                // Method ocaml_fn_78."<init>":()V
        2406: astore        132
        2408: new           #350                // class ocaml_fn_79
        2411: dup
        2412: invokespecial #351                // Method ocaml_fn_79."<init>":()V
        2415: astore        133
        2417: new           #353                // class ocaml_fn_80
        2420: dup
        2421: invokespecial #354                // Method ocaml_fn_80."<init>":()V
        2424: astore        134
        2426: new           #356                // class ocaml_fn_81
        2429: dup
        2430: invokespecial #357                // Method ocaml_fn_81."<init>":()V
        2433: astore        135
        2435: new           #359                // class ocaml_fn_82
        2438: dup
        2439: invokespecial #360                // Method ocaml_fn_82."<init>":()V
        2442: astore        136
        2444: new           #362                // class ocaml_fn_83
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_83."<init>":()V
        2451: astore        137
        2453: new           #365                // class ocaml_fn_84
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_84."<init>":()V
        2460: astore        138
        2462: new           #368                // class ocaml_fn_85
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_85."<init>":()V
        2469: astore        139
        2471: new           #371                // class ocaml_fn_86
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_86."<init>":()V
        2478: astore        140
        2480: new           #374                // class ocaml_fn_87
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_87."<init>":()V
        2487: astore        141
        2489: new           #377                // class ocaml_fn_88
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_88."<init>":()V
        2496: astore        142
        2498: new           #380                // class ocaml_fn_89
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_89."<init>":()V
        2505: astore        143
        2507: new           #383                // class ocaml_fn_90
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_90."<init>":()V
        2514: astore        144
        2516: new           #386                // class ocaml_fn_91
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_91."<init>":()V
        2523: astore        145
        2525: new           #389                // class ocaml_fn_92
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_92."<init>":()V
        2532: astore        146
        2534: new           #392                // class ocaml_fn_93
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_93."<init>":()V
        2541: astore        147
        2543: new           #2                  // class Block
        2546: dup
        2547: iconst_0
        2548: bipush        104
        2550: anewarray     #4                  // class java/lang/Object
        2553: dup
        2554: iconst_0
        2555: aload         18
        2557: aastore
        2558: dup
        2559: iconst_1
        2560: aload         17
        2562: aastore
        2563: dup
        2564: iconst_2
        2565: aload         22
        2567: aastore
        2568: dup
        2569: iconst_3
        2570: aload         23
        2572: aastore
        2573: dup
        2574: iconst_4
        2575: aload         24
        2577: aastore
        2578: dup
        2579: iconst_5
        2580: aload         25
        2582: aastore
        2583: dup
        2584: bipush        6
        2586: aload         26
        2588: aastore
        2589: dup
        2590: bipush        7
        2592: aload         27
        2594: aastore
        2595: dup
        2596: bipush        8
        2598: aload         28
        2600: aastore
        2601: dup
        2602: bipush        9
        2604: aload         29
        2606: aastore
        2607: dup
        2608: bipush        10
        2610: aload         30
        2612: aastore
        2613: dup
        2614: bipush        11
        2616: aload         31
        2618: aastore
        2619: dup
        2620: bipush        12
        2622: aload         32
        2624: aastore
        2625: dup
        2626: bipush        13
        2628: aload         33
        2630: aastore
        2631: dup
        2632: bipush        14
        2634: aload         34
        2636: aastore
        2637: dup
        2638: bipush        15
        2640: aload         35
        2642: aastore
        2643: dup
        2644: bipush        16
        2646: aload         36
        2648: aastore
        2649: dup
        2650: bipush        17
        2652: aload         37
        2654: aastore
        2655: dup
        2656: bipush        18
        2658: iload         39
        2660: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2663: aastore
        2664: dup
        2665: bipush        19
        2667: iload         40
        2669: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2672: aastore
        2673: dup
        2674: bipush        20
        2676: aload         38
        2678: aastore
        2679: dup
        2680: bipush        21
        2682: aload         42
        2684: aastore
        2685: dup
        2686: bipush        22
        2688: aload         44
        2690: aastore
        2691: dup
        2692: bipush        23
        2694: aload         46
        2696: aastore
        2697: dup
        2698: bipush        24
        2700: aload         48
        2702: aastore
        2703: dup
        2704: bipush        25
        2706: aload         50
        2708: aastore
        2709: dup
        2710: bipush        26
        2712: aload         52
        2714: aastore
        2715: dup
        2716: bipush        27
        2718: aload         53
        2720: aastore
        2721: dup
        2722: bipush        28
        2724: aload         54
        2726: aastore
        2727: dup
        2728: bipush        29
        2730: aload         55
        2732: aastore
        2733: dup
        2734: bipush        30
        2736: aload         57
        2738: aastore
        2739: dup
        2740: bipush        31
        2742: aload         56
        2744: aastore
        2745: dup
        2746: bipush        32
        2748: aload         58
        2750: aastore
        2751: dup
        2752: bipush        33
        2754: aload         59
        2756: aastore
        2757: dup
        2758: bipush        34
        2760: aload         61
        2762: aastore
        2763: dup
        2764: bipush        35
        2766: aload         62
        2768: aastore
        2769: dup
        2770: bipush        36
        2772: aload         63
        2774: aastore
        2775: dup
        2776: bipush        37
        2778: aload         70
        2780: aastore
        2781: dup
        2782: bipush        38
        2784: aload         72
        2786: aastore
        2787: dup
        2788: bipush        39
        2790: aload         74
        2792: aastore
        2793: dup
        2794: bipush        40
        2796: aload         95
        2798: aastore
        2799: dup
        2800: bipush        41
        2802: aload         96
        2804: aastore
        2805: dup
        2806: bipush        42
        2808: aload         97
        2810: aastore
        2811: dup
        2812: bipush        43
        2814: aload         98
        2816: aastore
        2817: dup
        2818: bipush        44
        2820: aload         99
        2822: aastore
        2823: dup
        2824: bipush        45
        2826: aload         100
        2828: aastore
        2829: dup
        2830: bipush        46
        2832: aload         101
        2834: aastore
        2835: dup
        2836: bipush        47
        2838: aload         102
        2840: aastore
        2841: dup
        2842: bipush        48
        2844: aload         103
        2846: aastore
        2847: dup
        2848: bipush        49
        2850: aload         104
        2852: aastore
        2853: dup
        2854: bipush        50
        2856: aload         105
        2858: aastore
        2859: dup
        2860: bipush        51
        2862: aload         106
        2864: aastore
        2865: dup
        2866: bipush        52
        2868: aload         107
        2870: aastore
        2871: dup
        2872: bipush        53
        2874: aload         108
        2876: aastore
        2877: dup
        2878: bipush        54
        2880: aload         109
        2882: aastore
        2883: dup
        2884: bipush        55
        2886: aload         111
        2888: aastore
        2889: dup
        2890: bipush        56
        2892: aload         110
        2894: aastore
        2895: dup
        2896: bipush        57
        2898: aload         113
        2900: aastore
        2901: dup
        2902: bipush        58
        2904: aload         112
        2906: aastore
        2907: dup
        2908: bipush        59
        2910: aload         76
        2912: aastore
        2913: dup
        2914: bipush        60
        2916: aload         77
        2918: aastore
        2919: dup
        2920: bipush        61
        2922: aload         75
        2924: aastore
        2925: dup
        2926: bipush        62
        2928: aload         147
        2930: aastore
        2931: dup
        2932: bipush        63
        2934: aload         78
        2936: aastore
        2937: dup
        2938: bipush        64
        2940: aload         146
        2942: aastore
        2943: dup
        2944: bipush        65
        2946: aload         80
        2948: aastore
        2949: dup
        2950: bipush        66
        2952: aload         79
        2954: aastore
        2955: dup
        2956: bipush        67
        2958: aload         81
        2960: aastore
        2961: dup
        2962: bipush        68
        2964: aload         82
        2966: aastore
        2967: dup
        2968: bipush        69
        2970: aload         145
        2972: aastore
        2973: dup
        2974: bipush        70
        2976: aload         144
        2978: aastore
        2979: dup
        2980: bipush        71
        2982: aload         83
        2984: aastore
        2985: dup
        2986: bipush        72
        2988: aload         143
        2990: aastore
        2991: dup
        2992: bipush        73
        2994: aload         142
        2996: aastore
        2997: dup
        2998: bipush        74
        3000: aload         141
        3002: aastore
        3003: dup
        3004: bipush        75
        3006: aload         84
        3008: aastore
        3009: dup
        3010: bipush        76
        3012: aload         85
        3014: aastore
        3015: dup
        3016: bipush        77
        3018: aload         140
        3020: aastore
        3021: dup
        3022: bipush        78
        3024: aload         87
        3026: aastore
        3027: dup
        3028: bipush        79
        3030: aload         88
        3032: aastore
        3033: dup
        3034: bipush        80
        3036: aload         86
        3038: aastore
        3039: dup
        3040: bipush        81
        3042: aload         139
        3044: aastore
        3045: dup
        3046: bipush        82
        3048: aload         93
        3050: aastore
        3051: dup
        3052: bipush        83
        3054: aload         89
        3056: aastore
        3057: dup
        3058: bipush        84
        3060: aload         91
        3062: aastore
        3063: dup
        3064: bipush        85
        3066: aload         92
        3068: aastore
        3069: dup
        3070: bipush        86
        3072: aload         138
        3074: aastore
        3075: dup
        3076: bipush        87
        3078: aload         137
        3080: aastore
        3081: dup
        3082: bipush        88
        3084: aload         136
        3086: aastore
        3087: dup
        3088: bipush        89
        3090: aload         135
        3092: aastore
        3093: dup
        3094: bipush        90
        3096: aload         134
        3098: aastore
        3099: dup
        3100: bipush        91
        3102: aload         133
        3104: aastore
        3105: dup
        3106: bipush        92
        3108: aload         132
        3110: aastore
        3111: dup
        3112: bipush        93
        3114: aload         94
        3116: aastore
        3117: dup
        3118: bipush        94
        3120: aload         131
        3122: aastore
        3123: dup
        3124: bipush        95
        3126: aload         130
        3128: aastore
        3129: dup
        3130: bipush        96
        3132: aload         114
        3134: aastore
        3135: dup
        3136: bipush        97
        3138: aload         115
        3140: aastore
        3141: dup
        3142: bipush        98
        3144: aload         121
        3146: aastore
        3147: dup
        3148: bipush        99
        3150: aload         117
        3152: aastore
        3153: dup
        3154: bipush        100
        3156: aload         60
        3158: aastore
        3159: dup
        3160: bipush        101
        3162: aload         90
        3164: aastore
        3165: dup
        3166: bipush        102
        3168: aload         120
        3170: aastore
        3171: dup
        3172: bipush        103
        3174: aload         119
        3176: aastore
        3177: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3180: astore        148
        3182: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3185: bipush        45
        3187: aload         148
        3189: aastore
        3190: iconst_0
        3191: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3194: astore        149
        3196: iconst_1
        3197: istore        150
        3199: iconst_0
        3200: istore        151
        3202: iload         151
        3204: ifeq          3219
        3207: iload         150
        3209: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3212: astore        152
        3214: goto_w        3247
        3219: iload         150
        3221: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3224: astore        153
        3226: goto_w        3231
        3231: bipush        10
        3233: istore        154
        3235: iload         154
        3237: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3240: astore        155
        3242: goto_w        3263
        3247: bipush        20
        3249: istore        156
        3251: iload         156
        3253: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3256: astore        155
        3258: goto_w        3263
        3263: getstatic     #397                // Field java/lang/System.out:Ljava/io/PrintStream;
        3266: aload         155
        3268: checkcast     #29                 // class java/lang/Integer
        3271: invokevirtual #401                // Method java/lang/Integer.intValue:()I
        3274: invokevirtual #407                // Method java/io/PrintStream.println:(I)V
        3277: iconst_0
        3278: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3281: astore        157
        3283: new           #2                  // class Block
        3286: dup
        3287: iconst_0
        3288: iconst_0
        3289: anewarray     #4                  // class java/lang/Object
        3292: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3295: astore        158
        3297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3300: bipush        46
        3302: aload         158
        3304: aastore
        3305: iconst_0
        3306: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3309: astore        159
        3311: iconst_0
        3312: istore        160
        3314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3317: bipush        45
        3319: aaload
        3320: checkcast     #2                  // class Block
        3323: getfield      #410                // Field Block.fields:[Ljava/lang/Object;
        3326: bipush        102
        3328: aaload
        3329: astore        161
        3331: aload         161
        3333: checkcast     #170                // class Closure
        3336: iload         160
        3338: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3341: invokevirtual #414                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3344: astore        162
        3346: new           #2                  // class Block
        3349: dup
        3350: iconst_0
        3351: iconst_0
        3352: anewarray     #4                  // class java/lang/Object
        3355: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3358: astore        163
        3360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3363: bipush        47
        3365: aload         163
        3367: aastore
        3368: iconst_0
        3369: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3372: astore        164
        3374: return
    }
    |}]
