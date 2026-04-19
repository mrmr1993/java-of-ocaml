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
        1438: checkcast     #89                 // class java/lang/Long
        1441: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1444: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1447: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        42
        1452: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        39
        1457: aaload
        1458: astore        43
        1460: aload         43
        1462: checkcast     #89                 // class java/lang/Long
        1465: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1468: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1471: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1474: astore        44
        1476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1479: bipush        40
        1481: aaload
        1482: astore        45
        1484: aload         45
        1486: checkcast     #89                 // class java/lang/Long
        1489: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1492: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1495: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1498: astore        46
        1500: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1503: bipush        41
        1505: aaload
        1506: astore        47
        1508: aload         47
        1510: checkcast     #89                 // class java/lang/Long
        1513: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1516: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1519: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1522: astore        48
        1524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1527: bipush        42
        1529: aaload
        1530: astore        49
        1532: aload         49
        1534: checkcast     #89                 // class java/lang/Long
        1537: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1540: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1543: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1546: astore        50
        1548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1551: bipush        43
        1553: aaload
        1554: astore        51
        1556: aload         51
        1558: checkcast     #89                 // class java/lang/Long
        1561: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1564: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1567: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1570: astore        52
        1572: new           #158                // class ocaml_fn_14
        1575: dup
        1576: invokespecial #159                // Method ocaml_fn_14."<init>":()V
        1579: astore        53
        1581: new           #161                // class ocaml_fn_15
        1584: dup
        1585: aload         18
        1587: invokespecial #164                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1590: astore        54
        1592: new           #166                // class ocaml_fn_16
        1595: dup
        1596: invokespecial #167                // Method ocaml_fn_16."<init>":()V
        1599: astore        55
        1601: new           #169                // class ocaml_fn_17
        1604: dup
        1605: aload         18
        1607: invokespecial #170                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1610: astore        56
        1612: new           #172                // class ocaml_fn_18
        1615: dup
        1616: invokespecial #173                // Method ocaml_fn_18."<init>":()V
        1619: astore        57
        1621: new           #175                // class ocaml_fn_19
        1624: dup
        1625: invokespecial #176                // Method ocaml_fn_19."<init>":()V
        1628: astore        58
        1630: new           #178                // class ocaml_fn_20
        1633: dup
        1634: aload         26
        1636: invokespecial #179                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1639: astore        59
        1641: new           #181                // class ocaml_fn_21
        1644: dup
        1645: aload         53
        1647: invokespecial #182                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1650: astore        60
        1652: new           #184                // class ocaml_fn_22
        1655: dup
        1656: aload         60
        1658: invokespecial #185                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1661: astore        61
        1663: new           #187                // class ocaml_fn_23
        1666: dup
        1667: aload         26
        1669: invokespecial #188                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1672: astore        62
        1674: new           #190                // class ocaml_fn_24
        1677: dup
        1678: invokespecial #191                // Method ocaml_fn_24."<init>":()V
        1681: astore        63
        1683: new           #193                // class ocaml_fn_25
        1686: dup
        1687: invokespecial #194                // Method ocaml_fn_25."<init>":()V
        1690: astore        64
        1692: aload         63
        1694: checkcast     #190                // class ocaml_fn_24
        1697: aload         63
        1699: checkcast     #196                // class Closure
        1702: putfield      #200                // Field ocaml_fn_24.sibling_0:LClosure;
        1705: iconst_0
        1706: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1709: astore        65
        1711: aload         63
        1713: checkcast     #190                // class ocaml_fn_24
        1716: aload         64
        1718: checkcast     #196                // class Closure
        1721: putfield      #203                // Field ocaml_fn_24.sibling_1:LClosure;
        1724: iconst_0
        1725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1728: astore        66
        1730: aload         64
        1732: checkcast     #193                // class ocaml_fn_25
        1735: aload         63
        1737: checkcast     #196                // class Closure
        1740: putfield      #204                // Field ocaml_fn_25.sibling_0:LClosure;
        1743: iconst_0
        1744: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1747: astore        67
        1749: aload         64
        1751: checkcast     #193                // class ocaml_fn_25
        1754: aload         64
        1756: checkcast     #196                // class Closure
        1759: putfield      #205                // Field ocaml_fn_25.sibling_1:LClosure;
        1762: iconst_0
        1763: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1766: astore        68
        1768: iconst_0
        1769: istore        69
        1771: iload         69
        1773: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        70
        1778: iconst_1
        1779: istore        71
        1781: iload         71
        1783: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1786: astore        72
        1788: iconst_2
        1789: istore        73
        1791: iload         73
        1793: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1796: astore        74
        1798: new           #211                // class ocaml_fn_26
        1801: dup
        1802: invokespecial #212                // Method ocaml_fn_26."<init>":()V
        1805: astore        75
        1807: new           #214                // class ocaml_fn_27
        1810: dup
        1811: aload         75
        1813: invokespecial #215                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1816: astore        76
        1818: new           #217                // class ocaml_fn_28
        1821: dup
        1822: aload         75
        1824: invokespecial #218                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1827: astore        77
        1829: new           #220                // class ocaml_fn_29
        1832: dup
        1833: aload         30
        1835: invokespecial #221                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1838: astore        78
        1840: new           #223                // class ocaml_fn_30
        1843: dup
        1844: invokespecial #224                // Method ocaml_fn_30."<init>":()V
        1847: astore        79
        1849: new           #226                // class ocaml_fn_31
        1852: dup
        1853: invokespecial #227                // Method ocaml_fn_31."<init>":()V
        1856: astore        80
        1858: new           #229                // class ocaml_fn_32
        1861: dup
        1862: aload         18
        1864: invokespecial #230                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1867: astore        81
        1869: new           #232                // class ocaml_fn_33
        1872: dup
        1873: aload         18
        1875: invokespecial #233                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1878: astore        82
        1880: new           #235                // class ocaml_fn_34
        1883: dup
        1884: invokespecial #236                // Method ocaml_fn_34."<init>":()V
        1887: astore        83
        1889: new           #238                // class ocaml_fn_35
        1892: dup
        1893: invokespecial #239                // Method ocaml_fn_35."<init>":()V
        1896: astore        84
        1898: new           #241                // class ocaml_fn_36
        1901: dup
        1902: invokespecial #242                // Method ocaml_fn_36."<init>":()V
        1905: astore        85
        1907: new           #244                // class ocaml_fn_37
        1910: dup
        1911: invokespecial #245                // Method ocaml_fn_37."<init>":()V
        1914: astore        86
        1916: new           #247                // class ocaml_fn_38
        1919: dup
        1920: aload         86
        1922: invokespecial #248                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1925: astore        87
        1927: new           #250                // class ocaml_fn_39
        1930: dup
        1931: aload         86
        1933: invokespecial #251                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1936: astore        88
        1938: new           #253                // class ocaml_fn_40
        1941: dup
        1942: aload         18
        1944: invokespecial #254                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1947: astore        89
        1949: new           #256                // class ocaml_fn_41
        1952: dup
        1953: aload         31
        1955: invokespecial #257                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1958: astore        90
        1960: new           #259                // class ocaml_fn_42
        1963: dup
        1964: aload         18
        1966: aload         90
        1968: invokespecial #262                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        91
        1973: new           #264                // class ocaml_fn_43
        1976: dup
        1977: aload         91
        1979: invokespecial #265                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1982: astore        92
        1984: new           #267                // class ocaml_fn_44
        1987: dup
        1988: aload         31
        1990: invokespecial #268                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1993: astore        93
        1995: new           #270                // class ocaml_fn_45
        1998: dup
        1999: invokespecial #271                // Method ocaml_fn_45."<init>":()V
        2002: astore        94
        2004: new           #273                // class ocaml_fn_46
        2007: dup
        2008: aload         72
        2010: invokespecial #274                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2013: astore        95
        2015: new           #276                // class ocaml_fn_47
        2018: dup
        2019: aload         72
        2021: aload         80
        2023: invokespecial #277                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        96
        2028: new           #279                // class ocaml_fn_48
        2031: dup
        2032: aload         72
        2034: aload         79
        2036: invokespecial #280                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2039: astore        97
        2041: new           #282                // class ocaml_fn_49
        2044: dup
        2045: aload         58
        2047: aload         72
        2049: aload         80
        2051: invokespecial #285                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2054: astore        98
        2056: new           #287                // class ocaml_fn_50
        2059: dup
        2060: aload         61
        2062: aload         72
        2064: aload         80
        2066: invokespecial #288                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        99
        2071: new           #290                // class ocaml_fn_51
        2074: dup
        2075: aload         72
        2077: aload         80
        2079: invokespecial #291                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2082: astore        100
        2084: new           #293                // class ocaml_fn_52
        2087: dup
        2088: aload         72
        2090: invokespecial #294                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2093: astore        101
        2095: new           #296                // class ocaml_fn_53
        2098: dup
        2099: aload         74
        2101: invokespecial #297                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2104: astore        102
        2106: new           #299                // class ocaml_fn_54
        2109: dup
        2110: aload         74
        2112: aload         80
        2114: invokespecial #300                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2117: astore        103
        2119: new           #302                // class ocaml_fn_55
        2122: dup
        2123: aload         74
        2125: aload         79
        2127: invokespecial #303                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2130: astore        104
        2132: new           #305                // class ocaml_fn_56
        2135: dup
        2136: aload         58
        2138: aload         74
        2140: aload         80
        2142: invokespecial #306                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2145: astore        105
        2147: new           #308                // class ocaml_fn_57
        2150: dup
        2151: aload         61
        2153: aload         74
        2155: aload         80
        2157: invokespecial #309                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2160: astore        106
        2162: new           #311                // class ocaml_fn_58
        2165: dup
        2166: aload         74
        2168: aload         80
        2170: invokespecial #312                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        107
        2175: new           #314                // class ocaml_fn_59
        2178: dup
        2179: aload         74
        2181: invokespecial #315                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2184: astore        108
        2186: new           #317                // class ocaml_fn_60
        2189: dup
        2190: aload         70
        2192: aload         72
        2194: aload         93
        2196: invokespecial #318                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2199: astore        109
        2201: new           #320                // class ocaml_fn_61
        2204: dup
        2205: aload         109
        2207: invokespecial #321                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        110
        2212: new           #323                // class ocaml_fn_62
        2215: dup
        2216: aload         59
        2218: aload         109
        2220: invokespecial #324                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2223: astore        111
        2225: new           #326                // class ocaml_fn_63
        2228: dup
        2229: aload         109
        2231: invokespecial #327                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2234: astore        112
        2236: new           #329                // class ocaml_fn_64
        2239: dup
        2240: aload         62
        2242: aload         109
        2244: invokespecial #330                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        113
        2249: new           #332                // class ocaml_fn_65
        2252: dup
        2253: invokespecial #333                // Method ocaml_fn_65."<init>":()V
        2256: astore        114
        2258: new           #335                // class ocaml_fn_66
        2261: dup
        2262: aload         53
        2264: invokespecial #336                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
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
        2288: new           #338                // class ocaml_fn_67
        2291: dup
        2292: aload         116
        2294: invokespecial #339                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2297: astore        117
        2299: new           #341                // class ocaml_fn_68
        2302: dup
        2303: invokespecial #342                // Method ocaml_fn_68."<init>":()V
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
        2327: new           #344                // class ocaml_fn_69
        2330: dup
        2331: aload         116
        2333: aload         119
        2335: invokespecial #345                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2338: astore        120
        2340: new           #347                // class ocaml_fn_70
        2343: dup
        2344: aload         120
        2346: invokespecial #348                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2349: astore        121
        2351: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2354: bipush        44
        2356: aaload
        2357: astore        122
        2359: iconst_0
        2360: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2363: astore        123
        2365: new           #350                // class ocaml_fn_71
        2368: dup
        2369: invokespecial #351                // Method ocaml_fn_71."<init>":()V
        2372: astore        124
        2374: new           #353                // class ocaml_fn_72
        2377: dup
        2378: invokespecial #354                // Method ocaml_fn_72."<init>":()V
        2381: astore        125
        2383: new           #356                // class ocaml_fn_73
        2386: dup
        2387: invokespecial #357                // Method ocaml_fn_73."<init>":()V
        2390: astore        126
        2392: new           #359                // class ocaml_fn_74
        2395: dup
        2396: invokespecial #360                // Method ocaml_fn_74."<init>":()V
        2399: astore        127
        2401: new           #362                // class ocaml_fn_75
        2404: dup
        2405: invokespecial #363                // Method ocaml_fn_75."<init>":()V
        2408: astore        128
        2410: new           #365                // class ocaml_fn_76
        2413: dup
        2414: invokespecial #366                // Method ocaml_fn_76."<init>":()V
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
        2464: new           #368                // class ocaml_fn_77
        2467: dup
        2468: invokespecial #369                // Method ocaml_fn_77."<init>":()V
        2471: astore        131
        2473: new           #371                // class ocaml_fn_78
        2476: dup
        2477: invokespecial #372                // Method ocaml_fn_78."<init>":()V
        2480: astore        132
        2482: new           #374                // class ocaml_fn_79
        2485: dup
        2486: invokespecial #375                // Method ocaml_fn_79."<init>":()V
        2489: astore        133
        2491: new           #377                // class ocaml_fn_80
        2494: dup
        2495: invokespecial #378                // Method ocaml_fn_80."<init>":()V
        2498: astore        134
        2500: new           #380                // class ocaml_fn_81
        2503: dup
        2504: invokespecial #381                // Method ocaml_fn_81."<init>":()V
        2507: astore        135
        2509: new           #383                // class ocaml_fn_82
        2512: dup
        2513: invokespecial #384                // Method ocaml_fn_82."<init>":()V
        2516: astore        136
        2518: new           #386                // class ocaml_fn_83
        2521: dup
        2522: invokespecial #387                // Method ocaml_fn_83."<init>":()V
        2525: astore        137
        2527: new           #389                // class ocaml_fn_84
        2530: dup
        2531: invokespecial #390                // Method ocaml_fn_84."<init>":()V
        2534: astore        138
        2536: new           #392                // class ocaml_fn_85
        2539: dup
        2540: invokespecial #393                // Method ocaml_fn_85."<init>":()V
        2543: astore        139
        2545: new           #395                // class ocaml_fn_86
        2548: dup
        2549: invokespecial #396                // Method ocaml_fn_86."<init>":()V
        2552: astore        140
        2554: new           #398                // class ocaml_fn_87
        2557: dup
        2558: invokespecial #399                // Method ocaml_fn_87."<init>":()V
        2561: astore        141
        2563: new           #401                // class ocaml_fn_88
        2566: dup
        2567: invokespecial #402                // Method ocaml_fn_88."<init>":()V
        2570: astore        142
        2572: new           #404                // class ocaml_fn_89
        2575: dup
        2576: invokespecial #405                // Method ocaml_fn_89."<init>":()V
        2579: astore        143
        2581: new           #407                // class ocaml_fn_90
        2584: dup
        2585: invokespecial #408                // Method ocaml_fn_90."<init>":()V
        2588: astore        144
        2590: new           #410                // class ocaml_fn_91
        2593: dup
        2594: invokespecial #411                // Method ocaml_fn_91."<init>":()V
        2597: astore        145
        2599: new           #413                // class ocaml_fn_92
        2602: dup
        2603: invokespecial #414                // Method ocaml_fn_92."<init>":()V
        2606: astore        146
        2608: new           #416                // class ocaml_fn_93
        2611: dup
        2612: invokespecial #417                // Method ocaml_fn_93."<init>":()V
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
        3270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3273: bipush        46
        3275: aaload
        3276: astore        150
        3278: getstatic     #421                // Field java/lang/System.out:Ljava/io/PrintStream;
        3281: aload         150
        3283: checkcast     #423                // class java/lang/String
        3286: invokevirtual #429                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3289: iconst_0
        3290: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3293: astore        151
        3295: new           #2                  // class Block
        3298: dup
        3299: iconst_0
        3300: iconst_0
        3301: anewarray     #4                  // class java/lang/Object
        3304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3307: astore        152
        3309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3312: bipush        47
        3314: aload         152
        3316: aastore
        3317: iconst_0
        3318: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3321: astore        153
        3323: iconst_0
        3324: istore        154
        3326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3329: bipush        45
        3331: aaload
        3332: checkcast     #2                  // class Block
        3335: getfield      #432                // Field Block.fields:[Ljava/lang/Object;
        3338: bipush        102
        3340: aaload
        3341: astore        155
        3343: aload         155
        3345: checkcast     #196                // class Closure
        3348: iload         154
        3350: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3353: invokevirtual #436                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3356: astore        156
        3358: new           #2                  // class Block
        3361: dup
        3362: iconst_0
        3363: iconst_0
        3364: anewarray     #4                  // class java/lang/Object
        3367: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3370: astore        157
        3372: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3375: bipush        48
        3377: aload         157
        3379: aastore
        3380: iconst_0
        3381: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3384: astore        158
        3386: return
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
        1430: checkcast     #89                 // class java/lang/Long
        1433: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1436: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1439: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        42
        1444: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        39
        1449: aaload
        1450: astore        43
        1452: aload         43
        1454: checkcast     #89                 // class java/lang/Long
        1457: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1460: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1463: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: aload         45
        1478: checkcast     #89                 // class java/lang/Long
        1481: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1484: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1487: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1490: astore        46
        1492: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1495: bipush        41
        1497: aaload
        1498: astore        47
        1500: aload         47
        1502: checkcast     #89                 // class java/lang/Long
        1505: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1508: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1511: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        48
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        42
        1521: aaload
        1522: astore        49
        1524: aload         49
        1526: checkcast     #89                 // class java/lang/Long
        1529: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1532: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1535: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1538: astore        50
        1540: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1543: bipush        43
        1545: aaload
        1546: astore        51
        1548: aload         51
        1550: checkcast     #89                 // class java/lang/Long
        1553: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1556: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1559: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1562: astore        52
        1564: new           #156                // class ocaml_fn_14
        1567: dup
        1568: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1571: astore        53
        1573: new           #159                // class ocaml_fn_15
        1576: dup
        1577: aload         18
        1579: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1582: astore        54
        1584: new           #164                // class ocaml_fn_16
        1587: dup
        1588: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1591: astore        55
        1593: new           #167                // class ocaml_fn_17
        1596: dup
        1597: aload         18
        1599: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1602: astore        56
        1604: new           #170                // class ocaml_fn_18
        1607: dup
        1608: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1611: astore        57
        1613: new           #173                // class ocaml_fn_19
        1616: dup
        1617: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1620: astore        58
        1622: new           #176                // class ocaml_fn_20
        1625: dup
        1626: aload         26
        1628: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1631: astore        59
        1633: new           #179                // class ocaml_fn_21
        1636: dup
        1637: aload         53
        1639: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1642: astore        60
        1644: new           #182                // class ocaml_fn_22
        1647: dup
        1648: aload         60
        1650: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1653: astore        61
        1655: new           #185                // class ocaml_fn_23
        1658: dup
        1659: aload         26
        1661: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1664: astore        62
        1666: new           #188                // class ocaml_fn_24
        1669: dup
        1670: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1673: astore        63
        1675: new           #191                // class ocaml_fn_25
        1678: dup
        1679: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1682: astore        64
        1684: aload         63
        1686: checkcast     #188                // class ocaml_fn_24
        1689: aload         63
        1691: checkcast     #194                // class Closure
        1694: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1697: iconst_0
        1698: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1701: astore        65
        1703: aload         63
        1705: checkcast     #188                // class ocaml_fn_24
        1708: aload         64
        1710: checkcast     #194                // class Closure
        1713: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1716: iconst_0
        1717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1720: astore        66
        1722: aload         64
        1724: checkcast     #191                // class ocaml_fn_25
        1727: aload         63
        1729: checkcast     #194                // class Closure
        1732: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1735: iconst_0
        1736: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1739: astore        67
        1741: aload         64
        1743: checkcast     #191                // class ocaml_fn_25
        1746: aload         64
        1748: checkcast     #194                // class Closure
        1751: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1754: iconst_0
        1755: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1758: astore        68
        1760: iconst_0
        1761: istore        69
        1763: iload         69
        1765: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1768: astore        70
        1770: iconst_1
        1771: istore        71
        1773: iload         71
        1775: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1778: astore        72
        1780: iconst_2
        1781: istore        73
        1783: iload         73
        1785: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1788: astore        74
        1790: new           #209                // class ocaml_fn_26
        1793: dup
        1794: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1797: astore        75
        1799: new           #212                // class ocaml_fn_27
        1802: dup
        1803: aload         75
        1805: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1808: astore        76
        1810: new           #215                // class ocaml_fn_28
        1813: dup
        1814: aload         75
        1816: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1819: astore        77
        1821: new           #218                // class ocaml_fn_29
        1824: dup
        1825: aload         30
        1827: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1830: astore        78
        1832: new           #221                // class ocaml_fn_30
        1835: dup
        1836: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1839: astore        79
        1841: new           #224                // class ocaml_fn_31
        1844: dup
        1845: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1848: astore        80
        1850: new           #227                // class ocaml_fn_32
        1853: dup
        1854: aload         18
        1856: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1859: astore        81
        1861: new           #230                // class ocaml_fn_33
        1864: dup
        1865: aload         18
        1867: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1870: astore        82
        1872: new           #233                // class ocaml_fn_34
        1875: dup
        1876: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1879: astore        83
        1881: new           #236                // class ocaml_fn_35
        1884: dup
        1885: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1888: astore        84
        1890: new           #239                // class ocaml_fn_36
        1893: dup
        1894: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1897: astore        85
        1899: new           #242                // class ocaml_fn_37
        1902: dup
        1903: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1906: astore        86
        1908: new           #245                // class ocaml_fn_38
        1911: dup
        1912: aload         86
        1914: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1917: astore        87
        1919: new           #248                // class ocaml_fn_39
        1922: dup
        1923: aload         86
        1925: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1928: astore        88
        1930: new           #251                // class ocaml_fn_40
        1933: dup
        1934: aload         18
        1936: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1939: astore        89
        1941: new           #254                // class ocaml_fn_41
        1944: dup
        1945: aload         31
        1947: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1950: astore        90
        1952: new           #257                // class ocaml_fn_42
        1955: dup
        1956: aload         18
        1958: aload         90
        1960: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1963: astore        91
        1965: new           #262                // class ocaml_fn_43
        1968: dup
        1969: aload         91
        1971: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1974: astore        92
        1976: new           #265                // class ocaml_fn_44
        1979: dup
        1980: aload         31
        1982: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1985: astore        93
        1987: new           #268                // class ocaml_fn_45
        1990: dup
        1991: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1994: astore        94
        1996: new           #271                // class ocaml_fn_46
        1999: dup
        2000: aload         72
        2002: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2005: astore        95
        2007: new           #274                // class ocaml_fn_47
        2010: dup
        2011: aload         72
        2013: aload         80
        2015: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2018: astore        96
        2020: new           #277                // class ocaml_fn_48
        2023: dup
        2024: aload         72
        2026: aload         79
        2028: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2031: astore        97
        2033: new           #280                // class ocaml_fn_49
        2036: dup
        2037: aload         58
        2039: aload         72
        2041: aload         80
        2043: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2046: astore        98
        2048: new           #285                // class ocaml_fn_50
        2051: dup
        2052: aload         61
        2054: aload         72
        2056: aload         80
        2058: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2061: astore        99
        2063: new           #288                // class ocaml_fn_51
        2066: dup
        2067: aload         72
        2069: aload         80
        2071: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2074: astore        100
        2076: new           #291                // class ocaml_fn_52
        2079: dup
        2080: aload         72
        2082: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2085: astore        101
        2087: new           #294                // class ocaml_fn_53
        2090: dup
        2091: aload         74
        2093: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2096: astore        102
        2098: new           #297                // class ocaml_fn_54
        2101: dup
        2102: aload         74
        2104: aload         80
        2106: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        103
        2111: new           #300                // class ocaml_fn_55
        2114: dup
        2115: aload         74
        2117: aload         79
        2119: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2122: astore        104
        2124: new           #303                // class ocaml_fn_56
        2127: dup
        2128: aload         58
        2130: aload         74
        2132: aload         80
        2134: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2137: astore        105
        2139: new           #306                // class ocaml_fn_57
        2142: dup
        2143: aload         61
        2145: aload         74
        2147: aload         80
        2149: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2152: astore        106
        2154: new           #309                // class ocaml_fn_58
        2157: dup
        2158: aload         74
        2160: aload         80
        2162: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2165: astore        107
        2167: new           #312                // class ocaml_fn_59
        2170: dup
        2171: aload         74
        2173: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2176: astore        108
        2178: new           #315                // class ocaml_fn_60
        2181: dup
        2182: aload         70
        2184: aload         72
        2186: aload         93
        2188: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2191: astore        109
        2193: new           #318                // class ocaml_fn_61
        2196: dup
        2197: aload         109
        2199: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2202: astore        110
        2204: new           #321                // class ocaml_fn_62
        2207: dup
        2208: aload         59
        2210: aload         109
        2212: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2215: astore        111
        2217: new           #324                // class ocaml_fn_63
        2220: dup
        2221: aload         109
        2223: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2226: astore        112
        2228: new           #327                // class ocaml_fn_64
        2231: dup
        2232: aload         62
        2234: aload         109
        2236: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2239: astore        113
        2241: new           #330                // class ocaml_fn_65
        2244: dup
        2245: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2248: astore        114
        2250: new           #333                // class ocaml_fn_66
        2253: dup
        2254: aload         53
        2256: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2259: astore        115
        2261: new           #2                  // class Block
        2264: dup
        2265: iconst_0
        2266: iconst_1
        2267: anewarray     #4                  // class java/lang/Object
        2270: dup
        2271: iconst_0
        2272: aload         78
        2274: aastore
        2275: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2278: astore        116
        2280: new           #336                // class ocaml_fn_67
        2283: dup
        2284: aload         116
        2286: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2289: astore        117
        2291: new           #339                // class ocaml_fn_68
        2294: dup
        2295: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2298: astore        118
        2300: new           #2                  // class Block
        2303: dup
        2304: iconst_0
        2305: iconst_1
        2306: anewarray     #4                  // class java/lang/Object
        2309: dup
        2310: iconst_0
        2311: aload         118
        2313: aastore
        2314: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2317: astore        119
        2319: new           #342                // class ocaml_fn_69
        2322: dup
        2323: aload         116
        2325: aload         119
        2327: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2330: astore        120
        2332: new           #345                // class ocaml_fn_70
        2335: dup
        2336: aload         120
        2338: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2341: astore        121
        2343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2346: bipush        44
        2348: aaload
        2349: astore        122
        2351: iconst_0
        2352: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2355: astore        123
        2357: new           #348                // class ocaml_fn_71
        2360: dup
        2361: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2364: astore        124
        2366: new           #351                // class ocaml_fn_72
        2369: dup
        2370: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2373: astore        125
        2375: new           #354                // class ocaml_fn_73
        2378: dup
        2379: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2382: astore        126
        2384: new           #357                // class ocaml_fn_74
        2387: dup
        2388: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2391: astore        127
        2393: new           #360                // class ocaml_fn_75
        2396: dup
        2397: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2400: astore        128
        2402: new           #363                // class ocaml_fn_76
        2405: dup
        2406: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2409: astore        129
        2411: new           #2                  // class Block
        2414: dup
        2415: iconst_0
        2416: bipush        6
        2418: anewarray     #4                  // class java/lang/Object
        2421: dup
        2422: iconst_0
        2423: aload         129
        2425: aastore
        2426: dup
        2427: iconst_1
        2428: aload         128
        2430: aastore
        2431: dup
        2432: iconst_2
        2433: aload         127
        2435: aastore
        2436: dup
        2437: iconst_3
        2438: aload         126
        2440: aastore
        2441: dup
        2442: iconst_4
        2443: aload         125
        2445: aastore
        2446: dup
        2447: iconst_5
        2448: aload         124
        2450: aastore
        2451: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2454: astore        130
        2456: new           #366                // class ocaml_fn_77
        2459: dup
        2460: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2463: astore        131
        2465: new           #369                // class ocaml_fn_78
        2468: dup
        2469: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2472: astore        132
        2474: new           #372                // class ocaml_fn_79
        2477: dup
        2478: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2481: astore        133
        2483: new           #375                // class ocaml_fn_80
        2486: dup
        2487: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2490: astore        134
        2492: new           #378                // class ocaml_fn_81
        2495: dup
        2496: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2499: astore        135
        2501: new           #381                // class ocaml_fn_82
        2504: dup
        2505: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2508: astore        136
        2510: new           #384                // class ocaml_fn_83
        2513: dup
        2514: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2517: astore        137
        2519: new           #387                // class ocaml_fn_84
        2522: dup
        2523: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2526: astore        138
        2528: new           #390                // class ocaml_fn_85
        2531: dup
        2532: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2535: astore        139
        2537: new           #393                // class ocaml_fn_86
        2540: dup
        2541: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2544: astore        140
        2546: new           #396                // class ocaml_fn_87
        2549: dup
        2550: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2553: astore        141
        2555: new           #399                // class ocaml_fn_88
        2558: dup
        2559: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2562: astore        142
        2564: new           #402                // class ocaml_fn_89
        2567: dup
        2568: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2571: astore        143
        2573: new           #405                // class ocaml_fn_90
        2576: dup
        2577: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2580: astore        144
        2582: new           #408                // class ocaml_fn_91
        2585: dup
        2586: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2589: astore        145
        2591: new           #411                // class ocaml_fn_92
        2594: dup
        2595: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2598: astore        146
        2600: new           #414                // class ocaml_fn_93
        2603: dup
        2604: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2607: astore        147
        2609: new           #2                  // class Block
        2612: dup
        2613: iconst_0
        2614: bipush        104
        2616: anewarray     #4                  // class java/lang/Object
        2619: dup
        2620: iconst_0
        2621: aload         18
        2623: aastore
        2624: dup
        2625: iconst_1
        2626: aload         17
        2628: aastore
        2629: dup
        2630: iconst_2
        2631: aload         22
        2633: aastore
        2634: dup
        2635: iconst_3
        2636: aload         23
        2638: aastore
        2639: dup
        2640: iconst_4
        2641: aload         24
        2643: aastore
        2644: dup
        2645: iconst_5
        2646: aload         25
        2648: aastore
        2649: dup
        2650: bipush        6
        2652: aload         26
        2654: aastore
        2655: dup
        2656: bipush        7
        2658: aload         27
        2660: aastore
        2661: dup
        2662: bipush        8
        2664: aload         28
        2666: aastore
        2667: dup
        2668: bipush        9
        2670: aload         29
        2672: aastore
        2673: dup
        2674: bipush        10
        2676: aload         30
        2678: aastore
        2679: dup
        2680: bipush        11
        2682: aload         31
        2684: aastore
        2685: dup
        2686: bipush        12
        2688: aload         32
        2690: aastore
        2691: dup
        2692: bipush        13
        2694: aload         33
        2696: aastore
        2697: dup
        2698: bipush        14
        2700: aload         34
        2702: aastore
        2703: dup
        2704: bipush        15
        2706: aload         35
        2708: aastore
        2709: dup
        2710: bipush        16
        2712: aload         36
        2714: aastore
        2715: dup
        2716: bipush        17
        2718: aload         37
        2720: aastore
        2721: dup
        2722: bipush        18
        2724: iload         39
        2726: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2729: aastore
        2730: dup
        2731: bipush        19
        2733: iload         40
        2735: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2738: aastore
        2739: dup
        2740: bipush        20
        2742: aload         38
        2744: aastore
        2745: dup
        2746: bipush        21
        2748: aload         42
        2750: aastore
        2751: dup
        2752: bipush        22
        2754: aload         44
        2756: aastore
        2757: dup
        2758: bipush        23
        2760: aload         46
        2762: aastore
        2763: dup
        2764: bipush        24
        2766: aload         48
        2768: aastore
        2769: dup
        2770: bipush        25
        2772: aload         50
        2774: aastore
        2775: dup
        2776: bipush        26
        2778: aload         52
        2780: aastore
        2781: dup
        2782: bipush        27
        2784: aload         53
        2786: aastore
        2787: dup
        2788: bipush        28
        2790: aload         54
        2792: aastore
        2793: dup
        2794: bipush        29
        2796: aload         55
        2798: aastore
        2799: dup
        2800: bipush        30
        2802: aload         57
        2804: aastore
        2805: dup
        2806: bipush        31
        2808: aload         56
        2810: aastore
        2811: dup
        2812: bipush        32
        2814: aload         58
        2816: aastore
        2817: dup
        2818: bipush        33
        2820: aload         59
        2822: aastore
        2823: dup
        2824: bipush        34
        2826: aload         61
        2828: aastore
        2829: dup
        2830: bipush        35
        2832: aload         62
        2834: aastore
        2835: dup
        2836: bipush        36
        2838: aload         63
        2840: aastore
        2841: dup
        2842: bipush        37
        2844: aload         70
        2846: aastore
        2847: dup
        2848: bipush        38
        2850: aload         72
        2852: aastore
        2853: dup
        2854: bipush        39
        2856: aload         74
        2858: aastore
        2859: dup
        2860: bipush        40
        2862: aload         95
        2864: aastore
        2865: dup
        2866: bipush        41
        2868: aload         96
        2870: aastore
        2871: dup
        2872: bipush        42
        2874: aload         97
        2876: aastore
        2877: dup
        2878: bipush        43
        2880: aload         98
        2882: aastore
        2883: dup
        2884: bipush        44
        2886: aload         99
        2888: aastore
        2889: dup
        2890: bipush        45
        2892: aload         100
        2894: aastore
        2895: dup
        2896: bipush        46
        2898: aload         101
        2900: aastore
        2901: dup
        2902: bipush        47
        2904: aload         102
        2906: aastore
        2907: dup
        2908: bipush        48
        2910: aload         103
        2912: aastore
        2913: dup
        2914: bipush        49
        2916: aload         104
        2918: aastore
        2919: dup
        2920: bipush        50
        2922: aload         105
        2924: aastore
        2925: dup
        2926: bipush        51
        2928: aload         106
        2930: aastore
        2931: dup
        2932: bipush        52
        2934: aload         107
        2936: aastore
        2937: dup
        2938: bipush        53
        2940: aload         108
        2942: aastore
        2943: dup
        2944: bipush        54
        2946: aload         109
        2948: aastore
        2949: dup
        2950: bipush        55
        2952: aload         111
        2954: aastore
        2955: dup
        2956: bipush        56
        2958: aload         110
        2960: aastore
        2961: dup
        2962: bipush        57
        2964: aload         113
        2966: aastore
        2967: dup
        2968: bipush        58
        2970: aload         112
        2972: aastore
        2973: dup
        2974: bipush        59
        2976: aload         76
        2978: aastore
        2979: dup
        2980: bipush        60
        2982: aload         77
        2984: aastore
        2985: dup
        2986: bipush        61
        2988: aload         75
        2990: aastore
        2991: dup
        2992: bipush        62
        2994: aload         147
        2996: aastore
        2997: dup
        2998: bipush        63
        3000: aload         78
        3002: aastore
        3003: dup
        3004: bipush        64
        3006: aload         146
        3008: aastore
        3009: dup
        3010: bipush        65
        3012: aload         80
        3014: aastore
        3015: dup
        3016: bipush        66
        3018: aload         79
        3020: aastore
        3021: dup
        3022: bipush        67
        3024: aload         81
        3026: aastore
        3027: dup
        3028: bipush        68
        3030: aload         82
        3032: aastore
        3033: dup
        3034: bipush        69
        3036: aload         145
        3038: aastore
        3039: dup
        3040: bipush        70
        3042: aload         144
        3044: aastore
        3045: dup
        3046: bipush        71
        3048: aload         83
        3050: aastore
        3051: dup
        3052: bipush        72
        3054: aload         143
        3056: aastore
        3057: dup
        3058: bipush        73
        3060: aload         142
        3062: aastore
        3063: dup
        3064: bipush        74
        3066: aload         141
        3068: aastore
        3069: dup
        3070: bipush        75
        3072: aload         84
        3074: aastore
        3075: dup
        3076: bipush        76
        3078: aload         85
        3080: aastore
        3081: dup
        3082: bipush        77
        3084: aload         140
        3086: aastore
        3087: dup
        3088: bipush        78
        3090: aload         87
        3092: aastore
        3093: dup
        3094: bipush        79
        3096: aload         88
        3098: aastore
        3099: dup
        3100: bipush        80
        3102: aload         86
        3104: aastore
        3105: dup
        3106: bipush        81
        3108: aload         139
        3110: aastore
        3111: dup
        3112: bipush        82
        3114: aload         93
        3116: aastore
        3117: dup
        3118: bipush        83
        3120: aload         89
        3122: aastore
        3123: dup
        3124: bipush        84
        3126: aload         91
        3128: aastore
        3129: dup
        3130: bipush        85
        3132: aload         92
        3134: aastore
        3135: dup
        3136: bipush        86
        3138: aload         138
        3140: aastore
        3141: dup
        3142: bipush        87
        3144: aload         137
        3146: aastore
        3147: dup
        3148: bipush        88
        3150: aload         136
        3152: aastore
        3153: dup
        3154: bipush        89
        3156: aload         135
        3158: aastore
        3159: dup
        3160: bipush        90
        3162: aload         134
        3164: aastore
        3165: dup
        3166: bipush        91
        3168: aload         133
        3170: aastore
        3171: dup
        3172: bipush        92
        3174: aload         132
        3176: aastore
        3177: dup
        3178: bipush        93
        3180: aload         94
        3182: aastore
        3183: dup
        3184: bipush        94
        3186: aload         131
        3188: aastore
        3189: dup
        3190: bipush        95
        3192: aload         130
        3194: aastore
        3195: dup
        3196: bipush        96
        3198: aload         114
        3200: aastore
        3201: dup
        3202: bipush        97
        3204: aload         115
        3206: aastore
        3207: dup
        3208: bipush        98
        3210: aload         121
        3212: aastore
        3213: dup
        3214: bipush        99
        3216: aload         117
        3218: aastore
        3219: dup
        3220: bipush        100
        3222: aload         60
        3224: aastore
        3225: dup
        3226: bipush        101
        3228: aload         90
        3230: aastore
        3231: dup
        3232: bipush        102
        3234: aload         120
        3236: aastore
        3237: dup
        3238: bipush        103
        3240: aload         119
        3242: aastore
        3243: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3246: astore        148
        3248: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3251: bipush        45
        3253: aload         148
        3255: aastore
        3256: iconst_0
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        149
        3262: bipush        8
        3264: istore        150
        3266: getstatic     #419                // Field java/lang/System.out:Ljava/io/PrintStream;
        3269: iload         150
        3271: invokevirtual #425                // Method java/io/PrintStream.println:(I)V
        3274: iconst_0
        3275: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3278: astore        151
        3280: new           #2                  // class Block
        3283: dup
        3284: iconst_0
        3285: iconst_0
        3286: anewarray     #4                  // class java/lang/Object
        3289: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3292: astore        152
        3294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3297: bipush        46
        3299: aload         152
        3301: aastore
        3302: iconst_0
        3303: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3306: astore        153
        3308: iconst_0
        3309: istore        154
        3311: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3314: bipush        45
        3316: aaload
        3317: checkcast     #2                  // class Block
        3320: getfield      #428                // Field Block.fields:[Ljava/lang/Object;
        3323: bipush        102
        3325: aaload
        3326: astore        155
        3328: aload         155
        3330: checkcast     #194                // class Closure
        3333: iload         154
        3335: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3338: invokevirtual #432                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3341: astore        156
        3343: new           #2                  // class Block
        3346: dup
        3347: iconst_0
        3348: iconst_0
        3349: anewarray     #4                  // class java/lang/Object
        3352: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3355: astore        157
        3357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3360: bipush        47
        3362: aload         157
        3364: aastore
        3365: iconst_0
        3366: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3369: astore        158
        3371: return
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
        1430: checkcast     #89                 // class java/lang/Long
        1433: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1436: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1439: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        42
        1444: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        39
        1449: aaload
        1450: astore        43
        1452: aload         43
        1454: checkcast     #89                 // class java/lang/Long
        1457: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1460: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1463: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: aload         45
        1478: checkcast     #89                 // class java/lang/Long
        1481: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1484: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1487: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1490: astore        46
        1492: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1495: bipush        41
        1497: aaload
        1498: astore        47
        1500: aload         47
        1502: checkcast     #89                 // class java/lang/Long
        1505: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1508: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1511: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        48
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        42
        1521: aaload
        1522: astore        49
        1524: aload         49
        1526: checkcast     #89                 // class java/lang/Long
        1529: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1532: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1535: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1538: astore        50
        1540: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1543: bipush        43
        1545: aaload
        1546: astore        51
        1548: aload         51
        1550: checkcast     #89                 // class java/lang/Long
        1553: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1556: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1559: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1562: astore        52
        1564: new           #156                // class ocaml_fn_14
        1567: dup
        1568: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1571: astore        53
        1573: new           #159                // class ocaml_fn_15
        1576: dup
        1577: aload         18
        1579: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1582: astore        54
        1584: new           #164                // class ocaml_fn_16
        1587: dup
        1588: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1591: astore        55
        1593: new           #167                // class ocaml_fn_17
        1596: dup
        1597: aload         18
        1599: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1602: astore        56
        1604: new           #170                // class ocaml_fn_18
        1607: dup
        1608: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1611: astore        57
        1613: new           #173                // class ocaml_fn_19
        1616: dup
        1617: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1620: astore        58
        1622: new           #176                // class ocaml_fn_20
        1625: dup
        1626: aload         26
        1628: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1631: astore        59
        1633: new           #179                // class ocaml_fn_21
        1636: dup
        1637: aload         53
        1639: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1642: astore        60
        1644: new           #182                // class ocaml_fn_22
        1647: dup
        1648: aload         60
        1650: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1653: astore        61
        1655: new           #185                // class ocaml_fn_23
        1658: dup
        1659: aload         26
        1661: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1664: astore        62
        1666: new           #188                // class ocaml_fn_24
        1669: dup
        1670: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1673: astore        63
        1675: new           #191                // class ocaml_fn_25
        1678: dup
        1679: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1682: astore        64
        1684: aload         63
        1686: checkcast     #188                // class ocaml_fn_24
        1689: aload         63
        1691: checkcast     #194                // class Closure
        1694: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1697: iconst_0
        1698: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1701: astore        65
        1703: aload         63
        1705: checkcast     #188                // class ocaml_fn_24
        1708: aload         64
        1710: checkcast     #194                // class Closure
        1713: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1716: iconst_0
        1717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1720: astore        66
        1722: aload         64
        1724: checkcast     #191                // class ocaml_fn_25
        1727: aload         63
        1729: checkcast     #194                // class Closure
        1732: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1735: iconst_0
        1736: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1739: astore        67
        1741: aload         64
        1743: checkcast     #191                // class ocaml_fn_25
        1746: aload         64
        1748: checkcast     #194                // class Closure
        1751: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1754: iconst_0
        1755: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1758: astore        68
        1760: iconst_0
        1761: istore        69
        1763: iload         69
        1765: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1768: astore        70
        1770: iconst_1
        1771: istore        71
        1773: iload         71
        1775: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1778: astore        72
        1780: iconst_2
        1781: istore        73
        1783: iload         73
        1785: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1788: astore        74
        1790: new           #209                // class ocaml_fn_26
        1793: dup
        1794: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1797: astore        75
        1799: new           #212                // class ocaml_fn_27
        1802: dup
        1803: aload         75
        1805: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1808: astore        76
        1810: new           #215                // class ocaml_fn_28
        1813: dup
        1814: aload         75
        1816: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1819: astore        77
        1821: new           #218                // class ocaml_fn_29
        1824: dup
        1825: aload         30
        1827: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1830: astore        78
        1832: new           #221                // class ocaml_fn_30
        1835: dup
        1836: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1839: astore        79
        1841: new           #224                // class ocaml_fn_31
        1844: dup
        1845: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1848: astore        80
        1850: new           #227                // class ocaml_fn_32
        1853: dup
        1854: aload         18
        1856: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1859: astore        81
        1861: new           #230                // class ocaml_fn_33
        1864: dup
        1865: aload         18
        1867: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1870: astore        82
        1872: new           #233                // class ocaml_fn_34
        1875: dup
        1876: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1879: astore        83
        1881: new           #236                // class ocaml_fn_35
        1884: dup
        1885: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1888: astore        84
        1890: new           #239                // class ocaml_fn_36
        1893: dup
        1894: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1897: astore        85
        1899: new           #242                // class ocaml_fn_37
        1902: dup
        1903: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1906: astore        86
        1908: new           #245                // class ocaml_fn_38
        1911: dup
        1912: aload         86
        1914: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1917: astore        87
        1919: new           #248                // class ocaml_fn_39
        1922: dup
        1923: aload         86
        1925: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1928: astore        88
        1930: new           #251                // class ocaml_fn_40
        1933: dup
        1934: aload         18
        1936: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1939: astore        89
        1941: new           #254                // class ocaml_fn_41
        1944: dup
        1945: aload         31
        1947: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1950: astore        90
        1952: new           #257                // class ocaml_fn_42
        1955: dup
        1956: aload         18
        1958: aload         90
        1960: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1963: astore        91
        1965: new           #262                // class ocaml_fn_43
        1968: dup
        1969: aload         91
        1971: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1974: astore        92
        1976: new           #265                // class ocaml_fn_44
        1979: dup
        1980: aload         31
        1982: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1985: astore        93
        1987: new           #268                // class ocaml_fn_45
        1990: dup
        1991: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1994: astore        94
        1996: new           #271                // class ocaml_fn_46
        1999: dup
        2000: aload         72
        2002: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2005: astore        95
        2007: new           #274                // class ocaml_fn_47
        2010: dup
        2011: aload         72
        2013: aload         80
        2015: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2018: astore        96
        2020: new           #277                // class ocaml_fn_48
        2023: dup
        2024: aload         72
        2026: aload         79
        2028: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2031: astore        97
        2033: new           #280                // class ocaml_fn_49
        2036: dup
        2037: aload         58
        2039: aload         72
        2041: aload         80
        2043: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2046: astore        98
        2048: new           #285                // class ocaml_fn_50
        2051: dup
        2052: aload         61
        2054: aload         72
        2056: aload         80
        2058: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2061: astore        99
        2063: new           #288                // class ocaml_fn_51
        2066: dup
        2067: aload         72
        2069: aload         80
        2071: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2074: astore        100
        2076: new           #291                // class ocaml_fn_52
        2079: dup
        2080: aload         72
        2082: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2085: astore        101
        2087: new           #294                // class ocaml_fn_53
        2090: dup
        2091: aload         74
        2093: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2096: astore        102
        2098: new           #297                // class ocaml_fn_54
        2101: dup
        2102: aload         74
        2104: aload         80
        2106: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        103
        2111: new           #300                // class ocaml_fn_55
        2114: dup
        2115: aload         74
        2117: aload         79
        2119: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2122: astore        104
        2124: new           #303                // class ocaml_fn_56
        2127: dup
        2128: aload         58
        2130: aload         74
        2132: aload         80
        2134: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2137: astore        105
        2139: new           #306                // class ocaml_fn_57
        2142: dup
        2143: aload         61
        2145: aload         74
        2147: aload         80
        2149: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2152: astore        106
        2154: new           #309                // class ocaml_fn_58
        2157: dup
        2158: aload         74
        2160: aload         80
        2162: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2165: astore        107
        2167: new           #312                // class ocaml_fn_59
        2170: dup
        2171: aload         74
        2173: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2176: astore        108
        2178: new           #315                // class ocaml_fn_60
        2181: dup
        2182: aload         70
        2184: aload         72
        2186: aload         93
        2188: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2191: astore        109
        2193: new           #318                // class ocaml_fn_61
        2196: dup
        2197: aload         109
        2199: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2202: astore        110
        2204: new           #321                // class ocaml_fn_62
        2207: dup
        2208: aload         59
        2210: aload         109
        2212: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2215: astore        111
        2217: new           #324                // class ocaml_fn_63
        2220: dup
        2221: aload         109
        2223: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2226: astore        112
        2228: new           #327                // class ocaml_fn_64
        2231: dup
        2232: aload         62
        2234: aload         109
        2236: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2239: astore        113
        2241: new           #330                // class ocaml_fn_65
        2244: dup
        2245: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2248: astore        114
        2250: new           #333                // class ocaml_fn_66
        2253: dup
        2254: aload         53
        2256: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2259: astore        115
        2261: new           #2                  // class Block
        2264: dup
        2265: iconst_0
        2266: iconst_1
        2267: anewarray     #4                  // class java/lang/Object
        2270: dup
        2271: iconst_0
        2272: aload         78
        2274: aastore
        2275: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2278: astore        116
        2280: new           #336                // class ocaml_fn_67
        2283: dup
        2284: aload         116
        2286: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2289: astore        117
        2291: new           #339                // class ocaml_fn_68
        2294: dup
        2295: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2298: astore        118
        2300: new           #2                  // class Block
        2303: dup
        2304: iconst_0
        2305: iconst_1
        2306: anewarray     #4                  // class java/lang/Object
        2309: dup
        2310: iconst_0
        2311: aload         118
        2313: aastore
        2314: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2317: astore        119
        2319: new           #342                // class ocaml_fn_69
        2322: dup
        2323: aload         116
        2325: aload         119
        2327: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2330: astore        120
        2332: new           #345                // class ocaml_fn_70
        2335: dup
        2336: aload         120
        2338: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2341: astore        121
        2343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2346: bipush        44
        2348: aaload
        2349: astore        122
        2351: iconst_0
        2352: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2355: astore        123
        2357: new           #348                // class ocaml_fn_71
        2360: dup
        2361: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2364: astore        124
        2366: new           #351                // class ocaml_fn_72
        2369: dup
        2370: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2373: astore        125
        2375: new           #354                // class ocaml_fn_73
        2378: dup
        2379: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2382: astore        126
        2384: new           #357                // class ocaml_fn_74
        2387: dup
        2388: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2391: astore        127
        2393: new           #360                // class ocaml_fn_75
        2396: dup
        2397: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2400: astore        128
        2402: new           #363                // class ocaml_fn_76
        2405: dup
        2406: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2409: astore        129
        2411: new           #2                  // class Block
        2414: dup
        2415: iconst_0
        2416: bipush        6
        2418: anewarray     #4                  // class java/lang/Object
        2421: dup
        2422: iconst_0
        2423: aload         129
        2425: aastore
        2426: dup
        2427: iconst_1
        2428: aload         128
        2430: aastore
        2431: dup
        2432: iconst_2
        2433: aload         127
        2435: aastore
        2436: dup
        2437: iconst_3
        2438: aload         126
        2440: aastore
        2441: dup
        2442: iconst_4
        2443: aload         125
        2445: aastore
        2446: dup
        2447: iconst_5
        2448: aload         124
        2450: aastore
        2451: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2454: astore        130
        2456: new           #366                // class ocaml_fn_77
        2459: dup
        2460: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2463: astore        131
        2465: new           #369                // class ocaml_fn_78
        2468: dup
        2469: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2472: astore        132
        2474: new           #372                // class ocaml_fn_79
        2477: dup
        2478: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2481: astore        133
        2483: new           #375                // class ocaml_fn_80
        2486: dup
        2487: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2490: astore        134
        2492: new           #378                // class ocaml_fn_81
        2495: dup
        2496: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2499: astore        135
        2501: new           #381                // class ocaml_fn_82
        2504: dup
        2505: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2508: astore        136
        2510: new           #384                // class ocaml_fn_83
        2513: dup
        2514: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2517: astore        137
        2519: new           #387                // class ocaml_fn_84
        2522: dup
        2523: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2526: astore        138
        2528: new           #390                // class ocaml_fn_85
        2531: dup
        2532: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2535: astore        139
        2537: new           #393                // class ocaml_fn_86
        2540: dup
        2541: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2544: astore        140
        2546: new           #396                // class ocaml_fn_87
        2549: dup
        2550: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2553: astore        141
        2555: new           #399                // class ocaml_fn_88
        2558: dup
        2559: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2562: astore        142
        2564: new           #402                // class ocaml_fn_89
        2567: dup
        2568: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2571: astore        143
        2573: new           #405                // class ocaml_fn_90
        2576: dup
        2577: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2580: astore        144
        2582: new           #408                // class ocaml_fn_91
        2585: dup
        2586: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2589: astore        145
        2591: new           #411                // class ocaml_fn_92
        2594: dup
        2595: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2598: astore        146
        2600: new           #414                // class ocaml_fn_93
        2603: dup
        2604: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2607: astore        147
        2609: new           #2                  // class Block
        2612: dup
        2613: iconst_0
        2614: bipush        104
        2616: anewarray     #4                  // class java/lang/Object
        2619: dup
        2620: iconst_0
        2621: aload         18
        2623: aastore
        2624: dup
        2625: iconst_1
        2626: aload         17
        2628: aastore
        2629: dup
        2630: iconst_2
        2631: aload         22
        2633: aastore
        2634: dup
        2635: iconst_3
        2636: aload         23
        2638: aastore
        2639: dup
        2640: iconst_4
        2641: aload         24
        2643: aastore
        2644: dup
        2645: iconst_5
        2646: aload         25
        2648: aastore
        2649: dup
        2650: bipush        6
        2652: aload         26
        2654: aastore
        2655: dup
        2656: bipush        7
        2658: aload         27
        2660: aastore
        2661: dup
        2662: bipush        8
        2664: aload         28
        2666: aastore
        2667: dup
        2668: bipush        9
        2670: aload         29
        2672: aastore
        2673: dup
        2674: bipush        10
        2676: aload         30
        2678: aastore
        2679: dup
        2680: bipush        11
        2682: aload         31
        2684: aastore
        2685: dup
        2686: bipush        12
        2688: aload         32
        2690: aastore
        2691: dup
        2692: bipush        13
        2694: aload         33
        2696: aastore
        2697: dup
        2698: bipush        14
        2700: aload         34
        2702: aastore
        2703: dup
        2704: bipush        15
        2706: aload         35
        2708: aastore
        2709: dup
        2710: bipush        16
        2712: aload         36
        2714: aastore
        2715: dup
        2716: bipush        17
        2718: aload         37
        2720: aastore
        2721: dup
        2722: bipush        18
        2724: iload         39
        2726: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2729: aastore
        2730: dup
        2731: bipush        19
        2733: iload         40
        2735: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2738: aastore
        2739: dup
        2740: bipush        20
        2742: aload         38
        2744: aastore
        2745: dup
        2746: bipush        21
        2748: aload         42
        2750: aastore
        2751: dup
        2752: bipush        22
        2754: aload         44
        2756: aastore
        2757: dup
        2758: bipush        23
        2760: aload         46
        2762: aastore
        2763: dup
        2764: bipush        24
        2766: aload         48
        2768: aastore
        2769: dup
        2770: bipush        25
        2772: aload         50
        2774: aastore
        2775: dup
        2776: bipush        26
        2778: aload         52
        2780: aastore
        2781: dup
        2782: bipush        27
        2784: aload         53
        2786: aastore
        2787: dup
        2788: bipush        28
        2790: aload         54
        2792: aastore
        2793: dup
        2794: bipush        29
        2796: aload         55
        2798: aastore
        2799: dup
        2800: bipush        30
        2802: aload         57
        2804: aastore
        2805: dup
        2806: bipush        31
        2808: aload         56
        2810: aastore
        2811: dup
        2812: bipush        32
        2814: aload         58
        2816: aastore
        2817: dup
        2818: bipush        33
        2820: aload         59
        2822: aastore
        2823: dup
        2824: bipush        34
        2826: aload         61
        2828: aastore
        2829: dup
        2830: bipush        35
        2832: aload         62
        2834: aastore
        2835: dup
        2836: bipush        36
        2838: aload         63
        2840: aastore
        2841: dup
        2842: bipush        37
        2844: aload         70
        2846: aastore
        2847: dup
        2848: bipush        38
        2850: aload         72
        2852: aastore
        2853: dup
        2854: bipush        39
        2856: aload         74
        2858: aastore
        2859: dup
        2860: bipush        40
        2862: aload         95
        2864: aastore
        2865: dup
        2866: bipush        41
        2868: aload         96
        2870: aastore
        2871: dup
        2872: bipush        42
        2874: aload         97
        2876: aastore
        2877: dup
        2878: bipush        43
        2880: aload         98
        2882: aastore
        2883: dup
        2884: bipush        44
        2886: aload         99
        2888: aastore
        2889: dup
        2890: bipush        45
        2892: aload         100
        2894: aastore
        2895: dup
        2896: bipush        46
        2898: aload         101
        2900: aastore
        2901: dup
        2902: bipush        47
        2904: aload         102
        2906: aastore
        2907: dup
        2908: bipush        48
        2910: aload         103
        2912: aastore
        2913: dup
        2914: bipush        49
        2916: aload         104
        2918: aastore
        2919: dup
        2920: bipush        50
        2922: aload         105
        2924: aastore
        2925: dup
        2926: bipush        51
        2928: aload         106
        2930: aastore
        2931: dup
        2932: bipush        52
        2934: aload         107
        2936: aastore
        2937: dup
        2938: bipush        53
        2940: aload         108
        2942: aastore
        2943: dup
        2944: bipush        54
        2946: aload         109
        2948: aastore
        2949: dup
        2950: bipush        55
        2952: aload         111
        2954: aastore
        2955: dup
        2956: bipush        56
        2958: aload         110
        2960: aastore
        2961: dup
        2962: bipush        57
        2964: aload         113
        2966: aastore
        2967: dup
        2968: bipush        58
        2970: aload         112
        2972: aastore
        2973: dup
        2974: bipush        59
        2976: aload         76
        2978: aastore
        2979: dup
        2980: bipush        60
        2982: aload         77
        2984: aastore
        2985: dup
        2986: bipush        61
        2988: aload         75
        2990: aastore
        2991: dup
        2992: bipush        62
        2994: aload         147
        2996: aastore
        2997: dup
        2998: bipush        63
        3000: aload         78
        3002: aastore
        3003: dup
        3004: bipush        64
        3006: aload         146
        3008: aastore
        3009: dup
        3010: bipush        65
        3012: aload         80
        3014: aastore
        3015: dup
        3016: bipush        66
        3018: aload         79
        3020: aastore
        3021: dup
        3022: bipush        67
        3024: aload         81
        3026: aastore
        3027: dup
        3028: bipush        68
        3030: aload         82
        3032: aastore
        3033: dup
        3034: bipush        69
        3036: aload         145
        3038: aastore
        3039: dup
        3040: bipush        70
        3042: aload         144
        3044: aastore
        3045: dup
        3046: bipush        71
        3048: aload         83
        3050: aastore
        3051: dup
        3052: bipush        72
        3054: aload         143
        3056: aastore
        3057: dup
        3058: bipush        73
        3060: aload         142
        3062: aastore
        3063: dup
        3064: bipush        74
        3066: aload         141
        3068: aastore
        3069: dup
        3070: bipush        75
        3072: aload         84
        3074: aastore
        3075: dup
        3076: bipush        76
        3078: aload         85
        3080: aastore
        3081: dup
        3082: bipush        77
        3084: aload         140
        3086: aastore
        3087: dup
        3088: bipush        78
        3090: aload         87
        3092: aastore
        3093: dup
        3094: bipush        79
        3096: aload         88
        3098: aastore
        3099: dup
        3100: bipush        80
        3102: aload         86
        3104: aastore
        3105: dup
        3106: bipush        81
        3108: aload         139
        3110: aastore
        3111: dup
        3112: bipush        82
        3114: aload         93
        3116: aastore
        3117: dup
        3118: bipush        83
        3120: aload         89
        3122: aastore
        3123: dup
        3124: bipush        84
        3126: aload         91
        3128: aastore
        3129: dup
        3130: bipush        85
        3132: aload         92
        3134: aastore
        3135: dup
        3136: bipush        86
        3138: aload         138
        3140: aastore
        3141: dup
        3142: bipush        87
        3144: aload         137
        3146: aastore
        3147: dup
        3148: bipush        88
        3150: aload         136
        3152: aastore
        3153: dup
        3154: bipush        89
        3156: aload         135
        3158: aastore
        3159: dup
        3160: bipush        90
        3162: aload         134
        3164: aastore
        3165: dup
        3166: bipush        91
        3168: aload         133
        3170: aastore
        3171: dup
        3172: bipush        92
        3174: aload         132
        3176: aastore
        3177: dup
        3178: bipush        93
        3180: aload         94
        3182: aastore
        3183: dup
        3184: bipush        94
        3186: aload         131
        3188: aastore
        3189: dup
        3190: bipush        95
        3192: aload         130
        3194: aastore
        3195: dup
        3196: bipush        96
        3198: aload         114
        3200: aastore
        3201: dup
        3202: bipush        97
        3204: aload         115
        3206: aastore
        3207: dup
        3208: bipush        98
        3210: aload         121
        3212: aastore
        3213: dup
        3214: bipush        99
        3216: aload         117
        3218: aastore
        3219: dup
        3220: bipush        100
        3222: aload         60
        3224: aastore
        3225: dup
        3226: bipush        101
        3228: aload         90
        3230: aastore
        3231: dup
        3232: bipush        102
        3234: aload         120
        3236: aastore
        3237: dup
        3238: bipush        103
        3240: aload         119
        3242: aastore
        3243: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3246: astore        148
        3248: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3251: bipush        45
        3253: aload         148
        3255: aastore
        3256: iconst_0
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        149
        3262: iconst_0
        3263: istore        150
        3265: iload         150
        3267: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3270: astore        151
        3272: goto_w        3277
        3277: new           #417                // class ocaml_fn_95
        3280: dup
        3281: invokespecial #418                // Method ocaml_fn_95."<init>":()V
        3284: astore        152
        3286: bipush        10
        3288: istore        153
        3290: aload         152
        3292: iload         153
        3294: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3297: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3300: astore        154
        3302: bipush        32
        3304: istore        155
        3306: aload         154
        3308: checkcast     #194                // class Closure
        3311: iload         155
        3313: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3316: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3319: astore        156
        3321: getstatic     #426                // Field java/lang/System.out:Ljava/io/PrintStream;
        3324: aload         156
        3326: checkcast     #29                 // class java/lang/Integer
        3329: invokevirtual #430                // Method java/lang/Integer.intValue:()I
        3332: invokevirtual #436                // Method java/io/PrintStream.println:(I)V
        3335: iconst_0
        3336: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3339: astore        157
        3341: new           #2                  // class Block
        3344: dup
        3345: iconst_0
        3346: iconst_1
        3347: anewarray     #4                  // class java/lang/Object
        3350: dup
        3351: iconst_0
        3352: aload         152
        3354: aastore
        3355: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3358: astore        158
        3360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3363: bipush        46
        3365: aload         158
        3367: aastore
        3368: iconst_0
        3369: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3372: astore        159
        3374: iconst_0
        3375: istore        160
        3377: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3380: bipush        45
        3382: aaload
        3383: checkcast     #2                  // class Block
        3386: getfield      #439                // Field Block.fields:[Ljava/lang/Object;
        3389: bipush        102
        3391: aaload
        3392: astore        161
        3394: aload         161
        3396: checkcast     #194                // class Closure
        3399: iload         160
        3401: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3404: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3407: astore        162
        3409: new           #2                  // class Block
        3412: dup
        3413: iconst_0
        3414: iconst_0
        3415: anewarray     #4                  // class java/lang/Object
        3418: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3421: astore        163
        3423: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3426: bipush        47
        3428: aload         163
        3430: aastore
        3431: iconst_0
        3432: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3435: astore        164
        3437: return
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
        1456: checkcast     #89                 // class java/lang/Long
        1459: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1462: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1465: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1468: astore        42
        1470: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1473: bipush        39
        1475: aaload
        1476: astore        43
        1478: aload         43
        1480: checkcast     #89                 // class java/lang/Long
        1483: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1486: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1489: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1492: astore        44
        1494: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1497: bipush        40
        1499: aaload
        1500: astore        45
        1502: aload         45
        1504: checkcast     #89                 // class java/lang/Long
        1507: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1510: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1513: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1516: astore        46
        1518: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1521: bipush        41
        1523: aaload
        1524: astore        47
        1526: aload         47
        1528: checkcast     #89                 // class java/lang/Long
        1531: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1534: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1537: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1540: astore        48
        1542: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1545: bipush        42
        1547: aaload
        1548: astore        49
        1550: aload         49
        1552: checkcast     #89                 // class java/lang/Long
        1555: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1558: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1561: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1564: astore        50
        1566: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1569: bipush        43
        1571: aaload
        1572: astore        51
        1574: aload         51
        1576: checkcast     #89                 // class java/lang/Long
        1579: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1582: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1585: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1588: astore        52
        1590: new           #156                // class ocaml_fn_14
        1593: dup
        1594: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1597: astore        53
        1599: new           #159                // class ocaml_fn_15
        1602: dup
        1603: aload         18
        1605: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1608: astore        54
        1610: new           #164                // class ocaml_fn_16
        1613: dup
        1614: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1617: astore        55
        1619: new           #167                // class ocaml_fn_17
        1622: dup
        1623: aload         18
        1625: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1628: astore        56
        1630: new           #170                // class ocaml_fn_18
        1633: dup
        1634: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1637: astore        57
        1639: new           #173                // class ocaml_fn_19
        1642: dup
        1643: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1646: astore        58
        1648: new           #176                // class ocaml_fn_20
        1651: dup
        1652: aload         26
        1654: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1657: astore        59
        1659: new           #179                // class ocaml_fn_21
        1662: dup
        1663: aload         53
        1665: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1668: astore        60
        1670: new           #182                // class ocaml_fn_22
        1673: dup
        1674: aload         60
        1676: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1679: astore        61
        1681: new           #185                // class ocaml_fn_23
        1684: dup
        1685: aload         26
        1687: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1690: astore        62
        1692: new           #188                // class ocaml_fn_24
        1695: dup
        1696: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1699: astore        63
        1701: new           #191                // class ocaml_fn_25
        1704: dup
        1705: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1708: astore        64
        1710: aload         63
        1712: checkcast     #188                // class ocaml_fn_24
        1715: aload         63
        1717: checkcast     #194                // class Closure
        1720: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1723: iconst_0
        1724: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1727: astore        65
        1729: aload         63
        1731: checkcast     #188                // class ocaml_fn_24
        1734: aload         64
        1736: checkcast     #194                // class Closure
        1739: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1742: iconst_0
        1743: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1746: astore        66
        1748: aload         64
        1750: checkcast     #191                // class ocaml_fn_25
        1753: aload         63
        1755: checkcast     #194                // class Closure
        1758: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1761: iconst_0
        1762: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1765: astore        67
        1767: aload         64
        1769: checkcast     #191                // class ocaml_fn_25
        1772: aload         64
        1774: checkcast     #194                // class Closure
        1777: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1780: iconst_0
        1781: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1784: astore        68
        1786: iconst_0
        1787: istore        69
        1789: iload         69
        1791: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1794: astore        70
        1796: iconst_1
        1797: istore        71
        1799: iload         71
        1801: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1804: astore        72
        1806: iconst_2
        1807: istore        73
        1809: iload         73
        1811: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1814: astore        74
        1816: new           #209                // class ocaml_fn_26
        1819: dup
        1820: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1823: astore        75
        1825: new           #212                // class ocaml_fn_27
        1828: dup
        1829: aload         75
        1831: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1834: astore        76
        1836: new           #215                // class ocaml_fn_28
        1839: dup
        1840: aload         75
        1842: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1845: astore        77
        1847: new           #218                // class ocaml_fn_29
        1850: dup
        1851: aload         30
        1853: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1856: astore        78
        1858: new           #221                // class ocaml_fn_30
        1861: dup
        1862: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1865: astore        79
        1867: new           #224                // class ocaml_fn_31
        1870: dup
        1871: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1874: astore        80
        1876: new           #227                // class ocaml_fn_32
        1879: dup
        1880: aload         18
        1882: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1885: astore        81
        1887: new           #230                // class ocaml_fn_33
        1890: dup
        1891: aload         18
        1893: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1896: astore        82
        1898: new           #233                // class ocaml_fn_34
        1901: dup
        1902: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1905: astore        83
        1907: new           #236                // class ocaml_fn_35
        1910: dup
        1911: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1914: astore        84
        1916: new           #239                // class ocaml_fn_36
        1919: dup
        1920: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1923: astore        85
        1925: new           #242                // class ocaml_fn_37
        1928: dup
        1929: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1932: astore        86
        1934: new           #245                // class ocaml_fn_38
        1937: dup
        1938: aload         86
        1940: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1943: astore        87
        1945: new           #248                // class ocaml_fn_39
        1948: dup
        1949: aload         86
        1951: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1954: astore        88
        1956: new           #251                // class ocaml_fn_40
        1959: dup
        1960: aload         18
        1962: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1965: astore        89
        1967: new           #254                // class ocaml_fn_41
        1970: dup
        1971: aload         31
        1973: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1976: astore        90
        1978: new           #257                // class ocaml_fn_42
        1981: dup
        1982: aload         18
        1984: aload         90
        1986: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1989: astore        91
        1991: new           #262                // class ocaml_fn_43
        1994: dup
        1995: aload         91
        1997: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        2000: astore        92
        2002: new           #265                // class ocaml_fn_44
        2005: dup
        2006: aload         31
        2008: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        2011: astore        93
        2013: new           #268                // class ocaml_fn_45
        2016: dup
        2017: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        2020: astore        94
        2022: new           #271                // class ocaml_fn_46
        2025: dup
        2026: aload         72
        2028: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2031: astore        95
        2033: new           #274                // class ocaml_fn_47
        2036: dup
        2037: aload         72
        2039: aload         80
        2041: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2044: astore        96
        2046: new           #277                // class ocaml_fn_48
        2049: dup
        2050: aload         72
        2052: aload         79
        2054: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2057: astore        97
        2059: new           #280                // class ocaml_fn_49
        2062: dup
        2063: aload         58
        2065: aload         72
        2067: aload         80
        2069: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2072: astore        98
        2074: new           #285                // class ocaml_fn_50
        2077: dup
        2078: aload         61
        2080: aload         72
        2082: aload         80
        2084: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2087: astore        99
        2089: new           #288                // class ocaml_fn_51
        2092: dup
        2093: aload         72
        2095: aload         80
        2097: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2100: astore        100
        2102: new           #291                // class ocaml_fn_52
        2105: dup
        2106: aload         72
        2108: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2111: astore        101
        2113: new           #294                // class ocaml_fn_53
        2116: dup
        2117: aload         74
        2119: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2122: astore        102
        2124: new           #297                // class ocaml_fn_54
        2127: dup
        2128: aload         74
        2130: aload         80
        2132: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        103
        2137: new           #300                // class ocaml_fn_55
        2140: dup
        2141: aload         74
        2143: aload         79
        2145: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2148: astore        104
        2150: new           #303                // class ocaml_fn_56
        2153: dup
        2154: aload         58
        2156: aload         74
        2158: aload         80
        2160: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2163: astore        105
        2165: new           #306                // class ocaml_fn_57
        2168: dup
        2169: aload         61
        2171: aload         74
        2173: aload         80
        2175: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2178: astore        106
        2180: new           #309                // class ocaml_fn_58
        2183: dup
        2184: aload         74
        2186: aload         80
        2188: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2191: astore        107
        2193: new           #312                // class ocaml_fn_59
        2196: dup
        2197: aload         74
        2199: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2202: astore        108
        2204: new           #315                // class ocaml_fn_60
        2207: dup
        2208: aload         70
        2210: aload         72
        2212: aload         93
        2214: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2217: astore        109
        2219: new           #318                // class ocaml_fn_61
        2222: dup
        2223: aload         109
        2225: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2228: astore        110
        2230: new           #321                // class ocaml_fn_62
        2233: dup
        2234: aload         59
        2236: aload         109
        2238: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2241: astore        111
        2243: new           #324                // class ocaml_fn_63
        2246: dup
        2247: aload         109
        2249: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2252: astore        112
        2254: new           #327                // class ocaml_fn_64
        2257: dup
        2258: aload         62
        2260: aload         109
        2262: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2265: astore        113
        2267: new           #330                // class ocaml_fn_65
        2270: dup
        2271: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2274: astore        114
        2276: new           #333                // class ocaml_fn_66
        2279: dup
        2280: aload         53
        2282: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2285: astore        115
        2287: new           #2                  // class Block
        2290: dup
        2291: iconst_0
        2292: iconst_1
        2293: anewarray     #4                  // class java/lang/Object
        2296: dup
        2297: iconst_0
        2298: aload         78
        2300: aastore
        2301: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2304: astore        116
        2306: new           #336                // class ocaml_fn_67
        2309: dup
        2310: aload         116
        2312: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2315: astore        117
        2317: new           #339                // class ocaml_fn_68
        2320: dup
        2321: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2324: astore        118
        2326: new           #2                  // class Block
        2329: dup
        2330: iconst_0
        2331: iconst_1
        2332: anewarray     #4                  // class java/lang/Object
        2335: dup
        2336: iconst_0
        2337: aload         118
        2339: aastore
        2340: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2343: astore        119
        2345: new           #342                // class ocaml_fn_69
        2348: dup
        2349: aload         116
        2351: aload         119
        2353: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2356: astore        120
        2358: new           #345                // class ocaml_fn_70
        2361: dup
        2362: aload         120
        2364: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2367: astore        121
        2369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2372: bipush        44
        2374: aaload
        2375: astore        122
        2377: iconst_0
        2378: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2381: astore        123
        2383: new           #348                // class ocaml_fn_71
        2386: dup
        2387: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2390: astore        124
        2392: new           #351                // class ocaml_fn_72
        2395: dup
        2396: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2399: astore        125
        2401: new           #354                // class ocaml_fn_73
        2404: dup
        2405: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2408: astore        126
        2410: new           #357                // class ocaml_fn_74
        2413: dup
        2414: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2417: astore        127
        2419: new           #360                // class ocaml_fn_75
        2422: dup
        2423: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2426: astore        128
        2428: new           #363                // class ocaml_fn_76
        2431: dup
        2432: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2435: astore        129
        2437: new           #2                  // class Block
        2440: dup
        2441: iconst_0
        2442: bipush        6
        2444: anewarray     #4                  // class java/lang/Object
        2447: dup
        2448: iconst_0
        2449: aload         129
        2451: aastore
        2452: dup
        2453: iconst_1
        2454: aload         128
        2456: aastore
        2457: dup
        2458: iconst_2
        2459: aload         127
        2461: aastore
        2462: dup
        2463: iconst_3
        2464: aload         126
        2466: aastore
        2467: dup
        2468: iconst_4
        2469: aload         125
        2471: aastore
        2472: dup
        2473: iconst_5
        2474: aload         124
        2476: aastore
        2477: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2480: astore        130
        2482: new           #366                // class ocaml_fn_77
        2485: dup
        2486: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2489: astore        131
        2491: new           #369                // class ocaml_fn_78
        2494: dup
        2495: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2498: astore        132
        2500: new           #372                // class ocaml_fn_79
        2503: dup
        2504: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2507: astore        133
        2509: new           #375                // class ocaml_fn_80
        2512: dup
        2513: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2516: astore        134
        2518: new           #378                // class ocaml_fn_81
        2521: dup
        2522: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2525: astore        135
        2527: new           #381                // class ocaml_fn_82
        2530: dup
        2531: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2534: astore        136
        2536: new           #384                // class ocaml_fn_83
        2539: dup
        2540: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2543: astore        137
        2545: new           #387                // class ocaml_fn_84
        2548: dup
        2549: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2552: astore        138
        2554: new           #390                // class ocaml_fn_85
        2557: dup
        2558: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2561: astore        139
        2563: new           #393                // class ocaml_fn_86
        2566: dup
        2567: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2570: astore        140
        2572: new           #396                // class ocaml_fn_87
        2575: dup
        2576: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2579: astore        141
        2581: new           #399                // class ocaml_fn_88
        2584: dup
        2585: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2588: astore        142
        2590: new           #402                // class ocaml_fn_89
        2593: dup
        2594: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2597: astore        143
        2599: new           #405                // class ocaml_fn_90
        2602: dup
        2603: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2606: astore        144
        2608: new           #408                // class ocaml_fn_91
        2611: dup
        2612: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2615: astore        145
        2617: new           #411                // class ocaml_fn_92
        2620: dup
        2621: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2624: astore        146
        2626: new           #414                // class ocaml_fn_93
        2629: dup
        2630: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2633: astore        147
        2635: new           #2                  // class Block
        2638: dup
        2639: iconst_0
        2640: bipush        104
        2642: anewarray     #4                  // class java/lang/Object
        2645: dup
        2646: iconst_0
        2647: aload         18
        2649: aastore
        2650: dup
        2651: iconst_1
        2652: aload         17
        2654: aastore
        2655: dup
        2656: iconst_2
        2657: aload         22
        2659: aastore
        2660: dup
        2661: iconst_3
        2662: aload         23
        2664: aastore
        2665: dup
        2666: iconst_4
        2667: aload         24
        2669: aastore
        2670: dup
        2671: iconst_5
        2672: aload         25
        2674: aastore
        2675: dup
        2676: bipush        6
        2678: aload         26
        2680: aastore
        2681: dup
        2682: bipush        7
        2684: aload         27
        2686: aastore
        2687: dup
        2688: bipush        8
        2690: aload         28
        2692: aastore
        2693: dup
        2694: bipush        9
        2696: aload         29
        2698: aastore
        2699: dup
        2700: bipush        10
        2702: aload         30
        2704: aastore
        2705: dup
        2706: bipush        11
        2708: aload         31
        2710: aastore
        2711: dup
        2712: bipush        12
        2714: aload         32
        2716: aastore
        2717: dup
        2718: bipush        13
        2720: aload         33
        2722: aastore
        2723: dup
        2724: bipush        14
        2726: aload         34
        2728: aastore
        2729: dup
        2730: bipush        15
        2732: aload         35
        2734: aastore
        2735: dup
        2736: bipush        16
        2738: aload         36
        2740: aastore
        2741: dup
        2742: bipush        17
        2744: aload         37
        2746: aastore
        2747: dup
        2748: bipush        18
        2750: iload         39
        2752: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2755: aastore
        2756: dup
        2757: bipush        19
        2759: iload         40
        2761: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2764: aastore
        2765: dup
        2766: bipush        20
        2768: aload         38
        2770: aastore
        2771: dup
        2772: bipush        21
        2774: aload         42
        2776: aastore
        2777: dup
        2778: bipush        22
        2780: aload         44
        2782: aastore
        2783: dup
        2784: bipush        23
        2786: aload         46
        2788: aastore
        2789: dup
        2790: bipush        24
        2792: aload         48
        2794: aastore
        2795: dup
        2796: bipush        25
        2798: aload         50
        2800: aastore
        2801: dup
        2802: bipush        26
        2804: aload         52
        2806: aastore
        2807: dup
        2808: bipush        27
        2810: aload         53
        2812: aastore
        2813: dup
        2814: bipush        28
        2816: aload         54
        2818: aastore
        2819: dup
        2820: bipush        29
        2822: aload         55
        2824: aastore
        2825: dup
        2826: bipush        30
        2828: aload         57
        2830: aastore
        2831: dup
        2832: bipush        31
        2834: aload         56
        2836: aastore
        2837: dup
        2838: bipush        32
        2840: aload         58
        2842: aastore
        2843: dup
        2844: bipush        33
        2846: aload         59
        2848: aastore
        2849: dup
        2850: bipush        34
        2852: aload         61
        2854: aastore
        2855: dup
        2856: bipush        35
        2858: aload         62
        2860: aastore
        2861: dup
        2862: bipush        36
        2864: aload         63
        2866: aastore
        2867: dup
        2868: bipush        37
        2870: aload         70
        2872: aastore
        2873: dup
        2874: bipush        38
        2876: aload         72
        2878: aastore
        2879: dup
        2880: bipush        39
        2882: aload         74
        2884: aastore
        2885: dup
        2886: bipush        40
        2888: aload         95
        2890: aastore
        2891: dup
        2892: bipush        41
        2894: aload         96
        2896: aastore
        2897: dup
        2898: bipush        42
        2900: aload         97
        2902: aastore
        2903: dup
        2904: bipush        43
        2906: aload         98
        2908: aastore
        2909: dup
        2910: bipush        44
        2912: aload         99
        2914: aastore
        2915: dup
        2916: bipush        45
        2918: aload         100
        2920: aastore
        2921: dup
        2922: bipush        46
        2924: aload         101
        2926: aastore
        2927: dup
        2928: bipush        47
        2930: aload         102
        2932: aastore
        2933: dup
        2934: bipush        48
        2936: aload         103
        2938: aastore
        2939: dup
        2940: bipush        49
        2942: aload         104
        2944: aastore
        2945: dup
        2946: bipush        50
        2948: aload         105
        2950: aastore
        2951: dup
        2952: bipush        51
        2954: aload         106
        2956: aastore
        2957: dup
        2958: bipush        52
        2960: aload         107
        2962: aastore
        2963: dup
        2964: bipush        53
        2966: aload         108
        2968: aastore
        2969: dup
        2970: bipush        54
        2972: aload         109
        2974: aastore
        2975: dup
        2976: bipush        55
        2978: aload         111
        2980: aastore
        2981: dup
        2982: bipush        56
        2984: aload         110
        2986: aastore
        2987: dup
        2988: bipush        57
        2990: aload         113
        2992: aastore
        2993: dup
        2994: bipush        58
        2996: aload         112
        2998: aastore
        2999: dup
        3000: bipush        59
        3002: aload         76
        3004: aastore
        3005: dup
        3006: bipush        60
        3008: aload         77
        3010: aastore
        3011: dup
        3012: bipush        61
        3014: aload         75
        3016: aastore
        3017: dup
        3018: bipush        62
        3020: aload         147
        3022: aastore
        3023: dup
        3024: bipush        63
        3026: aload         78
        3028: aastore
        3029: dup
        3030: bipush        64
        3032: aload         146
        3034: aastore
        3035: dup
        3036: bipush        65
        3038: aload         80
        3040: aastore
        3041: dup
        3042: bipush        66
        3044: aload         79
        3046: aastore
        3047: dup
        3048: bipush        67
        3050: aload         81
        3052: aastore
        3053: dup
        3054: bipush        68
        3056: aload         82
        3058: aastore
        3059: dup
        3060: bipush        69
        3062: aload         145
        3064: aastore
        3065: dup
        3066: bipush        70
        3068: aload         144
        3070: aastore
        3071: dup
        3072: bipush        71
        3074: aload         83
        3076: aastore
        3077: dup
        3078: bipush        72
        3080: aload         143
        3082: aastore
        3083: dup
        3084: bipush        73
        3086: aload         142
        3088: aastore
        3089: dup
        3090: bipush        74
        3092: aload         141
        3094: aastore
        3095: dup
        3096: bipush        75
        3098: aload         84
        3100: aastore
        3101: dup
        3102: bipush        76
        3104: aload         85
        3106: aastore
        3107: dup
        3108: bipush        77
        3110: aload         140
        3112: aastore
        3113: dup
        3114: bipush        78
        3116: aload         87
        3118: aastore
        3119: dup
        3120: bipush        79
        3122: aload         88
        3124: aastore
        3125: dup
        3126: bipush        80
        3128: aload         86
        3130: aastore
        3131: dup
        3132: bipush        81
        3134: aload         139
        3136: aastore
        3137: dup
        3138: bipush        82
        3140: aload         93
        3142: aastore
        3143: dup
        3144: bipush        83
        3146: aload         89
        3148: aastore
        3149: dup
        3150: bipush        84
        3152: aload         91
        3154: aastore
        3155: dup
        3156: bipush        85
        3158: aload         92
        3160: aastore
        3161: dup
        3162: bipush        86
        3164: aload         138
        3166: aastore
        3167: dup
        3168: bipush        87
        3170: aload         137
        3172: aastore
        3173: dup
        3174: bipush        88
        3176: aload         136
        3178: aastore
        3179: dup
        3180: bipush        89
        3182: aload         135
        3184: aastore
        3185: dup
        3186: bipush        90
        3188: aload         134
        3190: aastore
        3191: dup
        3192: bipush        91
        3194: aload         133
        3196: aastore
        3197: dup
        3198: bipush        92
        3200: aload         132
        3202: aastore
        3203: dup
        3204: bipush        93
        3206: aload         94
        3208: aastore
        3209: dup
        3210: bipush        94
        3212: aload         131
        3214: aastore
        3215: dup
        3216: bipush        95
        3218: aload         130
        3220: aastore
        3221: dup
        3222: bipush        96
        3224: aload         114
        3226: aastore
        3227: dup
        3228: bipush        97
        3230: aload         115
        3232: aastore
        3233: dup
        3234: bipush        98
        3236: aload         121
        3238: aastore
        3239: dup
        3240: bipush        99
        3242: aload         117
        3244: aastore
        3245: dup
        3246: bipush        100
        3248: aload         60
        3250: aastore
        3251: dup
        3252: bipush        101
        3254: aload         90
        3256: aastore
        3257: dup
        3258: bipush        102
        3260: aload         120
        3262: aastore
        3263: dup
        3264: bipush        103
        3266: aload         119
        3268: aastore
        3269: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3272: astore        148
        3274: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3277: bipush        45
        3279: aload         148
        3281: aastore
        3282: iconst_0
        3283: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3286: astore        149
        3288: iconst_0
        3289: istore        150
        3291: iload         150
        3293: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3296: astore        151
        3298: goto_w        3303
        3303: new           #417                // class ocaml_fn_94
        3306: dup
        3307: invokespecial #418                // Method ocaml_fn_94."<init>":()V
        3310: astore        152
        3312: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3315: bipush        46
        3317: aaload
        3318: astore        153
        3320: aload         152
        3322: aload         153
        3324: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3327: astore        154
        3329: getstatic     #426                // Field java/lang/System.out:Ljava/io/PrintStream;
        3332: aload         154
        3334: checkcast     #29                 // class java/lang/Integer
        3337: invokevirtual #430                // Method java/lang/Integer.intValue:()I
        3340: invokevirtual #436                // Method java/io/PrintStream.println:(I)V
        3343: iconst_0
        3344: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3347: astore        155
        3349: new           #2                  // class Block
        3352: dup
        3353: iconst_0
        3354: iconst_1
        3355: anewarray     #4                  // class java/lang/Object
        3358: dup
        3359: iconst_0
        3360: aload         152
        3362: aastore
        3363: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3366: astore        156
        3368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3371: bipush        47
        3373: aload         156
        3375: aastore
        3376: iconst_0
        3377: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3380: astore        157
        3382: iconst_0
        3383: istore        158
        3385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3388: bipush        45
        3390: aaload
        3391: checkcast     #2                  // class Block
        3394: getfield      #439                // Field Block.fields:[Ljava/lang/Object;
        3397: bipush        102
        3399: aaload
        3400: astore        159
        3402: aload         159
        3404: checkcast     #194                // class Closure
        3407: iload         158
        3409: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3412: invokevirtual #422                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3415: astore        160
        3417: new           #2                  // class Block
        3420: dup
        3421: iconst_0
        3422: iconst_0
        3423: anewarray     #4                  // class java/lang/Object
        3426: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3429: astore        161
        3431: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3434: bipush        48
        3436: aload         161
        3438: aastore
        3439: iconst_0
        3440: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3443: astore        162
        3445: return
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
        1438: checkcast     #89                 // class java/lang/Long
        1441: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1444: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1447: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        42
        1452: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        39
        1457: aaload
        1458: astore        43
        1460: aload         43
        1462: checkcast     #89                 // class java/lang/Long
        1465: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1468: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1471: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1474: astore        44
        1476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1479: bipush        40
        1481: aaload
        1482: astore        45
        1484: aload         45
        1486: checkcast     #89                 // class java/lang/Long
        1489: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1492: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1495: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1498: astore        46
        1500: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1503: bipush        41
        1505: aaload
        1506: astore        47
        1508: aload         47
        1510: checkcast     #89                 // class java/lang/Long
        1513: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1516: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1519: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1522: astore        48
        1524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1527: bipush        42
        1529: aaload
        1530: astore        49
        1532: aload         49
        1534: checkcast     #89                 // class java/lang/Long
        1537: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1540: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1543: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1546: astore        50
        1548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1551: bipush        43
        1553: aaload
        1554: astore        51
        1556: aload         51
        1558: checkcast     #89                 // class java/lang/Long
        1561: invokevirtual #147                // Method java/lang/Long.longValue:()J
        1564: invokestatic  #153                // Method java/lang/Double.longBitsToDouble:(J)D
        1567: invokestatic  #156                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1570: astore        52
        1572: new           #158                // class ocaml_fn_14
        1575: dup
        1576: invokespecial #159                // Method ocaml_fn_14."<init>":()V
        1579: astore        53
        1581: new           #161                // class ocaml_fn_15
        1584: dup
        1585: aload         18
        1587: invokespecial #164                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1590: astore        54
        1592: new           #166                // class ocaml_fn_16
        1595: dup
        1596: invokespecial #167                // Method ocaml_fn_16."<init>":()V
        1599: astore        55
        1601: new           #169                // class ocaml_fn_17
        1604: dup
        1605: aload         18
        1607: invokespecial #170                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1610: astore        56
        1612: new           #172                // class ocaml_fn_18
        1615: dup
        1616: invokespecial #173                // Method ocaml_fn_18."<init>":()V
        1619: astore        57
        1621: new           #175                // class ocaml_fn_19
        1624: dup
        1625: invokespecial #176                // Method ocaml_fn_19."<init>":()V
        1628: astore        58
        1630: new           #178                // class ocaml_fn_20
        1633: dup
        1634: aload         26
        1636: invokespecial #179                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1639: astore        59
        1641: new           #181                // class ocaml_fn_21
        1644: dup
        1645: aload         53
        1647: invokespecial #182                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1650: astore        60
        1652: new           #184                // class ocaml_fn_22
        1655: dup
        1656: aload         60
        1658: invokespecial #185                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1661: astore        61
        1663: new           #187                // class ocaml_fn_23
        1666: dup
        1667: aload         26
        1669: invokespecial #188                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1672: astore        62
        1674: new           #190                // class ocaml_fn_24
        1677: dup
        1678: invokespecial #191                // Method ocaml_fn_24."<init>":()V
        1681: astore        63
        1683: new           #193                // class ocaml_fn_25
        1686: dup
        1687: invokespecial #194                // Method ocaml_fn_25."<init>":()V
        1690: astore        64
        1692: aload         63
        1694: checkcast     #190                // class ocaml_fn_24
        1697: aload         63
        1699: checkcast     #196                // class Closure
        1702: putfield      #200                // Field ocaml_fn_24.sibling_0:LClosure;
        1705: iconst_0
        1706: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1709: astore        65
        1711: aload         63
        1713: checkcast     #190                // class ocaml_fn_24
        1716: aload         64
        1718: checkcast     #196                // class Closure
        1721: putfield      #203                // Field ocaml_fn_24.sibling_1:LClosure;
        1724: iconst_0
        1725: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1728: astore        66
        1730: aload         64
        1732: checkcast     #193                // class ocaml_fn_25
        1735: aload         63
        1737: checkcast     #196                // class Closure
        1740: putfield      #204                // Field ocaml_fn_25.sibling_0:LClosure;
        1743: iconst_0
        1744: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1747: astore        67
        1749: aload         64
        1751: checkcast     #193                // class ocaml_fn_25
        1754: aload         64
        1756: checkcast     #196                // class Closure
        1759: putfield      #205                // Field ocaml_fn_25.sibling_1:LClosure;
        1762: iconst_0
        1763: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1766: astore        68
        1768: iconst_0
        1769: istore        69
        1771: iload         69
        1773: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        70
        1778: iconst_1
        1779: istore        71
        1781: iload         71
        1783: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1786: astore        72
        1788: iconst_2
        1789: istore        73
        1791: iload         73
        1793: invokestatic  #209                // Method Channel.forDescriptor:(I)LChannel;
        1796: astore        74
        1798: new           #211                // class ocaml_fn_26
        1801: dup
        1802: invokespecial #212                // Method ocaml_fn_26."<init>":()V
        1805: astore        75
        1807: new           #214                // class ocaml_fn_27
        1810: dup
        1811: aload         75
        1813: invokespecial #215                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1816: astore        76
        1818: new           #217                // class ocaml_fn_28
        1821: dup
        1822: aload         75
        1824: invokespecial #218                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1827: astore        77
        1829: new           #220                // class ocaml_fn_29
        1832: dup
        1833: aload         30
        1835: invokespecial #221                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1838: astore        78
        1840: new           #223                // class ocaml_fn_30
        1843: dup
        1844: invokespecial #224                // Method ocaml_fn_30."<init>":()V
        1847: astore        79
        1849: new           #226                // class ocaml_fn_31
        1852: dup
        1853: invokespecial #227                // Method ocaml_fn_31."<init>":()V
        1856: astore        80
        1858: new           #229                // class ocaml_fn_32
        1861: dup
        1862: aload         18
        1864: invokespecial #230                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1867: astore        81
        1869: new           #232                // class ocaml_fn_33
        1872: dup
        1873: aload         18
        1875: invokespecial #233                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1878: astore        82
        1880: new           #235                // class ocaml_fn_34
        1883: dup
        1884: invokespecial #236                // Method ocaml_fn_34."<init>":()V
        1887: astore        83
        1889: new           #238                // class ocaml_fn_35
        1892: dup
        1893: invokespecial #239                // Method ocaml_fn_35."<init>":()V
        1896: astore        84
        1898: new           #241                // class ocaml_fn_36
        1901: dup
        1902: invokespecial #242                // Method ocaml_fn_36."<init>":()V
        1905: astore        85
        1907: new           #244                // class ocaml_fn_37
        1910: dup
        1911: invokespecial #245                // Method ocaml_fn_37."<init>":()V
        1914: astore        86
        1916: new           #247                // class ocaml_fn_38
        1919: dup
        1920: aload         86
        1922: invokespecial #248                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1925: astore        87
        1927: new           #250                // class ocaml_fn_39
        1930: dup
        1931: aload         86
        1933: invokespecial #251                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1936: astore        88
        1938: new           #253                // class ocaml_fn_40
        1941: dup
        1942: aload         18
        1944: invokespecial #254                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1947: astore        89
        1949: new           #256                // class ocaml_fn_41
        1952: dup
        1953: aload         31
        1955: invokespecial #257                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1958: astore        90
        1960: new           #259                // class ocaml_fn_42
        1963: dup
        1964: aload         18
        1966: aload         90
        1968: invokespecial #262                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        91
        1973: new           #264                // class ocaml_fn_43
        1976: dup
        1977: aload         91
        1979: invokespecial #265                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1982: astore        92
        1984: new           #267                // class ocaml_fn_44
        1987: dup
        1988: aload         31
        1990: invokespecial #268                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1993: astore        93
        1995: new           #270                // class ocaml_fn_45
        1998: dup
        1999: invokespecial #271                // Method ocaml_fn_45."<init>":()V
        2002: astore        94
        2004: new           #273                // class ocaml_fn_46
        2007: dup
        2008: aload         72
        2010: invokespecial #274                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2013: astore        95
        2015: new           #276                // class ocaml_fn_47
        2018: dup
        2019: aload         72
        2021: aload         80
        2023: invokespecial #277                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        96
        2028: new           #279                // class ocaml_fn_48
        2031: dup
        2032: aload         72
        2034: aload         79
        2036: invokespecial #280                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2039: astore        97
        2041: new           #282                // class ocaml_fn_49
        2044: dup
        2045: aload         58
        2047: aload         72
        2049: aload         80
        2051: invokespecial #285                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2054: astore        98
        2056: new           #287                // class ocaml_fn_50
        2059: dup
        2060: aload         61
        2062: aload         72
        2064: aload         80
        2066: invokespecial #288                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        99
        2071: new           #290                // class ocaml_fn_51
        2074: dup
        2075: aload         72
        2077: aload         80
        2079: invokespecial #291                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2082: astore        100
        2084: new           #293                // class ocaml_fn_52
        2087: dup
        2088: aload         72
        2090: invokespecial #294                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2093: astore        101
        2095: new           #296                // class ocaml_fn_53
        2098: dup
        2099: aload         74
        2101: invokespecial #297                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2104: astore        102
        2106: new           #299                // class ocaml_fn_54
        2109: dup
        2110: aload         74
        2112: aload         80
        2114: invokespecial #300                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2117: astore        103
        2119: new           #302                // class ocaml_fn_55
        2122: dup
        2123: aload         74
        2125: aload         79
        2127: invokespecial #303                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2130: astore        104
        2132: new           #305                // class ocaml_fn_56
        2135: dup
        2136: aload         58
        2138: aload         74
        2140: aload         80
        2142: invokespecial #306                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2145: astore        105
        2147: new           #308                // class ocaml_fn_57
        2150: dup
        2151: aload         61
        2153: aload         74
        2155: aload         80
        2157: invokespecial #309                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2160: astore        106
        2162: new           #311                // class ocaml_fn_58
        2165: dup
        2166: aload         74
        2168: aload         80
        2170: invokespecial #312                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2173: astore        107
        2175: new           #314                // class ocaml_fn_59
        2178: dup
        2179: aload         74
        2181: invokespecial #315                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2184: astore        108
        2186: new           #317                // class ocaml_fn_60
        2189: dup
        2190: aload         70
        2192: aload         72
        2194: aload         93
        2196: invokespecial #318                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2199: astore        109
        2201: new           #320                // class ocaml_fn_61
        2204: dup
        2205: aload         109
        2207: invokespecial #321                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        110
        2212: new           #323                // class ocaml_fn_62
        2215: dup
        2216: aload         59
        2218: aload         109
        2220: invokespecial #324                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2223: astore        111
        2225: new           #326                // class ocaml_fn_63
        2228: dup
        2229: aload         109
        2231: invokespecial #327                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2234: astore        112
        2236: new           #329                // class ocaml_fn_64
        2239: dup
        2240: aload         62
        2242: aload         109
        2244: invokespecial #330                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        113
        2249: new           #332                // class ocaml_fn_65
        2252: dup
        2253: invokespecial #333                // Method ocaml_fn_65."<init>":()V
        2256: astore        114
        2258: new           #335                // class ocaml_fn_66
        2261: dup
        2262: aload         53
        2264: invokespecial #336                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
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
        2288: new           #338                // class ocaml_fn_67
        2291: dup
        2292: aload         116
        2294: invokespecial #339                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2297: astore        117
        2299: new           #341                // class ocaml_fn_68
        2302: dup
        2303: invokespecial #342                // Method ocaml_fn_68."<init>":()V
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
        2327: new           #344                // class ocaml_fn_69
        2330: dup
        2331: aload         116
        2333: aload         119
        2335: invokespecial #345                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2338: astore        120
        2340: new           #347                // class ocaml_fn_70
        2343: dup
        2344: aload         120
        2346: invokespecial #348                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2349: astore        121
        2351: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2354: bipush        44
        2356: aaload
        2357: astore        122
        2359: iconst_0
        2360: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2363: astore        123
        2365: new           #350                // class ocaml_fn_71
        2368: dup
        2369: invokespecial #351                // Method ocaml_fn_71."<init>":()V
        2372: astore        124
        2374: new           #353                // class ocaml_fn_72
        2377: dup
        2378: invokespecial #354                // Method ocaml_fn_72."<init>":()V
        2381: astore        125
        2383: new           #356                // class ocaml_fn_73
        2386: dup
        2387: invokespecial #357                // Method ocaml_fn_73."<init>":()V
        2390: astore        126
        2392: new           #359                // class ocaml_fn_74
        2395: dup
        2396: invokespecial #360                // Method ocaml_fn_74."<init>":()V
        2399: astore        127
        2401: new           #362                // class ocaml_fn_75
        2404: dup
        2405: invokespecial #363                // Method ocaml_fn_75."<init>":()V
        2408: astore        128
        2410: new           #365                // class ocaml_fn_76
        2413: dup
        2414: invokespecial #366                // Method ocaml_fn_76."<init>":()V
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
        2464: new           #368                // class ocaml_fn_77
        2467: dup
        2468: invokespecial #369                // Method ocaml_fn_77."<init>":()V
        2471: astore        131
        2473: new           #371                // class ocaml_fn_78
        2476: dup
        2477: invokespecial #372                // Method ocaml_fn_78."<init>":()V
        2480: astore        132
        2482: new           #374                // class ocaml_fn_79
        2485: dup
        2486: invokespecial #375                // Method ocaml_fn_79."<init>":()V
        2489: astore        133
        2491: new           #377                // class ocaml_fn_80
        2494: dup
        2495: invokespecial #378                // Method ocaml_fn_80."<init>":()V
        2498: astore        134
        2500: new           #380                // class ocaml_fn_81
        2503: dup
        2504: invokespecial #381                // Method ocaml_fn_81."<init>":()V
        2507: astore        135
        2509: new           #383                // class ocaml_fn_82
        2512: dup
        2513: invokespecial #384                // Method ocaml_fn_82."<init>":()V
        2516: astore        136
        2518: new           #386                // class ocaml_fn_83
        2521: dup
        2522: invokespecial #387                // Method ocaml_fn_83."<init>":()V
        2525: astore        137
        2527: new           #389                // class ocaml_fn_84
        2530: dup
        2531: invokespecial #390                // Method ocaml_fn_84."<init>":()V
        2534: astore        138
        2536: new           #392                // class ocaml_fn_85
        2539: dup
        2540: invokespecial #393                // Method ocaml_fn_85."<init>":()V
        2543: astore        139
        2545: new           #395                // class ocaml_fn_86
        2548: dup
        2549: invokespecial #396                // Method ocaml_fn_86."<init>":()V
        2552: astore        140
        2554: new           #398                // class ocaml_fn_87
        2557: dup
        2558: invokespecial #399                // Method ocaml_fn_87."<init>":()V
        2561: astore        141
        2563: new           #401                // class ocaml_fn_88
        2566: dup
        2567: invokespecial #402                // Method ocaml_fn_88."<init>":()V
        2570: astore        142
        2572: new           #404                // class ocaml_fn_89
        2575: dup
        2576: invokespecial #405                // Method ocaml_fn_89."<init>":()V
        2579: astore        143
        2581: new           #407                // class ocaml_fn_90
        2584: dup
        2585: invokespecial #408                // Method ocaml_fn_90."<init>":()V
        2588: astore        144
        2590: new           #410                // class ocaml_fn_91
        2593: dup
        2594: invokespecial #411                // Method ocaml_fn_91."<init>":()V
        2597: astore        145
        2599: new           #413                // class ocaml_fn_92
        2602: dup
        2603: invokespecial #414                // Method ocaml_fn_92."<init>":()V
        2606: astore        146
        2608: new           #416                // class ocaml_fn_93
        2611: dup
        2612: invokespecial #417                // Method ocaml_fn_93."<init>":()V
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
        3285: iconst_0
        3286: istore        152
        3288: iconst_1
        3289: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3292: astore        153
        3294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3297: bipush        46
        3299: aaload
        3300: astore        154
        3302: new           #2                  // class Block
        3305: dup
        3306: sipush        248
        3309: iconst_2
        3310: anewarray     #4                  // class java/lang/Object
        3313: dup
        3314: iconst_0
        3315: aload         154
        3317: aastore
        3318: dup
        3319: iconst_1
        3320: aload         153
        3322: aastore
        3323: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3326: astore        155
        3328: new           #419                // class ocaml_fn_94
        3331: dup
        3332: aload         155
        3334: invokespecial #420                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3337: astore        156
        3339: iconst_0
        3340: istore        157
        3342: aload         156
        3344: iload         157
        3346: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3349: invokevirtual #424                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3352: astore        158
        3354: getstatic     #428                // Field java/lang/System.out:Ljava/io/PrintStream;
        3357: aload         158
        3359: checkcast     #29                 // class java/lang/Integer
        3362: invokevirtual #432                // Method java/lang/Integer.intValue:()I
        3365: invokevirtual #438                // Method java/io/PrintStream.println:(I)V
        3368: iconst_0
        3369: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3372: astore        159
        3374: new           #2                  // class Block
        3377: dup
        3378: iconst_0
        3379: iconst_2
        3380: anewarray     #4                  // class java/lang/Object
        3383: dup
        3384: iconst_0
        3385: aload         155
        3387: aastore
        3388: dup
        3389: iconst_1
        3390: aload         156
        3392: aastore
        3393: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3396: astore        160
        3398: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3401: bipush        47
        3403: aload         160
        3405: aastore
        3406: iconst_0
        3407: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3410: astore        161
        3412: iconst_0
        3413: istore        162
        3415: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3418: bipush        45
        3420: aaload
        3421: checkcast     #2                  // class Block
        3424: getfield      #441                // Field Block.fields:[Ljava/lang/Object;
        3427: bipush        102
        3429: aaload
        3430: astore        163
        3432: aload         163
        3434: checkcast     #196                // class Closure
        3437: iload         162
        3439: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3442: invokevirtual #424                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3445: astore        164
        3447: new           #2                  // class Block
        3450: dup
        3451: iconst_0
        3452: iconst_0
        3453: anewarray     #4                  // class java/lang/Object
        3456: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3459: astore        165
        3461: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3464: bipush        48
        3466: aload         165
        3468: aastore
        3469: iconst_0
        3470: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3473: astore        166
        3475: return
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
        1430: checkcast     #89                 // class java/lang/Long
        1433: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1436: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1439: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        42
        1444: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        39
        1449: aaload
        1450: astore        43
        1452: aload         43
        1454: checkcast     #89                 // class java/lang/Long
        1457: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1460: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1463: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: aload         45
        1478: checkcast     #89                 // class java/lang/Long
        1481: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1484: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1487: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1490: astore        46
        1492: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1495: bipush        41
        1497: aaload
        1498: astore        47
        1500: aload         47
        1502: checkcast     #89                 // class java/lang/Long
        1505: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1508: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1511: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        48
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        42
        1521: aaload
        1522: astore        49
        1524: aload         49
        1526: checkcast     #89                 // class java/lang/Long
        1529: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1532: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1535: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1538: astore        50
        1540: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1543: bipush        43
        1545: aaload
        1546: astore        51
        1548: aload         51
        1550: checkcast     #89                 // class java/lang/Long
        1553: invokevirtual #145                // Method java/lang/Long.longValue:()J
        1556: invokestatic  #151                // Method java/lang/Double.longBitsToDouble:(J)D
        1559: invokestatic  #154                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1562: astore        52
        1564: new           #156                // class ocaml_fn_14
        1567: dup
        1568: invokespecial #157                // Method ocaml_fn_14."<init>":()V
        1571: astore        53
        1573: new           #159                // class ocaml_fn_15
        1576: dup
        1577: aload         18
        1579: invokespecial #162                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1582: astore        54
        1584: new           #164                // class ocaml_fn_16
        1587: dup
        1588: invokespecial #165                // Method ocaml_fn_16."<init>":()V
        1591: astore        55
        1593: new           #167                // class ocaml_fn_17
        1596: dup
        1597: aload         18
        1599: invokespecial #168                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1602: astore        56
        1604: new           #170                // class ocaml_fn_18
        1607: dup
        1608: invokespecial #171                // Method ocaml_fn_18."<init>":()V
        1611: astore        57
        1613: new           #173                // class ocaml_fn_19
        1616: dup
        1617: invokespecial #174                // Method ocaml_fn_19."<init>":()V
        1620: astore        58
        1622: new           #176                // class ocaml_fn_20
        1625: dup
        1626: aload         26
        1628: invokespecial #177                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1631: astore        59
        1633: new           #179                // class ocaml_fn_21
        1636: dup
        1637: aload         53
        1639: invokespecial #180                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1642: astore        60
        1644: new           #182                // class ocaml_fn_22
        1647: dup
        1648: aload         60
        1650: invokespecial #183                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1653: astore        61
        1655: new           #185                // class ocaml_fn_23
        1658: dup
        1659: aload         26
        1661: invokespecial #186                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1664: astore        62
        1666: new           #188                // class ocaml_fn_24
        1669: dup
        1670: invokespecial #189                // Method ocaml_fn_24."<init>":()V
        1673: astore        63
        1675: new           #191                // class ocaml_fn_25
        1678: dup
        1679: invokespecial #192                // Method ocaml_fn_25."<init>":()V
        1682: astore        64
        1684: aload         63
        1686: checkcast     #188                // class ocaml_fn_24
        1689: aload         63
        1691: checkcast     #194                // class Closure
        1694: putfield      #198                // Field ocaml_fn_24.sibling_0:LClosure;
        1697: iconst_0
        1698: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1701: astore        65
        1703: aload         63
        1705: checkcast     #188                // class ocaml_fn_24
        1708: aload         64
        1710: checkcast     #194                // class Closure
        1713: putfield      #201                // Field ocaml_fn_24.sibling_1:LClosure;
        1716: iconst_0
        1717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1720: astore        66
        1722: aload         64
        1724: checkcast     #191                // class ocaml_fn_25
        1727: aload         63
        1729: checkcast     #194                // class Closure
        1732: putfield      #202                // Field ocaml_fn_25.sibling_0:LClosure;
        1735: iconst_0
        1736: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1739: astore        67
        1741: aload         64
        1743: checkcast     #191                // class ocaml_fn_25
        1746: aload         64
        1748: checkcast     #194                // class Closure
        1751: putfield      #203                // Field ocaml_fn_25.sibling_1:LClosure;
        1754: iconst_0
        1755: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1758: astore        68
        1760: iconst_0
        1761: istore        69
        1763: iload         69
        1765: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1768: astore        70
        1770: iconst_1
        1771: istore        71
        1773: iload         71
        1775: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1778: astore        72
        1780: iconst_2
        1781: istore        73
        1783: iload         73
        1785: invokestatic  #207                // Method Channel.forDescriptor:(I)LChannel;
        1788: astore        74
        1790: new           #209                // class ocaml_fn_26
        1793: dup
        1794: invokespecial #210                // Method ocaml_fn_26."<init>":()V
        1797: astore        75
        1799: new           #212                // class ocaml_fn_27
        1802: dup
        1803: aload         75
        1805: invokespecial #213                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1808: astore        76
        1810: new           #215                // class ocaml_fn_28
        1813: dup
        1814: aload         75
        1816: invokespecial #216                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1819: astore        77
        1821: new           #218                // class ocaml_fn_29
        1824: dup
        1825: aload         30
        1827: invokespecial #219                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1830: astore        78
        1832: new           #221                // class ocaml_fn_30
        1835: dup
        1836: invokespecial #222                // Method ocaml_fn_30."<init>":()V
        1839: astore        79
        1841: new           #224                // class ocaml_fn_31
        1844: dup
        1845: invokespecial #225                // Method ocaml_fn_31."<init>":()V
        1848: astore        80
        1850: new           #227                // class ocaml_fn_32
        1853: dup
        1854: aload         18
        1856: invokespecial #228                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1859: astore        81
        1861: new           #230                // class ocaml_fn_33
        1864: dup
        1865: aload         18
        1867: invokespecial #231                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1870: astore        82
        1872: new           #233                // class ocaml_fn_34
        1875: dup
        1876: invokespecial #234                // Method ocaml_fn_34."<init>":()V
        1879: astore        83
        1881: new           #236                // class ocaml_fn_35
        1884: dup
        1885: invokespecial #237                // Method ocaml_fn_35."<init>":()V
        1888: astore        84
        1890: new           #239                // class ocaml_fn_36
        1893: dup
        1894: invokespecial #240                // Method ocaml_fn_36."<init>":()V
        1897: astore        85
        1899: new           #242                // class ocaml_fn_37
        1902: dup
        1903: invokespecial #243                // Method ocaml_fn_37."<init>":()V
        1906: astore        86
        1908: new           #245                // class ocaml_fn_38
        1911: dup
        1912: aload         86
        1914: invokespecial #246                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1917: astore        87
        1919: new           #248                // class ocaml_fn_39
        1922: dup
        1923: aload         86
        1925: invokespecial #249                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1928: astore        88
        1930: new           #251                // class ocaml_fn_40
        1933: dup
        1934: aload         18
        1936: invokespecial #252                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1939: astore        89
        1941: new           #254                // class ocaml_fn_41
        1944: dup
        1945: aload         31
        1947: invokespecial #255                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1950: astore        90
        1952: new           #257                // class ocaml_fn_42
        1955: dup
        1956: aload         18
        1958: aload         90
        1960: invokespecial #260                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1963: astore        91
        1965: new           #262                // class ocaml_fn_43
        1968: dup
        1969: aload         91
        1971: invokespecial #263                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1974: astore        92
        1976: new           #265                // class ocaml_fn_44
        1979: dup
        1980: aload         31
        1982: invokespecial #266                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1985: astore        93
        1987: new           #268                // class ocaml_fn_45
        1990: dup
        1991: invokespecial #269                // Method ocaml_fn_45."<init>":()V
        1994: astore        94
        1996: new           #271                // class ocaml_fn_46
        1999: dup
        2000: aload         72
        2002: invokespecial #272                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2005: astore        95
        2007: new           #274                // class ocaml_fn_47
        2010: dup
        2011: aload         72
        2013: aload         80
        2015: invokespecial #275                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2018: astore        96
        2020: new           #277                // class ocaml_fn_48
        2023: dup
        2024: aload         72
        2026: aload         79
        2028: invokespecial #278                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2031: astore        97
        2033: new           #280                // class ocaml_fn_49
        2036: dup
        2037: aload         58
        2039: aload         72
        2041: aload         80
        2043: invokespecial #283                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2046: astore        98
        2048: new           #285                // class ocaml_fn_50
        2051: dup
        2052: aload         61
        2054: aload         72
        2056: aload         80
        2058: invokespecial #286                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2061: astore        99
        2063: new           #288                // class ocaml_fn_51
        2066: dup
        2067: aload         72
        2069: aload         80
        2071: invokespecial #289                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2074: astore        100
        2076: new           #291                // class ocaml_fn_52
        2079: dup
        2080: aload         72
        2082: invokespecial #292                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2085: astore        101
        2087: new           #294                // class ocaml_fn_53
        2090: dup
        2091: aload         74
        2093: invokespecial #295                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2096: astore        102
        2098: new           #297                // class ocaml_fn_54
        2101: dup
        2102: aload         74
        2104: aload         80
        2106: invokespecial #298                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        103
        2111: new           #300                // class ocaml_fn_55
        2114: dup
        2115: aload         74
        2117: aload         79
        2119: invokespecial #301                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2122: astore        104
        2124: new           #303                // class ocaml_fn_56
        2127: dup
        2128: aload         58
        2130: aload         74
        2132: aload         80
        2134: invokespecial #304                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2137: astore        105
        2139: new           #306                // class ocaml_fn_57
        2142: dup
        2143: aload         61
        2145: aload         74
        2147: aload         80
        2149: invokespecial #307                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2152: astore        106
        2154: new           #309                // class ocaml_fn_58
        2157: dup
        2158: aload         74
        2160: aload         80
        2162: invokespecial #310                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2165: astore        107
        2167: new           #312                // class ocaml_fn_59
        2170: dup
        2171: aload         74
        2173: invokespecial #313                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2176: astore        108
        2178: new           #315                // class ocaml_fn_60
        2181: dup
        2182: aload         70
        2184: aload         72
        2186: aload         93
        2188: invokespecial #316                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2191: astore        109
        2193: new           #318                // class ocaml_fn_61
        2196: dup
        2197: aload         109
        2199: invokespecial #319                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2202: astore        110
        2204: new           #321                // class ocaml_fn_62
        2207: dup
        2208: aload         59
        2210: aload         109
        2212: invokespecial #322                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2215: astore        111
        2217: new           #324                // class ocaml_fn_63
        2220: dup
        2221: aload         109
        2223: invokespecial #325                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2226: astore        112
        2228: new           #327                // class ocaml_fn_64
        2231: dup
        2232: aload         62
        2234: aload         109
        2236: invokespecial #328                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2239: astore        113
        2241: new           #330                // class ocaml_fn_65
        2244: dup
        2245: invokespecial #331                // Method ocaml_fn_65."<init>":()V
        2248: astore        114
        2250: new           #333                // class ocaml_fn_66
        2253: dup
        2254: aload         53
        2256: invokespecial #334                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2259: astore        115
        2261: new           #2                  // class Block
        2264: dup
        2265: iconst_0
        2266: iconst_1
        2267: anewarray     #4                  // class java/lang/Object
        2270: dup
        2271: iconst_0
        2272: aload         78
        2274: aastore
        2275: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2278: astore        116
        2280: new           #336                // class ocaml_fn_67
        2283: dup
        2284: aload         116
        2286: invokespecial #337                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2289: astore        117
        2291: new           #339                // class ocaml_fn_68
        2294: dup
        2295: invokespecial #340                // Method ocaml_fn_68."<init>":()V
        2298: astore        118
        2300: new           #2                  // class Block
        2303: dup
        2304: iconst_0
        2305: iconst_1
        2306: anewarray     #4                  // class java/lang/Object
        2309: dup
        2310: iconst_0
        2311: aload         118
        2313: aastore
        2314: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2317: astore        119
        2319: new           #342                // class ocaml_fn_69
        2322: dup
        2323: aload         116
        2325: aload         119
        2327: invokespecial #343                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2330: astore        120
        2332: new           #345                // class ocaml_fn_70
        2335: dup
        2336: aload         120
        2338: invokespecial #346                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2341: astore        121
        2343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2346: bipush        44
        2348: aaload
        2349: astore        122
        2351: iconst_0
        2352: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2355: astore        123
        2357: new           #348                // class ocaml_fn_71
        2360: dup
        2361: invokespecial #349                // Method ocaml_fn_71."<init>":()V
        2364: astore        124
        2366: new           #351                // class ocaml_fn_72
        2369: dup
        2370: invokespecial #352                // Method ocaml_fn_72."<init>":()V
        2373: astore        125
        2375: new           #354                // class ocaml_fn_73
        2378: dup
        2379: invokespecial #355                // Method ocaml_fn_73."<init>":()V
        2382: astore        126
        2384: new           #357                // class ocaml_fn_74
        2387: dup
        2388: invokespecial #358                // Method ocaml_fn_74."<init>":()V
        2391: astore        127
        2393: new           #360                // class ocaml_fn_75
        2396: dup
        2397: invokespecial #361                // Method ocaml_fn_75."<init>":()V
        2400: astore        128
        2402: new           #363                // class ocaml_fn_76
        2405: dup
        2406: invokespecial #364                // Method ocaml_fn_76."<init>":()V
        2409: astore        129
        2411: new           #2                  // class Block
        2414: dup
        2415: iconst_0
        2416: bipush        6
        2418: anewarray     #4                  // class java/lang/Object
        2421: dup
        2422: iconst_0
        2423: aload         129
        2425: aastore
        2426: dup
        2427: iconst_1
        2428: aload         128
        2430: aastore
        2431: dup
        2432: iconst_2
        2433: aload         127
        2435: aastore
        2436: dup
        2437: iconst_3
        2438: aload         126
        2440: aastore
        2441: dup
        2442: iconst_4
        2443: aload         125
        2445: aastore
        2446: dup
        2447: iconst_5
        2448: aload         124
        2450: aastore
        2451: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2454: astore        130
        2456: new           #366                // class ocaml_fn_77
        2459: dup
        2460: invokespecial #367                // Method ocaml_fn_77."<init>":()V
        2463: astore        131
        2465: new           #369                // class ocaml_fn_78
        2468: dup
        2469: invokespecial #370                // Method ocaml_fn_78."<init>":()V
        2472: astore        132
        2474: new           #372                // class ocaml_fn_79
        2477: dup
        2478: invokespecial #373                // Method ocaml_fn_79."<init>":()V
        2481: astore        133
        2483: new           #375                // class ocaml_fn_80
        2486: dup
        2487: invokespecial #376                // Method ocaml_fn_80."<init>":()V
        2490: astore        134
        2492: new           #378                // class ocaml_fn_81
        2495: dup
        2496: invokespecial #379                // Method ocaml_fn_81."<init>":()V
        2499: astore        135
        2501: new           #381                // class ocaml_fn_82
        2504: dup
        2505: invokespecial #382                // Method ocaml_fn_82."<init>":()V
        2508: astore        136
        2510: new           #384                // class ocaml_fn_83
        2513: dup
        2514: invokespecial #385                // Method ocaml_fn_83."<init>":()V
        2517: astore        137
        2519: new           #387                // class ocaml_fn_84
        2522: dup
        2523: invokespecial #388                // Method ocaml_fn_84."<init>":()V
        2526: astore        138
        2528: new           #390                // class ocaml_fn_85
        2531: dup
        2532: invokespecial #391                // Method ocaml_fn_85."<init>":()V
        2535: astore        139
        2537: new           #393                // class ocaml_fn_86
        2540: dup
        2541: invokespecial #394                // Method ocaml_fn_86."<init>":()V
        2544: astore        140
        2546: new           #396                // class ocaml_fn_87
        2549: dup
        2550: invokespecial #397                // Method ocaml_fn_87."<init>":()V
        2553: astore        141
        2555: new           #399                // class ocaml_fn_88
        2558: dup
        2559: invokespecial #400                // Method ocaml_fn_88."<init>":()V
        2562: astore        142
        2564: new           #402                // class ocaml_fn_89
        2567: dup
        2568: invokespecial #403                // Method ocaml_fn_89."<init>":()V
        2571: astore        143
        2573: new           #405                // class ocaml_fn_90
        2576: dup
        2577: invokespecial #406                // Method ocaml_fn_90."<init>":()V
        2580: astore        144
        2582: new           #408                // class ocaml_fn_91
        2585: dup
        2586: invokespecial #409                // Method ocaml_fn_91."<init>":()V
        2589: astore        145
        2591: new           #411                // class ocaml_fn_92
        2594: dup
        2595: invokespecial #412                // Method ocaml_fn_92."<init>":()V
        2598: astore        146
        2600: new           #414                // class ocaml_fn_93
        2603: dup
        2604: invokespecial #415                // Method ocaml_fn_93."<init>":()V
        2607: astore        147
        2609: new           #2                  // class Block
        2612: dup
        2613: iconst_0
        2614: bipush        104
        2616: anewarray     #4                  // class java/lang/Object
        2619: dup
        2620: iconst_0
        2621: aload         18
        2623: aastore
        2624: dup
        2625: iconst_1
        2626: aload         17
        2628: aastore
        2629: dup
        2630: iconst_2
        2631: aload         22
        2633: aastore
        2634: dup
        2635: iconst_3
        2636: aload         23
        2638: aastore
        2639: dup
        2640: iconst_4
        2641: aload         24
        2643: aastore
        2644: dup
        2645: iconst_5
        2646: aload         25
        2648: aastore
        2649: dup
        2650: bipush        6
        2652: aload         26
        2654: aastore
        2655: dup
        2656: bipush        7
        2658: aload         27
        2660: aastore
        2661: dup
        2662: bipush        8
        2664: aload         28
        2666: aastore
        2667: dup
        2668: bipush        9
        2670: aload         29
        2672: aastore
        2673: dup
        2674: bipush        10
        2676: aload         30
        2678: aastore
        2679: dup
        2680: bipush        11
        2682: aload         31
        2684: aastore
        2685: dup
        2686: bipush        12
        2688: aload         32
        2690: aastore
        2691: dup
        2692: bipush        13
        2694: aload         33
        2696: aastore
        2697: dup
        2698: bipush        14
        2700: aload         34
        2702: aastore
        2703: dup
        2704: bipush        15
        2706: aload         35
        2708: aastore
        2709: dup
        2710: bipush        16
        2712: aload         36
        2714: aastore
        2715: dup
        2716: bipush        17
        2718: aload         37
        2720: aastore
        2721: dup
        2722: bipush        18
        2724: iload         39
        2726: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2729: aastore
        2730: dup
        2731: bipush        19
        2733: iload         40
        2735: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2738: aastore
        2739: dup
        2740: bipush        20
        2742: aload         38
        2744: aastore
        2745: dup
        2746: bipush        21
        2748: aload         42
        2750: aastore
        2751: dup
        2752: bipush        22
        2754: aload         44
        2756: aastore
        2757: dup
        2758: bipush        23
        2760: aload         46
        2762: aastore
        2763: dup
        2764: bipush        24
        2766: aload         48
        2768: aastore
        2769: dup
        2770: bipush        25
        2772: aload         50
        2774: aastore
        2775: dup
        2776: bipush        26
        2778: aload         52
        2780: aastore
        2781: dup
        2782: bipush        27
        2784: aload         53
        2786: aastore
        2787: dup
        2788: bipush        28
        2790: aload         54
        2792: aastore
        2793: dup
        2794: bipush        29
        2796: aload         55
        2798: aastore
        2799: dup
        2800: bipush        30
        2802: aload         57
        2804: aastore
        2805: dup
        2806: bipush        31
        2808: aload         56
        2810: aastore
        2811: dup
        2812: bipush        32
        2814: aload         58
        2816: aastore
        2817: dup
        2818: bipush        33
        2820: aload         59
        2822: aastore
        2823: dup
        2824: bipush        34
        2826: aload         61
        2828: aastore
        2829: dup
        2830: bipush        35
        2832: aload         62
        2834: aastore
        2835: dup
        2836: bipush        36
        2838: aload         63
        2840: aastore
        2841: dup
        2842: bipush        37
        2844: aload         70
        2846: aastore
        2847: dup
        2848: bipush        38
        2850: aload         72
        2852: aastore
        2853: dup
        2854: bipush        39
        2856: aload         74
        2858: aastore
        2859: dup
        2860: bipush        40
        2862: aload         95
        2864: aastore
        2865: dup
        2866: bipush        41
        2868: aload         96
        2870: aastore
        2871: dup
        2872: bipush        42
        2874: aload         97
        2876: aastore
        2877: dup
        2878: bipush        43
        2880: aload         98
        2882: aastore
        2883: dup
        2884: bipush        44
        2886: aload         99
        2888: aastore
        2889: dup
        2890: bipush        45
        2892: aload         100
        2894: aastore
        2895: dup
        2896: bipush        46
        2898: aload         101
        2900: aastore
        2901: dup
        2902: bipush        47
        2904: aload         102
        2906: aastore
        2907: dup
        2908: bipush        48
        2910: aload         103
        2912: aastore
        2913: dup
        2914: bipush        49
        2916: aload         104
        2918: aastore
        2919: dup
        2920: bipush        50
        2922: aload         105
        2924: aastore
        2925: dup
        2926: bipush        51
        2928: aload         106
        2930: aastore
        2931: dup
        2932: bipush        52
        2934: aload         107
        2936: aastore
        2937: dup
        2938: bipush        53
        2940: aload         108
        2942: aastore
        2943: dup
        2944: bipush        54
        2946: aload         109
        2948: aastore
        2949: dup
        2950: bipush        55
        2952: aload         111
        2954: aastore
        2955: dup
        2956: bipush        56
        2958: aload         110
        2960: aastore
        2961: dup
        2962: bipush        57
        2964: aload         113
        2966: aastore
        2967: dup
        2968: bipush        58
        2970: aload         112
        2972: aastore
        2973: dup
        2974: bipush        59
        2976: aload         76
        2978: aastore
        2979: dup
        2980: bipush        60
        2982: aload         77
        2984: aastore
        2985: dup
        2986: bipush        61
        2988: aload         75
        2990: aastore
        2991: dup
        2992: bipush        62
        2994: aload         147
        2996: aastore
        2997: dup
        2998: bipush        63
        3000: aload         78
        3002: aastore
        3003: dup
        3004: bipush        64
        3006: aload         146
        3008: aastore
        3009: dup
        3010: bipush        65
        3012: aload         80
        3014: aastore
        3015: dup
        3016: bipush        66
        3018: aload         79
        3020: aastore
        3021: dup
        3022: bipush        67
        3024: aload         81
        3026: aastore
        3027: dup
        3028: bipush        68
        3030: aload         82
        3032: aastore
        3033: dup
        3034: bipush        69
        3036: aload         145
        3038: aastore
        3039: dup
        3040: bipush        70
        3042: aload         144
        3044: aastore
        3045: dup
        3046: bipush        71
        3048: aload         83
        3050: aastore
        3051: dup
        3052: bipush        72
        3054: aload         143
        3056: aastore
        3057: dup
        3058: bipush        73
        3060: aload         142
        3062: aastore
        3063: dup
        3064: bipush        74
        3066: aload         141
        3068: aastore
        3069: dup
        3070: bipush        75
        3072: aload         84
        3074: aastore
        3075: dup
        3076: bipush        76
        3078: aload         85
        3080: aastore
        3081: dup
        3082: bipush        77
        3084: aload         140
        3086: aastore
        3087: dup
        3088: bipush        78
        3090: aload         87
        3092: aastore
        3093: dup
        3094: bipush        79
        3096: aload         88
        3098: aastore
        3099: dup
        3100: bipush        80
        3102: aload         86
        3104: aastore
        3105: dup
        3106: bipush        81
        3108: aload         139
        3110: aastore
        3111: dup
        3112: bipush        82
        3114: aload         93
        3116: aastore
        3117: dup
        3118: bipush        83
        3120: aload         89
        3122: aastore
        3123: dup
        3124: bipush        84
        3126: aload         91
        3128: aastore
        3129: dup
        3130: bipush        85
        3132: aload         92
        3134: aastore
        3135: dup
        3136: bipush        86
        3138: aload         138
        3140: aastore
        3141: dup
        3142: bipush        87
        3144: aload         137
        3146: aastore
        3147: dup
        3148: bipush        88
        3150: aload         136
        3152: aastore
        3153: dup
        3154: bipush        89
        3156: aload         135
        3158: aastore
        3159: dup
        3160: bipush        90
        3162: aload         134
        3164: aastore
        3165: dup
        3166: bipush        91
        3168: aload         133
        3170: aastore
        3171: dup
        3172: bipush        92
        3174: aload         132
        3176: aastore
        3177: dup
        3178: bipush        93
        3180: aload         94
        3182: aastore
        3183: dup
        3184: bipush        94
        3186: aload         131
        3188: aastore
        3189: dup
        3190: bipush        95
        3192: aload         130
        3194: aastore
        3195: dup
        3196: bipush        96
        3198: aload         114
        3200: aastore
        3201: dup
        3202: bipush        97
        3204: aload         115
        3206: aastore
        3207: dup
        3208: bipush        98
        3210: aload         121
        3212: aastore
        3213: dup
        3214: bipush        99
        3216: aload         117
        3218: aastore
        3219: dup
        3220: bipush        100
        3222: aload         60
        3224: aastore
        3225: dup
        3226: bipush        101
        3228: aload         90
        3230: aastore
        3231: dup
        3232: bipush        102
        3234: aload         120
        3236: aastore
        3237: dup
        3238: bipush        103
        3240: aload         119
        3242: aastore
        3243: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3246: astore        148
        3248: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3251: bipush        45
        3253: aload         148
        3255: aastore
        3256: iconst_0
        3257: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        149
        3262: iconst_1
        3263: istore        150
        3265: iconst_0
        3266: istore        151
        3268: iload         151
        3270: ifeq          3285
        3273: iload         150
        3275: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3278: astore        152
        3280: goto_w        3313
        3285: iload         150
        3287: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3290: astore        153
        3292: goto_w        3297
        3297: bipush        10
        3299: istore        154
        3301: iload         154
        3303: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3306: astore        155
        3308: goto_w        3329
        3313: bipush        20
        3315: istore        156
        3317: iload         156
        3319: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3322: astore        155
        3324: goto_w        3329
        3329: getstatic     #419                // Field java/lang/System.out:Ljava/io/PrintStream;
        3332: aload         155
        3334: checkcast     #29                 // class java/lang/Integer
        3337: invokevirtual #423                // Method java/lang/Integer.intValue:()I
        3340: invokevirtual #429                // Method java/io/PrintStream.println:(I)V
        3343: iconst_0
        3344: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3347: astore        157
        3349: new           #2                  // class Block
        3352: dup
        3353: iconst_0
        3354: iconst_0
        3355: anewarray     #4                  // class java/lang/Object
        3358: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3361: astore        158
        3363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3366: bipush        46
        3368: aload         158
        3370: aastore
        3371: iconst_0
        3372: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3375: astore        159
        3377: iconst_0
        3378: istore        160
        3380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3383: bipush        45
        3385: aaload
        3386: checkcast     #2                  // class Block
        3389: getfield      #432                // Field Block.fields:[Ljava/lang/Object;
        3392: bipush        102
        3394: aaload
        3395: astore        161
        3397: aload         161
        3399: checkcast     #194                // class Closure
        3402: iload         160
        3404: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3407: invokevirtual #436                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3410: astore        162
        3412: new           #2                  // class Block
        3415: dup
        3416: iconst_0
        3417: iconst_0
        3418: anewarray     #4                  // class java/lang/Object
        3421: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3424: astore        163
        3426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3429: bipush        47
        3431: aload         163
        3433: aastore
        3434: iconst_0
        3435: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3438: astore        164
        3440: return
    }
    |}]
