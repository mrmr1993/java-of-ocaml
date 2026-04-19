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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: ldc           #106                // String hi
        1048: aastore
        1049: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1052: bipush        47
        1054: iconst_0
        1055: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1058: aastore
        1059: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1062: bipush        48
        1064: iconst_0
        1065: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1068: aastore
        1069: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1072: iconst_4
        1073: aaload
        1074: putstatic     #112                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1077: aconst_null
        1078: astore_1
        1079: aload_1
        1080: astore_2
        1081: goto_w        1086
        1086: new           #114                // class ocaml_fn_0
        1089: dup
        1090: invokespecial #117                // Method ocaml_fn_0."<init>":()V
        1093: astore_3
        1094: new           #119                // class ocaml_fn_1
        1097: dup
        1098: invokespecial #120                // Method ocaml_fn_1."<init>":()V
        1101: astore        4
        1103: new           #122                // class ocaml_fn_2
        1106: dup
        1107: invokespecial #123                // Method ocaml_fn_2."<init>":()V
        1110: astore        5
        1112: new           #2                  // class Block
        1115: dup
        1116: iconst_0
        1117: iconst_3
        1118: anewarray     #4                  // class java/lang/Object
        1121: dup
        1122: iconst_0
        1123: aload         4
        1125: aastore
        1126: dup
        1127: iconst_1
        1128: aload_3
        1129: aastore
        1130: dup
        1131: iconst_2
        1132: aload         5
        1134: aastore
        1135: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1138: astore        6
        1140: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1143: bipush        12
        1145: aload         6
        1147: aastore
        1148: iconst_0
        1149: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1152: astore        7
        1154: iconst_0
        1155: istore        8
        1157: iload         8
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        9
        1164: goto_w        1169
        1169: sipush        199
        1172: istore        10
        1174: iconst_0
        1175: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1178: astore        11
        1180: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1183: bipush        35
        1185: aaload
        1186: astore        12
        1188: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1191: iconst_3
        1192: aaload
        1193: astore        13
        1195: new           #2                  // class Block
        1198: dup
        1199: iconst_0
        1200: iconst_2
        1201: anewarray     #4                  // class java/lang/Object
        1204: dup
        1205: iconst_0
        1206: aload         13
        1208: aastore
        1209: dup
        1210: iconst_1
        1211: aload         12
        1213: aastore
        1214: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1217: astore        14
        1219: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1222: bipush        36
        1224: aaload
        1225: astore        15
        1227: iconst_0
        1228: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1231: astore        16
        1233: new           #125                // class ocaml_fn_8
        1236: dup
        1237: invokespecial #126                // Method ocaml_fn_8."<init>":()V
        1240: astore        17
        1242: new           #128                // class ocaml_fn_9
        1245: dup
        1246: invokespecial #129                // Method ocaml_fn_9."<init>":()V
        1249: astore        18
        1251: iconst_0
        1252: istore        19
        1254: iconst_0
        1255: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1258: astore        20
        1260: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1263: bipush        37
        1265: aaload
        1266: astore        21
        1268: new           #2                  // class Block
        1271: dup
        1272: sipush        248
        1275: iconst_2
        1276: anewarray     #4                  // class java/lang/Object
        1279: dup
        1280: iconst_0
        1281: aload         21
        1283: aastore
        1284: dup
        1285: iconst_1
        1286: aload         20
        1288: aastore
        1289: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1292: astore        22
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        7
        1299: aaload
        1300: astore        23
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        10
        1307: aaload
        1308: astore        24
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: iconst_3
        1314: aaload
        1315: astore        25
        1317: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1320: iconst_2
        1321: aaload
        1322: astore        26
        1324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1327: bipush        6
        1329: aaload
        1330: astore        27
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: iconst_0
        1336: aaload
        1337: astore        28
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: bipush        8
        1344: aaload
        1345: astore        29
        1347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1350: iconst_1
        1351: aaload
        1352: astore        30
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: iconst_4
        1358: aaload
        1359: astore        31
        1361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1364: iconst_5
        1365: aaload
        1366: astore        32
        1368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1371: bipush        9
        1373: aaload
        1374: astore        33
        1376: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1379: bipush        11
        1381: aaload
        1382: astore        34
        1384: new           #131                // class ocaml_fn_10
        1387: dup
        1388: invokespecial #132                // Method ocaml_fn_10."<init>":()V
        1391: astore        35
        1393: new           #134                // class ocaml_fn_11
        1396: dup
        1397: invokespecial #135                // Method ocaml_fn_11."<init>":()V
        1400: astore        36
        1402: new           #137                // class ocaml_fn_12
        1405: dup
        1406: invokespecial #138                // Method ocaml_fn_12."<init>":()V
        1409: astore        37
        1411: new           #140                // class ocaml_fn_13
        1414: dup
        1415: invokespecial #141                // Method ocaml_fn_13."<init>":()V
        1418: astore        38
        1420: ldc           #142                // int 2147483647
        1422: istore        39
        1424: ldc           #143                // int -2147483648
        1426: istore        40
        1428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1431: bipush        38
        1433: aaload
        1434: astore        41
        1436: aload         41
        1438: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1441: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1444: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1447: astore        42
        1449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1452: bipush        39
        1454: aaload
        1455: astore        43
        1457: aload         43
        1459: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1462: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1465: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        44
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        40
        1475: aaload
        1476: astore        45
        1478: aload         45
        1480: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1483: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1486: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1489: astore        46
        1491: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1494: bipush        41
        1496: aaload
        1497: astore        47
        1499: aload         47
        1501: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1504: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1507: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1510: astore        48
        1512: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1515: bipush        42
        1517: aaload
        1518: astore        49
        1520: aload         49
        1522: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1525: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1528: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1531: astore        50
        1533: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1536: bipush        43
        1538: aaload
        1539: astore        51
        1541: aload         51
        1543: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1546: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1549: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1552: astore        52
        1554: new           #158                // class ocaml_fn_14
        1557: dup
        1558: invokespecial #159                // Method ocaml_fn_14."<init>":()V
        1561: astore        53
        1563: new           #161                // class ocaml_fn_15
        1566: dup
        1567: aload         18
        1569: invokespecial #164                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1572: astore        54
        1574: new           #166                // class ocaml_fn_16
        1577: dup
        1578: invokespecial #167                // Method ocaml_fn_16."<init>":()V
        1581: astore        55
        1583: new           #169                // class ocaml_fn_17
        1586: dup
        1587: aload         18
        1589: invokespecial #170                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1592: astore        56
        1594: new           #172                // class ocaml_fn_18
        1597: dup
        1598: invokespecial #173                // Method ocaml_fn_18."<init>":()V
        1601: astore        57
        1603: new           #175                // class ocaml_fn_19
        1606: dup
        1607: invokespecial #176                // Method ocaml_fn_19."<init>":()V
        1610: astore        58
        1612: new           #178                // class ocaml_fn_20
        1615: dup
        1616: aload         26
        1618: invokespecial #179                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1621: astore        59
        1623: new           #181                // class ocaml_fn_21
        1626: dup
        1627: aload         53
        1629: invokespecial #182                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1632: astore        60
        1634: new           #184                // class ocaml_fn_22
        1637: dup
        1638: aload         60
        1640: invokespecial #185                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1643: astore        61
        1645: new           #187                // class ocaml_fn_23
        1648: dup
        1649: aload         26
        1651: invokespecial #188                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1654: astore        62
        1656: new           #190                // class ocaml_fn_24
        1659: dup
        1660: invokespecial #191                // Method ocaml_fn_24."<init>":()V
        1663: astore        63
        1665: new           #193                // class ocaml_fn_25
        1668: dup
        1669: invokespecial #194                // Method ocaml_fn_25."<init>":()V
        1672: astore        64
        1674: aload         63
        1676: checkcast     #190                // class ocaml_fn_24
        1679: aload         63
        1681: checkcast     #196                // class Closure
        1684: putfield      #200                // Field ocaml_fn_24.sibling_0:LClosure;
        1687: iconst_0
        1688: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1691: astore        65
        1693: aload         63
        1695: checkcast     #190                // class ocaml_fn_24
        1698: aload         64
        1700: checkcast     #196                // class Closure
        1703: putfield      #203                // Field ocaml_fn_24.sibling_1:LClosure;
        1706: iconst_0
        1707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1710: astore        66
        1712: aload         64
        1714: checkcast     #193                // class ocaml_fn_25
        1717: aload         63
        1719: checkcast     #196                // class Closure
        1722: putfield      #204                // Field ocaml_fn_25.sibling_0:LClosure;
        1725: iconst_0
        1726: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1729: astore        67
        1731: aload         64
        1733: checkcast     #193                // class ocaml_fn_25
        1736: aload         64
        1738: checkcast     #196                // class Closure
        1741: putfield      #205                // Field ocaml_fn_25.sibling_1:LClosure;
        1744: iconst_0
        1745: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1748: astore        68
        1750: iconst_0
        1751: istore        69
        1753: iload         69
        1755: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1758: astore        70
        1760: iconst_1
        1761: istore        71
        1763: iload         71
        1765: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1768: astore        72
        1770: iconst_2
        1771: istore        73
        1773: iload         73
        1775: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1778: astore        74
        1780: new           #211                // class ocaml_fn_26
        1783: dup
        1784: invokespecial #212                // Method ocaml_fn_26."<init>":()V
        1787: astore        75
        1789: new           #214                // class ocaml_fn_27
        1792: dup
        1793: aload         75
        1795: invokespecial #215                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1798: astore        76
        1800: new           #217                // class ocaml_fn_28
        1803: dup
        1804: aload         75
        1806: invokespecial #218                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1809: astore        77
        1811: new           #220                // class ocaml_fn_29
        1814: dup
        1815: aload         30
        1817: invokespecial #221                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1820: astore        78
        1822: new           #223                // class ocaml_fn_30
        1825: dup
        1826: invokespecial #224                // Method ocaml_fn_30."<init>":()V
        1829: astore        79
        1831: new           #226                // class ocaml_fn_31
        1834: dup
        1835: invokespecial #227                // Method ocaml_fn_31."<init>":()V
        1838: astore        80
        1840: new           #229                // class ocaml_fn_32
        1843: dup
        1844: aload         18
        1846: invokespecial #230                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1849: astore        81
        1851: new           #232                // class ocaml_fn_33
        1854: dup
        1855: aload         18
        1857: invokespecial #233                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1860: astore        82
        1862: new           #235                // class ocaml_fn_34
        1865: dup
        1866: invokespecial #236                // Method ocaml_fn_34."<init>":()V
        1869: astore        83
        1871: new           #238                // class ocaml_fn_35
        1874: dup
        1875: invokespecial #239                // Method ocaml_fn_35."<init>":()V
        1878: astore        84
        1880: new           #241                // class ocaml_fn_36
        1883: dup
        1884: invokespecial #242                // Method ocaml_fn_36."<init>":()V
        1887: astore        85
        1889: new           #244                // class ocaml_fn_37
        1892: dup
        1893: invokespecial #245                // Method ocaml_fn_37."<init>":()V
        1896: astore        86
        1898: new           #247                // class ocaml_fn_38
        1901: dup
        1902: aload         86
        1904: invokespecial #248                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1907: astore        87
        1909: new           #250                // class ocaml_fn_39
        1912: dup
        1913: aload         86
        1915: invokespecial #251                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1918: astore        88
        1920: new           #253                // class ocaml_fn_40
        1923: dup
        1924: aload         18
        1926: invokespecial #254                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1929: astore        89
        1931: new           #256                // class ocaml_fn_41
        1934: dup
        1935: aload         31
        1937: invokespecial #257                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1940: astore        90
        1942: new           #259                // class ocaml_fn_42
        1945: dup
        1946: aload         18
        1948: aload         90
        1950: invokespecial #262                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        91
        1955: new           #264                // class ocaml_fn_43
        1958: dup
        1959: aload         91
        1961: invokespecial #265                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1964: astore        92
        1966: new           #267                // class ocaml_fn_44
        1969: dup
        1970: aload         31
        1972: invokespecial #268                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1975: astore        93
        1977: new           #270                // class ocaml_fn_45
        1980: dup
        1981: invokespecial #271                // Method ocaml_fn_45."<init>":()V
        1984: astore        94
        1986: new           #273                // class ocaml_fn_46
        1989: dup
        1990: aload         72
        1992: invokespecial #274                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1995: astore        95
        1997: new           #276                // class ocaml_fn_47
        2000: dup
        2001: aload         72
        2003: aload         80
        2005: invokespecial #277                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        96
        2010: new           #279                // class ocaml_fn_48
        2013: dup
        2014: aload         72
        2016: aload         79
        2018: invokespecial #280                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        97
        2023: new           #282                // class ocaml_fn_49
        2026: dup
        2027: aload         58
        2029: aload         72
        2031: aload         80
        2033: invokespecial #285                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2036: astore        98
        2038: new           #287                // class ocaml_fn_50
        2041: dup
        2042: aload         61
        2044: aload         72
        2046: aload         80
        2048: invokespecial #288                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2051: astore        99
        2053: new           #290                // class ocaml_fn_51
        2056: dup
        2057: aload         72
        2059: aload         80
        2061: invokespecial #291                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        100
        2066: new           #293                // class ocaml_fn_52
        2069: dup
        2070: aload         72
        2072: invokespecial #294                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2075: astore        101
        2077: new           #296                // class ocaml_fn_53
        2080: dup
        2081: aload         74
        2083: invokespecial #297                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2086: astore        102
        2088: new           #299                // class ocaml_fn_54
        2091: dup
        2092: aload         74
        2094: aload         80
        2096: invokespecial #300                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        103
        2101: new           #302                // class ocaml_fn_55
        2104: dup
        2105: aload         74
        2107: aload         79
        2109: invokespecial #303                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        104
        2114: new           #305                // class ocaml_fn_56
        2117: dup
        2118: aload         58
        2120: aload         74
        2122: aload         80
        2124: invokespecial #306                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2127: astore        105
        2129: new           #308                // class ocaml_fn_57
        2132: dup
        2133: aload         61
        2135: aload         74
        2137: aload         80
        2139: invokespecial #309                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2142: astore        106
        2144: new           #311                // class ocaml_fn_58
        2147: dup
        2148: aload         74
        2150: aload         80
        2152: invokespecial #312                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        107
        2157: new           #314                // class ocaml_fn_59
        2160: dup
        2161: aload         74
        2163: invokespecial #315                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2166: astore        108
        2168: new           #317                // class ocaml_fn_60
        2171: dup
        2172: aload         70
        2174: aload         72
        2176: aload         93
        2178: invokespecial #318                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        109
        2183: new           #320                // class ocaml_fn_61
        2186: dup
        2187: aload         109
        2189: invokespecial #321                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2192: astore        110
        2194: new           #323                // class ocaml_fn_62
        2197: dup
        2198: aload         59
        2200: aload         109
        2202: invokespecial #324                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2205: astore        111
        2207: new           #326                // class ocaml_fn_63
        2210: dup
        2211: aload         109
        2213: invokespecial #327                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2216: astore        112
        2218: new           #329                // class ocaml_fn_64
        2221: dup
        2222: aload         62
        2224: aload         109
        2226: invokespecial #330                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2229: astore        113
        2231: new           #332                // class ocaml_fn_65
        2234: dup
        2235: invokespecial #333                // Method ocaml_fn_65."<init>":()V
        2238: astore        114
        2240: new           #335                // class ocaml_fn_66
        2243: dup
        2244: aload         53
        2246: invokespecial #336                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2249: astore        115
        2251: new           #2                  // class Block
        2254: dup
        2255: iconst_0
        2256: iconst_1
        2257: anewarray     #4                  // class java/lang/Object
        2260: dup
        2261: iconst_0
        2262: aload         78
        2264: aastore
        2265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2268: astore        116
        2270: new           #338                // class ocaml_fn_67
        2273: dup
        2274: aload         116
        2276: invokespecial #339                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2279: astore        117
        2281: new           #341                // class ocaml_fn_68
        2284: dup
        2285: invokespecial #342                // Method ocaml_fn_68."<init>":()V
        2288: astore        118
        2290: new           #2                  // class Block
        2293: dup
        2294: iconst_0
        2295: iconst_1
        2296: anewarray     #4                  // class java/lang/Object
        2299: dup
        2300: iconst_0
        2301: aload         118
        2303: aastore
        2304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2307: astore        119
        2309: new           #344                // class ocaml_fn_69
        2312: dup
        2313: aload         116
        2315: aload         119
        2317: invokespecial #345                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2320: astore        120
        2322: new           #347                // class ocaml_fn_70
        2325: dup
        2326: aload         120
        2328: invokespecial #348                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2331: astore        121
        2333: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2336: bipush        44
        2338: aaload
        2339: astore        122
        2341: iconst_0
        2342: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2345: astore        123
        2347: new           #350                // class ocaml_fn_71
        2350: dup
        2351: invokespecial #351                // Method ocaml_fn_71."<init>":()V
        2354: astore        124
        2356: new           #353                // class ocaml_fn_72
        2359: dup
        2360: invokespecial #354                // Method ocaml_fn_72."<init>":()V
        2363: astore        125
        2365: new           #356                // class ocaml_fn_73
        2368: dup
        2369: invokespecial #357                // Method ocaml_fn_73."<init>":()V
        2372: astore        126
        2374: new           #359                // class ocaml_fn_74
        2377: dup
        2378: invokespecial #360                // Method ocaml_fn_74."<init>":()V
        2381: astore        127
        2383: new           #362                // class ocaml_fn_75
        2386: dup
        2387: invokespecial #363                // Method ocaml_fn_75."<init>":()V
        2390: astore        128
        2392: new           #365                // class ocaml_fn_76
        2395: dup
        2396: invokespecial #366                // Method ocaml_fn_76."<init>":()V
        2399: astore        129
        2401: new           #2                  // class Block
        2404: dup
        2405: iconst_0
        2406: bipush        6
        2408: anewarray     #4                  // class java/lang/Object
        2411: dup
        2412: iconst_0
        2413: aload         129
        2415: aastore
        2416: dup
        2417: iconst_1
        2418: aload         128
        2420: aastore
        2421: dup
        2422: iconst_2
        2423: aload         127
        2425: aastore
        2426: dup
        2427: iconst_3
        2428: aload         126
        2430: aastore
        2431: dup
        2432: iconst_4
        2433: aload         125
        2435: aastore
        2436: dup
        2437: iconst_5
        2438: aload         124
        2440: aastore
        2441: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2444: astore        130
        2446: new           #368                // class ocaml_fn_77
        2449: dup
        2450: invokespecial #369                // Method ocaml_fn_77."<init>":()V
        2453: astore        131
        2455: new           #371                // class ocaml_fn_78
        2458: dup
        2459: invokespecial #372                // Method ocaml_fn_78."<init>":()V
        2462: astore        132
        2464: new           #374                // class ocaml_fn_79
        2467: dup
        2468: invokespecial #375                // Method ocaml_fn_79."<init>":()V
        2471: astore        133
        2473: new           #377                // class ocaml_fn_80
        2476: dup
        2477: invokespecial #378                // Method ocaml_fn_80."<init>":()V
        2480: astore        134
        2482: new           #380                // class ocaml_fn_81
        2485: dup
        2486: invokespecial #381                // Method ocaml_fn_81."<init>":()V
        2489: astore        135
        2491: new           #383                // class ocaml_fn_82
        2494: dup
        2495: invokespecial #384                // Method ocaml_fn_82."<init>":()V
        2498: astore        136
        2500: new           #386                // class ocaml_fn_83
        2503: dup
        2504: invokespecial #387                // Method ocaml_fn_83."<init>":()V
        2507: astore        137
        2509: new           #389                // class ocaml_fn_84
        2512: dup
        2513: invokespecial #390                // Method ocaml_fn_84."<init>":()V
        2516: astore        138
        2518: new           #392                // class ocaml_fn_85
        2521: dup
        2522: invokespecial #393                // Method ocaml_fn_85."<init>":()V
        2525: astore        139
        2527: new           #395                // class ocaml_fn_86
        2530: dup
        2531: invokespecial #396                // Method ocaml_fn_86."<init>":()V
        2534: astore        140
        2536: new           #398                // class ocaml_fn_87
        2539: dup
        2540: invokespecial #399                // Method ocaml_fn_87."<init>":()V
        2543: astore        141
        2545: new           #401                // class ocaml_fn_88
        2548: dup
        2549: invokespecial #402                // Method ocaml_fn_88."<init>":()V
        2552: astore        142
        2554: new           #404                // class ocaml_fn_89
        2557: dup
        2558: invokespecial #405                // Method ocaml_fn_89."<init>":()V
        2561: astore        143
        2563: new           #407                // class ocaml_fn_90
        2566: dup
        2567: invokespecial #408                // Method ocaml_fn_90."<init>":()V
        2570: astore        144
        2572: new           #410                // class ocaml_fn_91
        2575: dup
        2576: invokespecial #411                // Method ocaml_fn_91."<init>":()V
        2579: astore        145
        2581: new           #413                // class ocaml_fn_92
        2584: dup
        2585: invokespecial #414                // Method ocaml_fn_92."<init>":()V
        2588: astore        146
        2590: new           #416                // class ocaml_fn_93
        2593: dup
        2594: invokespecial #417                // Method ocaml_fn_93."<init>":()V
        2597: astore        147
        2599: new           #2                  // class Block
        2602: dup
        2603: iconst_0
        2604: bipush        104
        2606: anewarray     #4                  // class java/lang/Object
        2609: dup
        2610: iconst_0
        2611: aload         18
        2613: aastore
        2614: dup
        2615: iconst_1
        2616: aload         17
        2618: aastore
        2619: dup
        2620: iconst_2
        2621: aload         22
        2623: aastore
        2624: dup
        2625: iconst_3
        2626: aload         23
        2628: aastore
        2629: dup
        2630: iconst_4
        2631: aload         24
        2633: aastore
        2634: dup
        2635: iconst_5
        2636: aload         25
        2638: aastore
        2639: dup
        2640: bipush        6
        2642: aload         26
        2644: aastore
        2645: dup
        2646: bipush        7
        2648: aload         27
        2650: aastore
        2651: dup
        2652: bipush        8
        2654: aload         28
        2656: aastore
        2657: dup
        2658: bipush        9
        2660: aload         29
        2662: aastore
        2663: dup
        2664: bipush        10
        2666: aload         30
        2668: aastore
        2669: dup
        2670: bipush        11
        2672: aload         31
        2674: aastore
        2675: dup
        2676: bipush        12
        2678: aload         32
        2680: aastore
        2681: dup
        2682: bipush        13
        2684: aload         33
        2686: aastore
        2687: dup
        2688: bipush        14
        2690: aload         34
        2692: aastore
        2693: dup
        2694: bipush        15
        2696: aload         35
        2698: aastore
        2699: dup
        2700: bipush        16
        2702: aload         36
        2704: aastore
        2705: dup
        2706: bipush        17
        2708: aload         37
        2710: aastore
        2711: dup
        2712: bipush        18
        2714: iload         39
        2716: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2719: aastore
        2720: dup
        2721: bipush        19
        2723: iload         40
        2725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2728: aastore
        2729: dup
        2730: bipush        20
        2732: aload         38
        2734: aastore
        2735: dup
        2736: bipush        21
        2738: aload         42
        2740: aastore
        2741: dup
        2742: bipush        22
        2744: aload         44
        2746: aastore
        2747: dup
        2748: bipush        23
        2750: aload         46
        2752: aastore
        2753: dup
        2754: bipush        24
        2756: aload         48
        2758: aastore
        2759: dup
        2760: bipush        25
        2762: aload         50
        2764: aastore
        2765: dup
        2766: bipush        26
        2768: aload         52
        2770: aastore
        2771: dup
        2772: bipush        27
        2774: aload         53
        2776: aastore
        2777: dup
        2778: bipush        28
        2780: aload         54
        2782: aastore
        2783: dup
        2784: bipush        29
        2786: aload         55
        2788: aastore
        2789: dup
        2790: bipush        30
        2792: aload         57
        2794: aastore
        2795: dup
        2796: bipush        31
        2798: aload         56
        2800: aastore
        2801: dup
        2802: bipush        32
        2804: aload         58
        2806: aastore
        2807: dup
        2808: bipush        33
        2810: aload         59
        2812: aastore
        2813: dup
        2814: bipush        34
        2816: aload         61
        2818: aastore
        2819: dup
        2820: bipush        35
        2822: aload         62
        2824: aastore
        2825: dup
        2826: bipush        36
        2828: aload         63
        2830: aastore
        2831: dup
        2832: bipush        37
        2834: aload         70
        2836: aastore
        2837: dup
        2838: bipush        38
        2840: aload         72
        2842: aastore
        2843: dup
        2844: bipush        39
        2846: aload         74
        2848: aastore
        2849: dup
        2850: bipush        40
        2852: aload         95
        2854: aastore
        2855: dup
        2856: bipush        41
        2858: aload         96
        2860: aastore
        2861: dup
        2862: bipush        42
        2864: aload         97
        2866: aastore
        2867: dup
        2868: bipush        43
        2870: aload         98
        2872: aastore
        2873: dup
        2874: bipush        44
        2876: aload         99
        2878: aastore
        2879: dup
        2880: bipush        45
        2882: aload         100
        2884: aastore
        2885: dup
        2886: bipush        46
        2888: aload         101
        2890: aastore
        2891: dup
        2892: bipush        47
        2894: aload         102
        2896: aastore
        2897: dup
        2898: bipush        48
        2900: aload         103
        2902: aastore
        2903: dup
        2904: bipush        49
        2906: aload         104
        2908: aastore
        2909: dup
        2910: bipush        50
        2912: aload         105
        2914: aastore
        2915: dup
        2916: bipush        51
        2918: aload         106
        2920: aastore
        2921: dup
        2922: bipush        52
        2924: aload         107
        2926: aastore
        2927: dup
        2928: bipush        53
        2930: aload         108
        2932: aastore
        2933: dup
        2934: bipush        54
        2936: aload         109
        2938: aastore
        2939: dup
        2940: bipush        55
        2942: aload         111
        2944: aastore
        2945: dup
        2946: bipush        56
        2948: aload         110
        2950: aastore
        2951: dup
        2952: bipush        57
        2954: aload         113
        2956: aastore
        2957: dup
        2958: bipush        58
        2960: aload         112
        2962: aastore
        2963: dup
        2964: bipush        59
        2966: aload         76
        2968: aastore
        2969: dup
        2970: bipush        60
        2972: aload         77
        2974: aastore
        2975: dup
        2976: bipush        61
        2978: aload         75
        2980: aastore
        2981: dup
        2982: bipush        62
        2984: aload         147
        2986: aastore
        2987: dup
        2988: bipush        63
        2990: aload         78
        2992: aastore
        2993: dup
        2994: bipush        64
        2996: aload         146
        2998: aastore
        2999: dup
        3000: bipush        65
        3002: aload         80
        3004: aastore
        3005: dup
        3006: bipush        66
        3008: aload         79
        3010: aastore
        3011: dup
        3012: bipush        67
        3014: aload         81
        3016: aastore
        3017: dup
        3018: bipush        68
        3020: aload         82
        3022: aastore
        3023: dup
        3024: bipush        69
        3026: aload         145
        3028: aastore
        3029: dup
        3030: bipush        70
        3032: aload         144
        3034: aastore
        3035: dup
        3036: bipush        71
        3038: aload         83
        3040: aastore
        3041: dup
        3042: bipush        72
        3044: aload         143
        3046: aastore
        3047: dup
        3048: bipush        73
        3050: aload         142
        3052: aastore
        3053: dup
        3054: bipush        74
        3056: aload         141
        3058: aastore
        3059: dup
        3060: bipush        75
        3062: aload         84
        3064: aastore
        3065: dup
        3066: bipush        76
        3068: aload         85
        3070: aastore
        3071: dup
        3072: bipush        77
        3074: aload         140
        3076: aastore
        3077: dup
        3078: bipush        78
        3080: aload         87
        3082: aastore
        3083: dup
        3084: bipush        79
        3086: aload         88
        3088: aastore
        3089: dup
        3090: bipush        80
        3092: aload         86
        3094: aastore
        3095: dup
        3096: bipush        81
        3098: aload         139
        3100: aastore
        3101: dup
        3102: bipush        82
        3104: aload         93
        3106: aastore
        3107: dup
        3108: bipush        83
        3110: aload         89
        3112: aastore
        3113: dup
        3114: bipush        84
        3116: aload         91
        3118: aastore
        3119: dup
        3120: bipush        85
        3122: aload         92
        3124: aastore
        3125: dup
        3126: bipush        86
        3128: aload         138
        3130: aastore
        3131: dup
        3132: bipush        87
        3134: aload         137
        3136: aastore
        3137: dup
        3138: bipush        88
        3140: aload         136
        3142: aastore
        3143: dup
        3144: bipush        89
        3146: aload         135
        3148: aastore
        3149: dup
        3150: bipush        90
        3152: aload         134
        3154: aastore
        3155: dup
        3156: bipush        91
        3158: aload         133
        3160: aastore
        3161: dup
        3162: bipush        92
        3164: aload         132
        3166: aastore
        3167: dup
        3168: bipush        93
        3170: aload         94
        3172: aastore
        3173: dup
        3174: bipush        94
        3176: aload         131
        3178: aastore
        3179: dup
        3180: bipush        95
        3182: aload         130
        3184: aastore
        3185: dup
        3186: bipush        96
        3188: aload         114
        3190: aastore
        3191: dup
        3192: bipush        97
        3194: aload         115
        3196: aastore
        3197: dup
        3198: bipush        98
        3200: aload         121
        3202: aastore
        3203: dup
        3204: bipush        99
        3206: aload         117
        3208: aastore
        3209: dup
        3210: bipush        100
        3212: aload         60
        3214: aastore
        3215: dup
        3216: bipush        101
        3218: aload         90
        3220: aastore
        3221: dup
        3222: bipush        102
        3224: aload         120
        3226: aastore
        3227: dup
        3228: bipush        103
        3230: aload         119
        3232: aastore
        3233: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3236: astore        148
        3238: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3241: bipush        45
        3243: aload         148
        3245: aastore
        3246: iconst_0
        3247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3250: astore        149
        3252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3255: bipush        46
        3257: aaload
        3258: astore        150
        3260: getstatic     #421                // Field java/lang/System.out:Ljava/io/PrintStream;
        3263: aload         150
        3265: checkcast     #423                // class java/lang/String
        3268: invokevirtual #429                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3271: iconst_0
        3272: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3275: astore        151
        3277: new           #2                  // class Block
        3280: dup
        3281: iconst_0
        3282: iconst_0
        3283: anewarray     #4                  // class java/lang/Object
        3286: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3289: astore        152
        3291: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3294: bipush        47
        3296: aload         152
        3298: aastore
        3299: iconst_0
        3300: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3303: astore        153
        3305: iconst_0
        3306: istore        154
        3308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3311: bipush        45
        3313: aaload
        3314: checkcast     #2                  // class Block
        3317: getfield      #432                // Field Block.fields:[Ljava/lang/Object;
        3320: bipush        102
        3322: aaload
        3323: astore        155
        3325: aload         155
        3327: checkcast     #196                // class Closure
        3330: iload         154
        3332: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3335: invokevirtual #436                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3338: astore        156
        3340: new           #2                  // class Block
        3343: dup
        3344: iconst_0
        3345: iconst_0
        3346: anewarray     #4                  // class java/lang/Object
        3349: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3352: astore        157
        3354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3357: bipush        48
        3359: aload         157
        3361: aastore
        3362: iconst_0
        3363: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3366: astore        158
        3368: return
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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: iconst_0
        1047: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1050: aastore
        1051: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1054: bipush        47
        1056: iconst_0
        1057: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1060: aastore
        1061: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1064: iconst_4
        1065: aaload
        1066: putstatic     #110                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1069: aconst_null
        1070: astore_1
        1071: aload_1
        1072: astore_2
        1073: goto_w        1078
        1078: new           #112                // class ocaml_fn_0
        1081: dup
        1082: invokespecial #115                // Method ocaml_fn_0."<init>":()V
        1085: astore_3
        1086: new           #117                // class ocaml_fn_1
        1089: dup
        1090: invokespecial #118                // Method ocaml_fn_1."<init>":()V
        1093: astore        4
        1095: new           #120                // class ocaml_fn_2
        1098: dup
        1099: invokespecial #121                // Method ocaml_fn_2."<init>":()V
        1102: astore        5
        1104: new           #2                  // class Block
        1107: dup
        1108: iconst_0
        1109: iconst_3
        1110: anewarray     #4                  // class java/lang/Object
        1113: dup
        1114: iconst_0
        1115: aload         4
        1117: aastore
        1118: dup
        1119: iconst_1
        1120: aload_3
        1121: aastore
        1122: dup
        1123: iconst_2
        1124: aload         5
        1126: aastore
        1127: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1130: astore        6
        1132: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1135: bipush        12
        1137: aload         6
        1139: aastore
        1140: iconst_0
        1141: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        7
        1146: iconst_0
        1147: istore        8
        1149: iload         8
        1151: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1154: astore        9
        1156: goto_w        1161
        1161: sipush        199
        1164: istore        10
        1166: iconst_0
        1167: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1170: astore        11
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: bipush        35
        1177: aaload
        1178: astore        12
        1180: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1183: iconst_3
        1184: aaload
        1185: astore        13
        1187: new           #2                  // class Block
        1190: dup
        1191: iconst_0
        1192: iconst_2
        1193: anewarray     #4                  // class java/lang/Object
        1196: dup
        1197: iconst_0
        1198: aload         13
        1200: aastore
        1201: dup
        1202: iconst_1
        1203: aload         12
        1205: aastore
        1206: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1209: astore        14
        1211: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1214: bipush        36
        1216: aaload
        1217: astore        15
        1219: iconst_0
        1220: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1223: astore        16
        1225: new           #123                // class ocaml_fn_8
        1228: dup
        1229: invokespecial #124                // Method ocaml_fn_8."<init>":()V
        1232: astore        17
        1234: new           #126                // class ocaml_fn_9
        1237: dup
        1238: invokespecial #127                // Method ocaml_fn_9."<init>":()V
        1241: astore        18
        1243: iconst_0
        1244: istore        19
        1246: iconst_0
        1247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1250: astore        20
        1252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1255: bipush        37
        1257: aaload
        1258: astore        21
        1260: new           #2                  // class Block
        1263: dup
        1264: sipush        248
        1267: iconst_2
        1268: anewarray     #4                  // class java/lang/Object
        1271: dup
        1272: iconst_0
        1273: aload         21
        1275: aastore
        1276: dup
        1277: iconst_1
        1278: aload         20
        1280: aastore
        1281: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1284: astore        22
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        7
        1291: aaload
        1292: astore        23
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        10
        1299: aaload
        1300: astore        24
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: iconst_3
        1306: aaload
        1307: astore        25
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: iconst_2
        1313: aaload
        1314: astore        26
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: bipush        6
        1321: aaload
        1322: astore        27
        1324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1327: iconst_0
        1328: aaload
        1329: astore        28
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: bipush        8
        1336: aaload
        1337: astore        29
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_1
        1343: aaload
        1344: astore        30
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: iconst_4
        1350: aaload
        1351: astore        31
        1353: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1356: iconst_5
        1357: aaload
        1358: astore        32
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        9
        1365: aaload
        1366: astore        33
        1368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1371: bipush        11
        1373: aaload
        1374: astore        34
        1376: new           #129                // class ocaml_fn_10
        1379: dup
        1380: invokespecial #130                // Method ocaml_fn_10."<init>":()V
        1383: astore        35
        1385: new           #132                // class ocaml_fn_11
        1388: dup
        1389: invokespecial #133                // Method ocaml_fn_11."<init>":()V
        1392: astore        36
        1394: new           #135                // class ocaml_fn_12
        1397: dup
        1398: invokespecial #136                // Method ocaml_fn_12."<init>":()V
        1401: astore        37
        1403: new           #138                // class ocaml_fn_13
        1406: dup
        1407: invokespecial #139                // Method ocaml_fn_13."<init>":()V
        1410: astore        38
        1412: ldc           #140                // int 2147483647
        1414: istore        39
        1416: ldc           #141                // int -2147483648
        1418: istore        40
        1420: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        38
        1425: aaload
        1426: astore        41
        1428: aload         41
        1430: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1433: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1436: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        42
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        43
        1449: aload         43
        1451: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1454: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1457: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        44
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        40
        1467: aaload
        1468: astore        45
        1470: aload         45
        1472: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1475: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1478: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        46
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        41
        1488: aaload
        1489: astore        47
        1491: aload         47
        1493: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1496: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1499: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1502: astore        48
        1504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1507: bipush        42
        1509: aaload
        1510: astore        49
        1512: aload         49
        1514: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1517: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1520: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1523: astore        50
        1525: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1528: bipush        43
        1530: aaload
        1531: astore        51
        1533: aload         51
        1535: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1538: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1541: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1544: astore        52
        1546: new           #156                // class ocaml_fn_14
        1549: dup
        1550: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1553: astore        53
        1555: new           #159                // class ocaml_fn_15
        1558: dup
        1559: aload         18
        1561: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1564: astore        54
        1566: new           #164                // class ocaml_fn_16
        1569: dup
        1570: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1573: astore        55
        1575: new           #167                // class ocaml_fn_17
        1578: dup
        1579: aload         18
        1581: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1584: astore        56
        1586: new           #170                // class ocaml_fn_18
        1589: dup
        1590: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1593: astore        57
        1595: new           #173                // class ocaml_fn_19
        1598: dup
        1599: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1602: astore        58
        1604: new           #176                // class ocaml_fn_20
        1607: dup
        1608: aload         26
        1610: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1613: astore        59
        1615: new           #179                // class ocaml_fn_21
        1618: dup
        1619: aload         53
        1621: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1624: astore        60
        1626: new           #182                // class ocaml_fn_22
        1629: dup
        1630: aload         60
        1632: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1635: astore        61
        1637: new           #185                // class ocaml_fn_23
        1640: dup
        1641: aload         26
        1643: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1646: astore        62
        1648: new           #188                // class ocaml_fn_24
        1651: dup
        1652: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1655: astore        63
        1657: new           #191                // class ocaml_fn_25
        1660: dup
        1661: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1664: astore        64
        1666: aload         63
        1668: checkcast     #188                // class ocaml_fn_24
        1671: aload         63
        1673: checkcast     #194                // class Closure
        1676: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1679: iconst_0
        1680: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1683: astore        65
        1685: aload         63
        1687: checkcast     #188                // class ocaml_fn_24
        1690: aload         64
        1692: checkcast     #194                // class Closure
        1695: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1698: iconst_0
        1699: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1702: astore        66
        1704: aload         64
        1706: checkcast     #191                // class ocaml_fn_25
        1709: aload         63
        1711: checkcast     #194                // class Closure
        1714: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1717: iconst_0
        1718: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1721: astore        67
        1723: aload         64
        1725: checkcast     #191                // class ocaml_fn_25
        1728: aload         64
        1730: checkcast     #194                // class Closure
        1733: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1736: iconst_0
        1737: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1740: astore        68
        1742: iconst_0
        1743: istore        69
        1745: iload         69
        1747: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1750: astore        70
        1752: iconst_1
        1753: istore        71
        1755: iload         71
        1757: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1760: astore        72
        1762: iconst_2
        1763: istore        73
        1765: iload         73
        1767: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1770: astore        74
        1772: new           #209                // class ocaml_fn_26
        1775: dup
        1776: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1779: astore        75
        1781: new           #212                // class ocaml_fn_27
        1784: dup
        1785: aload         75
        1787: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1790: astore        76
        1792: new           #215                // class ocaml_fn_28
        1795: dup
        1796: aload         75
        1798: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1801: astore        77
        1803: new           #218                // class ocaml_fn_29
        1806: dup
        1807: aload         30
        1809: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1812: astore        78
        1814: new           #221                // class ocaml_fn_30
        1817: dup
        1818: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1821: astore        79
        1823: new           #224                // class ocaml_fn_31
        1826: dup
        1827: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1830: astore        80
        1832: new           #227                // class ocaml_fn_32
        1835: dup
        1836: aload         18
        1838: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1841: astore        81
        1843: new           #230                // class ocaml_fn_33
        1846: dup
        1847: aload         18
        1849: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1852: astore        82
        1854: new           #233                // class ocaml_fn_34
        1857: dup
        1858: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1861: astore        83
        1863: new           #236                // class ocaml_fn_35
        1866: dup
        1867: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1870: astore        84
        1872: new           #239                // class ocaml_fn_36
        1875: dup
        1876: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1879: astore        85
        1881: new           #242                // class ocaml_fn_37
        1884: dup
        1885: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1888: astore        86
        1890: new           #245                // class ocaml_fn_38
        1893: dup
        1894: aload         86
        1896: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1899: astore        87
        1901: new           #248                // class ocaml_fn_39
        1904: dup
        1905: aload         86
        1907: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1910: astore        88
        1912: new           #251                // class ocaml_fn_40
        1915: dup
        1916: aload         18
        1918: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1921: astore        89
        1923: new           #254                // class ocaml_fn_41
        1926: dup
        1927: aload         31
        1929: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1932: astore        90
        1934: new           #257                // class ocaml_fn_42
        1937: dup
        1938: aload         18
        1940: aload         90
        1942: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1945: astore        91
        1947: new           #262                // class ocaml_fn_43
        1950: dup
        1951: aload         91
        1953: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1956: astore        92
        1958: new           #265                // class ocaml_fn_44
        1961: dup
        1962: aload         31
        1964: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1967: astore        93
        1969: new           #268                // class ocaml_fn_45
        1972: dup
        1973: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1976: astore        94
        1978: new           #271                // class ocaml_fn_46
        1981: dup
        1982: aload         72
        1984: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1987: astore        95
        1989: new           #274                // class ocaml_fn_47
        1992: dup
        1993: aload         72
        1995: aload         80
        1997: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2000: astore        96
        2002: new           #277                // class ocaml_fn_48
        2005: dup
        2006: aload         72
        2008: aload         79
        2010: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        97
        2015: new           #280                // class ocaml_fn_49
        2018: dup
        2019: aload         58
        2021: aload         72
        2023: aload         80
        2025: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2028: astore        98
        2030: new           #285                // class ocaml_fn_50
        2033: dup
        2034: aload         61
        2036: aload         72
        2038: aload         80
        2040: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        99
        2045: new           #288                // class ocaml_fn_51
        2048: dup
        2049: aload         72
        2051: aload         80
        2053: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        100
        2058: new           #291                // class ocaml_fn_52
        2061: dup
        2062: aload         72
        2064: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2067: astore        101
        2069: new           #294                // class ocaml_fn_53
        2072: dup
        2073: aload         74
        2075: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2078: astore        102
        2080: new           #297                // class ocaml_fn_54
        2083: dup
        2084: aload         74
        2086: aload         80
        2088: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        103
        2093: new           #300                // class ocaml_fn_55
        2096: dup
        2097: aload         74
        2099: aload         79
        2101: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2104: astore        104
        2106: new           #303                // class ocaml_fn_56
        2109: dup
        2110: aload         58
        2112: aload         74
        2114: aload         80
        2116: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2119: astore        105
        2121: new           #306                // class ocaml_fn_57
        2124: dup
        2125: aload         61
        2127: aload         74
        2129: aload         80
        2131: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        106
        2136: new           #309                // class ocaml_fn_58
        2139: dup
        2140: aload         74
        2142: aload         80
        2144: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        107
        2149: new           #312                // class ocaml_fn_59
        2152: dup
        2153: aload         74
        2155: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        108
        2160: new           #315                // class ocaml_fn_60
        2163: dup
        2164: aload         70
        2166: aload         72
        2168: aload         93
        2170: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        109
        2175: new           #318                // class ocaml_fn_61
        2178: dup
        2179: aload         109
        2181: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2184: astore        110
        2186: new           #321                // class ocaml_fn_62
        2189: dup
        2190: aload         59
        2192: aload         109
        2194: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        111
        2199: new           #324                // class ocaml_fn_63
        2202: dup
        2203: aload         109
        2205: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2208: astore        112
        2210: new           #327                // class ocaml_fn_64
        2213: dup
        2214: aload         62
        2216: aload         109
        2218: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2221: astore        113
        2223: new           #330                // class ocaml_fn_65
        2226: dup
        2227: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2230: astore        114
        2232: new           #333                // class ocaml_fn_66
        2235: dup
        2236: aload         53
        2238: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2241: astore        115
        2243: new           #2                  // class Block
        2246: dup
        2247: iconst_0
        2248: iconst_1
        2249: anewarray     #4                  // class java/lang/Object
        2252: dup
        2253: iconst_0
        2254: aload         78
        2256: aastore
        2257: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2260: astore        116
        2262: new           #336                // class ocaml_fn_67
        2265: dup
        2266: aload         116
        2268: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2271: astore        117
        2273: new           #339                // class ocaml_fn_68
        2276: dup
        2277: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2280: astore        118
        2282: new           #2                  // class Block
        2285: dup
        2286: iconst_0
        2287: iconst_1
        2288: anewarray     #4                  // class java/lang/Object
        2291: dup
        2292: iconst_0
        2293: aload         118
        2295: aastore
        2296: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2299: astore        119
        2301: new           #342                // class ocaml_fn_69
        2304: dup
        2305: aload         116
        2307: aload         119
        2309: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2312: astore        120
        2314: new           #345                // class ocaml_fn_70
        2317: dup
        2318: aload         120
        2320: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2323: astore        121
        2325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2328: bipush        44
        2330: aaload
        2331: astore        122
        2333: iconst_0
        2334: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2337: astore        123
        2339: new           #348                // class ocaml_fn_71
        2342: dup
        2343: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2346: astore        124
        2348: new           #351                // class ocaml_fn_72
        2351: dup
        2352: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2355: astore        125
        2357: new           #354                // class ocaml_fn_73
        2360: dup
        2361: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2364: astore        126
        2366: new           #357                // class ocaml_fn_74
        2369: dup
        2370: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2373: astore        127
        2375: new           #360                // class ocaml_fn_75
        2378: dup
        2379: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2382: astore        128
        2384: new           #363                // class ocaml_fn_76
        2387: dup
        2388: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2391: astore        129
        2393: new           #2                  // class Block
        2396: dup
        2397: iconst_0
        2398: bipush        6
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         129
        2407: aastore
        2408: dup
        2409: iconst_1
        2410: aload         128
        2412: aastore
        2413: dup
        2414: iconst_2
        2415: aload         127
        2417: aastore
        2418: dup
        2419: iconst_3
        2420: aload         126
        2422: aastore
        2423: dup
        2424: iconst_4
        2425: aload         125
        2427: aastore
        2428: dup
        2429: iconst_5
        2430: aload         124
        2432: aastore
        2433: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2436: astore        130
        2438: new           #366                // class ocaml_fn_77
        2441: dup
        2442: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2445: astore        131
        2447: new           #369                // class ocaml_fn_78
        2450: dup
        2451: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2454: astore        132
        2456: new           #372                // class ocaml_fn_79
        2459: dup
        2460: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2463: astore        133
        2465: new           #375                // class ocaml_fn_80
        2468: dup
        2469: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2472: astore        134
        2474: new           #378                // class ocaml_fn_81
        2477: dup
        2478: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2481: astore        135
        2483: new           #381                // class ocaml_fn_82
        2486: dup
        2487: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2490: astore        136
        2492: new           #384                // class ocaml_fn_83
        2495: dup
        2496: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2499: astore        137
        2501: new           #387                // class ocaml_fn_84
        2504: dup
        2505: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2508: astore        138
        2510: new           #390                // class ocaml_fn_85
        2513: dup
        2514: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2517: astore        139
        2519: new           #393                // class ocaml_fn_86
        2522: dup
        2523: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2526: astore        140
        2528: new           #396                // class ocaml_fn_87
        2531: dup
        2532: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2535: astore        141
        2537: new           #399                // class ocaml_fn_88
        2540: dup
        2541: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2544: astore        142
        2546: new           #402                // class ocaml_fn_89
        2549: dup
        2550: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2553: astore        143
        2555: new           #405                // class ocaml_fn_90
        2558: dup
        2559: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2562: astore        144
        2564: new           #408                // class ocaml_fn_91
        2567: dup
        2568: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2571: astore        145
        2573: new           #411                // class ocaml_fn_92
        2576: dup
        2577: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2580: astore        146
        2582: new           #414                // class ocaml_fn_93
        2585: dup
        2586: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2589: astore        147
        2591: new           #2                  // class Block
        2594: dup
        2595: iconst_0
        2596: bipush        104
        2598: anewarray     #4                  // class java/lang/Object
        2601: dup
        2602: iconst_0
        2603: aload         18
        2605: aastore
        2606: dup
        2607: iconst_1
        2608: aload         17
        2610: aastore
        2611: dup
        2612: iconst_2
        2613: aload         22
        2615: aastore
        2616: dup
        2617: iconst_3
        2618: aload         23
        2620: aastore
        2621: dup
        2622: iconst_4
        2623: aload         24
        2625: aastore
        2626: dup
        2627: iconst_5
        2628: aload         25
        2630: aastore
        2631: dup
        2632: bipush        6
        2634: aload         26
        2636: aastore
        2637: dup
        2638: bipush        7
        2640: aload         27
        2642: aastore
        2643: dup
        2644: bipush        8
        2646: aload         28
        2648: aastore
        2649: dup
        2650: bipush        9
        2652: aload         29
        2654: aastore
        2655: dup
        2656: bipush        10
        2658: aload         30
        2660: aastore
        2661: dup
        2662: bipush        11
        2664: aload         31
        2666: aastore
        2667: dup
        2668: bipush        12
        2670: aload         32
        2672: aastore
        2673: dup
        2674: bipush        13
        2676: aload         33
        2678: aastore
        2679: dup
        2680: bipush        14
        2682: aload         34
        2684: aastore
        2685: dup
        2686: bipush        15
        2688: aload         35
        2690: aastore
        2691: dup
        2692: bipush        16
        2694: aload         36
        2696: aastore
        2697: dup
        2698: bipush        17
        2700: aload         37
        2702: aastore
        2703: dup
        2704: bipush        18
        2706: iload         39
        2708: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2711: aastore
        2712: dup
        2713: bipush        19
        2715: iload         40
        2717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2720: aastore
        2721: dup
        2722: bipush        20
        2724: aload         38
        2726: aastore
        2727: dup
        2728: bipush        21
        2730: aload         42
        2732: aastore
        2733: dup
        2734: bipush        22
        2736: aload         44
        2738: aastore
        2739: dup
        2740: bipush        23
        2742: aload         46
        2744: aastore
        2745: dup
        2746: bipush        24
        2748: aload         48
        2750: aastore
        2751: dup
        2752: bipush        25
        2754: aload         50
        2756: aastore
        2757: dup
        2758: bipush        26
        2760: aload         52
        2762: aastore
        2763: dup
        2764: bipush        27
        2766: aload         53
        2768: aastore
        2769: dup
        2770: bipush        28
        2772: aload         54
        2774: aastore
        2775: dup
        2776: bipush        29
        2778: aload         55
        2780: aastore
        2781: dup
        2782: bipush        30
        2784: aload         57
        2786: aastore
        2787: dup
        2788: bipush        31
        2790: aload         56
        2792: aastore
        2793: dup
        2794: bipush        32
        2796: aload         58
        2798: aastore
        2799: dup
        2800: bipush        33
        2802: aload         59
        2804: aastore
        2805: dup
        2806: bipush        34
        2808: aload         61
        2810: aastore
        2811: dup
        2812: bipush        35
        2814: aload         62
        2816: aastore
        2817: dup
        2818: bipush        36
        2820: aload         63
        2822: aastore
        2823: dup
        2824: bipush        37
        2826: aload         70
        2828: aastore
        2829: dup
        2830: bipush        38
        2832: aload         72
        2834: aastore
        2835: dup
        2836: bipush        39
        2838: aload         74
        2840: aastore
        2841: dup
        2842: bipush        40
        2844: aload         95
        2846: aastore
        2847: dup
        2848: bipush        41
        2850: aload         96
        2852: aastore
        2853: dup
        2854: bipush        42
        2856: aload         97
        2858: aastore
        2859: dup
        2860: bipush        43
        2862: aload         98
        2864: aastore
        2865: dup
        2866: bipush        44
        2868: aload         99
        2870: aastore
        2871: dup
        2872: bipush        45
        2874: aload         100
        2876: aastore
        2877: dup
        2878: bipush        46
        2880: aload         101
        2882: aastore
        2883: dup
        2884: bipush        47
        2886: aload         102
        2888: aastore
        2889: dup
        2890: bipush        48
        2892: aload         103
        2894: aastore
        2895: dup
        2896: bipush        49
        2898: aload         104
        2900: aastore
        2901: dup
        2902: bipush        50
        2904: aload         105
        2906: aastore
        2907: dup
        2908: bipush        51
        2910: aload         106
        2912: aastore
        2913: dup
        2914: bipush        52
        2916: aload         107
        2918: aastore
        2919: dup
        2920: bipush        53
        2922: aload         108
        2924: aastore
        2925: dup
        2926: bipush        54
        2928: aload         109
        2930: aastore
        2931: dup
        2932: bipush        55
        2934: aload         111
        2936: aastore
        2937: dup
        2938: bipush        56
        2940: aload         110
        2942: aastore
        2943: dup
        2944: bipush        57
        2946: aload         113
        2948: aastore
        2949: dup
        2950: bipush        58
        2952: aload         112
        2954: aastore
        2955: dup
        2956: bipush        59
        2958: aload         76
        2960: aastore
        2961: dup
        2962: bipush        60
        2964: aload         77
        2966: aastore
        2967: dup
        2968: bipush        61
        2970: aload         75
        2972: aastore
        2973: dup
        2974: bipush        62
        2976: aload         147
        2978: aastore
        2979: dup
        2980: bipush        63
        2982: aload         78
        2984: aastore
        2985: dup
        2986: bipush        64
        2988: aload         146
        2990: aastore
        2991: dup
        2992: bipush        65
        2994: aload         80
        2996: aastore
        2997: dup
        2998: bipush        66
        3000: aload         79
        3002: aastore
        3003: dup
        3004: bipush        67
        3006: aload         81
        3008: aastore
        3009: dup
        3010: bipush        68
        3012: aload         82
        3014: aastore
        3015: dup
        3016: bipush        69
        3018: aload         145
        3020: aastore
        3021: dup
        3022: bipush        70
        3024: aload         144
        3026: aastore
        3027: dup
        3028: bipush        71
        3030: aload         83
        3032: aastore
        3033: dup
        3034: bipush        72
        3036: aload         143
        3038: aastore
        3039: dup
        3040: bipush        73
        3042: aload         142
        3044: aastore
        3045: dup
        3046: bipush        74
        3048: aload         141
        3050: aastore
        3051: dup
        3052: bipush        75
        3054: aload         84
        3056: aastore
        3057: dup
        3058: bipush        76
        3060: aload         85
        3062: aastore
        3063: dup
        3064: bipush        77
        3066: aload         140
        3068: aastore
        3069: dup
        3070: bipush        78
        3072: aload         87
        3074: aastore
        3075: dup
        3076: bipush        79
        3078: aload         88
        3080: aastore
        3081: dup
        3082: bipush        80
        3084: aload         86
        3086: aastore
        3087: dup
        3088: bipush        81
        3090: aload         139
        3092: aastore
        3093: dup
        3094: bipush        82
        3096: aload         93
        3098: aastore
        3099: dup
        3100: bipush        83
        3102: aload         89
        3104: aastore
        3105: dup
        3106: bipush        84
        3108: aload         91
        3110: aastore
        3111: dup
        3112: bipush        85
        3114: aload         92
        3116: aastore
        3117: dup
        3118: bipush        86
        3120: aload         138
        3122: aastore
        3123: dup
        3124: bipush        87
        3126: aload         137
        3128: aastore
        3129: dup
        3130: bipush        88
        3132: aload         136
        3134: aastore
        3135: dup
        3136: bipush        89
        3138: aload         135
        3140: aastore
        3141: dup
        3142: bipush        90
        3144: aload         134
        3146: aastore
        3147: dup
        3148: bipush        91
        3150: aload         133
        3152: aastore
        3153: dup
        3154: bipush        92
        3156: aload         132
        3158: aastore
        3159: dup
        3160: bipush        93
        3162: aload         94
        3164: aastore
        3165: dup
        3166: bipush        94
        3168: aload         131
        3170: aastore
        3171: dup
        3172: bipush        95
        3174: aload         130
        3176: aastore
        3177: dup
        3178: bipush        96
        3180: aload         114
        3182: aastore
        3183: dup
        3184: bipush        97
        3186: aload         115
        3188: aastore
        3189: dup
        3190: bipush        98
        3192: aload         121
        3194: aastore
        3195: dup
        3196: bipush        99
        3198: aload         117
        3200: aastore
        3201: dup
        3202: bipush        100
        3204: aload         60
        3206: aastore
        3207: dup
        3208: bipush        101
        3210: aload         90
        3212: aastore
        3213: dup
        3214: bipush        102
        3216: aload         120
        3218: aastore
        3219: dup
        3220: bipush        103
        3222: aload         119
        3224: aastore
        3225: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3228: astore        148
        3230: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3233: bipush        45
        3235: aload         148
        3237: aastore
        3238: iconst_0
        3239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3242: astore        149
        3244: bipush        8
        3246: istore        150
        3248: getstatic     #419                // Field java/lang/System.out:Ljava/io/PrintStream;
        3251: iload         150
        3253: invokevirtual #425                // Method java/io/PrintStream.println:(I)V
        3256: iconst_0
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        151
        3262: new           #2                  // class Block
        3265: dup
        3266: iconst_0
        3267: iconst_0
        3268: anewarray     #4                  // class java/lang/Object
        3271: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3274: astore        152
        3276: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3279: bipush        46
        3281: aload         152
        3283: aastore
        3284: iconst_0
        3285: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3288: astore        153
        3290: iconst_0
        3291: istore        154
        3293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3296: bipush        45
        3298: aaload
        3299: checkcast     #2                  // class Block
        3302: getfield      #428                // Field Block.fields:[Ljava/lang/Object;
        3305: bipush        102
        3307: aaload
        3308: astore        155
        3310: aload         155
        3312: checkcast     #194                // class Closure
        3315: iload         154
        3317: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3320: invokevirtual #432                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3323: astore        156
        3325: new           #2                  // class Block
        3328: dup
        3329: iconst_0
        3330: iconst_0
        3331: anewarray     #4                  // class java/lang/Object
        3334: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3337: astore        157
        3339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3342: bipush        47
        3344: aload         157
        3346: aastore
        3347: iconst_0
        3348: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3351: astore        158
        3353: return
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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: iconst_0
        1047: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1050: aastore
        1051: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1054: bipush        47
        1056: iconst_0
        1057: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1060: aastore
        1061: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1064: iconst_4
        1065: aaload
        1066: putstatic     #110                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1069: aconst_null
        1070: astore_1
        1071: aload_1
        1072: astore_2
        1073: goto_w        1078
        1078: new           #112                // class ocaml_fn_0
        1081: dup
        1082: invokespecial #115                // Method ocaml_fn_0."<init>":()V
        1085: astore_3
        1086: new           #117                // class ocaml_fn_1
        1089: dup
        1090: invokespecial #118                // Method ocaml_fn_1."<init>":()V
        1093: astore        4
        1095: new           #120                // class ocaml_fn_2
        1098: dup
        1099: invokespecial #121                // Method ocaml_fn_2."<init>":()V
        1102: astore        5
        1104: new           #2                  // class Block
        1107: dup
        1108: iconst_0
        1109: iconst_3
        1110: anewarray     #4                  // class java/lang/Object
        1113: dup
        1114: iconst_0
        1115: aload         4
        1117: aastore
        1118: dup
        1119: iconst_1
        1120: aload_3
        1121: aastore
        1122: dup
        1123: iconst_2
        1124: aload         5
        1126: aastore
        1127: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1130: astore        6
        1132: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1135: bipush        12
        1137: aload         6
        1139: aastore
        1140: iconst_0
        1141: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        7
        1146: iconst_0
        1147: istore        8
        1149: iload         8
        1151: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1154: astore        9
        1156: goto_w        1161
        1161: sipush        199
        1164: istore        10
        1166: iconst_0
        1167: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1170: astore        11
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: bipush        35
        1177: aaload
        1178: astore        12
        1180: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1183: iconst_3
        1184: aaload
        1185: astore        13
        1187: new           #2                  // class Block
        1190: dup
        1191: iconst_0
        1192: iconst_2
        1193: anewarray     #4                  // class java/lang/Object
        1196: dup
        1197: iconst_0
        1198: aload         13
        1200: aastore
        1201: dup
        1202: iconst_1
        1203: aload         12
        1205: aastore
        1206: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1209: astore        14
        1211: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1214: bipush        36
        1216: aaload
        1217: astore        15
        1219: iconst_0
        1220: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1223: astore        16
        1225: new           #123                // class ocaml_fn_8
        1228: dup
        1229: invokespecial #124                // Method ocaml_fn_8."<init>":()V
        1232: astore        17
        1234: new           #126                // class ocaml_fn_9
        1237: dup
        1238: invokespecial #127                // Method ocaml_fn_9."<init>":()V
        1241: astore        18
        1243: iconst_0
        1244: istore        19
        1246: iconst_0
        1247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1250: astore        20
        1252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1255: bipush        37
        1257: aaload
        1258: astore        21
        1260: new           #2                  // class Block
        1263: dup
        1264: sipush        248
        1267: iconst_2
        1268: anewarray     #4                  // class java/lang/Object
        1271: dup
        1272: iconst_0
        1273: aload         21
        1275: aastore
        1276: dup
        1277: iconst_1
        1278: aload         20
        1280: aastore
        1281: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1284: astore        22
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        7
        1291: aaload
        1292: astore        23
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        10
        1299: aaload
        1300: astore        24
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: iconst_3
        1306: aaload
        1307: astore        25
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: iconst_2
        1313: aaload
        1314: astore        26
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: bipush        6
        1321: aaload
        1322: astore        27
        1324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1327: iconst_0
        1328: aaload
        1329: astore        28
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: bipush        8
        1336: aaload
        1337: astore        29
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_1
        1343: aaload
        1344: astore        30
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: iconst_4
        1350: aaload
        1351: astore        31
        1353: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1356: iconst_5
        1357: aaload
        1358: astore        32
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        9
        1365: aaload
        1366: astore        33
        1368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1371: bipush        11
        1373: aaload
        1374: astore        34
        1376: new           #129                // class ocaml_fn_10
        1379: dup
        1380: invokespecial #130                // Method ocaml_fn_10."<init>":()V
        1383: astore        35
        1385: new           #132                // class ocaml_fn_11
        1388: dup
        1389: invokespecial #133                // Method ocaml_fn_11."<init>":()V
        1392: astore        36
        1394: new           #135                // class ocaml_fn_12
        1397: dup
        1398: invokespecial #136                // Method ocaml_fn_12."<init>":()V
        1401: astore        37
        1403: new           #138                // class ocaml_fn_13
        1406: dup
        1407: invokespecial #139                // Method ocaml_fn_13."<init>":()V
        1410: astore        38
        1412: ldc           #140                // int 2147483647
        1414: istore        39
        1416: ldc           #141                // int -2147483648
        1418: istore        40
        1420: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        38
        1425: aaload
        1426: astore        41
        1428: aload         41
        1430: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1433: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1436: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        42
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        43
        1449: aload         43
        1451: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1454: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1457: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        44
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        40
        1467: aaload
        1468: astore        45
        1470: aload         45
        1472: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1475: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1478: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        46
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        41
        1488: aaload
        1489: astore        47
        1491: aload         47
        1493: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1496: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1499: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1502: astore        48
        1504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1507: bipush        42
        1509: aaload
        1510: astore        49
        1512: aload         49
        1514: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1517: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1520: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1523: astore        50
        1525: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1528: bipush        43
        1530: aaload
        1531: astore        51
        1533: aload         51
        1535: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1538: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1541: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1544: astore        52
        1546: new           #156                // class ocaml_fn_14
        1549: dup
        1550: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1553: astore        53
        1555: new           #159                // class ocaml_fn_15
        1558: dup
        1559: aload         18
        1561: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1564: astore        54
        1566: new           #164                // class ocaml_fn_16
        1569: dup
        1570: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1573: astore        55
        1575: new           #167                // class ocaml_fn_17
        1578: dup
        1579: aload         18
        1581: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1584: astore        56
        1586: new           #170                // class ocaml_fn_18
        1589: dup
        1590: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1593: astore        57
        1595: new           #173                // class ocaml_fn_19
        1598: dup
        1599: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1602: astore        58
        1604: new           #176                // class ocaml_fn_20
        1607: dup
        1608: aload         26
        1610: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1613: astore        59
        1615: new           #179                // class ocaml_fn_21
        1618: dup
        1619: aload         53
        1621: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1624: astore        60
        1626: new           #182                // class ocaml_fn_22
        1629: dup
        1630: aload         60
        1632: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1635: astore        61
        1637: new           #185                // class ocaml_fn_23
        1640: dup
        1641: aload         26
        1643: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1646: astore        62
        1648: new           #188                // class ocaml_fn_24
        1651: dup
        1652: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1655: astore        63
        1657: new           #191                // class ocaml_fn_25
        1660: dup
        1661: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1664: astore        64
        1666: aload         63
        1668: checkcast     #188                // class ocaml_fn_24
        1671: aload         63
        1673: checkcast     #194                // class Closure
        1676: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1679: iconst_0
        1680: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1683: astore        65
        1685: aload         63
        1687: checkcast     #188                // class ocaml_fn_24
        1690: aload         64
        1692: checkcast     #194                // class Closure
        1695: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1698: iconst_0
        1699: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1702: astore        66
        1704: aload         64
        1706: checkcast     #191                // class ocaml_fn_25
        1709: aload         63
        1711: checkcast     #194                // class Closure
        1714: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1717: iconst_0
        1718: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1721: astore        67
        1723: aload         64
        1725: checkcast     #191                // class ocaml_fn_25
        1728: aload         64
        1730: checkcast     #194                // class Closure
        1733: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1736: iconst_0
        1737: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1740: astore        68
        1742: iconst_0
        1743: istore        69
        1745: iload         69
        1747: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1750: astore        70
        1752: iconst_1
        1753: istore        71
        1755: iload         71
        1757: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1760: astore        72
        1762: iconst_2
        1763: istore        73
        1765: iload         73
        1767: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1770: astore        74
        1772: new           #209                // class ocaml_fn_26
        1775: dup
        1776: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1779: astore        75
        1781: new           #212                // class ocaml_fn_27
        1784: dup
        1785: aload         75
        1787: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1790: astore        76
        1792: new           #215                // class ocaml_fn_28
        1795: dup
        1796: aload         75
        1798: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1801: astore        77
        1803: new           #218                // class ocaml_fn_29
        1806: dup
        1807: aload         30
        1809: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1812: astore        78
        1814: new           #221                // class ocaml_fn_30
        1817: dup
        1818: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1821: astore        79
        1823: new           #224                // class ocaml_fn_31
        1826: dup
        1827: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1830: astore        80
        1832: new           #227                // class ocaml_fn_32
        1835: dup
        1836: aload         18
        1838: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1841: astore        81
        1843: new           #230                // class ocaml_fn_33
        1846: dup
        1847: aload         18
        1849: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1852: astore        82
        1854: new           #233                // class ocaml_fn_34
        1857: dup
        1858: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1861: astore        83
        1863: new           #236                // class ocaml_fn_35
        1866: dup
        1867: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1870: astore        84
        1872: new           #239                // class ocaml_fn_36
        1875: dup
        1876: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1879: astore        85
        1881: new           #242                // class ocaml_fn_37
        1884: dup
        1885: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1888: astore        86
        1890: new           #245                // class ocaml_fn_38
        1893: dup
        1894: aload         86
        1896: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1899: astore        87
        1901: new           #248                // class ocaml_fn_39
        1904: dup
        1905: aload         86
        1907: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1910: astore        88
        1912: new           #251                // class ocaml_fn_40
        1915: dup
        1916: aload         18
        1918: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1921: astore        89
        1923: new           #254                // class ocaml_fn_41
        1926: dup
        1927: aload         31
        1929: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1932: astore        90
        1934: new           #257                // class ocaml_fn_42
        1937: dup
        1938: aload         18
        1940: aload         90
        1942: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1945: astore        91
        1947: new           #262                // class ocaml_fn_43
        1950: dup
        1951: aload         91
        1953: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1956: astore        92
        1958: new           #265                // class ocaml_fn_44
        1961: dup
        1962: aload         31
        1964: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1967: astore        93
        1969: new           #268                // class ocaml_fn_45
        1972: dup
        1973: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1976: astore        94
        1978: new           #271                // class ocaml_fn_46
        1981: dup
        1982: aload         72
        1984: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1987: astore        95
        1989: new           #274                // class ocaml_fn_47
        1992: dup
        1993: aload         72
        1995: aload         80
        1997: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2000: astore        96
        2002: new           #277                // class ocaml_fn_48
        2005: dup
        2006: aload         72
        2008: aload         79
        2010: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        97
        2015: new           #280                // class ocaml_fn_49
        2018: dup
        2019: aload         58
        2021: aload         72
        2023: aload         80
        2025: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2028: astore        98
        2030: new           #285                // class ocaml_fn_50
        2033: dup
        2034: aload         61
        2036: aload         72
        2038: aload         80
        2040: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        99
        2045: new           #288                // class ocaml_fn_51
        2048: dup
        2049: aload         72
        2051: aload         80
        2053: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        100
        2058: new           #291                // class ocaml_fn_52
        2061: dup
        2062: aload         72
        2064: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2067: astore        101
        2069: new           #294                // class ocaml_fn_53
        2072: dup
        2073: aload         74
        2075: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2078: astore        102
        2080: new           #297                // class ocaml_fn_54
        2083: dup
        2084: aload         74
        2086: aload         80
        2088: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        103
        2093: new           #300                // class ocaml_fn_55
        2096: dup
        2097: aload         74
        2099: aload         79
        2101: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2104: astore        104
        2106: new           #303                // class ocaml_fn_56
        2109: dup
        2110: aload         58
        2112: aload         74
        2114: aload         80
        2116: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2119: astore        105
        2121: new           #306                // class ocaml_fn_57
        2124: dup
        2125: aload         61
        2127: aload         74
        2129: aload         80
        2131: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        106
        2136: new           #309                // class ocaml_fn_58
        2139: dup
        2140: aload         74
        2142: aload         80
        2144: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        107
        2149: new           #312                // class ocaml_fn_59
        2152: dup
        2153: aload         74
        2155: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        108
        2160: new           #315                // class ocaml_fn_60
        2163: dup
        2164: aload         70
        2166: aload         72
        2168: aload         93
        2170: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        109
        2175: new           #318                // class ocaml_fn_61
        2178: dup
        2179: aload         109
        2181: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2184: astore        110
        2186: new           #321                // class ocaml_fn_62
        2189: dup
        2190: aload         59
        2192: aload         109
        2194: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        111
        2199: new           #324                // class ocaml_fn_63
        2202: dup
        2203: aload         109
        2205: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2208: astore        112
        2210: new           #327                // class ocaml_fn_64
        2213: dup
        2214: aload         62
        2216: aload         109
        2218: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2221: astore        113
        2223: new           #330                // class ocaml_fn_65
        2226: dup
        2227: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2230: astore        114
        2232: new           #333                // class ocaml_fn_66
        2235: dup
        2236: aload         53
        2238: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2241: astore        115
        2243: new           #2                  // class Block
        2246: dup
        2247: iconst_0
        2248: iconst_1
        2249: anewarray     #4                  // class java/lang/Object
        2252: dup
        2253: iconst_0
        2254: aload         78
        2256: aastore
        2257: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2260: astore        116
        2262: new           #336                // class ocaml_fn_67
        2265: dup
        2266: aload         116
        2268: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2271: astore        117
        2273: new           #339                // class ocaml_fn_68
        2276: dup
        2277: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2280: astore        118
        2282: new           #2                  // class Block
        2285: dup
        2286: iconst_0
        2287: iconst_1
        2288: anewarray     #4                  // class java/lang/Object
        2291: dup
        2292: iconst_0
        2293: aload         118
        2295: aastore
        2296: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2299: astore        119
        2301: new           #342                // class ocaml_fn_69
        2304: dup
        2305: aload         116
        2307: aload         119
        2309: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2312: astore        120
        2314: new           #345                // class ocaml_fn_70
        2317: dup
        2318: aload         120
        2320: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2323: astore        121
        2325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2328: bipush        44
        2330: aaload
        2331: astore        122
        2333: iconst_0
        2334: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2337: astore        123
        2339: new           #348                // class ocaml_fn_71
        2342: dup
        2343: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2346: astore        124
        2348: new           #351                // class ocaml_fn_72
        2351: dup
        2352: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2355: astore        125
        2357: new           #354                // class ocaml_fn_73
        2360: dup
        2361: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2364: astore        126
        2366: new           #357                // class ocaml_fn_74
        2369: dup
        2370: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2373: astore        127
        2375: new           #360                // class ocaml_fn_75
        2378: dup
        2379: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2382: astore        128
        2384: new           #363                // class ocaml_fn_76
        2387: dup
        2388: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2391: astore        129
        2393: new           #2                  // class Block
        2396: dup
        2397: iconst_0
        2398: bipush        6
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         129
        2407: aastore
        2408: dup
        2409: iconst_1
        2410: aload         128
        2412: aastore
        2413: dup
        2414: iconst_2
        2415: aload         127
        2417: aastore
        2418: dup
        2419: iconst_3
        2420: aload         126
        2422: aastore
        2423: dup
        2424: iconst_4
        2425: aload         125
        2427: aastore
        2428: dup
        2429: iconst_5
        2430: aload         124
        2432: aastore
        2433: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2436: astore        130
        2438: new           #366                // class ocaml_fn_77
        2441: dup
        2442: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2445: astore        131
        2447: new           #369                // class ocaml_fn_78
        2450: dup
        2451: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2454: astore        132
        2456: new           #372                // class ocaml_fn_79
        2459: dup
        2460: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2463: astore        133
        2465: new           #375                // class ocaml_fn_80
        2468: dup
        2469: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2472: astore        134
        2474: new           #378                // class ocaml_fn_81
        2477: dup
        2478: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2481: astore        135
        2483: new           #381                // class ocaml_fn_82
        2486: dup
        2487: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2490: astore        136
        2492: new           #384                // class ocaml_fn_83
        2495: dup
        2496: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2499: astore        137
        2501: new           #387                // class ocaml_fn_84
        2504: dup
        2505: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2508: astore        138
        2510: new           #390                // class ocaml_fn_85
        2513: dup
        2514: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2517: astore        139
        2519: new           #393                // class ocaml_fn_86
        2522: dup
        2523: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2526: astore        140
        2528: new           #396                // class ocaml_fn_87
        2531: dup
        2532: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2535: astore        141
        2537: new           #399                // class ocaml_fn_88
        2540: dup
        2541: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2544: astore        142
        2546: new           #402                // class ocaml_fn_89
        2549: dup
        2550: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2553: astore        143
        2555: new           #405                // class ocaml_fn_90
        2558: dup
        2559: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2562: astore        144
        2564: new           #408                // class ocaml_fn_91
        2567: dup
        2568: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2571: astore        145
        2573: new           #411                // class ocaml_fn_92
        2576: dup
        2577: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2580: astore        146
        2582: new           #414                // class ocaml_fn_93
        2585: dup
        2586: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2589: astore        147
        2591: new           #2                  // class Block
        2594: dup
        2595: iconst_0
        2596: bipush        104
        2598: anewarray     #4                  // class java/lang/Object
        2601: dup
        2602: iconst_0
        2603: aload         18
        2605: aastore
        2606: dup
        2607: iconst_1
        2608: aload         17
        2610: aastore
        2611: dup
        2612: iconst_2
        2613: aload         22
        2615: aastore
        2616: dup
        2617: iconst_3
        2618: aload         23
        2620: aastore
        2621: dup
        2622: iconst_4
        2623: aload         24
        2625: aastore
        2626: dup
        2627: iconst_5
        2628: aload         25
        2630: aastore
        2631: dup
        2632: bipush        6
        2634: aload         26
        2636: aastore
        2637: dup
        2638: bipush        7
        2640: aload         27
        2642: aastore
        2643: dup
        2644: bipush        8
        2646: aload         28
        2648: aastore
        2649: dup
        2650: bipush        9
        2652: aload         29
        2654: aastore
        2655: dup
        2656: bipush        10
        2658: aload         30
        2660: aastore
        2661: dup
        2662: bipush        11
        2664: aload         31
        2666: aastore
        2667: dup
        2668: bipush        12
        2670: aload         32
        2672: aastore
        2673: dup
        2674: bipush        13
        2676: aload         33
        2678: aastore
        2679: dup
        2680: bipush        14
        2682: aload         34
        2684: aastore
        2685: dup
        2686: bipush        15
        2688: aload         35
        2690: aastore
        2691: dup
        2692: bipush        16
        2694: aload         36
        2696: aastore
        2697: dup
        2698: bipush        17
        2700: aload         37
        2702: aastore
        2703: dup
        2704: bipush        18
        2706: iload         39
        2708: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2711: aastore
        2712: dup
        2713: bipush        19
        2715: iload         40
        2717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2720: aastore
        2721: dup
        2722: bipush        20
        2724: aload         38
        2726: aastore
        2727: dup
        2728: bipush        21
        2730: aload         42
        2732: aastore
        2733: dup
        2734: bipush        22
        2736: aload         44
        2738: aastore
        2739: dup
        2740: bipush        23
        2742: aload         46
        2744: aastore
        2745: dup
        2746: bipush        24
        2748: aload         48
        2750: aastore
        2751: dup
        2752: bipush        25
        2754: aload         50
        2756: aastore
        2757: dup
        2758: bipush        26
        2760: aload         52
        2762: aastore
        2763: dup
        2764: bipush        27
        2766: aload         53
        2768: aastore
        2769: dup
        2770: bipush        28
        2772: aload         54
        2774: aastore
        2775: dup
        2776: bipush        29
        2778: aload         55
        2780: aastore
        2781: dup
        2782: bipush        30
        2784: aload         57
        2786: aastore
        2787: dup
        2788: bipush        31
        2790: aload         56
        2792: aastore
        2793: dup
        2794: bipush        32
        2796: aload         58
        2798: aastore
        2799: dup
        2800: bipush        33
        2802: aload         59
        2804: aastore
        2805: dup
        2806: bipush        34
        2808: aload         61
        2810: aastore
        2811: dup
        2812: bipush        35
        2814: aload         62
        2816: aastore
        2817: dup
        2818: bipush        36
        2820: aload         63
        2822: aastore
        2823: dup
        2824: bipush        37
        2826: aload         70
        2828: aastore
        2829: dup
        2830: bipush        38
        2832: aload         72
        2834: aastore
        2835: dup
        2836: bipush        39
        2838: aload         74
        2840: aastore
        2841: dup
        2842: bipush        40
        2844: aload         95
        2846: aastore
        2847: dup
        2848: bipush        41
        2850: aload         96
        2852: aastore
        2853: dup
        2854: bipush        42
        2856: aload         97
        2858: aastore
        2859: dup
        2860: bipush        43
        2862: aload         98
        2864: aastore
        2865: dup
        2866: bipush        44
        2868: aload         99
        2870: aastore
        2871: dup
        2872: bipush        45
        2874: aload         100
        2876: aastore
        2877: dup
        2878: bipush        46
        2880: aload         101
        2882: aastore
        2883: dup
        2884: bipush        47
        2886: aload         102
        2888: aastore
        2889: dup
        2890: bipush        48
        2892: aload         103
        2894: aastore
        2895: dup
        2896: bipush        49
        2898: aload         104
        2900: aastore
        2901: dup
        2902: bipush        50
        2904: aload         105
        2906: aastore
        2907: dup
        2908: bipush        51
        2910: aload         106
        2912: aastore
        2913: dup
        2914: bipush        52
        2916: aload         107
        2918: aastore
        2919: dup
        2920: bipush        53
        2922: aload         108
        2924: aastore
        2925: dup
        2926: bipush        54
        2928: aload         109
        2930: aastore
        2931: dup
        2932: bipush        55
        2934: aload         111
        2936: aastore
        2937: dup
        2938: bipush        56
        2940: aload         110
        2942: aastore
        2943: dup
        2944: bipush        57
        2946: aload         113
        2948: aastore
        2949: dup
        2950: bipush        58
        2952: aload         112
        2954: aastore
        2955: dup
        2956: bipush        59
        2958: aload         76
        2960: aastore
        2961: dup
        2962: bipush        60
        2964: aload         77
        2966: aastore
        2967: dup
        2968: bipush        61
        2970: aload         75
        2972: aastore
        2973: dup
        2974: bipush        62
        2976: aload         147
        2978: aastore
        2979: dup
        2980: bipush        63
        2982: aload         78
        2984: aastore
        2985: dup
        2986: bipush        64
        2988: aload         146
        2990: aastore
        2991: dup
        2992: bipush        65
        2994: aload         80
        2996: aastore
        2997: dup
        2998: bipush        66
        3000: aload         79
        3002: aastore
        3003: dup
        3004: bipush        67
        3006: aload         81
        3008: aastore
        3009: dup
        3010: bipush        68
        3012: aload         82
        3014: aastore
        3015: dup
        3016: bipush        69
        3018: aload         145
        3020: aastore
        3021: dup
        3022: bipush        70
        3024: aload         144
        3026: aastore
        3027: dup
        3028: bipush        71
        3030: aload         83
        3032: aastore
        3033: dup
        3034: bipush        72
        3036: aload         143
        3038: aastore
        3039: dup
        3040: bipush        73
        3042: aload         142
        3044: aastore
        3045: dup
        3046: bipush        74
        3048: aload         141
        3050: aastore
        3051: dup
        3052: bipush        75
        3054: aload         84
        3056: aastore
        3057: dup
        3058: bipush        76
        3060: aload         85
        3062: aastore
        3063: dup
        3064: bipush        77
        3066: aload         140
        3068: aastore
        3069: dup
        3070: bipush        78
        3072: aload         87
        3074: aastore
        3075: dup
        3076: bipush        79
        3078: aload         88
        3080: aastore
        3081: dup
        3082: bipush        80
        3084: aload         86
        3086: aastore
        3087: dup
        3088: bipush        81
        3090: aload         139
        3092: aastore
        3093: dup
        3094: bipush        82
        3096: aload         93
        3098: aastore
        3099: dup
        3100: bipush        83
        3102: aload         89
        3104: aastore
        3105: dup
        3106: bipush        84
        3108: aload         91
        3110: aastore
        3111: dup
        3112: bipush        85
        3114: aload         92
        3116: aastore
        3117: dup
        3118: bipush        86
        3120: aload         138
        3122: aastore
        3123: dup
        3124: bipush        87
        3126: aload         137
        3128: aastore
        3129: dup
        3130: bipush        88
        3132: aload         136
        3134: aastore
        3135: dup
        3136: bipush        89
        3138: aload         135
        3140: aastore
        3141: dup
        3142: bipush        90
        3144: aload         134
        3146: aastore
        3147: dup
        3148: bipush        91
        3150: aload         133
        3152: aastore
        3153: dup
        3154: bipush        92
        3156: aload         132
        3158: aastore
        3159: dup
        3160: bipush        93
        3162: aload         94
        3164: aastore
        3165: dup
        3166: bipush        94
        3168: aload         131
        3170: aastore
        3171: dup
        3172: bipush        95
        3174: aload         130
        3176: aastore
        3177: dup
        3178: bipush        96
        3180: aload         114
        3182: aastore
        3183: dup
        3184: bipush        97
        3186: aload         115
        3188: aastore
        3189: dup
        3190: bipush        98
        3192: aload         121
        3194: aastore
        3195: dup
        3196: bipush        99
        3198: aload         117
        3200: aastore
        3201: dup
        3202: bipush        100
        3204: aload         60
        3206: aastore
        3207: dup
        3208: bipush        101
        3210: aload         90
        3212: aastore
        3213: dup
        3214: bipush        102
        3216: aload         120
        3218: aastore
        3219: dup
        3220: bipush        103
        3222: aload         119
        3224: aastore
        3225: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3228: astore        148
        3230: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3233: bipush        45
        3235: aload         148
        3237: aastore
        3238: iconst_0
        3239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3242: astore        149
        3244: iconst_0
        3245: istore        150
        3247: iload         150
        3249: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3252: astore        151
        3254: goto_w        3259
        3259: new           #417                // class ocaml_fn_95
        3262: dup
        3263: invokespecial #418                // Method ocaml_fn_95."<init>":()V
        3266: astore        152
        3268: bipush        10
        3270: istore        153
        3272: aload         152
        3274: iload         153
        3276: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3279: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3282: astore        154
        3284: bipush        32
        3286: istore        155
        3288: aload         154
        3290: checkcast     #194                // class Closure
        3293: iload         155
        3295: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3298: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3301: astore        156
        3303: getstatic     #426                // Field java/lang/System.out:Ljava/io/PrintStream;
        3306: aload         156
        3308: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        3311: l2i
        3312: invokevirtual #432                // Method java/io/PrintStream.println:(I)V
        3315: iconst_0
        3316: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3319: astore        157
        3321: new           #2                  // class Block
        3324: dup
        3325: iconst_0
        3326: iconst_1
        3327: anewarray     #4                  // class java/lang/Object
        3330: dup
        3331: iconst_0
        3332: aload         152
        3334: aastore
        3335: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3338: astore        158
        3340: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3343: bipush        46
        3345: aload         158
        3347: aastore
        3348: iconst_0
        3349: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3352: astore        159
        3354: iconst_0
        3355: istore        160
        3357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3360: bipush        45
        3362: aaload
        3363: checkcast     #2                  // class Block
        3366: getfield      #435                // Field Block.fields:[Ljava/lang/Object;
        3369: bipush        102
        3371: aaload
        3372: astore        161
        3374: aload         161
        3376: checkcast     #194                // class Closure
        3379: iload         160
        3381: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3384: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3387: astore        162
        3389: new           #2                  // class Block
        3392: dup
        3393: iconst_0
        3394: iconst_0
        3395: anewarray     #4                  // class java/lang/Object
        3398: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3401: astore        163
        3403: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3406: bipush        47
        3408: aload         163
        3410: aastore
        3411: iconst_0
        3412: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3415: astore        164
        3417: return
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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: new           #2                  // class Block
        1049: dup
        1050: iconst_0
        1051: iconst_1
        1052: anewarray     #4                  // class java/lang/Object
        1055: dup
        1056: iconst_0
        1057: bipush        42
        1059: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1062: aastore
        1063: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1066: aastore
        1067: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1070: bipush        47
        1072: iconst_0
        1073: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1076: aastore
        1077: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1080: bipush        48
        1082: iconst_0
        1083: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1086: aastore
        1087: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1090: iconst_4
        1091: aaload
        1092: putstatic     #110                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1095: aconst_null
        1096: astore_1
        1097: aload_1
        1098: astore_2
        1099: goto_w        1104
        1104: new           #112                // class ocaml_fn_0
        1107: dup
        1108: invokespecial #115                // Method ocaml_fn_0."<init>":()V
        1111: astore_3
        1112: new           #117                // class ocaml_fn_1
        1115: dup
        1116: invokespecial #118                // Method ocaml_fn_1."<init>":()V
        1119: astore        4
        1121: new           #120                // class ocaml_fn_2
        1124: dup
        1125: invokespecial #121                // Method ocaml_fn_2."<init>":()V
        1128: astore        5
        1130: new           #2                  // class Block
        1133: dup
        1134: iconst_0
        1135: iconst_3
        1136: anewarray     #4                  // class java/lang/Object
        1139: dup
        1140: iconst_0
        1141: aload         4
        1143: aastore
        1144: dup
        1145: iconst_1
        1146: aload_3
        1147: aastore
        1148: dup
        1149: iconst_2
        1150: aload         5
        1152: aastore
        1153: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1156: astore        6
        1158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1161: bipush        12
        1163: aload         6
        1165: aastore
        1166: iconst_0
        1167: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1170: astore        7
        1172: iconst_0
        1173: istore        8
        1175: iload         8
        1177: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1180: astore        9
        1182: goto_w        1187
        1187: sipush        199
        1190: istore        10
        1192: iconst_0
        1193: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1196: astore        11
        1198: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1201: bipush        35
        1203: aaload
        1204: astore        12
        1206: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1209: iconst_3
        1210: aaload
        1211: astore        13
        1213: new           #2                  // class Block
        1216: dup
        1217: iconst_0
        1218: iconst_2
        1219: anewarray     #4                  // class java/lang/Object
        1222: dup
        1223: iconst_0
        1224: aload         13
        1226: aastore
        1227: dup
        1228: iconst_1
        1229: aload         12
        1231: aastore
        1232: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1235: astore        14
        1237: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1240: bipush        36
        1242: aaload
        1243: astore        15
        1245: iconst_0
        1246: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1249: astore        16
        1251: new           #123                // class ocaml_fn_8
        1254: dup
        1255: invokespecial #124                // Method ocaml_fn_8."<init>":()V
        1258: astore        17
        1260: new           #126                // class ocaml_fn_9
        1263: dup
        1264: invokespecial #127                // Method ocaml_fn_9."<init>":()V
        1267: astore        18
        1269: iconst_0
        1270: istore        19
        1272: iconst_0
        1273: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1276: astore        20
        1278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1281: bipush        37
        1283: aaload
        1284: astore        21
        1286: new           #2                  // class Block
        1289: dup
        1290: sipush        248
        1293: iconst_2
        1294: anewarray     #4                  // class java/lang/Object
        1297: dup
        1298: iconst_0
        1299: aload         21
        1301: aastore
        1302: dup
        1303: iconst_1
        1304: aload         20
        1306: aastore
        1307: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1310: astore        22
        1312: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1315: bipush        7
        1317: aaload
        1318: astore        23
        1320: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        10
        1325: aaload
        1326: astore        24
        1328: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1331: iconst_3
        1332: aaload
        1333: astore        25
        1335: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1338: iconst_2
        1339: aaload
        1340: astore        26
        1342: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1345: bipush        6
        1347: aaload
        1348: astore        27
        1350: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1353: iconst_0
        1354: aaload
        1355: astore        28
        1357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1360: bipush        8
        1362: aaload
        1363: astore        29
        1365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1368: iconst_1
        1369: aaload
        1370: astore        30
        1372: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1375: iconst_4
        1376: aaload
        1377: astore        31
        1379: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1382: iconst_5
        1383: aaload
        1384: astore        32
        1386: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1389: bipush        9
        1391: aaload
        1392: astore        33
        1394: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1397: bipush        11
        1399: aaload
        1400: astore        34
        1402: new           #129                // class ocaml_fn_10
        1405: dup
        1406: invokespecial #130                // Method ocaml_fn_10."<init>":()V
        1409: astore        35
        1411: new           #132                // class ocaml_fn_11
        1414: dup
        1415: invokespecial #133                // Method ocaml_fn_11."<init>":()V
        1418: astore        36
        1420: new           #135                // class ocaml_fn_12
        1423: dup
        1424: invokespecial #136                // Method ocaml_fn_12."<init>":()V
        1427: astore        37
        1429: new           #138                // class ocaml_fn_13
        1432: dup
        1433: invokespecial #139                // Method ocaml_fn_13."<init>":()V
        1436: astore        38
        1438: ldc           #140                // int 2147483647
        1440: istore        39
        1442: ldc           #141                // int -2147483648
        1444: istore        40
        1446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1449: bipush        38
        1451: aaload
        1452: astore        41
        1454: aload         41
        1456: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1459: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1462: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1465: astore        42
        1467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1470: bipush        39
        1472: aaload
        1473: astore        43
        1475: aload         43
        1477: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1480: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1483: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1486: astore        44
        1488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1491: bipush        40
        1493: aaload
        1494: astore        45
        1496: aload         45
        1498: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1501: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1504: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1507: astore        46
        1509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1512: bipush        41
        1514: aaload
        1515: astore        47
        1517: aload         47
        1519: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1522: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1525: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1528: astore        48
        1530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1533: bipush        42
        1535: aaload
        1536: astore        49
        1538: aload         49
        1540: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1543: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1546: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1549: astore        50
        1551: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1554: bipush        43
        1556: aaload
        1557: astore        51
        1559: aload         51
        1561: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1564: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1567: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1570: astore        52
        1572: new           #156                // class ocaml_fn_14
        1575: dup
        1576: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1579: astore        53
        1581: new           #159                // class ocaml_fn_15
        1584: dup
        1585: aload         18
        1587: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1590: astore        54
        1592: new           #164                // class ocaml_fn_16
        1595: dup
        1596: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1599: astore        55
        1601: new           #167                // class ocaml_fn_17
        1604: dup
        1605: aload         18
        1607: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1610: astore        56
        1612: new           #170                // class ocaml_fn_18
        1615: dup
        1616: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1619: astore        57
        1621: new           #173                // class ocaml_fn_19
        1624: dup
        1625: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1628: astore        58
        1630: new           #176                // class ocaml_fn_20
        1633: dup
        1634: aload         26
        1636: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1639: astore        59
        1641: new           #179                // class ocaml_fn_21
        1644: dup
        1645: aload         53
        1647: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1650: astore        60
        1652: new           #182                // class ocaml_fn_22
        1655: dup
        1656: aload         60
        1658: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1661: astore        61
        1663: new           #185                // class ocaml_fn_23
        1666: dup
        1667: aload         26
        1669: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1672: astore        62
        1674: new           #188                // class ocaml_fn_24
        1677: dup
        1678: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1681: astore        63
        1683: new           #191                // class ocaml_fn_25
        1686: dup
        1687: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1690: astore        64
        1692: aload         63
        1694: checkcast     #188                // class ocaml_fn_24
        1697: aload         63
        1699: checkcast     #194                // class Closure
        1702: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1705: iconst_0
        1706: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1709: astore        65
        1711: aload         63
        1713: checkcast     #188                // class ocaml_fn_24
        1716: aload         64
        1718: checkcast     #194                // class Closure
        1721: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1724: iconst_0
        1725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1728: astore        66
        1730: aload         64
        1732: checkcast     #191                // class ocaml_fn_25
        1735: aload         63
        1737: checkcast     #194                // class Closure
        1740: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1743: iconst_0
        1744: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1747: astore        67
        1749: aload         64
        1751: checkcast     #191                // class ocaml_fn_25
        1754: aload         64
        1756: checkcast     #194                // class Closure
        1759: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1762: iconst_0
        1763: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1766: astore        68
        1768: iconst_0
        1769: istore        69
        1771: iload         69
        1773: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        70
        1778: iconst_1
        1779: istore        71
        1781: iload         71
        1783: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1786: astore        72
        1788: iconst_2
        1789: istore        73
        1791: iload         73
        1793: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1796: astore        74
        1798: new           #209                // class ocaml_fn_26
        1801: dup
        1802: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1805: astore        75
        1807: new           #212                // class ocaml_fn_27
        1810: dup
        1811: aload         75
        1813: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1816: astore        76
        1818: new           #215                // class ocaml_fn_28
        1821: dup
        1822: aload         75
        1824: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1827: astore        77
        1829: new           #218                // class ocaml_fn_29
        1832: dup
        1833: aload         30
        1835: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1838: astore        78
        1840: new           #221                // class ocaml_fn_30
        1843: dup
        1844: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1847: astore        79
        1849: new           #224                // class ocaml_fn_31
        1852: dup
        1853: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1856: astore        80
        1858: new           #227                // class ocaml_fn_32
        1861: dup
        1862: aload         18
        1864: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1867: astore        81
        1869: new           #230                // class ocaml_fn_33
        1872: dup
        1873: aload         18
        1875: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1878: astore        82
        1880: new           #233                // class ocaml_fn_34
        1883: dup
        1884: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1887: astore        83
        1889: new           #236                // class ocaml_fn_35
        1892: dup
        1893: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1896: astore        84
        1898: new           #239                // class ocaml_fn_36
        1901: dup
        1902: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1905: astore        85
        1907: new           #242                // class ocaml_fn_37
        1910: dup
        1911: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1914: astore        86
        1916: new           #245                // class ocaml_fn_38
        1919: dup
        1920: aload         86
        1922: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1925: astore        87
        1927: new           #248                // class ocaml_fn_39
        1930: dup
        1931: aload         86
        1933: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1936: astore        88
        1938: new           #251                // class ocaml_fn_40
        1941: dup
        1942: aload         18
        1944: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1947: astore        89
        1949: new           #254                // class ocaml_fn_41
        1952: dup
        1953: aload         31
        1955: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1958: astore        90
        1960: new           #257                // class ocaml_fn_42
        1963: dup
        1964: aload         18
        1966: aload         90
        1968: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        91
        1973: new           #262                // class ocaml_fn_43
        1976: dup
        1977: aload         91
        1979: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1982: astore        92
        1984: new           #265                // class ocaml_fn_44
        1987: dup
        1988: aload         31
        1990: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1993: astore        93
        1995: new           #268                // class ocaml_fn_45
        1998: dup
        1999: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        2002: astore        94
        2004: new           #271                // class ocaml_fn_46
        2007: dup
        2008: aload         72
        2010: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2013: astore        95
        2015: new           #274                // class ocaml_fn_47
        2018: dup
        2019: aload         72
        2021: aload         80
        2023: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        96
        2028: new           #277                // class ocaml_fn_48
        2031: dup
        2032: aload         72
        2034: aload         79
        2036: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2039: astore        97
        2041: new           #280                // class ocaml_fn_49
        2044: dup
        2045: aload         58
        2047: aload         72
        2049: aload         80
        2051: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2054: astore        98
        2056: new           #285                // class ocaml_fn_50
        2059: dup
        2060: aload         61
        2062: aload         72
        2064: aload         80
        2066: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        99
        2071: new           #288                // class ocaml_fn_51
        2074: dup
        2075: aload         72
        2077: aload         80
        2079: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2082: astore        100
        2084: new           #291                // class ocaml_fn_52
        2087: dup
        2088: aload         72
        2090: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2093: astore        101
        2095: new           #294                // class ocaml_fn_53
        2098: dup
        2099: aload         74
        2101: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2104: astore        102
        2106: new           #297                // class ocaml_fn_54
        2109: dup
        2110: aload         74
        2112: aload         80
        2114: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2117: astore        103
        2119: new           #300                // class ocaml_fn_55
        2122: dup
        2123: aload         74
        2125: aload         79
        2127: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2130: astore        104
        2132: new           #303                // class ocaml_fn_56
        2135: dup
        2136: aload         58
        2138: aload         74
        2140: aload         80
        2142: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2145: astore        105
        2147: new           #306                // class ocaml_fn_57
        2150: dup
        2151: aload         61
        2153: aload         74
        2155: aload         80
        2157: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2160: astore        106
        2162: new           #309                // class ocaml_fn_58
        2165: dup
        2166: aload         74
        2168: aload         80
        2170: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        107
        2175: new           #312                // class ocaml_fn_59
        2178: dup
        2179: aload         74
        2181: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2184: astore        108
        2186: new           #315                // class ocaml_fn_60
        2189: dup
        2190: aload         70
        2192: aload         72
        2194: aload         93
        2196: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2199: astore        109
        2201: new           #318                // class ocaml_fn_61
        2204: dup
        2205: aload         109
        2207: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        110
        2212: new           #321                // class ocaml_fn_62
        2215: dup
        2216: aload         59
        2218: aload         109
        2220: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2223: astore        111
        2225: new           #324                // class ocaml_fn_63
        2228: dup
        2229: aload         109
        2231: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2234: astore        112
        2236: new           #327                // class ocaml_fn_64
        2239: dup
        2240: aload         62
        2242: aload         109
        2244: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        113
        2249: new           #330                // class ocaml_fn_65
        2252: dup
        2253: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2256: astore        114
        2258: new           #333                // class ocaml_fn_66
        2261: dup
        2262: aload         53
        2264: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2267: astore        115
        2269: new           #2                  // class Block
        2272: dup
        2273: iconst_0
        2274: iconst_1
        2275: anewarray     #4                  // class java/lang/Object
        2278: dup
        2279: iconst_0
        2280: aload         78
        2282: aastore
        2283: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2286: astore        116
        2288: new           #336                // class ocaml_fn_67
        2291: dup
        2292: aload         116
        2294: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2297: astore        117
        2299: new           #339                // class ocaml_fn_68
        2302: dup
        2303: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2306: astore        118
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         118
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        119
        2327: new           #342                // class ocaml_fn_69
        2330: dup
        2331: aload         116
        2333: aload         119
        2335: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2338: astore        120
        2340: new           #345                // class ocaml_fn_70
        2343: dup
        2344: aload         120
        2346: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2349: astore        121
        2351: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2354: bipush        44
        2356: aaload
        2357: astore        122
        2359: iconst_0
        2360: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2363: astore        123
        2365: new           #348                // class ocaml_fn_71
        2368: dup
        2369: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2372: astore        124
        2374: new           #351                // class ocaml_fn_72
        2377: dup
        2378: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2381: astore        125
        2383: new           #354                // class ocaml_fn_73
        2386: dup
        2387: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2390: astore        126
        2392: new           #357                // class ocaml_fn_74
        2395: dup
        2396: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2399: astore        127
        2401: new           #360                // class ocaml_fn_75
        2404: dup
        2405: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2408: astore        128
        2410: new           #363                // class ocaml_fn_76
        2413: dup
        2414: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2417: astore        129
        2419: new           #2                  // class Block
        2422: dup
        2423: iconst_0
        2424: bipush        6
        2426: anewarray     #4                  // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         129
        2433: aastore
        2434: dup
        2435: iconst_1
        2436: aload         128
        2438: aastore
        2439: dup
        2440: iconst_2
        2441: aload         127
        2443: aastore
        2444: dup
        2445: iconst_3
        2446: aload         126
        2448: aastore
        2449: dup
        2450: iconst_4
        2451: aload         125
        2453: aastore
        2454: dup
        2455: iconst_5
        2456: aload         124
        2458: aastore
        2459: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2462: astore        130
        2464: new           #366                // class ocaml_fn_77
        2467: dup
        2468: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2471: astore        131
        2473: new           #369                // class ocaml_fn_78
        2476: dup
        2477: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2480: astore        132
        2482: new           #372                // class ocaml_fn_79
        2485: dup
        2486: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2489: astore        133
        2491: new           #375                // class ocaml_fn_80
        2494: dup
        2495: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2498: astore        134
        2500: new           #378                // class ocaml_fn_81
        2503: dup
        2504: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2507: astore        135
        2509: new           #381                // class ocaml_fn_82
        2512: dup
        2513: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2516: astore        136
        2518: new           #384                // class ocaml_fn_83
        2521: dup
        2522: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2525: astore        137
        2527: new           #387                // class ocaml_fn_84
        2530: dup
        2531: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2534: astore        138
        2536: new           #390                // class ocaml_fn_85
        2539: dup
        2540: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2543: astore        139
        2545: new           #393                // class ocaml_fn_86
        2548: dup
        2549: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2552: astore        140
        2554: new           #396                // class ocaml_fn_87
        2557: dup
        2558: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2561: astore        141
        2563: new           #399                // class ocaml_fn_88
        2566: dup
        2567: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2570: astore        142
        2572: new           #402                // class ocaml_fn_89
        2575: dup
        2576: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2579: astore        143
        2581: new           #405                // class ocaml_fn_90
        2584: dup
        2585: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2588: astore        144
        2590: new           #408                // class ocaml_fn_91
        2593: dup
        2594: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2597: astore        145
        2599: new           #411                // class ocaml_fn_92
        2602: dup
        2603: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2606: astore        146
        2608: new           #414                // class ocaml_fn_93
        2611: dup
        2612: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2615: astore        147
        2617: new           #2                  // class Block
        2620: dup
        2621: iconst_0
        2622: bipush        104
        2624: anewarray     #4                  // class java/lang/Object
        2627: dup
        2628: iconst_0
        2629: aload         18
        2631: aastore
        2632: dup
        2633: iconst_1
        2634: aload         17
        2636: aastore
        2637: dup
        2638: iconst_2
        2639: aload         22
        2641: aastore
        2642: dup
        2643: iconst_3
        2644: aload         23
        2646: aastore
        2647: dup
        2648: iconst_4
        2649: aload         24
        2651: aastore
        2652: dup
        2653: iconst_5
        2654: aload         25
        2656: aastore
        2657: dup
        2658: bipush        6
        2660: aload         26
        2662: aastore
        2663: dup
        2664: bipush        7
        2666: aload         27
        2668: aastore
        2669: dup
        2670: bipush        8
        2672: aload         28
        2674: aastore
        2675: dup
        2676: bipush        9
        2678: aload         29
        2680: aastore
        2681: dup
        2682: bipush        10
        2684: aload         30
        2686: aastore
        2687: dup
        2688: bipush        11
        2690: aload         31
        2692: aastore
        2693: dup
        2694: bipush        12
        2696: aload         32
        2698: aastore
        2699: dup
        2700: bipush        13
        2702: aload         33
        2704: aastore
        2705: dup
        2706: bipush        14
        2708: aload         34
        2710: aastore
        2711: dup
        2712: bipush        15
        2714: aload         35
        2716: aastore
        2717: dup
        2718: bipush        16
        2720: aload         36
        2722: aastore
        2723: dup
        2724: bipush        17
        2726: aload         37
        2728: aastore
        2729: dup
        2730: bipush        18
        2732: iload         39
        2734: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2737: aastore
        2738: dup
        2739: bipush        19
        2741: iload         40
        2743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2746: aastore
        2747: dup
        2748: bipush        20
        2750: aload         38
        2752: aastore
        2753: dup
        2754: bipush        21
        2756: aload         42
        2758: aastore
        2759: dup
        2760: bipush        22
        2762: aload         44
        2764: aastore
        2765: dup
        2766: bipush        23
        2768: aload         46
        2770: aastore
        2771: dup
        2772: bipush        24
        2774: aload         48
        2776: aastore
        2777: dup
        2778: bipush        25
        2780: aload         50
        2782: aastore
        2783: dup
        2784: bipush        26
        2786: aload         52
        2788: aastore
        2789: dup
        2790: bipush        27
        2792: aload         53
        2794: aastore
        2795: dup
        2796: bipush        28
        2798: aload         54
        2800: aastore
        2801: dup
        2802: bipush        29
        2804: aload         55
        2806: aastore
        2807: dup
        2808: bipush        30
        2810: aload         57
        2812: aastore
        2813: dup
        2814: bipush        31
        2816: aload         56
        2818: aastore
        2819: dup
        2820: bipush        32
        2822: aload         58
        2824: aastore
        2825: dup
        2826: bipush        33
        2828: aload         59
        2830: aastore
        2831: dup
        2832: bipush        34
        2834: aload         61
        2836: aastore
        2837: dup
        2838: bipush        35
        2840: aload         62
        2842: aastore
        2843: dup
        2844: bipush        36
        2846: aload         63
        2848: aastore
        2849: dup
        2850: bipush        37
        2852: aload         70
        2854: aastore
        2855: dup
        2856: bipush        38
        2858: aload         72
        2860: aastore
        2861: dup
        2862: bipush        39
        2864: aload         74
        2866: aastore
        2867: dup
        2868: bipush        40
        2870: aload         95
        2872: aastore
        2873: dup
        2874: bipush        41
        2876: aload         96
        2878: aastore
        2879: dup
        2880: bipush        42
        2882: aload         97
        2884: aastore
        2885: dup
        2886: bipush        43
        2888: aload         98
        2890: aastore
        2891: dup
        2892: bipush        44
        2894: aload         99
        2896: aastore
        2897: dup
        2898: bipush        45
        2900: aload         100
        2902: aastore
        2903: dup
        2904: bipush        46
        2906: aload         101
        2908: aastore
        2909: dup
        2910: bipush        47
        2912: aload         102
        2914: aastore
        2915: dup
        2916: bipush        48
        2918: aload         103
        2920: aastore
        2921: dup
        2922: bipush        49
        2924: aload         104
        2926: aastore
        2927: dup
        2928: bipush        50
        2930: aload         105
        2932: aastore
        2933: dup
        2934: bipush        51
        2936: aload         106
        2938: aastore
        2939: dup
        2940: bipush        52
        2942: aload         107
        2944: aastore
        2945: dup
        2946: bipush        53
        2948: aload         108
        2950: aastore
        2951: dup
        2952: bipush        54
        2954: aload         109
        2956: aastore
        2957: dup
        2958: bipush        55
        2960: aload         111
        2962: aastore
        2963: dup
        2964: bipush        56
        2966: aload         110
        2968: aastore
        2969: dup
        2970: bipush        57
        2972: aload         113
        2974: aastore
        2975: dup
        2976: bipush        58
        2978: aload         112
        2980: aastore
        2981: dup
        2982: bipush        59
        2984: aload         76
        2986: aastore
        2987: dup
        2988: bipush        60
        2990: aload         77
        2992: aastore
        2993: dup
        2994: bipush        61
        2996: aload         75
        2998: aastore
        2999: dup
        3000: bipush        62
        3002: aload         147
        3004: aastore
        3005: dup
        3006: bipush        63
        3008: aload         78
        3010: aastore
        3011: dup
        3012: bipush        64
        3014: aload         146
        3016: aastore
        3017: dup
        3018: bipush        65
        3020: aload         80
        3022: aastore
        3023: dup
        3024: bipush        66
        3026: aload         79
        3028: aastore
        3029: dup
        3030: bipush        67
        3032: aload         81
        3034: aastore
        3035: dup
        3036: bipush        68
        3038: aload         82
        3040: aastore
        3041: dup
        3042: bipush        69
        3044: aload         145
        3046: aastore
        3047: dup
        3048: bipush        70
        3050: aload         144
        3052: aastore
        3053: dup
        3054: bipush        71
        3056: aload         83
        3058: aastore
        3059: dup
        3060: bipush        72
        3062: aload         143
        3064: aastore
        3065: dup
        3066: bipush        73
        3068: aload         142
        3070: aastore
        3071: dup
        3072: bipush        74
        3074: aload         141
        3076: aastore
        3077: dup
        3078: bipush        75
        3080: aload         84
        3082: aastore
        3083: dup
        3084: bipush        76
        3086: aload         85
        3088: aastore
        3089: dup
        3090: bipush        77
        3092: aload         140
        3094: aastore
        3095: dup
        3096: bipush        78
        3098: aload         87
        3100: aastore
        3101: dup
        3102: bipush        79
        3104: aload         88
        3106: aastore
        3107: dup
        3108: bipush        80
        3110: aload         86
        3112: aastore
        3113: dup
        3114: bipush        81
        3116: aload         139
        3118: aastore
        3119: dup
        3120: bipush        82
        3122: aload         93
        3124: aastore
        3125: dup
        3126: bipush        83
        3128: aload         89
        3130: aastore
        3131: dup
        3132: bipush        84
        3134: aload         91
        3136: aastore
        3137: dup
        3138: bipush        85
        3140: aload         92
        3142: aastore
        3143: dup
        3144: bipush        86
        3146: aload         138
        3148: aastore
        3149: dup
        3150: bipush        87
        3152: aload         137
        3154: aastore
        3155: dup
        3156: bipush        88
        3158: aload         136
        3160: aastore
        3161: dup
        3162: bipush        89
        3164: aload         135
        3166: aastore
        3167: dup
        3168: bipush        90
        3170: aload         134
        3172: aastore
        3173: dup
        3174: bipush        91
        3176: aload         133
        3178: aastore
        3179: dup
        3180: bipush        92
        3182: aload         132
        3184: aastore
        3185: dup
        3186: bipush        93
        3188: aload         94
        3190: aastore
        3191: dup
        3192: bipush        94
        3194: aload         131
        3196: aastore
        3197: dup
        3198: bipush        95
        3200: aload         130
        3202: aastore
        3203: dup
        3204: bipush        96
        3206: aload         114
        3208: aastore
        3209: dup
        3210: bipush        97
        3212: aload         115
        3214: aastore
        3215: dup
        3216: bipush        98
        3218: aload         121
        3220: aastore
        3221: dup
        3222: bipush        99
        3224: aload         117
        3226: aastore
        3227: dup
        3228: bipush        100
        3230: aload         60
        3232: aastore
        3233: dup
        3234: bipush        101
        3236: aload         90
        3238: aastore
        3239: dup
        3240: bipush        102
        3242: aload         120
        3244: aastore
        3245: dup
        3246: bipush        103
        3248: aload         119
        3250: aastore
        3251: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3254: astore        148
        3256: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3259: bipush        45
        3261: aload         148
        3263: aastore
        3264: iconst_0
        3265: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3268: astore        149
        3270: iconst_0
        3271: istore        150
        3273: iload         150
        3275: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3278: astore        151
        3280: goto_w        3285
        3285: new           #417                // class ocaml_fn_94
        3288: dup
        3289: invokespecial #418                // Method ocaml_fn_94."<init>":()V
        3292: astore        152
        3294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3297: bipush        46
        3299: aaload
        3300: astore        153
        3302: aload         152
        3304: aload         153
        3306: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3309: astore        154
        3311: getstatic     #426                // Field java/lang/System.out:Ljava/io/PrintStream;
        3314: aload         154
        3316: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        3319: l2i
        3320: invokevirtual #432                // Method java/io/PrintStream.println:(I)V
        3323: iconst_0
        3324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3327: astore        155
        3329: new           #2                  // class Block
        3332: dup
        3333: iconst_0
        3334: iconst_1
        3335: anewarray     #4                  // class java/lang/Object
        3338: dup
        3339: iconst_0
        3340: aload         152
        3342: aastore
        3343: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3346: astore        156
        3348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3351: bipush        47
        3353: aload         156
        3355: aastore
        3356: iconst_0
        3357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3360: astore        157
        3362: iconst_0
        3363: istore        158
        3365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3368: bipush        45
        3370: aaload
        3371: checkcast     #2                  // class Block
        3374: getfield      #435                // Field Block.fields:[Ljava/lang/Object;
        3377: bipush        102
        3379: aaload
        3380: astore        159
        3382: aload         159
        3384: checkcast     #194                // class Closure
        3387: iload         158
        3389: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3392: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3395: astore        160
        3397: new           #2                  // class Block
        3400: dup
        3401: iconst_0
        3402: iconst_0
        3403: anewarray     #4                  // class java/lang/Object
        3406: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3409: astore        161
        3411: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3414: bipush        48
        3416: aload         161
        3418: aastore
        3419: iconst_0
        3420: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3423: astore        162
        3425: return
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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: ldc           #106                // String Test.Oops
        1048: aastore
        1049: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1052: bipush        47
        1054: iconst_0
        1055: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1058: aastore
        1059: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1062: bipush        48
        1064: iconst_0
        1065: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1068: aastore
        1069: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1072: iconst_4
        1073: aaload
        1074: putstatic     #112                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1077: aconst_null
        1078: astore_1
        1079: aload_1
        1080: astore_2
        1081: goto_w        1086
        1086: new           #114                // class ocaml_fn_0
        1089: dup
        1090: invokespecial #117                // Method ocaml_fn_0."<init>":()V
        1093: astore_3
        1094: new           #119                // class ocaml_fn_1
        1097: dup
        1098: invokespecial #120                // Method ocaml_fn_1."<init>":()V
        1101: astore        4
        1103: new           #122                // class ocaml_fn_2
        1106: dup
        1107: invokespecial #123                // Method ocaml_fn_2."<init>":()V
        1110: astore        5
        1112: new           #2                  // class Block
        1115: dup
        1116: iconst_0
        1117: iconst_3
        1118: anewarray     #4                  // class java/lang/Object
        1121: dup
        1122: iconst_0
        1123: aload         4
        1125: aastore
        1126: dup
        1127: iconst_1
        1128: aload_3
        1129: aastore
        1130: dup
        1131: iconst_2
        1132: aload         5
        1134: aastore
        1135: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1138: astore        6
        1140: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1143: bipush        12
        1145: aload         6
        1147: aastore
        1148: iconst_0
        1149: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1152: astore        7
        1154: iconst_0
        1155: istore        8
        1157: iload         8
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        9
        1164: goto_w        1169
        1169: sipush        199
        1172: istore        10
        1174: iconst_0
        1175: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1178: astore        11
        1180: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1183: bipush        35
        1185: aaload
        1186: astore        12
        1188: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1191: iconst_3
        1192: aaload
        1193: astore        13
        1195: new           #2                  // class Block
        1198: dup
        1199: iconst_0
        1200: iconst_2
        1201: anewarray     #4                  // class java/lang/Object
        1204: dup
        1205: iconst_0
        1206: aload         13
        1208: aastore
        1209: dup
        1210: iconst_1
        1211: aload         12
        1213: aastore
        1214: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1217: astore        14
        1219: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1222: bipush        36
        1224: aaload
        1225: astore        15
        1227: iconst_0
        1228: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1231: astore        16
        1233: new           #125                // class ocaml_fn_8
        1236: dup
        1237: invokespecial #126                // Method ocaml_fn_8."<init>":()V
        1240: astore        17
        1242: new           #128                // class ocaml_fn_9
        1245: dup
        1246: invokespecial #129                // Method ocaml_fn_9."<init>":()V
        1249: astore        18
        1251: iconst_0
        1252: istore        19
        1254: iconst_0
        1255: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1258: astore        20
        1260: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1263: bipush        37
        1265: aaload
        1266: astore        21
        1268: new           #2                  // class Block
        1271: dup
        1272: sipush        248
        1275: iconst_2
        1276: anewarray     #4                  // class java/lang/Object
        1279: dup
        1280: iconst_0
        1281: aload         21
        1283: aastore
        1284: dup
        1285: iconst_1
        1286: aload         20
        1288: aastore
        1289: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1292: astore        22
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        7
        1299: aaload
        1300: astore        23
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        10
        1307: aaload
        1308: astore        24
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: iconst_3
        1314: aaload
        1315: astore        25
        1317: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1320: iconst_2
        1321: aaload
        1322: astore        26
        1324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1327: bipush        6
        1329: aaload
        1330: astore        27
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: iconst_0
        1336: aaload
        1337: astore        28
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: bipush        8
        1344: aaload
        1345: astore        29
        1347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1350: iconst_1
        1351: aaload
        1352: astore        30
        1354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1357: iconst_4
        1358: aaload
        1359: astore        31
        1361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1364: iconst_5
        1365: aaload
        1366: astore        32
        1368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1371: bipush        9
        1373: aaload
        1374: astore        33
        1376: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1379: bipush        11
        1381: aaload
        1382: astore        34
        1384: new           #131                // class ocaml_fn_10
        1387: dup
        1388: invokespecial #132                // Method ocaml_fn_10."<init>":()V
        1391: astore        35
        1393: new           #134                // class ocaml_fn_11
        1396: dup
        1397: invokespecial #135                // Method ocaml_fn_11."<init>":()V
        1400: astore        36
        1402: new           #137                // class ocaml_fn_12
        1405: dup
        1406: invokespecial #138                // Method ocaml_fn_12."<init>":()V
        1409: astore        37
        1411: new           #140                // class ocaml_fn_13
        1414: dup
        1415: invokespecial #141                // Method ocaml_fn_13."<init>":()V
        1418: astore        38
        1420: ldc           #142                // int 2147483647
        1422: istore        39
        1424: ldc           #143                // int -2147483648
        1426: istore        40
        1428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1431: bipush        38
        1433: aaload
        1434: astore        41
        1436: aload         41
        1438: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1441: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1444: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1447: astore        42
        1449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1452: bipush        39
        1454: aaload
        1455: astore        43
        1457: aload         43
        1459: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1462: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1465: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        44
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        40
        1475: aaload
        1476: astore        45
        1478: aload         45
        1480: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1483: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1486: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1489: astore        46
        1491: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1494: bipush        41
        1496: aaload
        1497: astore        47
        1499: aload         47
        1501: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1504: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1507: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1510: astore        48
        1512: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1515: bipush        42
        1517: aaload
        1518: astore        49
        1520: aload         49
        1522: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1525: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1528: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1531: astore        50
        1533: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1536: bipush        43
        1538: aaload
        1539: astore        51
        1541: aload         51
        1543: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        1546: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1549: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1552: astore        52
        1554: new           #158                // class ocaml_fn_14
        1557: dup
        1558: invokespecial #159                // Method ocaml_fn_14."<init>":()V
        1561: astore        53
        1563: new           #161                // class ocaml_fn_15
        1566: dup
        1567: aload         18
        1569: invokespecial #164                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1572: astore        54
        1574: new           #166                // class ocaml_fn_16
        1577: dup
        1578: invokespecial #167                // Method ocaml_fn_16."<init>":()V
        1581: astore        55
        1583: new           #169                // class ocaml_fn_17
        1586: dup
        1587: aload         18
        1589: invokespecial #170                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1592: astore        56
        1594: new           #172                // class ocaml_fn_18
        1597: dup
        1598: invokespecial #173                // Method ocaml_fn_18."<init>":()V
        1601: astore        57
        1603: new           #175                // class ocaml_fn_19
        1606: dup
        1607: invokespecial #176                // Method ocaml_fn_19."<init>":()V
        1610: astore        58
        1612: new           #178                // class ocaml_fn_20
        1615: dup
        1616: aload         26
        1618: invokespecial #179                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1621: astore        59
        1623: new           #181                // class ocaml_fn_21
        1626: dup
        1627: aload         53
        1629: invokespecial #182                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1632: astore        60
        1634: new           #184                // class ocaml_fn_22
        1637: dup
        1638: aload         60
        1640: invokespecial #185                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1643: astore        61
        1645: new           #187                // class ocaml_fn_23
        1648: dup
        1649: aload         26
        1651: invokespecial #188                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1654: astore        62
        1656: new           #190                // class ocaml_fn_24
        1659: dup
        1660: invokespecial #191                // Method ocaml_fn_24."<init>":()V
        1663: astore        63
        1665: new           #193                // class ocaml_fn_25
        1668: dup
        1669: invokespecial #194                // Method ocaml_fn_25."<init>":()V
        1672: astore        64
        1674: aload         63
        1676: checkcast     #190                // class ocaml_fn_24
        1679: aload         63
        1681: checkcast     #196                // class Closure
        1684: putfield      #200                // Field ocaml_fn_24.sibling_0:LClosure;
        1687: iconst_0
        1688: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1691: astore        65
        1693: aload         63
        1695: checkcast     #190                // class ocaml_fn_24
        1698: aload         64
        1700: checkcast     #196                // class Closure
        1703: putfield      #203                // Field ocaml_fn_24.sibling_1:LClosure;
        1706: iconst_0
        1707: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1710: astore        66
        1712: aload         64
        1714: checkcast     #193                // class ocaml_fn_25
        1717: aload         63
        1719: checkcast     #196                // class Closure
        1722: putfield      #204                // Field ocaml_fn_25.sibling_0:LClosure;
        1725: iconst_0
        1726: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1729: astore        67
        1731: aload         64
        1733: checkcast     #193                // class ocaml_fn_25
        1736: aload         64
        1738: checkcast     #196                // class Closure
        1741: putfield      #205                // Field ocaml_fn_25.sibling_1:LClosure;
        1744: iconst_0
        1745: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1748: astore        68
        1750: iconst_0
        1751: istore        69
        1753: iload         69
        1755: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1758: astore        70
        1760: iconst_1
        1761: istore        71
        1763: iload         71
        1765: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1768: astore        72
        1770: iconst_2
        1771: istore        73
        1773: iload         73
        1775: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1778: astore        74
        1780: new           #211                // class ocaml_fn_26
        1783: dup
        1784: invokespecial #212                // Method ocaml_fn_26."<init>":()V
        1787: astore        75
        1789: new           #214                // class ocaml_fn_27
        1792: dup
        1793: aload         75
        1795: invokespecial #215                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1798: astore        76
        1800: new           #217                // class ocaml_fn_28
        1803: dup
        1804: aload         75
        1806: invokespecial #218                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1809: astore        77
        1811: new           #220                // class ocaml_fn_29
        1814: dup
        1815: aload         30
        1817: invokespecial #221                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1820: astore        78
        1822: new           #223                // class ocaml_fn_30
        1825: dup
        1826: invokespecial #224                // Method ocaml_fn_30."<init>":()V
        1829: astore        79
        1831: new           #226                // class ocaml_fn_31
        1834: dup
        1835: invokespecial #227                // Method ocaml_fn_31."<init>":()V
        1838: astore        80
        1840: new           #229                // class ocaml_fn_32
        1843: dup
        1844: aload         18
        1846: invokespecial #230                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1849: astore        81
        1851: new           #232                // class ocaml_fn_33
        1854: dup
        1855: aload         18
        1857: invokespecial #233                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1860: astore        82
        1862: new           #235                // class ocaml_fn_34
        1865: dup
        1866: invokespecial #236                // Method ocaml_fn_34."<init>":()V
        1869: astore        83
        1871: new           #238                // class ocaml_fn_35
        1874: dup
        1875: invokespecial #239                // Method ocaml_fn_35."<init>":()V
        1878: astore        84
        1880: new           #241                // class ocaml_fn_36
        1883: dup
        1884: invokespecial #242                // Method ocaml_fn_36."<init>":()V
        1887: astore        85
        1889: new           #244                // class ocaml_fn_37
        1892: dup
        1893: invokespecial #245                // Method ocaml_fn_37."<init>":()V
        1896: astore        86
        1898: new           #247                // class ocaml_fn_38
        1901: dup
        1902: aload         86
        1904: invokespecial #248                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1907: astore        87
        1909: new           #250                // class ocaml_fn_39
        1912: dup
        1913: aload         86
        1915: invokespecial #251                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1918: astore        88
        1920: new           #253                // class ocaml_fn_40
        1923: dup
        1924: aload         18
        1926: invokespecial #254                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1929: astore        89
        1931: new           #256                // class ocaml_fn_41
        1934: dup
        1935: aload         31
        1937: invokespecial #257                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1940: astore        90
        1942: new           #259                // class ocaml_fn_42
        1945: dup
        1946: aload         18
        1948: aload         90
        1950: invokespecial #262                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        91
        1955: new           #264                // class ocaml_fn_43
        1958: dup
        1959: aload         91
        1961: invokespecial #265                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1964: astore        92
        1966: new           #267                // class ocaml_fn_44
        1969: dup
        1970: aload         31
        1972: invokespecial #268                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1975: astore        93
        1977: new           #270                // class ocaml_fn_45
        1980: dup
        1981: invokespecial #271                // Method ocaml_fn_45."<init>":()V
        1984: astore        94
        1986: new           #273                // class ocaml_fn_46
        1989: dup
        1990: aload         72
        1992: invokespecial #274                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1995: astore        95
        1997: new           #276                // class ocaml_fn_47
        2000: dup
        2001: aload         72
        2003: aload         80
        2005: invokespecial #277                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        96
        2010: new           #279                // class ocaml_fn_48
        2013: dup
        2014: aload         72
        2016: aload         79
        2018: invokespecial #280                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        97
        2023: new           #282                // class ocaml_fn_49
        2026: dup
        2027: aload         58
        2029: aload         72
        2031: aload         80
        2033: invokespecial #285                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2036: astore        98
        2038: new           #287                // class ocaml_fn_50
        2041: dup
        2042: aload         61
        2044: aload         72
        2046: aload         80
        2048: invokespecial #288                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2051: astore        99
        2053: new           #290                // class ocaml_fn_51
        2056: dup
        2057: aload         72
        2059: aload         80
        2061: invokespecial #291                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        100
        2066: new           #293                // class ocaml_fn_52
        2069: dup
        2070: aload         72
        2072: invokespecial #294                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2075: astore        101
        2077: new           #296                // class ocaml_fn_53
        2080: dup
        2081: aload         74
        2083: invokespecial #297                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2086: astore        102
        2088: new           #299                // class ocaml_fn_54
        2091: dup
        2092: aload         74
        2094: aload         80
        2096: invokespecial #300                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        103
        2101: new           #302                // class ocaml_fn_55
        2104: dup
        2105: aload         74
        2107: aload         79
        2109: invokespecial #303                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        104
        2114: new           #305                // class ocaml_fn_56
        2117: dup
        2118: aload         58
        2120: aload         74
        2122: aload         80
        2124: invokespecial #306                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2127: astore        105
        2129: new           #308                // class ocaml_fn_57
        2132: dup
        2133: aload         61
        2135: aload         74
        2137: aload         80
        2139: invokespecial #309                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2142: astore        106
        2144: new           #311                // class ocaml_fn_58
        2147: dup
        2148: aload         74
        2150: aload         80
        2152: invokespecial #312                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        107
        2157: new           #314                // class ocaml_fn_59
        2160: dup
        2161: aload         74
        2163: invokespecial #315                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2166: astore        108
        2168: new           #317                // class ocaml_fn_60
        2171: dup
        2172: aload         70
        2174: aload         72
        2176: aload         93
        2178: invokespecial #318                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        109
        2183: new           #320                // class ocaml_fn_61
        2186: dup
        2187: aload         109
        2189: invokespecial #321                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2192: astore        110
        2194: new           #323                // class ocaml_fn_62
        2197: dup
        2198: aload         59
        2200: aload         109
        2202: invokespecial #324                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2205: astore        111
        2207: new           #326                // class ocaml_fn_63
        2210: dup
        2211: aload         109
        2213: invokespecial #327                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2216: astore        112
        2218: new           #329                // class ocaml_fn_64
        2221: dup
        2222: aload         62
        2224: aload         109
        2226: invokespecial #330                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2229: astore        113
        2231: new           #332                // class ocaml_fn_65
        2234: dup
        2235: invokespecial #333                // Method ocaml_fn_65."<init>":()V
        2238: astore        114
        2240: new           #335                // class ocaml_fn_66
        2243: dup
        2244: aload         53
        2246: invokespecial #336                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2249: astore        115
        2251: new           #2                  // class Block
        2254: dup
        2255: iconst_0
        2256: iconst_1
        2257: anewarray     #4                  // class java/lang/Object
        2260: dup
        2261: iconst_0
        2262: aload         78
        2264: aastore
        2265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2268: astore        116
        2270: new           #338                // class ocaml_fn_67
        2273: dup
        2274: aload         116
        2276: invokespecial #339                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2279: astore        117
        2281: new           #341                // class ocaml_fn_68
        2284: dup
        2285: invokespecial #342                // Method ocaml_fn_68."<init>":()V
        2288: astore        118
        2290: new           #2                  // class Block
        2293: dup
        2294: iconst_0
        2295: iconst_1
        2296: anewarray     #4                  // class java/lang/Object
        2299: dup
        2300: iconst_0
        2301: aload         118
        2303: aastore
        2304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2307: astore        119
        2309: new           #344                // class ocaml_fn_69
        2312: dup
        2313: aload         116
        2315: aload         119
        2317: invokespecial #345                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2320: astore        120
        2322: new           #347                // class ocaml_fn_70
        2325: dup
        2326: aload         120
        2328: invokespecial #348                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2331: astore        121
        2333: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2336: bipush        44
        2338: aaload
        2339: astore        122
        2341: iconst_0
        2342: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2345: astore        123
        2347: new           #350                // class ocaml_fn_71
        2350: dup
        2351: invokespecial #351                // Method ocaml_fn_71."<init>":()V
        2354: astore        124
        2356: new           #353                // class ocaml_fn_72
        2359: dup
        2360: invokespecial #354                // Method ocaml_fn_72."<init>":()V
        2363: astore        125
        2365: new           #356                // class ocaml_fn_73
        2368: dup
        2369: invokespecial #357                // Method ocaml_fn_73."<init>":()V
        2372: astore        126
        2374: new           #359                // class ocaml_fn_74
        2377: dup
        2378: invokespecial #360                // Method ocaml_fn_74."<init>":()V
        2381: astore        127
        2383: new           #362                // class ocaml_fn_75
        2386: dup
        2387: invokespecial #363                // Method ocaml_fn_75."<init>":()V
        2390: astore        128
        2392: new           #365                // class ocaml_fn_76
        2395: dup
        2396: invokespecial #366                // Method ocaml_fn_76."<init>":()V
        2399: astore        129
        2401: new           #2                  // class Block
        2404: dup
        2405: iconst_0
        2406: bipush        6
        2408: anewarray     #4                  // class java/lang/Object
        2411: dup
        2412: iconst_0
        2413: aload         129
        2415: aastore
        2416: dup
        2417: iconst_1
        2418: aload         128
        2420: aastore
        2421: dup
        2422: iconst_2
        2423: aload         127
        2425: aastore
        2426: dup
        2427: iconst_3
        2428: aload         126
        2430: aastore
        2431: dup
        2432: iconst_4
        2433: aload         125
        2435: aastore
        2436: dup
        2437: iconst_5
        2438: aload         124
        2440: aastore
        2441: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2444: astore        130
        2446: new           #368                // class ocaml_fn_77
        2449: dup
        2450: invokespecial #369                // Method ocaml_fn_77."<init>":()V
        2453: astore        131
        2455: new           #371                // class ocaml_fn_78
        2458: dup
        2459: invokespecial #372                // Method ocaml_fn_78."<init>":()V
        2462: astore        132
        2464: new           #374                // class ocaml_fn_79
        2467: dup
        2468: invokespecial #375                // Method ocaml_fn_79."<init>":()V
        2471: astore        133
        2473: new           #377                // class ocaml_fn_80
        2476: dup
        2477: invokespecial #378                // Method ocaml_fn_80."<init>":()V
        2480: astore        134
        2482: new           #380                // class ocaml_fn_81
        2485: dup
        2486: invokespecial #381                // Method ocaml_fn_81."<init>":()V
        2489: astore        135
        2491: new           #383                // class ocaml_fn_82
        2494: dup
        2495: invokespecial #384                // Method ocaml_fn_82."<init>":()V
        2498: astore        136
        2500: new           #386                // class ocaml_fn_83
        2503: dup
        2504: invokespecial #387                // Method ocaml_fn_83."<init>":()V
        2507: astore        137
        2509: new           #389                // class ocaml_fn_84
        2512: dup
        2513: invokespecial #390                // Method ocaml_fn_84."<init>":()V
        2516: astore        138
        2518: new           #392                // class ocaml_fn_85
        2521: dup
        2522: invokespecial #393                // Method ocaml_fn_85."<init>":()V
        2525: astore        139
        2527: new           #395                // class ocaml_fn_86
        2530: dup
        2531: invokespecial #396                // Method ocaml_fn_86."<init>":()V
        2534: astore        140
        2536: new           #398                // class ocaml_fn_87
        2539: dup
        2540: invokespecial #399                // Method ocaml_fn_87."<init>":()V
        2543: astore        141
        2545: new           #401                // class ocaml_fn_88
        2548: dup
        2549: invokespecial #402                // Method ocaml_fn_88."<init>":()V
        2552: astore        142
        2554: new           #404                // class ocaml_fn_89
        2557: dup
        2558: invokespecial #405                // Method ocaml_fn_89."<init>":()V
        2561: astore        143
        2563: new           #407                // class ocaml_fn_90
        2566: dup
        2567: invokespecial #408                // Method ocaml_fn_90."<init>":()V
        2570: astore        144
        2572: new           #410                // class ocaml_fn_91
        2575: dup
        2576: invokespecial #411                // Method ocaml_fn_91."<init>":()V
        2579: astore        145
        2581: new           #413                // class ocaml_fn_92
        2584: dup
        2585: invokespecial #414                // Method ocaml_fn_92."<init>":()V
        2588: astore        146
        2590: new           #416                // class ocaml_fn_93
        2593: dup
        2594: invokespecial #417                // Method ocaml_fn_93."<init>":()V
        2597: astore        147
        2599: new           #2                  // class Block
        2602: dup
        2603: iconst_0
        2604: bipush        104
        2606: anewarray     #4                  // class java/lang/Object
        2609: dup
        2610: iconst_0
        2611: aload         18
        2613: aastore
        2614: dup
        2615: iconst_1
        2616: aload         17
        2618: aastore
        2619: dup
        2620: iconst_2
        2621: aload         22
        2623: aastore
        2624: dup
        2625: iconst_3
        2626: aload         23
        2628: aastore
        2629: dup
        2630: iconst_4
        2631: aload         24
        2633: aastore
        2634: dup
        2635: iconst_5
        2636: aload         25
        2638: aastore
        2639: dup
        2640: bipush        6
        2642: aload         26
        2644: aastore
        2645: dup
        2646: bipush        7
        2648: aload         27
        2650: aastore
        2651: dup
        2652: bipush        8
        2654: aload         28
        2656: aastore
        2657: dup
        2658: bipush        9
        2660: aload         29
        2662: aastore
        2663: dup
        2664: bipush        10
        2666: aload         30
        2668: aastore
        2669: dup
        2670: bipush        11
        2672: aload         31
        2674: aastore
        2675: dup
        2676: bipush        12
        2678: aload         32
        2680: aastore
        2681: dup
        2682: bipush        13
        2684: aload         33
        2686: aastore
        2687: dup
        2688: bipush        14
        2690: aload         34
        2692: aastore
        2693: dup
        2694: bipush        15
        2696: aload         35
        2698: aastore
        2699: dup
        2700: bipush        16
        2702: aload         36
        2704: aastore
        2705: dup
        2706: bipush        17
        2708: aload         37
        2710: aastore
        2711: dup
        2712: bipush        18
        2714: iload         39
        2716: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2719: aastore
        2720: dup
        2721: bipush        19
        2723: iload         40
        2725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2728: aastore
        2729: dup
        2730: bipush        20
        2732: aload         38
        2734: aastore
        2735: dup
        2736: bipush        21
        2738: aload         42
        2740: aastore
        2741: dup
        2742: bipush        22
        2744: aload         44
        2746: aastore
        2747: dup
        2748: bipush        23
        2750: aload         46
        2752: aastore
        2753: dup
        2754: bipush        24
        2756: aload         48
        2758: aastore
        2759: dup
        2760: bipush        25
        2762: aload         50
        2764: aastore
        2765: dup
        2766: bipush        26
        2768: aload         52
        2770: aastore
        2771: dup
        2772: bipush        27
        2774: aload         53
        2776: aastore
        2777: dup
        2778: bipush        28
        2780: aload         54
        2782: aastore
        2783: dup
        2784: bipush        29
        2786: aload         55
        2788: aastore
        2789: dup
        2790: bipush        30
        2792: aload         57
        2794: aastore
        2795: dup
        2796: bipush        31
        2798: aload         56
        2800: aastore
        2801: dup
        2802: bipush        32
        2804: aload         58
        2806: aastore
        2807: dup
        2808: bipush        33
        2810: aload         59
        2812: aastore
        2813: dup
        2814: bipush        34
        2816: aload         61
        2818: aastore
        2819: dup
        2820: bipush        35
        2822: aload         62
        2824: aastore
        2825: dup
        2826: bipush        36
        2828: aload         63
        2830: aastore
        2831: dup
        2832: bipush        37
        2834: aload         70
        2836: aastore
        2837: dup
        2838: bipush        38
        2840: aload         72
        2842: aastore
        2843: dup
        2844: bipush        39
        2846: aload         74
        2848: aastore
        2849: dup
        2850: bipush        40
        2852: aload         95
        2854: aastore
        2855: dup
        2856: bipush        41
        2858: aload         96
        2860: aastore
        2861: dup
        2862: bipush        42
        2864: aload         97
        2866: aastore
        2867: dup
        2868: bipush        43
        2870: aload         98
        2872: aastore
        2873: dup
        2874: bipush        44
        2876: aload         99
        2878: aastore
        2879: dup
        2880: bipush        45
        2882: aload         100
        2884: aastore
        2885: dup
        2886: bipush        46
        2888: aload         101
        2890: aastore
        2891: dup
        2892: bipush        47
        2894: aload         102
        2896: aastore
        2897: dup
        2898: bipush        48
        2900: aload         103
        2902: aastore
        2903: dup
        2904: bipush        49
        2906: aload         104
        2908: aastore
        2909: dup
        2910: bipush        50
        2912: aload         105
        2914: aastore
        2915: dup
        2916: bipush        51
        2918: aload         106
        2920: aastore
        2921: dup
        2922: bipush        52
        2924: aload         107
        2926: aastore
        2927: dup
        2928: bipush        53
        2930: aload         108
        2932: aastore
        2933: dup
        2934: bipush        54
        2936: aload         109
        2938: aastore
        2939: dup
        2940: bipush        55
        2942: aload         111
        2944: aastore
        2945: dup
        2946: bipush        56
        2948: aload         110
        2950: aastore
        2951: dup
        2952: bipush        57
        2954: aload         113
        2956: aastore
        2957: dup
        2958: bipush        58
        2960: aload         112
        2962: aastore
        2963: dup
        2964: bipush        59
        2966: aload         76
        2968: aastore
        2969: dup
        2970: bipush        60
        2972: aload         77
        2974: aastore
        2975: dup
        2976: bipush        61
        2978: aload         75
        2980: aastore
        2981: dup
        2982: bipush        62
        2984: aload         147
        2986: aastore
        2987: dup
        2988: bipush        63
        2990: aload         78
        2992: aastore
        2993: dup
        2994: bipush        64
        2996: aload         146
        2998: aastore
        2999: dup
        3000: bipush        65
        3002: aload         80
        3004: aastore
        3005: dup
        3006: bipush        66
        3008: aload         79
        3010: aastore
        3011: dup
        3012: bipush        67
        3014: aload         81
        3016: aastore
        3017: dup
        3018: bipush        68
        3020: aload         82
        3022: aastore
        3023: dup
        3024: bipush        69
        3026: aload         145
        3028: aastore
        3029: dup
        3030: bipush        70
        3032: aload         144
        3034: aastore
        3035: dup
        3036: bipush        71
        3038: aload         83
        3040: aastore
        3041: dup
        3042: bipush        72
        3044: aload         143
        3046: aastore
        3047: dup
        3048: bipush        73
        3050: aload         142
        3052: aastore
        3053: dup
        3054: bipush        74
        3056: aload         141
        3058: aastore
        3059: dup
        3060: bipush        75
        3062: aload         84
        3064: aastore
        3065: dup
        3066: bipush        76
        3068: aload         85
        3070: aastore
        3071: dup
        3072: bipush        77
        3074: aload         140
        3076: aastore
        3077: dup
        3078: bipush        78
        3080: aload         87
        3082: aastore
        3083: dup
        3084: bipush        79
        3086: aload         88
        3088: aastore
        3089: dup
        3090: bipush        80
        3092: aload         86
        3094: aastore
        3095: dup
        3096: bipush        81
        3098: aload         139
        3100: aastore
        3101: dup
        3102: bipush        82
        3104: aload         93
        3106: aastore
        3107: dup
        3108: bipush        83
        3110: aload         89
        3112: aastore
        3113: dup
        3114: bipush        84
        3116: aload         91
        3118: aastore
        3119: dup
        3120: bipush        85
        3122: aload         92
        3124: aastore
        3125: dup
        3126: bipush        86
        3128: aload         138
        3130: aastore
        3131: dup
        3132: bipush        87
        3134: aload         137
        3136: aastore
        3137: dup
        3138: bipush        88
        3140: aload         136
        3142: aastore
        3143: dup
        3144: bipush        89
        3146: aload         135
        3148: aastore
        3149: dup
        3150: bipush        90
        3152: aload         134
        3154: aastore
        3155: dup
        3156: bipush        91
        3158: aload         133
        3160: aastore
        3161: dup
        3162: bipush        92
        3164: aload         132
        3166: aastore
        3167: dup
        3168: bipush        93
        3170: aload         94
        3172: aastore
        3173: dup
        3174: bipush        94
        3176: aload         131
        3178: aastore
        3179: dup
        3180: bipush        95
        3182: aload         130
        3184: aastore
        3185: dup
        3186: bipush        96
        3188: aload         114
        3190: aastore
        3191: dup
        3192: bipush        97
        3194: aload         115
        3196: aastore
        3197: dup
        3198: bipush        98
        3200: aload         121
        3202: aastore
        3203: dup
        3204: bipush        99
        3206: aload         117
        3208: aastore
        3209: dup
        3210: bipush        100
        3212: aload         60
        3214: aastore
        3215: dup
        3216: bipush        101
        3218: aload         90
        3220: aastore
        3221: dup
        3222: bipush        102
        3224: aload         120
        3226: aastore
        3227: dup
        3228: bipush        103
        3230: aload         119
        3232: aastore
        3233: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3236: astore        148
        3238: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3241: bipush        45
        3243: aload         148
        3245: aastore
        3246: iconst_0
        3247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3250: astore        149
        3252: iconst_0
        3253: istore        150
        3255: iload         150
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        151
        3262: goto_w        3267
        3267: iconst_0
        3268: istore        152
        3270: iconst_1
        3271: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3274: astore        153
        3276: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3279: bipush        46
        3281: aaload
        3282: astore        154
        3284: new           #2                  // class Block
        3287: dup
        3288: sipush        248
        3291: iconst_2
        3292: anewarray     #4                  // class java/lang/Object
        3295: dup
        3296: iconst_0
        3297: aload         154
        3299: aastore
        3300: dup
        3301: iconst_1
        3302: aload         153
        3304: aastore
        3305: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3308: astore        155
        3310: new           #419                // class ocaml_fn_94
        3313: dup
        3314: aload         155
        3316: invokespecial #420                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3319: astore        156
        3321: iconst_0
        3322: istore        157
        3324: aload         156
        3326: iload         157
        3328: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3331: invokevirtual #424                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3334: astore        158
        3336: getstatic     #428                // Field java/lang/System.out:Ljava/io/PrintStream;
        3339: aload         158
        3341: invokestatic  #147                // Method Block.asLong:(Ljava/lang/Object;)J
        3344: l2i
        3345: invokevirtual #434                // Method java/io/PrintStream.println:(I)V
        3348: iconst_0
        3349: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3352: astore        159
        3354: new           #2                  // class Block
        3357: dup
        3358: iconst_0
        3359: iconst_2
        3360: anewarray     #4                  // class java/lang/Object
        3363: dup
        3364: iconst_0
        3365: aload         155
        3367: aastore
        3368: dup
        3369: iconst_1
        3370: aload         156
        3372: aastore
        3373: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3376: astore        160
        3378: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3381: bipush        47
        3383: aload         160
        3385: aastore
        3386: iconst_0
        3387: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3390: astore        161
        3392: iconst_0
        3393: istore        162
        3395: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3398: bipush        45
        3400: aaload
        3401: checkcast     #2                  // class Block
        3404: getfield      #437                // Field Block.fields:[Ljava/lang/Object;
        3407: bipush        102
        3409: aaload
        3410: astore        163
        3412: aload         163
        3414: checkcast     #196                // class Closure
        3417: iload         162
        3419: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3422: invokevirtual #424                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3425: astore        164
        3427: new           #2                  // class Block
        3430: dup
        3431: iconst_0
        3432: iconst_0
        3433: anewarray     #4                  // class java/lang/Object
        3436: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3439: astore        165
        3441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3444: bipush        48
        3446: aload         165
        3448: aastore
        3449: iconst_0
        3450: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3453: astore        166
        3455: return
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
         956: ldc2_w        #86                 // long 9218868437227405312l
         959: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         962: aastore
         963: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         966: bipush        39
         968: ldc2_w        #93                 // long -4503599627370496l
         971: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         974: aastore
         975: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        40
         980: ldc2_w        #95                 // long 9221120237041090561l
         983: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         986: aastore
         987: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         990: bipush        41
         992: ldc2_w        #97                 // long 9218868437227405311l
         995: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         998: aastore
         999: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1002: bipush        42
        1004: ldc2_w        #99                 // long 4503599627370496l
        1007: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1010: aastore
        1011: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        43
        1016: ldc2_w        #101                // long 4372995238176751616l
        1019: invokestatic  #92                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1022: aastore
        1023: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1026: bipush        44
        1028: ldc           #104                // String Pervasives.do_at_exit
        1030: aastore
        1031: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1034: bipush        45
        1036: iconst_0
        1037: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1040: aastore
        1041: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1044: bipush        46
        1046: iconst_0
        1047: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1050: aastore
        1051: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1054: bipush        47
        1056: iconst_0
        1057: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1060: aastore
        1061: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1064: iconst_4
        1065: aaload
        1066: putstatic     #110                // Field Channel.endOfFileExn:Ljava/lang/Object;
        1069: aconst_null
        1070: astore_1
        1071: aload_1
        1072: astore_2
        1073: goto_w        1078
        1078: new           #112                // class ocaml_fn_0
        1081: dup
        1082: invokespecial #115                // Method ocaml_fn_0."<init>":()V
        1085: astore_3
        1086: new           #117                // class ocaml_fn_1
        1089: dup
        1090: invokespecial #118                // Method ocaml_fn_1."<init>":()V
        1093: astore        4
        1095: new           #120                // class ocaml_fn_2
        1098: dup
        1099: invokespecial #121                // Method ocaml_fn_2."<init>":()V
        1102: astore        5
        1104: new           #2                  // class Block
        1107: dup
        1108: iconst_0
        1109: iconst_3
        1110: anewarray     #4                  // class java/lang/Object
        1113: dup
        1114: iconst_0
        1115: aload         4
        1117: aastore
        1118: dup
        1119: iconst_1
        1120: aload_3
        1121: aastore
        1122: dup
        1123: iconst_2
        1124: aload         5
        1126: aastore
        1127: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1130: astore        6
        1132: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1135: bipush        12
        1137: aload         6
        1139: aastore
        1140: iconst_0
        1141: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        7
        1146: iconst_0
        1147: istore        8
        1149: iload         8
        1151: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1154: astore        9
        1156: goto_w        1161
        1161: sipush        199
        1164: istore        10
        1166: iconst_0
        1167: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1170: astore        11
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: bipush        35
        1177: aaload
        1178: astore        12
        1180: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1183: iconst_3
        1184: aaload
        1185: astore        13
        1187: new           #2                  // class Block
        1190: dup
        1191: iconst_0
        1192: iconst_2
        1193: anewarray     #4                  // class java/lang/Object
        1196: dup
        1197: iconst_0
        1198: aload         13
        1200: aastore
        1201: dup
        1202: iconst_1
        1203: aload         12
        1205: aastore
        1206: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1209: astore        14
        1211: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1214: bipush        36
        1216: aaload
        1217: astore        15
        1219: iconst_0
        1220: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1223: astore        16
        1225: new           #123                // class ocaml_fn_8
        1228: dup
        1229: invokespecial #124                // Method ocaml_fn_8."<init>":()V
        1232: astore        17
        1234: new           #126                // class ocaml_fn_9
        1237: dup
        1238: invokespecial #127                // Method ocaml_fn_9."<init>":()V
        1241: astore        18
        1243: iconst_0
        1244: istore        19
        1246: iconst_0
        1247: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1250: astore        20
        1252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1255: bipush        37
        1257: aaload
        1258: astore        21
        1260: new           #2                  // class Block
        1263: dup
        1264: sipush        248
        1267: iconst_2
        1268: anewarray     #4                  // class java/lang/Object
        1271: dup
        1272: iconst_0
        1273: aload         21
        1275: aastore
        1276: dup
        1277: iconst_1
        1278: aload         20
        1280: aastore
        1281: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1284: astore        22
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        7
        1291: aaload
        1292: astore        23
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        10
        1299: aaload
        1300: astore        24
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: iconst_3
        1306: aaload
        1307: astore        25
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: iconst_2
        1313: aaload
        1314: astore        26
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: bipush        6
        1321: aaload
        1322: astore        27
        1324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1327: iconst_0
        1328: aaload
        1329: astore        28
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: bipush        8
        1336: aaload
        1337: astore        29
        1339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1342: iconst_1
        1343: aaload
        1344: astore        30
        1346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1349: iconst_4
        1350: aaload
        1351: astore        31
        1353: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1356: iconst_5
        1357: aaload
        1358: astore        32
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        9
        1365: aaload
        1366: astore        33
        1368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1371: bipush        11
        1373: aaload
        1374: astore        34
        1376: new           #129                // class ocaml_fn_10
        1379: dup
        1380: invokespecial #130                // Method ocaml_fn_10."<init>":()V
        1383: astore        35
        1385: new           #132                // class ocaml_fn_11
        1388: dup
        1389: invokespecial #133                // Method ocaml_fn_11."<init>":()V
        1392: astore        36
        1394: new           #135                // class ocaml_fn_12
        1397: dup
        1398: invokespecial #136                // Method ocaml_fn_12."<init>":()V
        1401: astore        37
        1403: new           #138                // class ocaml_fn_13
        1406: dup
        1407: invokespecial #139                // Method ocaml_fn_13."<init>":()V
        1410: astore        38
        1412: ldc           #140                // int 2147483647
        1414: istore        39
        1416: ldc           #141                // int -2147483648
        1418: istore        40
        1420: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        38
        1425: aaload
        1426: astore        41
        1428: aload         41
        1430: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1433: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1436: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        42
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        43
        1449: aload         43
        1451: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1454: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1457: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        44
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        40
        1467: aaload
        1468: astore        45
        1470: aload         45
        1472: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1475: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1478: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        46
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        41
        1488: aaload
        1489: astore        47
        1491: aload         47
        1493: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1496: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1499: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1502: astore        48
        1504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1507: bipush        42
        1509: aaload
        1510: astore        49
        1512: aload         49
        1514: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1517: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1520: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1523: astore        50
        1525: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1528: bipush        43
        1530: aaload
        1531: astore        51
        1533: aload         51
        1535: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        1538: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1541: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1544: astore        52
        1546: new           #156                // class ocaml_fn_14
        1549: dup
        1550: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1553: astore        53
        1555: new           #159                // class ocaml_fn_15
        1558: dup
        1559: aload         18
        1561: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1564: astore        54
        1566: new           #164                // class ocaml_fn_16
        1569: dup
        1570: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1573: astore        55
        1575: new           #167                // class ocaml_fn_17
        1578: dup
        1579: aload         18
        1581: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1584: astore        56
        1586: new           #170                // class ocaml_fn_18
        1589: dup
        1590: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1593: astore        57
        1595: new           #173                // class ocaml_fn_19
        1598: dup
        1599: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1602: astore        58
        1604: new           #176                // class ocaml_fn_20
        1607: dup
        1608: aload         26
        1610: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1613: astore        59
        1615: new           #179                // class ocaml_fn_21
        1618: dup
        1619: aload         53
        1621: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1624: astore        60
        1626: new           #182                // class ocaml_fn_22
        1629: dup
        1630: aload         60
        1632: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1635: astore        61
        1637: new           #185                // class ocaml_fn_23
        1640: dup
        1641: aload         26
        1643: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1646: astore        62
        1648: new           #188                // class ocaml_fn_24
        1651: dup
        1652: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1655: astore        63
        1657: new           #191                // class ocaml_fn_25
        1660: dup
        1661: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1664: astore        64
        1666: aload         63
        1668: checkcast     #188                // class ocaml_fn_24
        1671: aload         63
        1673: checkcast     #194                // class Closure
        1676: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1679: iconst_0
        1680: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1683: astore        65
        1685: aload         63
        1687: checkcast     #188                // class ocaml_fn_24
        1690: aload         64
        1692: checkcast     #194                // class Closure
        1695: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1698: iconst_0
        1699: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1702: astore        66
        1704: aload         64
        1706: checkcast     #191                // class ocaml_fn_25
        1709: aload         63
        1711: checkcast     #194                // class Closure
        1714: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1717: iconst_0
        1718: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1721: astore        67
        1723: aload         64
        1725: checkcast     #191                // class ocaml_fn_25
        1728: aload         64
        1730: checkcast     #194                // class Closure
        1733: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1736: iconst_0
        1737: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1740: astore        68
        1742: iconst_0
        1743: istore        69
        1745: iload         69
        1747: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1750: astore        70
        1752: iconst_1
        1753: istore        71
        1755: iload         71
        1757: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1760: astore        72
        1762: iconst_2
        1763: istore        73
        1765: iload         73
        1767: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1770: astore        74
        1772: new           #209                // class ocaml_fn_26
        1775: dup
        1776: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1779: astore        75
        1781: new           #212                // class ocaml_fn_27
        1784: dup
        1785: aload         75
        1787: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1790: astore        76
        1792: new           #215                // class ocaml_fn_28
        1795: dup
        1796: aload         75
        1798: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1801: astore        77
        1803: new           #218                // class ocaml_fn_29
        1806: dup
        1807: aload         30
        1809: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1812: astore        78
        1814: new           #221                // class ocaml_fn_30
        1817: dup
        1818: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1821: astore        79
        1823: new           #224                // class ocaml_fn_31
        1826: dup
        1827: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1830: astore        80
        1832: new           #227                // class ocaml_fn_32
        1835: dup
        1836: aload         18
        1838: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1841: astore        81
        1843: new           #230                // class ocaml_fn_33
        1846: dup
        1847: aload         18
        1849: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1852: astore        82
        1854: new           #233                // class ocaml_fn_34
        1857: dup
        1858: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1861: astore        83
        1863: new           #236                // class ocaml_fn_35
        1866: dup
        1867: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1870: astore        84
        1872: new           #239                // class ocaml_fn_36
        1875: dup
        1876: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1879: astore        85
        1881: new           #242                // class ocaml_fn_37
        1884: dup
        1885: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1888: astore        86
        1890: new           #245                // class ocaml_fn_38
        1893: dup
        1894: aload         86
        1896: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1899: astore        87
        1901: new           #248                // class ocaml_fn_39
        1904: dup
        1905: aload         86
        1907: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1910: astore        88
        1912: new           #251                // class ocaml_fn_40
        1915: dup
        1916: aload         18
        1918: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1921: astore        89
        1923: new           #254                // class ocaml_fn_41
        1926: dup
        1927: aload         31
        1929: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1932: astore        90
        1934: new           #257                // class ocaml_fn_42
        1937: dup
        1938: aload         18
        1940: aload         90
        1942: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1945: astore        91
        1947: new           #262                // class ocaml_fn_43
        1950: dup
        1951: aload         91
        1953: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1956: astore        92
        1958: new           #265                // class ocaml_fn_44
        1961: dup
        1962: aload         31
        1964: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1967: astore        93
        1969: new           #268                // class ocaml_fn_45
        1972: dup
        1973: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1976: astore        94
        1978: new           #271                // class ocaml_fn_46
        1981: dup
        1982: aload         72
        1984: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1987: astore        95
        1989: new           #274                // class ocaml_fn_47
        1992: dup
        1993: aload         72
        1995: aload         80
        1997: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2000: astore        96
        2002: new           #277                // class ocaml_fn_48
        2005: dup
        2006: aload         72
        2008: aload         79
        2010: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        97
        2015: new           #280                // class ocaml_fn_49
        2018: dup
        2019: aload         58
        2021: aload         72
        2023: aload         80
        2025: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2028: astore        98
        2030: new           #285                // class ocaml_fn_50
        2033: dup
        2034: aload         61
        2036: aload         72
        2038: aload         80
        2040: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2043: astore        99
        2045: new           #288                // class ocaml_fn_51
        2048: dup
        2049: aload         72
        2051: aload         80
        2053: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        100
        2058: new           #291                // class ocaml_fn_52
        2061: dup
        2062: aload         72
        2064: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2067: astore        101
        2069: new           #294                // class ocaml_fn_53
        2072: dup
        2073: aload         74
        2075: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2078: astore        102
        2080: new           #297                // class ocaml_fn_54
        2083: dup
        2084: aload         74
        2086: aload         80
        2088: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        103
        2093: new           #300                // class ocaml_fn_55
        2096: dup
        2097: aload         74
        2099: aload         79
        2101: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2104: astore        104
        2106: new           #303                // class ocaml_fn_56
        2109: dup
        2110: aload         58
        2112: aload         74
        2114: aload         80
        2116: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2119: astore        105
        2121: new           #306                // class ocaml_fn_57
        2124: dup
        2125: aload         61
        2127: aload         74
        2129: aload         80
        2131: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        106
        2136: new           #309                // class ocaml_fn_58
        2139: dup
        2140: aload         74
        2142: aload         80
        2144: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        107
        2149: new           #312                // class ocaml_fn_59
        2152: dup
        2153: aload         74
        2155: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        108
        2160: new           #315                // class ocaml_fn_60
        2163: dup
        2164: aload         70
        2166: aload         72
        2168: aload         93
        2170: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        109
        2175: new           #318                // class ocaml_fn_61
        2178: dup
        2179: aload         109
        2181: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2184: astore        110
        2186: new           #321                // class ocaml_fn_62
        2189: dup
        2190: aload         59
        2192: aload         109
        2194: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        111
        2199: new           #324                // class ocaml_fn_63
        2202: dup
        2203: aload         109
        2205: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2208: astore        112
        2210: new           #327                // class ocaml_fn_64
        2213: dup
        2214: aload         62
        2216: aload         109
        2218: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2221: astore        113
        2223: new           #330                // class ocaml_fn_65
        2226: dup
        2227: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2230: astore        114
        2232: new           #333                // class ocaml_fn_66
        2235: dup
        2236: aload         53
        2238: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2241: astore        115
        2243: new           #2                  // class Block
        2246: dup
        2247: iconst_0
        2248: iconst_1
        2249: anewarray     #4                  // class java/lang/Object
        2252: dup
        2253: iconst_0
        2254: aload         78
        2256: aastore
        2257: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2260: astore        116
        2262: new           #336                // class ocaml_fn_67
        2265: dup
        2266: aload         116
        2268: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2271: astore        117
        2273: new           #339                // class ocaml_fn_68
        2276: dup
        2277: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2280: astore        118
        2282: new           #2                  // class Block
        2285: dup
        2286: iconst_0
        2287: iconst_1
        2288: anewarray     #4                  // class java/lang/Object
        2291: dup
        2292: iconst_0
        2293: aload         118
        2295: aastore
        2296: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2299: astore        119
        2301: new           #342                // class ocaml_fn_69
        2304: dup
        2305: aload         116
        2307: aload         119
        2309: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2312: astore        120
        2314: new           #345                // class ocaml_fn_70
        2317: dup
        2318: aload         120
        2320: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2323: astore        121
        2325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2328: bipush        44
        2330: aaload
        2331: astore        122
        2333: iconst_0
        2334: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2337: astore        123
        2339: new           #348                // class ocaml_fn_71
        2342: dup
        2343: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2346: astore        124
        2348: new           #351                // class ocaml_fn_72
        2351: dup
        2352: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2355: astore        125
        2357: new           #354                // class ocaml_fn_73
        2360: dup
        2361: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2364: astore        126
        2366: new           #357                // class ocaml_fn_74
        2369: dup
        2370: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2373: astore        127
        2375: new           #360                // class ocaml_fn_75
        2378: dup
        2379: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2382: astore        128
        2384: new           #363                // class ocaml_fn_76
        2387: dup
        2388: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2391: astore        129
        2393: new           #2                  // class Block
        2396: dup
        2397: iconst_0
        2398: bipush        6
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         129
        2407: aastore
        2408: dup
        2409: iconst_1
        2410: aload         128
        2412: aastore
        2413: dup
        2414: iconst_2
        2415: aload         127
        2417: aastore
        2418: dup
        2419: iconst_3
        2420: aload         126
        2422: aastore
        2423: dup
        2424: iconst_4
        2425: aload         125
        2427: aastore
        2428: dup
        2429: iconst_5
        2430: aload         124
        2432: aastore
        2433: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2436: astore        130
        2438: new           #366                // class ocaml_fn_77
        2441: dup
        2442: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2445: astore        131
        2447: new           #369                // class ocaml_fn_78
        2450: dup
        2451: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2454: astore        132
        2456: new           #372                // class ocaml_fn_79
        2459: dup
        2460: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2463: astore        133
        2465: new           #375                // class ocaml_fn_80
        2468: dup
        2469: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2472: astore        134
        2474: new           #378                // class ocaml_fn_81
        2477: dup
        2478: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2481: astore        135
        2483: new           #381                // class ocaml_fn_82
        2486: dup
        2487: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2490: astore        136
        2492: new           #384                // class ocaml_fn_83
        2495: dup
        2496: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2499: astore        137
        2501: new           #387                // class ocaml_fn_84
        2504: dup
        2505: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2508: astore        138
        2510: new           #390                // class ocaml_fn_85
        2513: dup
        2514: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2517: astore        139
        2519: new           #393                // class ocaml_fn_86
        2522: dup
        2523: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2526: astore        140
        2528: new           #396                // class ocaml_fn_87
        2531: dup
        2532: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2535: astore        141
        2537: new           #399                // class ocaml_fn_88
        2540: dup
        2541: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2544: astore        142
        2546: new           #402                // class ocaml_fn_89
        2549: dup
        2550: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2553: astore        143
        2555: new           #405                // class ocaml_fn_90
        2558: dup
        2559: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2562: astore        144
        2564: new           #408                // class ocaml_fn_91
        2567: dup
        2568: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2571: astore        145
        2573: new           #411                // class ocaml_fn_92
        2576: dup
        2577: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2580: astore        146
        2582: new           #414                // class ocaml_fn_93
        2585: dup
        2586: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2589: astore        147
        2591: new           #2                  // class Block
        2594: dup
        2595: iconst_0
        2596: bipush        104
        2598: anewarray     #4                  // class java/lang/Object
        2601: dup
        2602: iconst_0
        2603: aload         18
        2605: aastore
        2606: dup
        2607: iconst_1
        2608: aload         17
        2610: aastore
        2611: dup
        2612: iconst_2
        2613: aload         22
        2615: aastore
        2616: dup
        2617: iconst_3
        2618: aload         23
        2620: aastore
        2621: dup
        2622: iconst_4
        2623: aload         24
        2625: aastore
        2626: dup
        2627: iconst_5
        2628: aload         25
        2630: aastore
        2631: dup
        2632: bipush        6
        2634: aload         26
        2636: aastore
        2637: dup
        2638: bipush        7
        2640: aload         27
        2642: aastore
        2643: dup
        2644: bipush        8
        2646: aload         28
        2648: aastore
        2649: dup
        2650: bipush        9
        2652: aload         29
        2654: aastore
        2655: dup
        2656: bipush        10
        2658: aload         30
        2660: aastore
        2661: dup
        2662: bipush        11
        2664: aload         31
        2666: aastore
        2667: dup
        2668: bipush        12
        2670: aload         32
        2672: aastore
        2673: dup
        2674: bipush        13
        2676: aload         33
        2678: aastore
        2679: dup
        2680: bipush        14
        2682: aload         34
        2684: aastore
        2685: dup
        2686: bipush        15
        2688: aload         35
        2690: aastore
        2691: dup
        2692: bipush        16
        2694: aload         36
        2696: aastore
        2697: dup
        2698: bipush        17
        2700: aload         37
        2702: aastore
        2703: dup
        2704: bipush        18
        2706: iload         39
        2708: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2711: aastore
        2712: dup
        2713: bipush        19
        2715: iload         40
        2717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2720: aastore
        2721: dup
        2722: bipush        20
        2724: aload         38
        2726: aastore
        2727: dup
        2728: bipush        21
        2730: aload         42
        2732: aastore
        2733: dup
        2734: bipush        22
        2736: aload         44
        2738: aastore
        2739: dup
        2740: bipush        23
        2742: aload         46
        2744: aastore
        2745: dup
        2746: bipush        24
        2748: aload         48
        2750: aastore
        2751: dup
        2752: bipush        25
        2754: aload         50
        2756: aastore
        2757: dup
        2758: bipush        26
        2760: aload         52
        2762: aastore
        2763: dup
        2764: bipush        27
        2766: aload         53
        2768: aastore
        2769: dup
        2770: bipush        28
        2772: aload         54
        2774: aastore
        2775: dup
        2776: bipush        29
        2778: aload         55
        2780: aastore
        2781: dup
        2782: bipush        30
        2784: aload         57
        2786: aastore
        2787: dup
        2788: bipush        31
        2790: aload         56
        2792: aastore
        2793: dup
        2794: bipush        32
        2796: aload         58
        2798: aastore
        2799: dup
        2800: bipush        33
        2802: aload         59
        2804: aastore
        2805: dup
        2806: bipush        34
        2808: aload         61
        2810: aastore
        2811: dup
        2812: bipush        35
        2814: aload         62
        2816: aastore
        2817: dup
        2818: bipush        36
        2820: aload         63
        2822: aastore
        2823: dup
        2824: bipush        37
        2826: aload         70
        2828: aastore
        2829: dup
        2830: bipush        38
        2832: aload         72
        2834: aastore
        2835: dup
        2836: bipush        39
        2838: aload         74
        2840: aastore
        2841: dup
        2842: bipush        40
        2844: aload         95
        2846: aastore
        2847: dup
        2848: bipush        41
        2850: aload         96
        2852: aastore
        2853: dup
        2854: bipush        42
        2856: aload         97
        2858: aastore
        2859: dup
        2860: bipush        43
        2862: aload         98
        2864: aastore
        2865: dup
        2866: bipush        44
        2868: aload         99
        2870: aastore
        2871: dup
        2872: bipush        45
        2874: aload         100
        2876: aastore
        2877: dup
        2878: bipush        46
        2880: aload         101
        2882: aastore
        2883: dup
        2884: bipush        47
        2886: aload         102
        2888: aastore
        2889: dup
        2890: bipush        48
        2892: aload         103
        2894: aastore
        2895: dup
        2896: bipush        49
        2898: aload         104
        2900: aastore
        2901: dup
        2902: bipush        50
        2904: aload         105
        2906: aastore
        2907: dup
        2908: bipush        51
        2910: aload         106
        2912: aastore
        2913: dup
        2914: bipush        52
        2916: aload         107
        2918: aastore
        2919: dup
        2920: bipush        53
        2922: aload         108
        2924: aastore
        2925: dup
        2926: bipush        54
        2928: aload         109
        2930: aastore
        2931: dup
        2932: bipush        55
        2934: aload         111
        2936: aastore
        2937: dup
        2938: bipush        56
        2940: aload         110
        2942: aastore
        2943: dup
        2944: bipush        57
        2946: aload         113
        2948: aastore
        2949: dup
        2950: bipush        58
        2952: aload         112
        2954: aastore
        2955: dup
        2956: bipush        59
        2958: aload         76
        2960: aastore
        2961: dup
        2962: bipush        60
        2964: aload         77
        2966: aastore
        2967: dup
        2968: bipush        61
        2970: aload         75
        2972: aastore
        2973: dup
        2974: bipush        62
        2976: aload         147
        2978: aastore
        2979: dup
        2980: bipush        63
        2982: aload         78
        2984: aastore
        2985: dup
        2986: bipush        64
        2988: aload         146
        2990: aastore
        2991: dup
        2992: bipush        65
        2994: aload         80
        2996: aastore
        2997: dup
        2998: bipush        66
        3000: aload         79
        3002: aastore
        3003: dup
        3004: bipush        67
        3006: aload         81
        3008: aastore
        3009: dup
        3010: bipush        68
        3012: aload         82
        3014: aastore
        3015: dup
        3016: bipush        69
        3018: aload         145
        3020: aastore
        3021: dup
        3022: bipush        70
        3024: aload         144
        3026: aastore
        3027: dup
        3028: bipush        71
        3030: aload         83
        3032: aastore
        3033: dup
        3034: bipush        72
        3036: aload         143
        3038: aastore
        3039: dup
        3040: bipush        73
        3042: aload         142
        3044: aastore
        3045: dup
        3046: bipush        74
        3048: aload         141
        3050: aastore
        3051: dup
        3052: bipush        75
        3054: aload         84
        3056: aastore
        3057: dup
        3058: bipush        76
        3060: aload         85
        3062: aastore
        3063: dup
        3064: bipush        77
        3066: aload         140
        3068: aastore
        3069: dup
        3070: bipush        78
        3072: aload         87
        3074: aastore
        3075: dup
        3076: bipush        79
        3078: aload         88
        3080: aastore
        3081: dup
        3082: bipush        80
        3084: aload         86
        3086: aastore
        3087: dup
        3088: bipush        81
        3090: aload         139
        3092: aastore
        3093: dup
        3094: bipush        82
        3096: aload         93
        3098: aastore
        3099: dup
        3100: bipush        83
        3102: aload         89
        3104: aastore
        3105: dup
        3106: bipush        84
        3108: aload         91
        3110: aastore
        3111: dup
        3112: bipush        85
        3114: aload         92
        3116: aastore
        3117: dup
        3118: bipush        86
        3120: aload         138
        3122: aastore
        3123: dup
        3124: bipush        87
        3126: aload         137
        3128: aastore
        3129: dup
        3130: bipush        88
        3132: aload         136
        3134: aastore
        3135: dup
        3136: bipush        89
        3138: aload         135
        3140: aastore
        3141: dup
        3142: bipush        90
        3144: aload         134
        3146: aastore
        3147: dup
        3148: bipush        91
        3150: aload         133
        3152: aastore
        3153: dup
        3154: bipush        92
        3156: aload         132
        3158: aastore
        3159: dup
        3160: bipush        93
        3162: aload         94
        3164: aastore
        3165: dup
        3166: bipush        94
        3168: aload         131
        3170: aastore
        3171: dup
        3172: bipush        95
        3174: aload         130
        3176: aastore
        3177: dup
        3178: bipush        96
        3180: aload         114
        3182: aastore
        3183: dup
        3184: bipush        97
        3186: aload         115
        3188: aastore
        3189: dup
        3190: bipush        98
        3192: aload         121
        3194: aastore
        3195: dup
        3196: bipush        99
        3198: aload         117
        3200: aastore
        3201: dup
        3202: bipush        100
        3204: aload         60
        3206: aastore
        3207: dup
        3208: bipush        101
        3210: aload         90
        3212: aastore
        3213: dup
        3214: bipush        102
        3216: aload         120
        3218: aastore
        3219: dup
        3220: bipush        103
        3222: aload         119
        3224: aastore
        3225: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3228: astore        148
        3230: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3233: bipush        45
        3235: aload         148
        3237: aastore
        3238: iconst_0
        3239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3242: astore        149
        3244: iconst_1
        3245: istore        150
        3247: iconst_0
        3248: istore        151
        3250: iload         151
        3252: ifeq          3267
        3255: iload         150
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        152
        3262: goto_w        3295
        3267: iload         150
        3269: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3272: astore        153
        3274: goto_w        3279
        3279: bipush        10
        3281: istore        154
        3283: iload         154
        3285: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3288: astore        155
        3290: goto_w        3311
        3295: bipush        20
        3297: istore        156
        3299: iload         156
        3301: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3304: astore        155
        3306: goto_w        3311
        3311: getstatic     #419                // Field java/lang/System.out:Ljava/io/PrintStream;
        3314: aload         155
        3316: invokestatic  #145                // Method Block.asLong:(Ljava/lang/Object;)J
        3319: l2i
        3320: invokevirtual #425                // Method java/io/PrintStream.println:(I)V
        3323: iconst_0
        3324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3327: astore        157
        3329: new           #2                  // class Block
        3332: dup
        3333: iconst_0
        3334: iconst_0
        3335: anewarray     #4                  // class java/lang/Object
        3338: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3341: astore        158
        3343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3346: bipush        46
        3348: aload         158
        3350: aastore
        3351: iconst_0
        3352: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3355: astore        159
        3357: iconst_0
        3358: istore        160
        3360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3363: bipush        45
        3365: aaload
        3366: checkcast     #2                  // class Block
        3369: getfield      #428                // Field Block.fields:[Ljava/lang/Object;
        3372: bipush        102
        3374: aaload
        3375: astore        161
        3377: aload         161
        3379: checkcast     #194                // class Closure
        3382: iload         160
        3384: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3387: invokevirtual #432                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3390: astore        162
        3392: new           #2                  // class Block
        3395: dup
        3396: iconst_0
        3397: iconst_0
        3398: anewarray     #4                  // class java/lang/Object
        3401: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3404: astore        163
        3406: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3409: bipush        47
        3411: aload         163
        3413: aastore
        3414: iconst_0
        3415: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3418: astore        164
        3420: return
    }
    |}]
