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
        1069: aconst_null
        1070: astore_1
        1071: aload_1
        1072: astore_2
        1073: goto_w        1078
        1078: new           #108                // class ocaml_fn_0
        1081: dup
        1082: invokespecial #111                // Method ocaml_fn_0."<init>":()V
        1085: astore_3
        1086: new           #113                // class ocaml_fn_1
        1089: dup
        1090: invokespecial #114                // Method ocaml_fn_1."<init>":()V
        1093: astore        4
        1095: new           #116                // class ocaml_fn_2
        1098: dup
        1099: invokespecial #117                // Method ocaml_fn_2."<init>":()V
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
        1225: new           #119                // class ocaml_fn_8
        1228: dup
        1229: invokespecial #120                // Method ocaml_fn_8."<init>":()V
        1232: astore        17
        1234: new           #122                // class ocaml_fn_9
        1237: dup
        1238: invokespecial #123                // Method ocaml_fn_9."<init>":()V
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
        1376: new           #125                // class ocaml_fn_10
        1379: dup
        1380: invokespecial #126                // Method ocaml_fn_10."<init>":()V
        1383: astore        35
        1385: new           #128                // class ocaml_fn_11
        1388: dup
        1389: invokespecial #129                // Method ocaml_fn_11."<init>":()V
        1392: astore        36
        1394: new           #131                // class ocaml_fn_12
        1397: dup
        1398: invokespecial #132                // Method ocaml_fn_12."<init>":()V
        1401: astore        37
        1403: new           #134                // class ocaml_fn_13
        1406: dup
        1407: invokespecial #135                // Method ocaml_fn_13."<init>":()V
        1410: astore        38
        1412: ldc           #136                // int 2147483647
        1414: istore        39
        1416: ldc           #137                // int -2147483648
        1418: istore        40
        1420: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        38
        1425: aaload
        1426: astore        41
        1428: aload         41
        1430: checkcast     #89                 // class java/lang/Long
        1433: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1436: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1439: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        42
        1444: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        39
        1449: aaload
        1450: astore        43
        1452: aload         43
        1454: checkcast     #89                 // class java/lang/Long
        1457: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1460: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1463: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: aload         45
        1478: checkcast     #89                 // class java/lang/Long
        1481: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1484: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1487: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1490: astore        46
        1492: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1495: bipush        41
        1497: aaload
        1498: astore        47
        1500: aload         47
        1502: checkcast     #89                 // class java/lang/Long
        1505: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1508: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1511: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        48
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        42
        1521: aaload
        1522: astore        49
        1524: aload         49
        1526: checkcast     #89                 // class java/lang/Long
        1529: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1532: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1535: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1538: astore        50
        1540: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1543: bipush        43
        1545: aaload
        1546: astore        51
        1548: aload         51
        1550: checkcast     #89                 // class java/lang/Long
        1553: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1556: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1559: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1562: astore        52
        1564: new           #152                // class ocaml_fn_14
        1567: dup
        1568: invokespecial #153                // Method ocaml_fn_14."<init>":()V
        1571: astore        53
        1573: new           #155                // class ocaml_fn_15
        1576: dup
        1577: aload         18
        1579: invokespecial #158                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1582: astore        54
        1584: new           #160                // class ocaml_fn_16
        1587: dup
        1588: invokespecial #161                // Method ocaml_fn_16."<init>":()V
        1591: astore        55
        1593: new           #163                // class ocaml_fn_17
        1596: dup
        1597: aload         18
        1599: invokespecial #164                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1602: astore        56
        1604: new           #166                // class ocaml_fn_18
        1607: dup
        1608: invokespecial #167                // Method ocaml_fn_18."<init>":()V
        1611: astore        57
        1613: new           #169                // class ocaml_fn_19
        1616: dup
        1617: invokespecial #170                // Method ocaml_fn_19."<init>":()V
        1620: astore        58
        1622: new           #172                // class ocaml_fn_20
        1625: dup
        1626: aload         26
        1628: invokespecial #173                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1631: astore        59
        1633: new           #175                // class ocaml_fn_21
        1636: dup
        1637: aload         53
        1639: invokespecial #176                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1642: astore        60
        1644: new           #178                // class ocaml_fn_22
        1647: dup
        1648: aload         60
        1650: invokespecial #179                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1653: astore        61
        1655: new           #181                // class ocaml_fn_23
        1658: dup
        1659: aload         26
        1661: invokespecial #182                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1664: astore        62
        1666: new           #184                // class ocaml_fn_24
        1669: dup
        1670: invokespecial #185                // Method ocaml_fn_24."<init>":()V
        1673: astore        63
        1675: new           #187                // class ocaml_fn_25
        1678: dup
        1679: invokespecial #188                // Method ocaml_fn_25."<init>":()V
        1682: astore        64
        1684: aload         63
        1686: checkcast     #184                // class ocaml_fn_24
        1689: aload         63
        1691: checkcast     #190                // class Closure
        1694: putfield      #194                // Field ocaml_fn_24.sibling_0:LClosure;
        1697: iconst_0
        1698: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1701: astore        65
        1703: aload         63
        1705: checkcast     #184                // class ocaml_fn_24
        1708: aload         64
        1710: checkcast     #190                // class Closure
        1713: putfield      #197                // Field ocaml_fn_24.sibling_1:LClosure;
        1716: iconst_0
        1717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1720: astore        66
        1722: aload         64
        1724: checkcast     #187                // class ocaml_fn_25
        1727: aload         63
        1729: checkcast     #190                // class Closure
        1732: putfield      #198                // Field ocaml_fn_25.sibling_0:LClosure;
        1735: iconst_0
        1736: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1739: astore        67
        1741: aload         64
        1743: checkcast     #187                // class ocaml_fn_25
        1746: aload         64
        1748: checkcast     #190                // class Closure
        1751: putfield      #199                // Field ocaml_fn_25.sibling_1:LClosure;
        1754: iconst_0
        1755: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1758: astore        68
        1760: iconst_0
        1761: istore        69
        1763: aconst_null
        1764: astore        70
        1766: iconst_1
        1767: istore        71
        1769: iload         71
        1771: invokestatic  #205                // Method Channel.forDescriptor:(I)LChannel;
        1774: astore        72
        1776: iconst_2
        1777: istore        73
        1779: iload         73
        1781: invokestatic  #205                // Method Channel.forDescriptor:(I)LChannel;
        1784: astore        74
        1786: new           #207                // class ocaml_fn_26
        1789: dup
        1790: invokespecial #208                // Method ocaml_fn_26."<init>":()V
        1793: astore        75
        1795: new           #210                // class ocaml_fn_27
        1798: dup
        1799: aload         75
        1801: invokespecial #211                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1804: astore        76
        1806: new           #213                // class ocaml_fn_28
        1809: dup
        1810: aload         75
        1812: invokespecial #214                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1815: astore        77
        1817: new           #216                // class ocaml_fn_29
        1820: dup
        1821: aload         30
        1823: invokespecial #217                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1826: astore        78
        1828: new           #219                // class ocaml_fn_30
        1831: dup
        1832: invokespecial #220                // Method ocaml_fn_30."<init>":()V
        1835: astore        79
        1837: new           #222                // class ocaml_fn_31
        1840: dup
        1841: invokespecial #223                // Method ocaml_fn_31."<init>":()V
        1844: astore        80
        1846: new           #225                // class ocaml_fn_32
        1849: dup
        1850: aload         18
        1852: invokespecial #226                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1855: astore        81
        1857: new           #228                // class ocaml_fn_33
        1860: dup
        1861: aload         18
        1863: invokespecial #229                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1866: astore        82
        1868: new           #231                // class ocaml_fn_34
        1871: dup
        1872: invokespecial #232                // Method ocaml_fn_34."<init>":()V
        1875: astore        83
        1877: new           #234                // class ocaml_fn_35
        1880: dup
        1881: invokespecial #235                // Method ocaml_fn_35."<init>":()V
        1884: astore        84
        1886: new           #237                // class ocaml_fn_36
        1889: dup
        1890: invokespecial #238                // Method ocaml_fn_36."<init>":()V
        1893: astore        85
        1895: new           #240                // class ocaml_fn_37
        1898: dup
        1899: invokespecial #241                // Method ocaml_fn_37."<init>":()V
        1902: astore        86
        1904: new           #243                // class ocaml_fn_38
        1907: dup
        1908: aload         86
        1910: invokespecial #244                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1913: astore        87
        1915: new           #246                // class ocaml_fn_39
        1918: dup
        1919: aload         86
        1921: invokespecial #247                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1924: astore        88
        1926: new           #249                // class ocaml_fn_40
        1929: dup
        1930: aload         18
        1932: invokespecial #250                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1935: astore        89
        1937: new           #252                // class ocaml_fn_41
        1940: dup
        1941: aload         31
        1943: invokespecial #253                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1946: astore        90
        1948: new           #255                // class ocaml_fn_42
        1951: dup
        1952: aload         18
        1954: aload         90
        1956: invokespecial #258                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1959: astore        91
        1961: new           #260                // class ocaml_fn_43
        1964: dup
        1965: aload         91
        1967: invokespecial #261                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1970: astore        92
        1972: new           #263                // class ocaml_fn_44
        1975: dup
        1976: aload         31
        1978: invokespecial #264                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1981: astore        93
        1983: new           #266                // class ocaml_fn_45
        1986: dup
        1987: invokespecial #267                // Method ocaml_fn_45."<init>":()V
        1990: astore        94
        1992: new           #269                // class ocaml_fn_46
        1995: dup
        1996: aload         72
        1998: invokespecial #270                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2001: astore        95
        2003: new           #272                // class ocaml_fn_47
        2006: dup
        2007: aload         72
        2009: aload         80
        2011: invokespecial #273                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2014: astore        96
        2016: new           #275                // class ocaml_fn_48
        2019: dup
        2020: aload         72
        2022: aload         79
        2024: invokespecial #276                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        97
        2029: new           #278                // class ocaml_fn_49
        2032: dup
        2033: aload         58
        2035: aload         72
        2037: aload         80
        2039: invokespecial #281                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2042: astore        98
        2044: new           #283                // class ocaml_fn_50
        2047: dup
        2048: aload         61
        2050: aload         72
        2052: aload         80
        2054: invokespecial #284                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2057: astore        99
        2059: new           #286                // class ocaml_fn_51
        2062: dup
        2063: aload         72
        2065: aload         80
        2067: invokespecial #287                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2070: astore        100
        2072: new           #289                // class ocaml_fn_52
        2075: dup
        2076: aload         72
        2078: invokespecial #290                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2081: astore        101
        2083: new           #292                // class ocaml_fn_53
        2086: dup
        2087: aload         74
        2089: invokespecial #293                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2092: astore        102
        2094: new           #295                // class ocaml_fn_54
        2097: dup
        2098: aload         74
        2100: aload         80
        2102: invokespecial #296                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2105: astore        103
        2107: new           #298                // class ocaml_fn_55
        2110: dup
        2111: aload         74
        2113: aload         79
        2115: invokespecial #299                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2118: astore        104
        2120: new           #301                // class ocaml_fn_56
        2123: dup
        2124: aload         58
        2126: aload         74
        2128: aload         80
        2130: invokespecial #302                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2133: astore        105
        2135: new           #304                // class ocaml_fn_57
        2138: dup
        2139: aload         61
        2141: aload         74
        2143: aload         80
        2145: invokespecial #305                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2148: astore        106
        2150: new           #307                // class ocaml_fn_58
        2153: dup
        2154: aload         74
        2156: aload         80
        2158: invokespecial #308                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2161: astore        107
        2163: new           #310                // class ocaml_fn_59
        2166: dup
        2167: aload         74
        2169: invokespecial #311                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2172: astore        108
        2174: new           #313                // class ocaml_fn_60
        2177: dup
        2178: aload         70
        2180: aload         72
        2182: aload         93
        2184: invokespecial #314                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        109
        2189: new           #316                // class ocaml_fn_61
        2192: dup
        2193: aload         109
        2195: invokespecial #317                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2198: astore        110
        2200: new           #319                // class ocaml_fn_62
        2203: dup
        2204: aload         59
        2206: aload         109
        2208: invokespecial #320                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2211: astore        111
        2213: new           #322                // class ocaml_fn_63
        2216: dup
        2217: aload         109
        2219: invokespecial #323                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2222: astore        112
        2224: new           #325                // class ocaml_fn_64
        2227: dup
        2228: aload         62
        2230: aload         109
        2232: invokespecial #326                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2235: astore        113
        2237: new           #328                // class ocaml_fn_65
        2240: dup
        2241: invokespecial #329                // Method ocaml_fn_65."<init>":()V
        2244: astore        114
        2246: new           #331                // class ocaml_fn_66
        2249: dup
        2250: aload         53
        2252: invokespecial #332                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2255: astore        115
        2257: new           #2                  // class Block
        2260: dup
        2261: iconst_0
        2262: iconst_1
        2263: anewarray     #4                  // class java/lang/Object
        2266: dup
        2267: iconst_0
        2268: aload         78
        2270: aastore
        2271: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2274: astore        116
        2276: new           #334                // class ocaml_fn_67
        2279: dup
        2280: aload         116
        2282: invokespecial #335                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2285: astore        117
        2287: new           #337                // class ocaml_fn_68
        2290: dup
        2291: invokespecial #338                // Method ocaml_fn_68."<init>":()V
        2294: astore        118
        2296: new           #2                  // class Block
        2299: dup
        2300: iconst_0
        2301: iconst_1
        2302: anewarray     #4                  // class java/lang/Object
        2305: dup
        2306: iconst_0
        2307: aload         118
        2309: aastore
        2310: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2313: astore        119
        2315: new           #340                // class ocaml_fn_69
        2318: dup
        2319: aload         116
        2321: aload         119
        2323: invokespecial #341                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2326: astore        120
        2328: new           #343                // class ocaml_fn_70
        2331: dup
        2332: aload         120
        2334: invokespecial #344                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2337: astore        121
        2339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2342: bipush        44
        2344: aaload
        2345: astore        122
        2347: iconst_0
        2348: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2351: astore        123
        2353: new           #346                // class ocaml_fn_71
        2356: dup
        2357: invokespecial #347                // Method ocaml_fn_71."<init>":()V
        2360: astore        124
        2362: new           #349                // class ocaml_fn_72
        2365: dup
        2366: invokespecial #350                // Method ocaml_fn_72."<init>":()V
        2369: astore        125
        2371: new           #352                // class ocaml_fn_73
        2374: dup
        2375: invokespecial #353                // Method ocaml_fn_73."<init>":()V
        2378: astore        126
        2380: new           #355                // class ocaml_fn_74
        2383: dup
        2384: invokespecial #356                // Method ocaml_fn_74."<init>":()V
        2387: astore        127
        2389: new           #358                // class ocaml_fn_75
        2392: dup
        2393: invokespecial #359                // Method ocaml_fn_75."<init>":()V
        2396: astore        128
        2398: new           #361                // class ocaml_fn_76
        2401: dup
        2402: invokespecial #362                // Method ocaml_fn_76."<init>":()V
        2405: astore        129
        2407: new           #2                  // class Block
        2410: dup
        2411: iconst_0
        2412: bipush        6
        2414: anewarray     #4                  // class java/lang/Object
        2417: dup
        2418: iconst_0
        2419: aload         129
        2421: aastore
        2422: dup
        2423: iconst_1
        2424: aload         128
        2426: aastore
        2427: dup
        2428: iconst_2
        2429: aload         127
        2431: aastore
        2432: dup
        2433: iconst_3
        2434: aload         126
        2436: aastore
        2437: dup
        2438: iconst_4
        2439: aload         125
        2441: aastore
        2442: dup
        2443: iconst_5
        2444: aload         124
        2446: aastore
        2447: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2450: astore        130
        2452: new           #364                // class ocaml_fn_77
        2455: dup
        2456: invokespecial #365                // Method ocaml_fn_77."<init>":()V
        2459: astore        131
        2461: new           #367                // class ocaml_fn_78
        2464: dup
        2465: invokespecial #368                // Method ocaml_fn_78."<init>":()V
        2468: astore        132
        2470: new           #370                // class ocaml_fn_79
        2473: dup
        2474: invokespecial #371                // Method ocaml_fn_79."<init>":()V
        2477: astore        133
        2479: new           #373                // class ocaml_fn_80
        2482: dup
        2483: invokespecial #374                // Method ocaml_fn_80."<init>":()V
        2486: astore        134
        2488: new           #376                // class ocaml_fn_81
        2491: dup
        2492: invokespecial #377                // Method ocaml_fn_81."<init>":()V
        2495: astore        135
        2497: new           #379                // class ocaml_fn_82
        2500: dup
        2501: invokespecial #380                // Method ocaml_fn_82."<init>":()V
        2504: astore        136
        2506: new           #382                // class ocaml_fn_83
        2509: dup
        2510: invokespecial #383                // Method ocaml_fn_83."<init>":()V
        2513: astore        137
        2515: new           #385                // class ocaml_fn_84
        2518: dup
        2519: invokespecial #386                // Method ocaml_fn_84."<init>":()V
        2522: astore        138
        2524: new           #388                // class ocaml_fn_85
        2527: dup
        2528: invokespecial #389                // Method ocaml_fn_85."<init>":()V
        2531: astore        139
        2533: new           #391                // class ocaml_fn_86
        2536: dup
        2537: invokespecial #392                // Method ocaml_fn_86."<init>":()V
        2540: astore        140
        2542: new           #394                // class ocaml_fn_87
        2545: dup
        2546: invokespecial #395                // Method ocaml_fn_87."<init>":()V
        2549: astore        141
        2551: new           #397                // class ocaml_fn_88
        2554: dup
        2555: invokespecial #398                // Method ocaml_fn_88."<init>":()V
        2558: astore        142
        2560: new           #400                // class ocaml_fn_89
        2563: dup
        2564: invokespecial #401                // Method ocaml_fn_89."<init>":()V
        2567: astore        143
        2569: new           #403                // class ocaml_fn_90
        2572: dup
        2573: invokespecial #404                // Method ocaml_fn_90."<init>":()V
        2576: astore        144
        2578: new           #406                // class ocaml_fn_91
        2581: dup
        2582: invokespecial #407                // Method ocaml_fn_91."<init>":()V
        2585: astore        145
        2587: new           #409                // class ocaml_fn_92
        2590: dup
        2591: invokespecial #410                // Method ocaml_fn_92."<init>":()V
        2594: astore        146
        2596: new           #412                // class ocaml_fn_93
        2599: dup
        2600: invokespecial #413                // Method ocaml_fn_93."<init>":()V
        2603: astore        147
        2605: new           #2                  // class Block
        2608: dup
        2609: iconst_0
        2610: bipush        104
        2612: anewarray     #4                  // class java/lang/Object
        2615: dup
        2616: iconst_0
        2617: aload         18
        2619: aastore
        2620: dup
        2621: iconst_1
        2622: aload         17
        2624: aastore
        2625: dup
        2626: iconst_2
        2627: aload         22
        2629: aastore
        2630: dup
        2631: iconst_3
        2632: aload         23
        2634: aastore
        2635: dup
        2636: iconst_4
        2637: aload         24
        2639: aastore
        2640: dup
        2641: iconst_5
        2642: aload         25
        2644: aastore
        2645: dup
        2646: bipush        6
        2648: aload         26
        2650: aastore
        2651: dup
        2652: bipush        7
        2654: aload         27
        2656: aastore
        2657: dup
        2658: bipush        8
        2660: aload         28
        2662: aastore
        2663: dup
        2664: bipush        9
        2666: aload         29
        2668: aastore
        2669: dup
        2670: bipush        10
        2672: aload         30
        2674: aastore
        2675: dup
        2676: bipush        11
        2678: aload         31
        2680: aastore
        2681: dup
        2682: bipush        12
        2684: aload         32
        2686: aastore
        2687: dup
        2688: bipush        13
        2690: aload         33
        2692: aastore
        2693: dup
        2694: bipush        14
        2696: aload         34
        2698: aastore
        2699: dup
        2700: bipush        15
        2702: aload         35
        2704: aastore
        2705: dup
        2706: bipush        16
        2708: aload         36
        2710: aastore
        2711: dup
        2712: bipush        17
        2714: aload         37
        2716: aastore
        2717: dup
        2718: bipush        18
        2720: iload         39
        2722: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2725: aastore
        2726: dup
        2727: bipush        19
        2729: iload         40
        2731: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2734: aastore
        2735: dup
        2736: bipush        20
        2738: aload         38
        2740: aastore
        2741: dup
        2742: bipush        21
        2744: aload         42
        2746: aastore
        2747: dup
        2748: bipush        22
        2750: aload         44
        2752: aastore
        2753: dup
        2754: bipush        23
        2756: aload         46
        2758: aastore
        2759: dup
        2760: bipush        24
        2762: aload         48
        2764: aastore
        2765: dup
        2766: bipush        25
        2768: aload         50
        2770: aastore
        2771: dup
        2772: bipush        26
        2774: aload         52
        2776: aastore
        2777: dup
        2778: bipush        27
        2780: aload         53
        2782: aastore
        2783: dup
        2784: bipush        28
        2786: aload         54
        2788: aastore
        2789: dup
        2790: bipush        29
        2792: aload         55
        2794: aastore
        2795: dup
        2796: bipush        30
        2798: aload         57
        2800: aastore
        2801: dup
        2802: bipush        31
        2804: aload         56
        2806: aastore
        2807: dup
        2808: bipush        32
        2810: aload         58
        2812: aastore
        2813: dup
        2814: bipush        33
        2816: aload         59
        2818: aastore
        2819: dup
        2820: bipush        34
        2822: aload         61
        2824: aastore
        2825: dup
        2826: bipush        35
        2828: aload         62
        2830: aastore
        2831: dup
        2832: bipush        36
        2834: aload         63
        2836: aastore
        2837: dup
        2838: bipush        37
        2840: aload         70
        2842: aastore
        2843: dup
        2844: bipush        38
        2846: aload         72
        2848: aastore
        2849: dup
        2850: bipush        39
        2852: aload         74
        2854: aastore
        2855: dup
        2856: bipush        40
        2858: aload         95
        2860: aastore
        2861: dup
        2862: bipush        41
        2864: aload         96
        2866: aastore
        2867: dup
        2868: bipush        42
        2870: aload         97
        2872: aastore
        2873: dup
        2874: bipush        43
        2876: aload         98
        2878: aastore
        2879: dup
        2880: bipush        44
        2882: aload         99
        2884: aastore
        2885: dup
        2886: bipush        45
        2888: aload         100
        2890: aastore
        2891: dup
        2892: bipush        46
        2894: aload         101
        2896: aastore
        2897: dup
        2898: bipush        47
        2900: aload         102
        2902: aastore
        2903: dup
        2904: bipush        48
        2906: aload         103
        2908: aastore
        2909: dup
        2910: bipush        49
        2912: aload         104
        2914: aastore
        2915: dup
        2916: bipush        50
        2918: aload         105
        2920: aastore
        2921: dup
        2922: bipush        51
        2924: aload         106
        2926: aastore
        2927: dup
        2928: bipush        52
        2930: aload         107
        2932: aastore
        2933: dup
        2934: bipush        53
        2936: aload         108
        2938: aastore
        2939: dup
        2940: bipush        54
        2942: aload         109
        2944: aastore
        2945: dup
        2946: bipush        55
        2948: aload         111
        2950: aastore
        2951: dup
        2952: bipush        56
        2954: aload         110
        2956: aastore
        2957: dup
        2958: bipush        57
        2960: aload         113
        2962: aastore
        2963: dup
        2964: bipush        58
        2966: aload         112
        2968: aastore
        2969: dup
        2970: bipush        59
        2972: aload         76
        2974: aastore
        2975: dup
        2976: bipush        60
        2978: aload         77
        2980: aastore
        2981: dup
        2982: bipush        61
        2984: aload         75
        2986: aastore
        2987: dup
        2988: bipush        62
        2990: aload         147
        2992: aastore
        2993: dup
        2994: bipush        63
        2996: aload         78
        2998: aastore
        2999: dup
        3000: bipush        64
        3002: aload         146
        3004: aastore
        3005: dup
        3006: bipush        65
        3008: aload         80
        3010: aastore
        3011: dup
        3012: bipush        66
        3014: aload         79
        3016: aastore
        3017: dup
        3018: bipush        67
        3020: aload         81
        3022: aastore
        3023: dup
        3024: bipush        68
        3026: aload         82
        3028: aastore
        3029: dup
        3030: bipush        69
        3032: aload         145
        3034: aastore
        3035: dup
        3036: bipush        70
        3038: aload         144
        3040: aastore
        3041: dup
        3042: bipush        71
        3044: aload         83
        3046: aastore
        3047: dup
        3048: bipush        72
        3050: aload         143
        3052: aastore
        3053: dup
        3054: bipush        73
        3056: aload         142
        3058: aastore
        3059: dup
        3060: bipush        74
        3062: aload         141
        3064: aastore
        3065: dup
        3066: bipush        75
        3068: aload         84
        3070: aastore
        3071: dup
        3072: bipush        76
        3074: aload         85
        3076: aastore
        3077: dup
        3078: bipush        77
        3080: aload         140
        3082: aastore
        3083: dup
        3084: bipush        78
        3086: aload         87
        3088: aastore
        3089: dup
        3090: bipush        79
        3092: aload         88
        3094: aastore
        3095: dup
        3096: bipush        80
        3098: aload         86
        3100: aastore
        3101: dup
        3102: bipush        81
        3104: aload         139
        3106: aastore
        3107: dup
        3108: bipush        82
        3110: aload         93
        3112: aastore
        3113: dup
        3114: bipush        83
        3116: aload         89
        3118: aastore
        3119: dup
        3120: bipush        84
        3122: aload         91
        3124: aastore
        3125: dup
        3126: bipush        85
        3128: aload         92
        3130: aastore
        3131: dup
        3132: bipush        86
        3134: aload         138
        3136: aastore
        3137: dup
        3138: bipush        87
        3140: aload         137
        3142: aastore
        3143: dup
        3144: bipush        88
        3146: aload         136
        3148: aastore
        3149: dup
        3150: bipush        89
        3152: aload         135
        3154: aastore
        3155: dup
        3156: bipush        90
        3158: aload         134
        3160: aastore
        3161: dup
        3162: bipush        91
        3164: aload         133
        3166: aastore
        3167: dup
        3168: bipush        92
        3170: aload         132
        3172: aastore
        3173: dup
        3174: bipush        93
        3176: aload         94
        3178: aastore
        3179: dup
        3180: bipush        94
        3182: aload         131
        3184: aastore
        3185: dup
        3186: bipush        95
        3188: aload         130
        3190: aastore
        3191: dup
        3192: bipush        96
        3194: aload         114
        3196: aastore
        3197: dup
        3198: bipush        97
        3200: aload         115
        3202: aastore
        3203: dup
        3204: bipush        98
        3206: aload         121
        3208: aastore
        3209: dup
        3210: bipush        99
        3212: aload         117
        3214: aastore
        3215: dup
        3216: bipush        100
        3218: aload         60
        3220: aastore
        3221: dup
        3222: bipush        101
        3224: aload         90
        3226: aastore
        3227: dup
        3228: bipush        102
        3230: aload         120
        3232: aastore
        3233: dup
        3234: bipush        103
        3236: aload         119
        3238: aastore
        3239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3242: astore        148
        3244: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3247: bipush        45
        3249: aload         148
        3251: aastore
        3252: iconst_0
        3253: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3256: astore        149
        3258: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3261: bipush        46
        3263: aaload
        3264: astore        150
        3266: getstatic     #417                // Field java/lang/System.out:Ljava/io/PrintStream;
        3269: aload         150
        3271: checkcast     #419                // class java/lang/String
        3274: invokevirtual #425                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3277: iconst_0
        3278: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3281: astore        151
        3283: new           #2                  // class Block
        3286: dup
        3287: iconst_0
        3288: iconst_0
        3289: anewarray     #4                  // class java/lang/Object
        3292: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3295: astore        152
        3297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3300: bipush        47
        3302: aload         152
        3304: aastore
        3305: iconst_0
        3306: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3309: astore        153
        3311: iconst_0
        3312: istore        154
        3314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3317: bipush        45
        3319: aaload
        3320: checkcast     #2                  // class Block
        3323: getfield      #428                // Field Block.fields:[Ljava/lang/Object;
        3326: bipush        102
        3328: aaload
        3329: astore        155
        3331: aload         155
        3333: checkcast     #190                // class Closure
        3336: iload         154
        3338: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3341: invokevirtual #432                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3344: astore        156
        3346: new           #2                  // class Block
        3349: dup
        3350: iconst_0
        3351: iconst_0
        3352: anewarray     #4                  // class java/lang/Object
        3355: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3358: astore        157
        3360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3363: bipush        48
        3365: aload         157
        3367: aastore
        3368: iconst_0
        3369: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3372: astore        158
        3374: return
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
        1061: aconst_null
        1062: astore_1
        1063: aload_1
        1064: astore_2
        1065: goto_w        1070
        1070: new           #106                // class ocaml_fn_0
        1073: dup
        1074: invokespecial #109                // Method ocaml_fn_0."<init>":()V
        1077: astore_3
        1078: new           #111                // class ocaml_fn_1
        1081: dup
        1082: invokespecial #112                // Method ocaml_fn_1."<init>":()V
        1085: astore        4
        1087: new           #114                // class ocaml_fn_2
        1090: dup
        1091: invokespecial #115                // Method ocaml_fn_2."<init>":()V
        1094: astore        5
        1096: new           #2                  // class Block
        1099: dup
        1100: iconst_0
        1101: iconst_3
        1102: anewarray     #4                  // class java/lang/Object
        1105: dup
        1106: iconst_0
        1107: aload         4
        1109: aastore
        1110: dup
        1111: iconst_1
        1112: aload_3
        1113: aastore
        1114: dup
        1115: iconst_2
        1116: aload         5
        1118: aastore
        1119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1122: astore        6
        1124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        12
        1129: aload         6
        1131: aastore
        1132: iconst_0
        1133: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1136: astore        7
        1138: iconst_0
        1139: istore        8
        1141: iload         8
        1143: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1146: astore        9
        1148: goto_w        1153
        1153: sipush        199
        1156: istore        10
        1158: iconst_0
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        11
        1164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1167: bipush        35
        1169: aaload
        1170: astore        12
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: iconst_3
        1176: aaload
        1177: astore        13
        1179: new           #2                  // class Block
        1182: dup
        1183: iconst_0
        1184: iconst_2
        1185: anewarray     #4                  // class java/lang/Object
        1188: dup
        1189: iconst_0
        1190: aload         13
        1192: aastore
        1193: dup
        1194: iconst_1
        1195: aload         12
        1197: aastore
        1198: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1201: astore        14
        1203: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1206: bipush        36
        1208: aaload
        1209: astore        15
        1211: iconst_0
        1212: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1215: astore        16
        1217: new           #117                // class ocaml_fn_8
        1220: dup
        1221: invokespecial #118                // Method ocaml_fn_8."<init>":()V
        1224: astore        17
        1226: new           #120                // class ocaml_fn_9
        1229: dup
        1230: invokespecial #121                // Method ocaml_fn_9."<init>":()V
        1233: astore        18
        1235: iconst_0
        1236: istore        19
        1238: iconst_0
        1239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1242: astore        20
        1244: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1247: bipush        37
        1249: aaload
        1250: astore        21
        1252: new           #2                  // class Block
        1255: dup
        1256: sipush        248
        1259: iconst_2
        1260: anewarray     #4                  // class java/lang/Object
        1263: dup
        1264: iconst_0
        1265: aload         21
        1267: aastore
        1268: dup
        1269: iconst_1
        1270: aload         20
        1272: aastore
        1273: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1276: astore        22
        1278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1281: bipush        7
        1283: aaload
        1284: astore        23
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        10
        1291: aaload
        1292: astore        24
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: iconst_3
        1298: aaload
        1299: astore        25
        1301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1304: iconst_2
        1305: aaload
        1306: astore        26
        1308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1311: bipush        6
        1313: aaload
        1314: astore        27
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: iconst_0
        1320: aaload
        1321: astore        28
        1323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1326: bipush        8
        1328: aaload
        1329: astore        29
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: iconst_1
        1335: aaload
        1336: astore        30
        1338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1341: iconst_4
        1342: aaload
        1343: astore        31
        1345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1348: iconst_5
        1349: aaload
        1350: astore        32
        1352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1355: bipush        9
        1357: aaload
        1358: astore        33
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        11
        1365: aaload
        1366: astore        34
        1368: new           #123                // class ocaml_fn_10
        1371: dup
        1372: invokespecial #124                // Method ocaml_fn_10."<init>":()V
        1375: astore        35
        1377: new           #126                // class ocaml_fn_11
        1380: dup
        1381: invokespecial #127                // Method ocaml_fn_11."<init>":()V
        1384: astore        36
        1386: new           #129                // class ocaml_fn_12
        1389: dup
        1390: invokespecial #130                // Method ocaml_fn_12."<init>":()V
        1393: astore        37
        1395: new           #132                // class ocaml_fn_13
        1398: dup
        1399: invokespecial #133                // Method ocaml_fn_13."<init>":()V
        1402: astore        38
        1404: ldc           #134                // int 2147483647
        1406: istore        39
        1408: ldc           #135                // int -2147483648
        1410: istore        40
        1412: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1415: bipush        38
        1417: aaload
        1418: astore        41
        1420: aload         41
        1422: checkcast     #89                 // class java/lang/Long
        1425: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1428: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1431: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        42
        1436: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        39
        1441: aaload
        1442: astore        43
        1444: aload         43
        1446: checkcast     #89                 // class java/lang/Long
        1449: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1452: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1455: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1458: astore        44
        1460: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1463: bipush        40
        1465: aaload
        1466: astore        45
        1468: aload         45
        1470: checkcast     #89                 // class java/lang/Long
        1473: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1476: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1479: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1482: astore        46
        1484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1487: bipush        41
        1489: aaload
        1490: astore        47
        1492: aload         47
        1494: checkcast     #89                 // class java/lang/Long
        1497: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1500: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1503: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1506: astore        48
        1508: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1511: bipush        42
        1513: aaload
        1514: astore        49
        1516: aload         49
        1518: checkcast     #89                 // class java/lang/Long
        1521: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1524: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1527: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1530: astore        50
        1532: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1535: bipush        43
        1537: aaload
        1538: astore        51
        1540: aload         51
        1542: checkcast     #89                 // class java/lang/Long
        1545: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1548: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1551: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1554: astore        52
        1556: new           #150                // class ocaml_fn_14
        1559: dup
        1560: invokespecial #151                // Method ocaml_fn_14."<init>":()V
        1563: astore        53
        1565: new           #153                // class ocaml_fn_15
        1568: dup
        1569: aload         18
        1571: invokespecial #156                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1574: astore        54
        1576: new           #158                // class ocaml_fn_16
        1579: dup
        1580: invokespecial #159                // Method ocaml_fn_16."<init>":()V
        1583: astore        55
        1585: new           #161                // class ocaml_fn_17
        1588: dup
        1589: aload         18
        1591: invokespecial #162                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1594: astore        56
        1596: new           #164                // class ocaml_fn_18
        1599: dup
        1600: invokespecial #165                // Method ocaml_fn_18."<init>":()V
        1603: astore        57
        1605: new           #167                // class ocaml_fn_19
        1608: dup
        1609: invokespecial #168                // Method ocaml_fn_19."<init>":()V
        1612: astore        58
        1614: new           #170                // class ocaml_fn_20
        1617: dup
        1618: aload         26
        1620: invokespecial #171                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1623: astore        59
        1625: new           #173                // class ocaml_fn_21
        1628: dup
        1629: aload         53
        1631: invokespecial #174                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1634: astore        60
        1636: new           #176                // class ocaml_fn_22
        1639: dup
        1640: aload         60
        1642: invokespecial #177                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1645: astore        61
        1647: new           #179                // class ocaml_fn_23
        1650: dup
        1651: aload         26
        1653: invokespecial #180                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1656: astore        62
        1658: new           #182                // class ocaml_fn_24
        1661: dup
        1662: invokespecial #183                // Method ocaml_fn_24."<init>":()V
        1665: astore        63
        1667: new           #185                // class ocaml_fn_25
        1670: dup
        1671: invokespecial #186                // Method ocaml_fn_25."<init>":()V
        1674: astore        64
        1676: aload         63
        1678: checkcast     #182                // class ocaml_fn_24
        1681: aload         63
        1683: checkcast     #188                // class Closure
        1686: putfield      #192                // Field ocaml_fn_24.sibling_0:LClosure;
        1689: iconst_0
        1690: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1693: astore        65
        1695: aload         63
        1697: checkcast     #182                // class ocaml_fn_24
        1700: aload         64
        1702: checkcast     #188                // class Closure
        1705: putfield      #195                // Field ocaml_fn_24.sibling_1:LClosure;
        1708: iconst_0
        1709: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1712: astore        66
        1714: aload         64
        1716: checkcast     #185                // class ocaml_fn_25
        1719: aload         63
        1721: checkcast     #188                // class Closure
        1724: putfield      #196                // Field ocaml_fn_25.sibling_0:LClosure;
        1727: iconst_0
        1728: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1731: astore        67
        1733: aload         64
        1735: checkcast     #185                // class ocaml_fn_25
        1738: aload         64
        1740: checkcast     #188                // class Closure
        1743: putfield      #197                // Field ocaml_fn_25.sibling_1:LClosure;
        1746: iconst_0
        1747: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1750: astore        68
        1752: iconst_0
        1753: istore        69
        1755: aconst_null
        1756: astore        70
        1758: iconst_1
        1759: istore        71
        1761: iload         71
        1763: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1766: astore        72
        1768: iconst_2
        1769: istore        73
        1771: iload         73
        1773: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        74
        1778: new           #205                // class ocaml_fn_26
        1781: dup
        1782: invokespecial #206                // Method ocaml_fn_26."<init>":()V
        1785: astore        75
        1787: new           #208                // class ocaml_fn_27
        1790: dup
        1791: aload         75
        1793: invokespecial #209                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1796: astore        76
        1798: new           #211                // class ocaml_fn_28
        1801: dup
        1802: aload         75
        1804: invokespecial #212                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1807: astore        77
        1809: new           #214                // class ocaml_fn_29
        1812: dup
        1813: aload         30
        1815: invokespecial #215                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1818: astore        78
        1820: new           #217                // class ocaml_fn_30
        1823: dup
        1824: invokespecial #218                // Method ocaml_fn_30."<init>":()V
        1827: astore        79
        1829: new           #220                // class ocaml_fn_31
        1832: dup
        1833: invokespecial #221                // Method ocaml_fn_31."<init>":()V
        1836: astore        80
        1838: new           #223                // class ocaml_fn_32
        1841: dup
        1842: aload         18
        1844: invokespecial #224                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1847: astore        81
        1849: new           #226                // class ocaml_fn_33
        1852: dup
        1853: aload         18
        1855: invokespecial #227                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1858: astore        82
        1860: new           #229                // class ocaml_fn_34
        1863: dup
        1864: invokespecial #230                // Method ocaml_fn_34."<init>":()V
        1867: astore        83
        1869: new           #232                // class ocaml_fn_35
        1872: dup
        1873: invokespecial #233                // Method ocaml_fn_35."<init>":()V
        1876: astore        84
        1878: new           #235                // class ocaml_fn_36
        1881: dup
        1882: invokespecial #236                // Method ocaml_fn_36."<init>":()V
        1885: astore        85
        1887: new           #238                // class ocaml_fn_37
        1890: dup
        1891: invokespecial #239                // Method ocaml_fn_37."<init>":()V
        1894: astore        86
        1896: new           #241                // class ocaml_fn_38
        1899: dup
        1900: aload         86
        1902: invokespecial #242                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1905: astore        87
        1907: new           #244                // class ocaml_fn_39
        1910: dup
        1911: aload         86
        1913: invokespecial #245                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1916: astore        88
        1918: new           #247                // class ocaml_fn_40
        1921: dup
        1922: aload         18
        1924: invokespecial #248                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1927: astore        89
        1929: new           #250                // class ocaml_fn_41
        1932: dup
        1933: aload         31
        1935: invokespecial #251                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1938: astore        90
        1940: new           #253                // class ocaml_fn_42
        1943: dup
        1944: aload         18
        1946: aload         90
        1948: invokespecial #256                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1951: astore        91
        1953: new           #258                // class ocaml_fn_43
        1956: dup
        1957: aload         91
        1959: invokespecial #259                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1962: astore        92
        1964: new           #261                // class ocaml_fn_44
        1967: dup
        1968: aload         31
        1970: invokespecial #262                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1973: astore        93
        1975: new           #264                // class ocaml_fn_45
        1978: dup
        1979: invokespecial #265                // Method ocaml_fn_45."<init>":()V
        1982: astore        94
        1984: new           #267                // class ocaml_fn_46
        1987: dup
        1988: aload         72
        1990: invokespecial #268                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1993: astore        95
        1995: new           #270                // class ocaml_fn_47
        1998: dup
        1999: aload         72
        2001: aload         80
        2003: invokespecial #271                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2006: astore        96
        2008: new           #273                // class ocaml_fn_48
        2011: dup
        2012: aload         72
        2014: aload         79
        2016: invokespecial #274                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2019: astore        97
        2021: new           #276                // class ocaml_fn_49
        2024: dup
        2025: aload         58
        2027: aload         72
        2029: aload         80
        2031: invokespecial #279                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2034: astore        98
        2036: new           #281                // class ocaml_fn_50
        2039: dup
        2040: aload         61
        2042: aload         72
        2044: aload         80
        2046: invokespecial #282                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2049: astore        99
        2051: new           #284                // class ocaml_fn_51
        2054: dup
        2055: aload         72
        2057: aload         80
        2059: invokespecial #285                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        100
        2064: new           #287                // class ocaml_fn_52
        2067: dup
        2068: aload         72
        2070: invokespecial #288                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2073: astore        101
        2075: new           #290                // class ocaml_fn_53
        2078: dup
        2079: aload         74
        2081: invokespecial #291                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2084: astore        102
        2086: new           #293                // class ocaml_fn_54
        2089: dup
        2090: aload         74
        2092: aload         80
        2094: invokespecial #294                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2097: astore        103
        2099: new           #296                // class ocaml_fn_55
        2102: dup
        2103: aload         74
        2105: aload         79
        2107: invokespecial #297                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2110: astore        104
        2112: new           #299                // class ocaml_fn_56
        2115: dup
        2116: aload         58
        2118: aload         74
        2120: aload         80
        2122: invokespecial #300                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        105
        2127: new           #302                // class ocaml_fn_57
        2130: dup
        2131: aload         61
        2133: aload         74
        2135: aload         80
        2137: invokespecial #303                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2140: astore        106
        2142: new           #305                // class ocaml_fn_58
        2145: dup
        2146: aload         74
        2148: aload         80
        2150: invokespecial #306                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        107
        2155: new           #308                // class ocaml_fn_59
        2158: dup
        2159: aload         74
        2161: invokespecial #309                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2164: astore        108
        2166: new           #311                // class ocaml_fn_60
        2169: dup
        2170: aload         70
        2172: aload         72
        2174: aload         93
        2176: invokespecial #312                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2179: astore        109
        2181: new           #314                // class ocaml_fn_61
        2184: dup
        2185: aload         109
        2187: invokespecial #315                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2190: astore        110
        2192: new           #317                // class ocaml_fn_62
        2195: dup
        2196: aload         59
        2198: aload         109
        2200: invokespecial #318                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2203: astore        111
        2205: new           #320                // class ocaml_fn_63
        2208: dup
        2209: aload         109
        2211: invokespecial #321                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2214: astore        112
        2216: new           #323                // class ocaml_fn_64
        2219: dup
        2220: aload         62
        2222: aload         109
        2224: invokespecial #324                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2227: astore        113
        2229: new           #326                // class ocaml_fn_65
        2232: dup
        2233: invokespecial #327                // Method ocaml_fn_65."<init>":()V
        2236: astore        114
        2238: new           #329                // class ocaml_fn_66
        2241: dup
        2242: aload         53
        2244: invokespecial #330                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2247: astore        115
        2249: new           #2                  // class Block
        2252: dup
        2253: iconst_0
        2254: iconst_1
        2255: anewarray     #4                  // class java/lang/Object
        2258: dup
        2259: iconst_0
        2260: aload         78
        2262: aastore
        2263: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2266: astore        116
        2268: new           #332                // class ocaml_fn_67
        2271: dup
        2272: aload         116
        2274: invokespecial #333                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2277: astore        117
        2279: new           #335                // class ocaml_fn_68
        2282: dup
        2283: invokespecial #336                // Method ocaml_fn_68."<init>":()V
        2286: astore        118
        2288: new           #2                  // class Block
        2291: dup
        2292: iconst_0
        2293: iconst_1
        2294: anewarray     #4                  // class java/lang/Object
        2297: dup
        2298: iconst_0
        2299: aload         118
        2301: aastore
        2302: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2305: astore        119
        2307: new           #338                // class ocaml_fn_69
        2310: dup
        2311: aload         116
        2313: aload         119
        2315: invokespecial #339                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2318: astore        120
        2320: new           #341                // class ocaml_fn_70
        2323: dup
        2324: aload         120
        2326: invokespecial #342                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2329: astore        121
        2331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2334: bipush        44
        2336: aaload
        2337: astore        122
        2339: iconst_0
        2340: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2343: astore        123
        2345: new           #344                // class ocaml_fn_71
        2348: dup
        2349: invokespecial #345                // Method ocaml_fn_71."<init>":()V
        2352: astore        124
        2354: new           #347                // class ocaml_fn_72
        2357: dup
        2358: invokespecial #348                // Method ocaml_fn_72."<init>":()V
        2361: astore        125
        2363: new           #350                // class ocaml_fn_73
        2366: dup
        2367: invokespecial #351                // Method ocaml_fn_73."<init>":()V
        2370: astore        126
        2372: new           #353                // class ocaml_fn_74
        2375: dup
        2376: invokespecial #354                // Method ocaml_fn_74."<init>":()V
        2379: astore        127
        2381: new           #356                // class ocaml_fn_75
        2384: dup
        2385: invokespecial #357                // Method ocaml_fn_75."<init>":()V
        2388: astore        128
        2390: new           #359                // class ocaml_fn_76
        2393: dup
        2394: invokespecial #360                // Method ocaml_fn_76."<init>":()V
        2397: astore        129
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: bipush        6
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         129
        2413: aastore
        2414: dup
        2415: iconst_1
        2416: aload         128
        2418: aastore
        2419: dup
        2420: iconst_2
        2421: aload         127
        2423: aastore
        2424: dup
        2425: iconst_3
        2426: aload         126
        2428: aastore
        2429: dup
        2430: iconst_4
        2431: aload         125
        2433: aastore
        2434: dup
        2435: iconst_5
        2436: aload         124
        2438: aastore
        2439: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2442: astore        130
        2444: new           #362                // class ocaml_fn_77
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_77."<init>":()V
        2451: astore        131
        2453: new           #365                // class ocaml_fn_78
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_78."<init>":()V
        2460: astore        132
        2462: new           #368                // class ocaml_fn_79
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_79."<init>":()V
        2469: astore        133
        2471: new           #371                // class ocaml_fn_80
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_80."<init>":()V
        2478: astore        134
        2480: new           #374                // class ocaml_fn_81
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_81."<init>":()V
        2487: astore        135
        2489: new           #377                // class ocaml_fn_82
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_82."<init>":()V
        2496: astore        136
        2498: new           #380                // class ocaml_fn_83
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_83."<init>":()V
        2505: astore        137
        2507: new           #383                // class ocaml_fn_84
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_84."<init>":()V
        2514: astore        138
        2516: new           #386                // class ocaml_fn_85
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_85."<init>":()V
        2523: astore        139
        2525: new           #389                // class ocaml_fn_86
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_86."<init>":()V
        2532: astore        140
        2534: new           #392                // class ocaml_fn_87
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_87."<init>":()V
        2541: astore        141
        2543: new           #395                // class ocaml_fn_88
        2546: dup
        2547: invokespecial #396                // Method ocaml_fn_88."<init>":()V
        2550: astore        142
        2552: new           #398                // class ocaml_fn_89
        2555: dup
        2556: invokespecial #399                // Method ocaml_fn_89."<init>":()V
        2559: astore        143
        2561: new           #401                // class ocaml_fn_90
        2564: dup
        2565: invokespecial #402                // Method ocaml_fn_90."<init>":()V
        2568: astore        144
        2570: new           #404                // class ocaml_fn_91
        2573: dup
        2574: invokespecial #405                // Method ocaml_fn_91."<init>":()V
        2577: astore        145
        2579: new           #407                // class ocaml_fn_92
        2582: dup
        2583: invokespecial #408                // Method ocaml_fn_92."<init>":()V
        2586: astore        146
        2588: new           #410                // class ocaml_fn_93
        2591: dup
        2592: invokespecial #411                // Method ocaml_fn_93."<init>":()V
        2595: astore        147
        2597: new           #2                  // class Block
        2600: dup
        2601: iconst_0
        2602: bipush        104
        2604: anewarray     #4                  // class java/lang/Object
        2607: dup
        2608: iconst_0
        2609: aload         18
        2611: aastore
        2612: dup
        2613: iconst_1
        2614: aload         17
        2616: aastore
        2617: dup
        2618: iconst_2
        2619: aload         22
        2621: aastore
        2622: dup
        2623: iconst_3
        2624: aload         23
        2626: aastore
        2627: dup
        2628: iconst_4
        2629: aload         24
        2631: aastore
        2632: dup
        2633: iconst_5
        2634: aload         25
        2636: aastore
        2637: dup
        2638: bipush        6
        2640: aload         26
        2642: aastore
        2643: dup
        2644: bipush        7
        2646: aload         27
        2648: aastore
        2649: dup
        2650: bipush        8
        2652: aload         28
        2654: aastore
        2655: dup
        2656: bipush        9
        2658: aload         29
        2660: aastore
        2661: dup
        2662: bipush        10
        2664: aload         30
        2666: aastore
        2667: dup
        2668: bipush        11
        2670: aload         31
        2672: aastore
        2673: dup
        2674: bipush        12
        2676: aload         32
        2678: aastore
        2679: dup
        2680: bipush        13
        2682: aload         33
        2684: aastore
        2685: dup
        2686: bipush        14
        2688: aload         34
        2690: aastore
        2691: dup
        2692: bipush        15
        2694: aload         35
        2696: aastore
        2697: dup
        2698: bipush        16
        2700: aload         36
        2702: aastore
        2703: dup
        2704: bipush        17
        2706: aload         37
        2708: aastore
        2709: dup
        2710: bipush        18
        2712: iload         39
        2714: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2717: aastore
        2718: dup
        2719: bipush        19
        2721: iload         40
        2723: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2726: aastore
        2727: dup
        2728: bipush        20
        2730: aload         38
        2732: aastore
        2733: dup
        2734: bipush        21
        2736: aload         42
        2738: aastore
        2739: dup
        2740: bipush        22
        2742: aload         44
        2744: aastore
        2745: dup
        2746: bipush        23
        2748: aload         46
        2750: aastore
        2751: dup
        2752: bipush        24
        2754: aload         48
        2756: aastore
        2757: dup
        2758: bipush        25
        2760: aload         50
        2762: aastore
        2763: dup
        2764: bipush        26
        2766: aload         52
        2768: aastore
        2769: dup
        2770: bipush        27
        2772: aload         53
        2774: aastore
        2775: dup
        2776: bipush        28
        2778: aload         54
        2780: aastore
        2781: dup
        2782: bipush        29
        2784: aload         55
        2786: aastore
        2787: dup
        2788: bipush        30
        2790: aload         57
        2792: aastore
        2793: dup
        2794: bipush        31
        2796: aload         56
        2798: aastore
        2799: dup
        2800: bipush        32
        2802: aload         58
        2804: aastore
        2805: dup
        2806: bipush        33
        2808: aload         59
        2810: aastore
        2811: dup
        2812: bipush        34
        2814: aload         61
        2816: aastore
        2817: dup
        2818: bipush        35
        2820: aload         62
        2822: aastore
        2823: dup
        2824: bipush        36
        2826: aload         63
        2828: aastore
        2829: dup
        2830: bipush        37
        2832: aload         70
        2834: aastore
        2835: dup
        2836: bipush        38
        2838: aload         72
        2840: aastore
        2841: dup
        2842: bipush        39
        2844: aload         74
        2846: aastore
        2847: dup
        2848: bipush        40
        2850: aload         95
        2852: aastore
        2853: dup
        2854: bipush        41
        2856: aload         96
        2858: aastore
        2859: dup
        2860: bipush        42
        2862: aload         97
        2864: aastore
        2865: dup
        2866: bipush        43
        2868: aload         98
        2870: aastore
        2871: dup
        2872: bipush        44
        2874: aload         99
        2876: aastore
        2877: dup
        2878: bipush        45
        2880: aload         100
        2882: aastore
        2883: dup
        2884: bipush        46
        2886: aload         101
        2888: aastore
        2889: dup
        2890: bipush        47
        2892: aload         102
        2894: aastore
        2895: dup
        2896: bipush        48
        2898: aload         103
        2900: aastore
        2901: dup
        2902: bipush        49
        2904: aload         104
        2906: aastore
        2907: dup
        2908: bipush        50
        2910: aload         105
        2912: aastore
        2913: dup
        2914: bipush        51
        2916: aload         106
        2918: aastore
        2919: dup
        2920: bipush        52
        2922: aload         107
        2924: aastore
        2925: dup
        2926: bipush        53
        2928: aload         108
        2930: aastore
        2931: dup
        2932: bipush        54
        2934: aload         109
        2936: aastore
        2937: dup
        2938: bipush        55
        2940: aload         111
        2942: aastore
        2943: dup
        2944: bipush        56
        2946: aload         110
        2948: aastore
        2949: dup
        2950: bipush        57
        2952: aload         113
        2954: aastore
        2955: dup
        2956: bipush        58
        2958: aload         112
        2960: aastore
        2961: dup
        2962: bipush        59
        2964: aload         76
        2966: aastore
        2967: dup
        2968: bipush        60
        2970: aload         77
        2972: aastore
        2973: dup
        2974: bipush        61
        2976: aload         75
        2978: aastore
        2979: dup
        2980: bipush        62
        2982: aload         147
        2984: aastore
        2985: dup
        2986: bipush        63
        2988: aload         78
        2990: aastore
        2991: dup
        2992: bipush        64
        2994: aload         146
        2996: aastore
        2997: dup
        2998: bipush        65
        3000: aload         80
        3002: aastore
        3003: dup
        3004: bipush        66
        3006: aload         79
        3008: aastore
        3009: dup
        3010: bipush        67
        3012: aload         81
        3014: aastore
        3015: dup
        3016: bipush        68
        3018: aload         82
        3020: aastore
        3021: dup
        3022: bipush        69
        3024: aload         145
        3026: aastore
        3027: dup
        3028: bipush        70
        3030: aload         144
        3032: aastore
        3033: dup
        3034: bipush        71
        3036: aload         83
        3038: aastore
        3039: dup
        3040: bipush        72
        3042: aload         143
        3044: aastore
        3045: dup
        3046: bipush        73
        3048: aload         142
        3050: aastore
        3051: dup
        3052: bipush        74
        3054: aload         141
        3056: aastore
        3057: dup
        3058: bipush        75
        3060: aload         84
        3062: aastore
        3063: dup
        3064: bipush        76
        3066: aload         85
        3068: aastore
        3069: dup
        3070: bipush        77
        3072: aload         140
        3074: aastore
        3075: dup
        3076: bipush        78
        3078: aload         87
        3080: aastore
        3081: dup
        3082: bipush        79
        3084: aload         88
        3086: aastore
        3087: dup
        3088: bipush        80
        3090: aload         86
        3092: aastore
        3093: dup
        3094: bipush        81
        3096: aload         139
        3098: aastore
        3099: dup
        3100: bipush        82
        3102: aload         93
        3104: aastore
        3105: dup
        3106: bipush        83
        3108: aload         89
        3110: aastore
        3111: dup
        3112: bipush        84
        3114: aload         91
        3116: aastore
        3117: dup
        3118: bipush        85
        3120: aload         92
        3122: aastore
        3123: dup
        3124: bipush        86
        3126: aload         138
        3128: aastore
        3129: dup
        3130: bipush        87
        3132: aload         137
        3134: aastore
        3135: dup
        3136: bipush        88
        3138: aload         136
        3140: aastore
        3141: dup
        3142: bipush        89
        3144: aload         135
        3146: aastore
        3147: dup
        3148: bipush        90
        3150: aload         134
        3152: aastore
        3153: dup
        3154: bipush        91
        3156: aload         133
        3158: aastore
        3159: dup
        3160: bipush        92
        3162: aload         132
        3164: aastore
        3165: dup
        3166: bipush        93
        3168: aload         94
        3170: aastore
        3171: dup
        3172: bipush        94
        3174: aload         131
        3176: aastore
        3177: dup
        3178: bipush        95
        3180: aload         130
        3182: aastore
        3183: dup
        3184: bipush        96
        3186: aload         114
        3188: aastore
        3189: dup
        3190: bipush        97
        3192: aload         115
        3194: aastore
        3195: dup
        3196: bipush        98
        3198: aload         121
        3200: aastore
        3201: dup
        3202: bipush        99
        3204: aload         117
        3206: aastore
        3207: dup
        3208: bipush        100
        3210: aload         60
        3212: aastore
        3213: dup
        3214: bipush        101
        3216: aload         90
        3218: aastore
        3219: dup
        3220: bipush        102
        3222: aload         120
        3224: aastore
        3225: dup
        3226: bipush        103
        3228: aload         119
        3230: aastore
        3231: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3234: astore        148
        3236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3239: bipush        45
        3241: aload         148
        3243: aastore
        3244: iconst_0
        3245: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3248: astore        149
        3250: bipush        8
        3252: istore        150
        3254: getstatic     #415                // Field java/lang/System.out:Ljava/io/PrintStream;
        3257: iload         150
        3259: invokevirtual #421                // Method java/io/PrintStream.println:(I)V
        3262: iconst_0
        3263: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3266: astore        151
        3268: new           #2                  // class Block
        3271: dup
        3272: iconst_0
        3273: iconst_0
        3274: anewarray     #4                  // class java/lang/Object
        3277: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3280: astore        152
        3282: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3285: bipush        46
        3287: aload         152
        3289: aastore
        3290: iconst_0
        3291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3294: astore        153
        3296: iconst_0
        3297: istore        154
        3299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3302: bipush        45
        3304: aaload
        3305: checkcast     #2                  // class Block
        3308: getfield      #424                // Field Block.fields:[Ljava/lang/Object;
        3311: bipush        102
        3313: aaload
        3314: astore        155
        3316: aload         155
        3318: checkcast     #188                // class Closure
        3321: iload         154
        3323: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3326: invokevirtual #428                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3329: astore        156
        3331: new           #2                  // class Block
        3334: dup
        3335: iconst_0
        3336: iconst_0
        3337: anewarray     #4                  // class java/lang/Object
        3340: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3343: astore        157
        3345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3348: bipush        47
        3350: aload         157
        3352: aastore
        3353: iconst_0
        3354: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3357: astore        158
        3359: return
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
        1061: aconst_null
        1062: astore_1
        1063: aload_1
        1064: astore_2
        1065: goto_w        1070
        1070: new           #106                // class ocaml_fn_0
        1073: dup
        1074: invokespecial #109                // Method ocaml_fn_0."<init>":()V
        1077: astore_3
        1078: new           #111                // class ocaml_fn_1
        1081: dup
        1082: invokespecial #112                // Method ocaml_fn_1."<init>":()V
        1085: astore        4
        1087: new           #114                // class ocaml_fn_2
        1090: dup
        1091: invokespecial #115                // Method ocaml_fn_2."<init>":()V
        1094: astore        5
        1096: new           #2                  // class Block
        1099: dup
        1100: iconst_0
        1101: iconst_3
        1102: anewarray     #4                  // class java/lang/Object
        1105: dup
        1106: iconst_0
        1107: aload         4
        1109: aastore
        1110: dup
        1111: iconst_1
        1112: aload_3
        1113: aastore
        1114: dup
        1115: iconst_2
        1116: aload         5
        1118: aastore
        1119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1122: astore        6
        1124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        12
        1129: aload         6
        1131: aastore
        1132: iconst_0
        1133: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1136: astore        7
        1138: iconst_0
        1139: istore        8
        1141: iload         8
        1143: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1146: astore        9
        1148: goto_w        1153
        1153: sipush        199
        1156: istore        10
        1158: iconst_0
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        11
        1164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1167: bipush        35
        1169: aaload
        1170: astore        12
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: iconst_3
        1176: aaload
        1177: astore        13
        1179: new           #2                  // class Block
        1182: dup
        1183: iconst_0
        1184: iconst_2
        1185: anewarray     #4                  // class java/lang/Object
        1188: dup
        1189: iconst_0
        1190: aload         13
        1192: aastore
        1193: dup
        1194: iconst_1
        1195: aload         12
        1197: aastore
        1198: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1201: astore        14
        1203: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1206: bipush        36
        1208: aaload
        1209: astore        15
        1211: iconst_0
        1212: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1215: astore        16
        1217: new           #117                // class ocaml_fn_8
        1220: dup
        1221: invokespecial #118                // Method ocaml_fn_8."<init>":()V
        1224: astore        17
        1226: new           #120                // class ocaml_fn_9
        1229: dup
        1230: invokespecial #121                // Method ocaml_fn_9."<init>":()V
        1233: astore        18
        1235: iconst_0
        1236: istore        19
        1238: iconst_0
        1239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1242: astore        20
        1244: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1247: bipush        37
        1249: aaload
        1250: astore        21
        1252: new           #2                  // class Block
        1255: dup
        1256: sipush        248
        1259: iconst_2
        1260: anewarray     #4                  // class java/lang/Object
        1263: dup
        1264: iconst_0
        1265: aload         21
        1267: aastore
        1268: dup
        1269: iconst_1
        1270: aload         20
        1272: aastore
        1273: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1276: astore        22
        1278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1281: bipush        7
        1283: aaload
        1284: astore        23
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        10
        1291: aaload
        1292: astore        24
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: iconst_3
        1298: aaload
        1299: astore        25
        1301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1304: iconst_2
        1305: aaload
        1306: astore        26
        1308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1311: bipush        6
        1313: aaload
        1314: astore        27
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: iconst_0
        1320: aaload
        1321: astore        28
        1323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1326: bipush        8
        1328: aaload
        1329: astore        29
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: iconst_1
        1335: aaload
        1336: astore        30
        1338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1341: iconst_4
        1342: aaload
        1343: astore        31
        1345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1348: iconst_5
        1349: aaload
        1350: astore        32
        1352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1355: bipush        9
        1357: aaload
        1358: astore        33
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        11
        1365: aaload
        1366: astore        34
        1368: new           #123                // class ocaml_fn_10
        1371: dup
        1372: invokespecial #124                // Method ocaml_fn_10."<init>":()V
        1375: astore        35
        1377: new           #126                // class ocaml_fn_11
        1380: dup
        1381: invokespecial #127                // Method ocaml_fn_11."<init>":()V
        1384: astore        36
        1386: new           #129                // class ocaml_fn_12
        1389: dup
        1390: invokespecial #130                // Method ocaml_fn_12."<init>":()V
        1393: astore        37
        1395: new           #132                // class ocaml_fn_13
        1398: dup
        1399: invokespecial #133                // Method ocaml_fn_13."<init>":()V
        1402: astore        38
        1404: ldc           #134                // int 2147483647
        1406: istore        39
        1408: ldc           #135                // int -2147483648
        1410: istore        40
        1412: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1415: bipush        38
        1417: aaload
        1418: astore        41
        1420: aload         41
        1422: checkcast     #89                 // class java/lang/Long
        1425: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1428: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1431: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        42
        1436: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        39
        1441: aaload
        1442: astore        43
        1444: aload         43
        1446: checkcast     #89                 // class java/lang/Long
        1449: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1452: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1455: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1458: astore        44
        1460: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1463: bipush        40
        1465: aaload
        1466: astore        45
        1468: aload         45
        1470: checkcast     #89                 // class java/lang/Long
        1473: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1476: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1479: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1482: astore        46
        1484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1487: bipush        41
        1489: aaload
        1490: astore        47
        1492: aload         47
        1494: checkcast     #89                 // class java/lang/Long
        1497: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1500: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1503: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1506: astore        48
        1508: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1511: bipush        42
        1513: aaload
        1514: astore        49
        1516: aload         49
        1518: checkcast     #89                 // class java/lang/Long
        1521: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1524: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1527: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1530: astore        50
        1532: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1535: bipush        43
        1537: aaload
        1538: astore        51
        1540: aload         51
        1542: checkcast     #89                 // class java/lang/Long
        1545: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1548: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1551: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1554: astore        52
        1556: new           #150                // class ocaml_fn_14
        1559: dup
        1560: invokespecial #151                // Method ocaml_fn_14."<init>":()V
        1563: astore        53
        1565: new           #153                // class ocaml_fn_15
        1568: dup
        1569: aload         18
        1571: invokespecial #156                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1574: astore        54
        1576: new           #158                // class ocaml_fn_16
        1579: dup
        1580: invokespecial #159                // Method ocaml_fn_16."<init>":()V
        1583: astore        55
        1585: new           #161                // class ocaml_fn_17
        1588: dup
        1589: aload         18
        1591: invokespecial #162                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1594: astore        56
        1596: new           #164                // class ocaml_fn_18
        1599: dup
        1600: invokespecial #165                // Method ocaml_fn_18."<init>":()V
        1603: astore        57
        1605: new           #167                // class ocaml_fn_19
        1608: dup
        1609: invokespecial #168                // Method ocaml_fn_19."<init>":()V
        1612: astore        58
        1614: new           #170                // class ocaml_fn_20
        1617: dup
        1618: aload         26
        1620: invokespecial #171                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1623: astore        59
        1625: new           #173                // class ocaml_fn_21
        1628: dup
        1629: aload         53
        1631: invokespecial #174                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1634: astore        60
        1636: new           #176                // class ocaml_fn_22
        1639: dup
        1640: aload         60
        1642: invokespecial #177                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1645: astore        61
        1647: new           #179                // class ocaml_fn_23
        1650: dup
        1651: aload         26
        1653: invokespecial #180                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1656: astore        62
        1658: new           #182                // class ocaml_fn_24
        1661: dup
        1662: invokespecial #183                // Method ocaml_fn_24."<init>":()V
        1665: astore        63
        1667: new           #185                // class ocaml_fn_25
        1670: dup
        1671: invokespecial #186                // Method ocaml_fn_25."<init>":()V
        1674: astore        64
        1676: aload         63
        1678: checkcast     #182                // class ocaml_fn_24
        1681: aload         63
        1683: checkcast     #188                // class Closure
        1686: putfield      #192                // Field ocaml_fn_24.sibling_0:LClosure;
        1689: iconst_0
        1690: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1693: astore        65
        1695: aload         63
        1697: checkcast     #182                // class ocaml_fn_24
        1700: aload         64
        1702: checkcast     #188                // class Closure
        1705: putfield      #195                // Field ocaml_fn_24.sibling_1:LClosure;
        1708: iconst_0
        1709: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1712: astore        66
        1714: aload         64
        1716: checkcast     #185                // class ocaml_fn_25
        1719: aload         63
        1721: checkcast     #188                // class Closure
        1724: putfield      #196                // Field ocaml_fn_25.sibling_0:LClosure;
        1727: iconst_0
        1728: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1731: astore        67
        1733: aload         64
        1735: checkcast     #185                // class ocaml_fn_25
        1738: aload         64
        1740: checkcast     #188                // class Closure
        1743: putfield      #197                // Field ocaml_fn_25.sibling_1:LClosure;
        1746: iconst_0
        1747: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1750: astore        68
        1752: iconst_0
        1753: istore        69
        1755: aconst_null
        1756: astore        70
        1758: iconst_1
        1759: istore        71
        1761: iload         71
        1763: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1766: astore        72
        1768: iconst_2
        1769: istore        73
        1771: iload         73
        1773: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        74
        1778: new           #205                // class ocaml_fn_26
        1781: dup
        1782: invokespecial #206                // Method ocaml_fn_26."<init>":()V
        1785: astore        75
        1787: new           #208                // class ocaml_fn_27
        1790: dup
        1791: aload         75
        1793: invokespecial #209                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1796: astore        76
        1798: new           #211                // class ocaml_fn_28
        1801: dup
        1802: aload         75
        1804: invokespecial #212                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1807: astore        77
        1809: new           #214                // class ocaml_fn_29
        1812: dup
        1813: aload         30
        1815: invokespecial #215                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1818: astore        78
        1820: new           #217                // class ocaml_fn_30
        1823: dup
        1824: invokespecial #218                // Method ocaml_fn_30."<init>":()V
        1827: astore        79
        1829: new           #220                // class ocaml_fn_31
        1832: dup
        1833: invokespecial #221                // Method ocaml_fn_31."<init>":()V
        1836: astore        80
        1838: new           #223                // class ocaml_fn_32
        1841: dup
        1842: aload         18
        1844: invokespecial #224                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1847: astore        81
        1849: new           #226                // class ocaml_fn_33
        1852: dup
        1853: aload         18
        1855: invokespecial #227                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1858: astore        82
        1860: new           #229                // class ocaml_fn_34
        1863: dup
        1864: invokespecial #230                // Method ocaml_fn_34."<init>":()V
        1867: astore        83
        1869: new           #232                // class ocaml_fn_35
        1872: dup
        1873: invokespecial #233                // Method ocaml_fn_35."<init>":()V
        1876: astore        84
        1878: new           #235                // class ocaml_fn_36
        1881: dup
        1882: invokespecial #236                // Method ocaml_fn_36."<init>":()V
        1885: astore        85
        1887: new           #238                // class ocaml_fn_37
        1890: dup
        1891: invokespecial #239                // Method ocaml_fn_37."<init>":()V
        1894: astore        86
        1896: new           #241                // class ocaml_fn_38
        1899: dup
        1900: aload         86
        1902: invokespecial #242                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1905: astore        87
        1907: new           #244                // class ocaml_fn_39
        1910: dup
        1911: aload         86
        1913: invokespecial #245                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1916: astore        88
        1918: new           #247                // class ocaml_fn_40
        1921: dup
        1922: aload         18
        1924: invokespecial #248                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1927: astore        89
        1929: new           #250                // class ocaml_fn_41
        1932: dup
        1933: aload         31
        1935: invokespecial #251                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1938: astore        90
        1940: new           #253                // class ocaml_fn_42
        1943: dup
        1944: aload         18
        1946: aload         90
        1948: invokespecial #256                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1951: astore        91
        1953: new           #258                // class ocaml_fn_43
        1956: dup
        1957: aload         91
        1959: invokespecial #259                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1962: astore        92
        1964: new           #261                // class ocaml_fn_44
        1967: dup
        1968: aload         31
        1970: invokespecial #262                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1973: astore        93
        1975: new           #264                // class ocaml_fn_45
        1978: dup
        1979: invokespecial #265                // Method ocaml_fn_45."<init>":()V
        1982: astore        94
        1984: new           #267                // class ocaml_fn_46
        1987: dup
        1988: aload         72
        1990: invokespecial #268                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1993: astore        95
        1995: new           #270                // class ocaml_fn_47
        1998: dup
        1999: aload         72
        2001: aload         80
        2003: invokespecial #271                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2006: astore        96
        2008: new           #273                // class ocaml_fn_48
        2011: dup
        2012: aload         72
        2014: aload         79
        2016: invokespecial #274                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2019: astore        97
        2021: new           #276                // class ocaml_fn_49
        2024: dup
        2025: aload         58
        2027: aload         72
        2029: aload         80
        2031: invokespecial #279                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2034: astore        98
        2036: new           #281                // class ocaml_fn_50
        2039: dup
        2040: aload         61
        2042: aload         72
        2044: aload         80
        2046: invokespecial #282                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2049: astore        99
        2051: new           #284                // class ocaml_fn_51
        2054: dup
        2055: aload         72
        2057: aload         80
        2059: invokespecial #285                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        100
        2064: new           #287                // class ocaml_fn_52
        2067: dup
        2068: aload         72
        2070: invokespecial #288                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2073: astore        101
        2075: new           #290                // class ocaml_fn_53
        2078: dup
        2079: aload         74
        2081: invokespecial #291                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2084: astore        102
        2086: new           #293                // class ocaml_fn_54
        2089: dup
        2090: aload         74
        2092: aload         80
        2094: invokespecial #294                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2097: astore        103
        2099: new           #296                // class ocaml_fn_55
        2102: dup
        2103: aload         74
        2105: aload         79
        2107: invokespecial #297                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2110: astore        104
        2112: new           #299                // class ocaml_fn_56
        2115: dup
        2116: aload         58
        2118: aload         74
        2120: aload         80
        2122: invokespecial #300                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        105
        2127: new           #302                // class ocaml_fn_57
        2130: dup
        2131: aload         61
        2133: aload         74
        2135: aload         80
        2137: invokespecial #303                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2140: astore        106
        2142: new           #305                // class ocaml_fn_58
        2145: dup
        2146: aload         74
        2148: aload         80
        2150: invokespecial #306                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        107
        2155: new           #308                // class ocaml_fn_59
        2158: dup
        2159: aload         74
        2161: invokespecial #309                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2164: astore        108
        2166: new           #311                // class ocaml_fn_60
        2169: dup
        2170: aload         70
        2172: aload         72
        2174: aload         93
        2176: invokespecial #312                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2179: astore        109
        2181: new           #314                // class ocaml_fn_61
        2184: dup
        2185: aload         109
        2187: invokespecial #315                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2190: astore        110
        2192: new           #317                // class ocaml_fn_62
        2195: dup
        2196: aload         59
        2198: aload         109
        2200: invokespecial #318                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2203: astore        111
        2205: new           #320                // class ocaml_fn_63
        2208: dup
        2209: aload         109
        2211: invokespecial #321                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2214: astore        112
        2216: new           #323                // class ocaml_fn_64
        2219: dup
        2220: aload         62
        2222: aload         109
        2224: invokespecial #324                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2227: astore        113
        2229: new           #326                // class ocaml_fn_65
        2232: dup
        2233: invokespecial #327                // Method ocaml_fn_65."<init>":()V
        2236: astore        114
        2238: new           #329                // class ocaml_fn_66
        2241: dup
        2242: aload         53
        2244: invokespecial #330                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2247: astore        115
        2249: new           #2                  // class Block
        2252: dup
        2253: iconst_0
        2254: iconst_1
        2255: anewarray     #4                  // class java/lang/Object
        2258: dup
        2259: iconst_0
        2260: aload         78
        2262: aastore
        2263: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2266: astore        116
        2268: new           #332                // class ocaml_fn_67
        2271: dup
        2272: aload         116
        2274: invokespecial #333                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2277: astore        117
        2279: new           #335                // class ocaml_fn_68
        2282: dup
        2283: invokespecial #336                // Method ocaml_fn_68."<init>":()V
        2286: astore        118
        2288: new           #2                  // class Block
        2291: dup
        2292: iconst_0
        2293: iconst_1
        2294: anewarray     #4                  // class java/lang/Object
        2297: dup
        2298: iconst_0
        2299: aload         118
        2301: aastore
        2302: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2305: astore        119
        2307: new           #338                // class ocaml_fn_69
        2310: dup
        2311: aload         116
        2313: aload         119
        2315: invokespecial #339                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2318: astore        120
        2320: new           #341                // class ocaml_fn_70
        2323: dup
        2324: aload         120
        2326: invokespecial #342                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2329: astore        121
        2331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2334: bipush        44
        2336: aaload
        2337: astore        122
        2339: iconst_0
        2340: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2343: astore        123
        2345: new           #344                // class ocaml_fn_71
        2348: dup
        2349: invokespecial #345                // Method ocaml_fn_71."<init>":()V
        2352: astore        124
        2354: new           #347                // class ocaml_fn_72
        2357: dup
        2358: invokespecial #348                // Method ocaml_fn_72."<init>":()V
        2361: astore        125
        2363: new           #350                // class ocaml_fn_73
        2366: dup
        2367: invokespecial #351                // Method ocaml_fn_73."<init>":()V
        2370: astore        126
        2372: new           #353                // class ocaml_fn_74
        2375: dup
        2376: invokespecial #354                // Method ocaml_fn_74."<init>":()V
        2379: astore        127
        2381: new           #356                // class ocaml_fn_75
        2384: dup
        2385: invokespecial #357                // Method ocaml_fn_75."<init>":()V
        2388: astore        128
        2390: new           #359                // class ocaml_fn_76
        2393: dup
        2394: invokespecial #360                // Method ocaml_fn_76."<init>":()V
        2397: astore        129
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: bipush        6
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         129
        2413: aastore
        2414: dup
        2415: iconst_1
        2416: aload         128
        2418: aastore
        2419: dup
        2420: iconst_2
        2421: aload         127
        2423: aastore
        2424: dup
        2425: iconst_3
        2426: aload         126
        2428: aastore
        2429: dup
        2430: iconst_4
        2431: aload         125
        2433: aastore
        2434: dup
        2435: iconst_5
        2436: aload         124
        2438: aastore
        2439: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2442: astore        130
        2444: new           #362                // class ocaml_fn_77
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_77."<init>":()V
        2451: astore        131
        2453: new           #365                // class ocaml_fn_78
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_78."<init>":()V
        2460: astore        132
        2462: new           #368                // class ocaml_fn_79
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_79."<init>":()V
        2469: astore        133
        2471: new           #371                // class ocaml_fn_80
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_80."<init>":()V
        2478: astore        134
        2480: new           #374                // class ocaml_fn_81
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_81."<init>":()V
        2487: astore        135
        2489: new           #377                // class ocaml_fn_82
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_82."<init>":()V
        2496: astore        136
        2498: new           #380                // class ocaml_fn_83
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_83."<init>":()V
        2505: astore        137
        2507: new           #383                // class ocaml_fn_84
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_84."<init>":()V
        2514: astore        138
        2516: new           #386                // class ocaml_fn_85
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_85."<init>":()V
        2523: astore        139
        2525: new           #389                // class ocaml_fn_86
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_86."<init>":()V
        2532: astore        140
        2534: new           #392                // class ocaml_fn_87
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_87."<init>":()V
        2541: astore        141
        2543: new           #395                // class ocaml_fn_88
        2546: dup
        2547: invokespecial #396                // Method ocaml_fn_88."<init>":()V
        2550: astore        142
        2552: new           #398                // class ocaml_fn_89
        2555: dup
        2556: invokespecial #399                // Method ocaml_fn_89."<init>":()V
        2559: astore        143
        2561: new           #401                // class ocaml_fn_90
        2564: dup
        2565: invokespecial #402                // Method ocaml_fn_90."<init>":()V
        2568: astore        144
        2570: new           #404                // class ocaml_fn_91
        2573: dup
        2574: invokespecial #405                // Method ocaml_fn_91."<init>":()V
        2577: astore        145
        2579: new           #407                // class ocaml_fn_92
        2582: dup
        2583: invokespecial #408                // Method ocaml_fn_92."<init>":()V
        2586: astore        146
        2588: new           #410                // class ocaml_fn_93
        2591: dup
        2592: invokespecial #411                // Method ocaml_fn_93."<init>":()V
        2595: astore        147
        2597: new           #2                  // class Block
        2600: dup
        2601: iconst_0
        2602: bipush        104
        2604: anewarray     #4                  // class java/lang/Object
        2607: dup
        2608: iconst_0
        2609: aload         18
        2611: aastore
        2612: dup
        2613: iconst_1
        2614: aload         17
        2616: aastore
        2617: dup
        2618: iconst_2
        2619: aload         22
        2621: aastore
        2622: dup
        2623: iconst_3
        2624: aload         23
        2626: aastore
        2627: dup
        2628: iconst_4
        2629: aload         24
        2631: aastore
        2632: dup
        2633: iconst_5
        2634: aload         25
        2636: aastore
        2637: dup
        2638: bipush        6
        2640: aload         26
        2642: aastore
        2643: dup
        2644: bipush        7
        2646: aload         27
        2648: aastore
        2649: dup
        2650: bipush        8
        2652: aload         28
        2654: aastore
        2655: dup
        2656: bipush        9
        2658: aload         29
        2660: aastore
        2661: dup
        2662: bipush        10
        2664: aload         30
        2666: aastore
        2667: dup
        2668: bipush        11
        2670: aload         31
        2672: aastore
        2673: dup
        2674: bipush        12
        2676: aload         32
        2678: aastore
        2679: dup
        2680: bipush        13
        2682: aload         33
        2684: aastore
        2685: dup
        2686: bipush        14
        2688: aload         34
        2690: aastore
        2691: dup
        2692: bipush        15
        2694: aload         35
        2696: aastore
        2697: dup
        2698: bipush        16
        2700: aload         36
        2702: aastore
        2703: dup
        2704: bipush        17
        2706: aload         37
        2708: aastore
        2709: dup
        2710: bipush        18
        2712: iload         39
        2714: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2717: aastore
        2718: dup
        2719: bipush        19
        2721: iload         40
        2723: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2726: aastore
        2727: dup
        2728: bipush        20
        2730: aload         38
        2732: aastore
        2733: dup
        2734: bipush        21
        2736: aload         42
        2738: aastore
        2739: dup
        2740: bipush        22
        2742: aload         44
        2744: aastore
        2745: dup
        2746: bipush        23
        2748: aload         46
        2750: aastore
        2751: dup
        2752: bipush        24
        2754: aload         48
        2756: aastore
        2757: dup
        2758: bipush        25
        2760: aload         50
        2762: aastore
        2763: dup
        2764: bipush        26
        2766: aload         52
        2768: aastore
        2769: dup
        2770: bipush        27
        2772: aload         53
        2774: aastore
        2775: dup
        2776: bipush        28
        2778: aload         54
        2780: aastore
        2781: dup
        2782: bipush        29
        2784: aload         55
        2786: aastore
        2787: dup
        2788: bipush        30
        2790: aload         57
        2792: aastore
        2793: dup
        2794: bipush        31
        2796: aload         56
        2798: aastore
        2799: dup
        2800: bipush        32
        2802: aload         58
        2804: aastore
        2805: dup
        2806: bipush        33
        2808: aload         59
        2810: aastore
        2811: dup
        2812: bipush        34
        2814: aload         61
        2816: aastore
        2817: dup
        2818: bipush        35
        2820: aload         62
        2822: aastore
        2823: dup
        2824: bipush        36
        2826: aload         63
        2828: aastore
        2829: dup
        2830: bipush        37
        2832: aload         70
        2834: aastore
        2835: dup
        2836: bipush        38
        2838: aload         72
        2840: aastore
        2841: dup
        2842: bipush        39
        2844: aload         74
        2846: aastore
        2847: dup
        2848: bipush        40
        2850: aload         95
        2852: aastore
        2853: dup
        2854: bipush        41
        2856: aload         96
        2858: aastore
        2859: dup
        2860: bipush        42
        2862: aload         97
        2864: aastore
        2865: dup
        2866: bipush        43
        2868: aload         98
        2870: aastore
        2871: dup
        2872: bipush        44
        2874: aload         99
        2876: aastore
        2877: dup
        2878: bipush        45
        2880: aload         100
        2882: aastore
        2883: dup
        2884: bipush        46
        2886: aload         101
        2888: aastore
        2889: dup
        2890: bipush        47
        2892: aload         102
        2894: aastore
        2895: dup
        2896: bipush        48
        2898: aload         103
        2900: aastore
        2901: dup
        2902: bipush        49
        2904: aload         104
        2906: aastore
        2907: dup
        2908: bipush        50
        2910: aload         105
        2912: aastore
        2913: dup
        2914: bipush        51
        2916: aload         106
        2918: aastore
        2919: dup
        2920: bipush        52
        2922: aload         107
        2924: aastore
        2925: dup
        2926: bipush        53
        2928: aload         108
        2930: aastore
        2931: dup
        2932: bipush        54
        2934: aload         109
        2936: aastore
        2937: dup
        2938: bipush        55
        2940: aload         111
        2942: aastore
        2943: dup
        2944: bipush        56
        2946: aload         110
        2948: aastore
        2949: dup
        2950: bipush        57
        2952: aload         113
        2954: aastore
        2955: dup
        2956: bipush        58
        2958: aload         112
        2960: aastore
        2961: dup
        2962: bipush        59
        2964: aload         76
        2966: aastore
        2967: dup
        2968: bipush        60
        2970: aload         77
        2972: aastore
        2973: dup
        2974: bipush        61
        2976: aload         75
        2978: aastore
        2979: dup
        2980: bipush        62
        2982: aload         147
        2984: aastore
        2985: dup
        2986: bipush        63
        2988: aload         78
        2990: aastore
        2991: dup
        2992: bipush        64
        2994: aload         146
        2996: aastore
        2997: dup
        2998: bipush        65
        3000: aload         80
        3002: aastore
        3003: dup
        3004: bipush        66
        3006: aload         79
        3008: aastore
        3009: dup
        3010: bipush        67
        3012: aload         81
        3014: aastore
        3015: dup
        3016: bipush        68
        3018: aload         82
        3020: aastore
        3021: dup
        3022: bipush        69
        3024: aload         145
        3026: aastore
        3027: dup
        3028: bipush        70
        3030: aload         144
        3032: aastore
        3033: dup
        3034: bipush        71
        3036: aload         83
        3038: aastore
        3039: dup
        3040: bipush        72
        3042: aload         143
        3044: aastore
        3045: dup
        3046: bipush        73
        3048: aload         142
        3050: aastore
        3051: dup
        3052: bipush        74
        3054: aload         141
        3056: aastore
        3057: dup
        3058: bipush        75
        3060: aload         84
        3062: aastore
        3063: dup
        3064: bipush        76
        3066: aload         85
        3068: aastore
        3069: dup
        3070: bipush        77
        3072: aload         140
        3074: aastore
        3075: dup
        3076: bipush        78
        3078: aload         87
        3080: aastore
        3081: dup
        3082: bipush        79
        3084: aload         88
        3086: aastore
        3087: dup
        3088: bipush        80
        3090: aload         86
        3092: aastore
        3093: dup
        3094: bipush        81
        3096: aload         139
        3098: aastore
        3099: dup
        3100: bipush        82
        3102: aload         93
        3104: aastore
        3105: dup
        3106: bipush        83
        3108: aload         89
        3110: aastore
        3111: dup
        3112: bipush        84
        3114: aload         91
        3116: aastore
        3117: dup
        3118: bipush        85
        3120: aload         92
        3122: aastore
        3123: dup
        3124: bipush        86
        3126: aload         138
        3128: aastore
        3129: dup
        3130: bipush        87
        3132: aload         137
        3134: aastore
        3135: dup
        3136: bipush        88
        3138: aload         136
        3140: aastore
        3141: dup
        3142: bipush        89
        3144: aload         135
        3146: aastore
        3147: dup
        3148: bipush        90
        3150: aload         134
        3152: aastore
        3153: dup
        3154: bipush        91
        3156: aload         133
        3158: aastore
        3159: dup
        3160: bipush        92
        3162: aload         132
        3164: aastore
        3165: dup
        3166: bipush        93
        3168: aload         94
        3170: aastore
        3171: dup
        3172: bipush        94
        3174: aload         131
        3176: aastore
        3177: dup
        3178: bipush        95
        3180: aload         130
        3182: aastore
        3183: dup
        3184: bipush        96
        3186: aload         114
        3188: aastore
        3189: dup
        3190: bipush        97
        3192: aload         115
        3194: aastore
        3195: dup
        3196: bipush        98
        3198: aload         121
        3200: aastore
        3201: dup
        3202: bipush        99
        3204: aload         117
        3206: aastore
        3207: dup
        3208: bipush        100
        3210: aload         60
        3212: aastore
        3213: dup
        3214: bipush        101
        3216: aload         90
        3218: aastore
        3219: dup
        3220: bipush        102
        3222: aload         120
        3224: aastore
        3225: dup
        3226: bipush        103
        3228: aload         119
        3230: aastore
        3231: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3234: astore        148
        3236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3239: bipush        45
        3241: aload         148
        3243: aastore
        3244: iconst_0
        3245: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3248: astore        149
        3250: iconst_0
        3251: istore        150
        3253: iload         150
        3255: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3258: astore        151
        3260: goto_w        3265
        3265: new           #413                // class ocaml_fn_95
        3268: dup
        3269: invokespecial #414                // Method ocaml_fn_95."<init>":()V
        3272: astore        152
        3274: bipush        10
        3276: istore        153
        3278: aload         152
        3280: iload         153
        3282: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3285: invokevirtual #418                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3288: astore        154
        3290: bipush        32
        3292: istore        155
        3294: aload         154
        3296: checkcast     #188                // class Closure
        3299: iload         155
        3301: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3304: invokevirtual #418                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3307: astore        156
        3309: getstatic     #422                // Field java/lang/System.out:Ljava/io/PrintStream;
        3312: aload         156
        3314: checkcast     #29                 // class java/lang/Integer
        3317: invokevirtual #426                // Method java/lang/Integer.intValue:()I
        3320: invokevirtual #432                // Method java/io/PrintStream.println:(I)V
        3323: iconst_0
        3324: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3327: astore        157
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
        3346: astore        158
        3348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3351: bipush        46
        3353: aload         158
        3355: aastore
        3356: iconst_0
        3357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3360: astore        159
        3362: iconst_0
        3363: istore        160
        3365: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3368: bipush        45
        3370: aaload
        3371: checkcast     #2                  // class Block
        3374: getfield      #435                // Field Block.fields:[Ljava/lang/Object;
        3377: bipush        102
        3379: aaload
        3380: astore        161
        3382: aload         161
        3384: checkcast     #188                // class Closure
        3387: iload         160
        3389: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3392: invokevirtual #418                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3395: astore        162
        3397: new           #2                  // class Block
        3400: dup
        3401: iconst_0
        3402: iconst_0
        3403: anewarray     #4                  // class java/lang/Object
        3406: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3409: astore        163
        3411: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3414: bipush        47
        3416: aload         163
        3418: aastore
        3419: iconst_0
        3420: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3423: astore        164
        3425: return
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
        1087: aconst_null
        1088: astore_1
        1089: aload_1
        1090: astore_2
        1091: goto_w        1096
        1096: new           #106                // class ocaml_fn_0
        1099: dup
        1100: invokespecial #109                // Method ocaml_fn_0."<init>":()V
        1103: astore_3
        1104: new           #111                // class ocaml_fn_1
        1107: dup
        1108: invokespecial #112                // Method ocaml_fn_1."<init>":()V
        1111: astore        4
        1113: new           #114                // class ocaml_fn_2
        1116: dup
        1117: invokespecial #115                // Method ocaml_fn_2."<init>":()V
        1120: astore        5
        1122: new           #2                  // class Block
        1125: dup
        1126: iconst_0
        1127: iconst_3
        1128: anewarray     #4                  // class java/lang/Object
        1131: dup
        1132: iconst_0
        1133: aload         4
        1135: aastore
        1136: dup
        1137: iconst_1
        1138: aload_3
        1139: aastore
        1140: dup
        1141: iconst_2
        1142: aload         5
        1144: aastore
        1145: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1148: astore        6
        1150: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1153: bipush        12
        1155: aload         6
        1157: aastore
        1158: iconst_0
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        7
        1164: iconst_0
        1165: istore        8
        1167: iload         8
        1169: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1172: astore        9
        1174: goto_w        1179
        1179: sipush        199
        1182: istore        10
        1184: iconst_0
        1185: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1188: astore        11
        1190: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1193: bipush        35
        1195: aaload
        1196: astore        12
        1198: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1201: iconst_3
        1202: aaload
        1203: astore        13
        1205: new           #2                  // class Block
        1208: dup
        1209: iconst_0
        1210: iconst_2
        1211: anewarray     #4                  // class java/lang/Object
        1214: dup
        1215: iconst_0
        1216: aload         13
        1218: aastore
        1219: dup
        1220: iconst_1
        1221: aload         12
        1223: aastore
        1224: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1227: astore        14
        1229: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1232: bipush        36
        1234: aaload
        1235: astore        15
        1237: iconst_0
        1238: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1241: astore        16
        1243: new           #117                // class ocaml_fn_8
        1246: dup
        1247: invokespecial #118                // Method ocaml_fn_8."<init>":()V
        1250: astore        17
        1252: new           #120                // class ocaml_fn_9
        1255: dup
        1256: invokespecial #121                // Method ocaml_fn_9."<init>":()V
        1259: astore        18
        1261: iconst_0
        1262: istore        19
        1264: iconst_0
        1265: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1268: astore        20
        1270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1273: bipush        37
        1275: aaload
        1276: astore        21
        1278: new           #2                  // class Block
        1281: dup
        1282: sipush        248
        1285: iconst_2
        1286: anewarray     #4                  // class java/lang/Object
        1289: dup
        1290: iconst_0
        1291: aload         21
        1293: aastore
        1294: dup
        1295: iconst_1
        1296: aload         20
        1298: aastore
        1299: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1302: astore        22
        1304: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1307: bipush        7
        1309: aaload
        1310: astore        23
        1312: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1315: bipush        10
        1317: aaload
        1318: astore        24
        1320: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1323: iconst_3
        1324: aaload
        1325: astore        25
        1327: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1330: iconst_2
        1331: aaload
        1332: astore        26
        1334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1337: bipush        6
        1339: aaload
        1340: astore        27
        1342: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1345: iconst_0
        1346: aaload
        1347: astore        28
        1349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1352: bipush        8
        1354: aaload
        1355: astore        29
        1357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1360: iconst_1
        1361: aaload
        1362: astore        30
        1364: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1367: iconst_4
        1368: aaload
        1369: astore        31
        1371: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1374: iconst_5
        1375: aaload
        1376: astore        32
        1378: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1381: bipush        9
        1383: aaload
        1384: astore        33
        1386: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1389: bipush        11
        1391: aaload
        1392: astore        34
        1394: new           #123                // class ocaml_fn_10
        1397: dup
        1398: invokespecial #124                // Method ocaml_fn_10."<init>":()V
        1401: astore        35
        1403: new           #126                // class ocaml_fn_11
        1406: dup
        1407: invokespecial #127                // Method ocaml_fn_11."<init>":()V
        1410: astore        36
        1412: new           #129                // class ocaml_fn_12
        1415: dup
        1416: invokespecial #130                // Method ocaml_fn_12."<init>":()V
        1419: astore        37
        1421: new           #132                // class ocaml_fn_13
        1424: dup
        1425: invokespecial #133                // Method ocaml_fn_13."<init>":()V
        1428: astore        38
        1430: ldc           #134                // int 2147483647
        1432: istore        39
        1434: ldc           #135                // int -2147483648
        1436: istore        40
        1438: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1441: bipush        38
        1443: aaload
        1444: astore        41
        1446: aload         41
        1448: checkcast     #89                 // class java/lang/Long
        1451: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1454: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1457: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        42
        1462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        39
        1467: aaload
        1468: astore        43
        1470: aload         43
        1472: checkcast     #89                 // class java/lang/Long
        1475: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1478: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1481: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1484: astore        44
        1486: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1489: bipush        40
        1491: aaload
        1492: astore        45
        1494: aload         45
        1496: checkcast     #89                 // class java/lang/Long
        1499: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1502: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1505: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1508: astore        46
        1510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1513: bipush        41
        1515: aaload
        1516: astore        47
        1518: aload         47
        1520: checkcast     #89                 // class java/lang/Long
        1523: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1526: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1529: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1532: astore        48
        1534: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1537: bipush        42
        1539: aaload
        1540: astore        49
        1542: aload         49
        1544: checkcast     #89                 // class java/lang/Long
        1547: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1550: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1553: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1556: astore        50
        1558: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1561: bipush        43
        1563: aaload
        1564: astore        51
        1566: aload         51
        1568: checkcast     #89                 // class java/lang/Long
        1571: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1574: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1577: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1580: astore        52
        1582: new           #150                // class ocaml_fn_14
        1585: dup
        1586: invokespecial #151                // Method ocaml_fn_14."<init>":()V
        1589: astore        53
        1591: new           #153                // class ocaml_fn_15
        1594: dup
        1595: aload         18
        1597: invokespecial #156                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1600: astore        54
        1602: new           #158                // class ocaml_fn_16
        1605: dup
        1606: invokespecial #159                // Method ocaml_fn_16."<init>":()V
        1609: astore        55
        1611: new           #161                // class ocaml_fn_17
        1614: dup
        1615: aload         18
        1617: invokespecial #162                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1620: astore        56
        1622: new           #164                // class ocaml_fn_18
        1625: dup
        1626: invokespecial #165                // Method ocaml_fn_18."<init>":()V
        1629: astore        57
        1631: new           #167                // class ocaml_fn_19
        1634: dup
        1635: invokespecial #168                // Method ocaml_fn_19."<init>":()V
        1638: astore        58
        1640: new           #170                // class ocaml_fn_20
        1643: dup
        1644: aload         26
        1646: invokespecial #171                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1649: astore        59
        1651: new           #173                // class ocaml_fn_21
        1654: dup
        1655: aload         53
        1657: invokespecial #174                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1660: astore        60
        1662: new           #176                // class ocaml_fn_22
        1665: dup
        1666: aload         60
        1668: invokespecial #177                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1671: astore        61
        1673: new           #179                // class ocaml_fn_23
        1676: dup
        1677: aload         26
        1679: invokespecial #180                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1682: astore        62
        1684: new           #182                // class ocaml_fn_24
        1687: dup
        1688: invokespecial #183                // Method ocaml_fn_24."<init>":()V
        1691: astore        63
        1693: new           #185                // class ocaml_fn_25
        1696: dup
        1697: invokespecial #186                // Method ocaml_fn_25."<init>":()V
        1700: astore        64
        1702: aload         63
        1704: checkcast     #182                // class ocaml_fn_24
        1707: aload         63
        1709: checkcast     #188                // class Closure
        1712: putfield      #192                // Field ocaml_fn_24.sibling_0:LClosure;
        1715: iconst_0
        1716: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1719: astore        65
        1721: aload         63
        1723: checkcast     #182                // class ocaml_fn_24
        1726: aload         64
        1728: checkcast     #188                // class Closure
        1731: putfield      #195                // Field ocaml_fn_24.sibling_1:LClosure;
        1734: iconst_0
        1735: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1738: astore        66
        1740: aload         64
        1742: checkcast     #185                // class ocaml_fn_25
        1745: aload         63
        1747: checkcast     #188                // class Closure
        1750: putfield      #196                // Field ocaml_fn_25.sibling_0:LClosure;
        1753: iconst_0
        1754: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1757: astore        67
        1759: aload         64
        1761: checkcast     #185                // class ocaml_fn_25
        1764: aload         64
        1766: checkcast     #188                // class Closure
        1769: putfield      #197                // Field ocaml_fn_25.sibling_1:LClosure;
        1772: iconst_0
        1773: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1776: astore        68
        1778: iconst_0
        1779: istore        69
        1781: aconst_null
        1782: astore        70
        1784: iconst_1
        1785: istore        71
        1787: iload         71
        1789: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1792: astore        72
        1794: iconst_2
        1795: istore        73
        1797: iload         73
        1799: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1802: astore        74
        1804: new           #205                // class ocaml_fn_26
        1807: dup
        1808: invokespecial #206                // Method ocaml_fn_26."<init>":()V
        1811: astore        75
        1813: new           #208                // class ocaml_fn_27
        1816: dup
        1817: aload         75
        1819: invokespecial #209                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1822: astore        76
        1824: new           #211                // class ocaml_fn_28
        1827: dup
        1828: aload         75
        1830: invokespecial #212                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1833: astore        77
        1835: new           #214                // class ocaml_fn_29
        1838: dup
        1839: aload         30
        1841: invokespecial #215                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1844: astore        78
        1846: new           #217                // class ocaml_fn_30
        1849: dup
        1850: invokespecial #218                // Method ocaml_fn_30."<init>":()V
        1853: astore        79
        1855: new           #220                // class ocaml_fn_31
        1858: dup
        1859: invokespecial #221                // Method ocaml_fn_31."<init>":()V
        1862: astore        80
        1864: new           #223                // class ocaml_fn_32
        1867: dup
        1868: aload         18
        1870: invokespecial #224                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1873: astore        81
        1875: new           #226                // class ocaml_fn_33
        1878: dup
        1879: aload         18
        1881: invokespecial #227                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1884: astore        82
        1886: new           #229                // class ocaml_fn_34
        1889: dup
        1890: invokespecial #230                // Method ocaml_fn_34."<init>":()V
        1893: astore        83
        1895: new           #232                // class ocaml_fn_35
        1898: dup
        1899: invokespecial #233                // Method ocaml_fn_35."<init>":()V
        1902: astore        84
        1904: new           #235                // class ocaml_fn_36
        1907: dup
        1908: invokespecial #236                // Method ocaml_fn_36."<init>":()V
        1911: astore        85
        1913: new           #238                // class ocaml_fn_37
        1916: dup
        1917: invokespecial #239                // Method ocaml_fn_37."<init>":()V
        1920: astore        86
        1922: new           #241                // class ocaml_fn_38
        1925: dup
        1926: aload         86
        1928: invokespecial #242                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1931: astore        87
        1933: new           #244                // class ocaml_fn_39
        1936: dup
        1937: aload         86
        1939: invokespecial #245                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1942: astore        88
        1944: new           #247                // class ocaml_fn_40
        1947: dup
        1948: aload         18
        1950: invokespecial #248                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1953: astore        89
        1955: new           #250                // class ocaml_fn_41
        1958: dup
        1959: aload         31
        1961: invokespecial #251                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1964: astore        90
        1966: new           #253                // class ocaml_fn_42
        1969: dup
        1970: aload         18
        1972: aload         90
        1974: invokespecial #256                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1977: astore        91
        1979: new           #258                // class ocaml_fn_43
        1982: dup
        1983: aload         91
        1985: invokespecial #259                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1988: astore        92
        1990: new           #261                // class ocaml_fn_44
        1993: dup
        1994: aload         31
        1996: invokespecial #262                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1999: astore        93
        2001: new           #264                // class ocaml_fn_45
        2004: dup
        2005: invokespecial #265                // Method ocaml_fn_45."<init>":()V
        2008: astore        94
        2010: new           #267                // class ocaml_fn_46
        2013: dup
        2014: aload         72
        2016: invokespecial #268                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2019: astore        95
        2021: new           #270                // class ocaml_fn_47
        2024: dup
        2025: aload         72
        2027: aload         80
        2029: invokespecial #271                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2032: astore        96
        2034: new           #273                // class ocaml_fn_48
        2037: dup
        2038: aload         72
        2040: aload         79
        2042: invokespecial #274                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2045: astore        97
        2047: new           #276                // class ocaml_fn_49
        2050: dup
        2051: aload         58
        2053: aload         72
        2055: aload         80
        2057: invokespecial #279                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        98
        2062: new           #281                // class ocaml_fn_50
        2065: dup
        2066: aload         61
        2068: aload         72
        2070: aload         80
        2072: invokespecial #282                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        99
        2077: new           #284                // class ocaml_fn_51
        2080: dup
        2081: aload         72
        2083: aload         80
        2085: invokespecial #285                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2088: astore        100
        2090: new           #287                // class ocaml_fn_52
        2093: dup
        2094: aload         72
        2096: invokespecial #288                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2099: astore        101
        2101: new           #290                // class ocaml_fn_53
        2104: dup
        2105: aload         74
        2107: invokespecial #291                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2110: astore        102
        2112: new           #293                // class ocaml_fn_54
        2115: dup
        2116: aload         74
        2118: aload         80
        2120: invokespecial #294                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2123: astore        103
        2125: new           #296                // class ocaml_fn_55
        2128: dup
        2129: aload         74
        2131: aload         79
        2133: invokespecial #297                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2136: astore        104
        2138: new           #299                // class ocaml_fn_56
        2141: dup
        2142: aload         58
        2144: aload         74
        2146: aload         80
        2148: invokespecial #300                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2151: astore        105
        2153: new           #302                // class ocaml_fn_57
        2156: dup
        2157: aload         61
        2159: aload         74
        2161: aload         80
        2163: invokespecial #303                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2166: astore        106
        2168: new           #305                // class ocaml_fn_58
        2171: dup
        2172: aload         74
        2174: aload         80
        2176: invokespecial #306                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2179: astore        107
        2181: new           #308                // class ocaml_fn_59
        2184: dup
        2185: aload         74
        2187: invokespecial #309                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2190: astore        108
        2192: new           #311                // class ocaml_fn_60
        2195: dup
        2196: aload         70
        2198: aload         72
        2200: aload         93
        2202: invokespecial #312                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2205: astore        109
        2207: new           #314                // class ocaml_fn_61
        2210: dup
        2211: aload         109
        2213: invokespecial #315                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2216: astore        110
        2218: new           #317                // class ocaml_fn_62
        2221: dup
        2222: aload         59
        2224: aload         109
        2226: invokespecial #318                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2229: astore        111
        2231: new           #320                // class ocaml_fn_63
        2234: dup
        2235: aload         109
        2237: invokespecial #321                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2240: astore        112
        2242: new           #323                // class ocaml_fn_64
        2245: dup
        2246: aload         62
        2248: aload         109
        2250: invokespecial #324                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2253: astore        113
        2255: new           #326                // class ocaml_fn_65
        2258: dup
        2259: invokespecial #327                // Method ocaml_fn_65."<init>":()V
        2262: astore        114
        2264: new           #329                // class ocaml_fn_66
        2267: dup
        2268: aload         53
        2270: invokespecial #330                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2273: astore        115
        2275: new           #2                  // class Block
        2278: dup
        2279: iconst_0
        2280: iconst_1
        2281: anewarray     #4                  // class java/lang/Object
        2284: dup
        2285: iconst_0
        2286: aload         78
        2288: aastore
        2289: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2292: astore        116
        2294: new           #332                // class ocaml_fn_67
        2297: dup
        2298: aload         116
        2300: invokespecial #333                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2303: astore        117
        2305: new           #335                // class ocaml_fn_68
        2308: dup
        2309: invokespecial #336                // Method ocaml_fn_68."<init>":()V
        2312: astore        118
        2314: new           #2                  // class Block
        2317: dup
        2318: iconst_0
        2319: iconst_1
        2320: anewarray     #4                  // class java/lang/Object
        2323: dup
        2324: iconst_0
        2325: aload         118
        2327: aastore
        2328: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2331: astore        119
        2333: new           #338                // class ocaml_fn_69
        2336: dup
        2337: aload         116
        2339: aload         119
        2341: invokespecial #339                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2344: astore        120
        2346: new           #341                // class ocaml_fn_70
        2349: dup
        2350: aload         120
        2352: invokespecial #342                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2355: astore        121
        2357: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2360: bipush        44
        2362: aaload
        2363: astore        122
        2365: iconst_0
        2366: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2369: astore        123
        2371: new           #344                // class ocaml_fn_71
        2374: dup
        2375: invokespecial #345                // Method ocaml_fn_71."<init>":()V
        2378: astore        124
        2380: new           #347                // class ocaml_fn_72
        2383: dup
        2384: invokespecial #348                // Method ocaml_fn_72."<init>":()V
        2387: astore        125
        2389: new           #350                // class ocaml_fn_73
        2392: dup
        2393: invokespecial #351                // Method ocaml_fn_73."<init>":()V
        2396: astore        126
        2398: new           #353                // class ocaml_fn_74
        2401: dup
        2402: invokespecial #354                // Method ocaml_fn_74."<init>":()V
        2405: astore        127
        2407: new           #356                // class ocaml_fn_75
        2410: dup
        2411: invokespecial #357                // Method ocaml_fn_75."<init>":()V
        2414: astore        128
        2416: new           #359                // class ocaml_fn_76
        2419: dup
        2420: invokespecial #360                // Method ocaml_fn_76."<init>":()V
        2423: astore        129
        2425: new           #2                  // class Block
        2428: dup
        2429: iconst_0
        2430: bipush        6
        2432: anewarray     #4                  // class java/lang/Object
        2435: dup
        2436: iconst_0
        2437: aload         129
        2439: aastore
        2440: dup
        2441: iconst_1
        2442: aload         128
        2444: aastore
        2445: dup
        2446: iconst_2
        2447: aload         127
        2449: aastore
        2450: dup
        2451: iconst_3
        2452: aload         126
        2454: aastore
        2455: dup
        2456: iconst_4
        2457: aload         125
        2459: aastore
        2460: dup
        2461: iconst_5
        2462: aload         124
        2464: aastore
        2465: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2468: astore        130
        2470: new           #362                // class ocaml_fn_77
        2473: dup
        2474: invokespecial #363                // Method ocaml_fn_77."<init>":()V
        2477: astore        131
        2479: new           #365                // class ocaml_fn_78
        2482: dup
        2483: invokespecial #366                // Method ocaml_fn_78."<init>":()V
        2486: astore        132
        2488: new           #368                // class ocaml_fn_79
        2491: dup
        2492: invokespecial #369                // Method ocaml_fn_79."<init>":()V
        2495: astore        133
        2497: new           #371                // class ocaml_fn_80
        2500: dup
        2501: invokespecial #372                // Method ocaml_fn_80."<init>":()V
        2504: astore        134
        2506: new           #374                // class ocaml_fn_81
        2509: dup
        2510: invokespecial #375                // Method ocaml_fn_81."<init>":()V
        2513: astore        135
        2515: new           #377                // class ocaml_fn_82
        2518: dup
        2519: invokespecial #378                // Method ocaml_fn_82."<init>":()V
        2522: astore        136
        2524: new           #380                // class ocaml_fn_83
        2527: dup
        2528: invokespecial #381                // Method ocaml_fn_83."<init>":()V
        2531: astore        137
        2533: new           #383                // class ocaml_fn_84
        2536: dup
        2537: invokespecial #384                // Method ocaml_fn_84."<init>":()V
        2540: astore        138
        2542: new           #386                // class ocaml_fn_85
        2545: dup
        2546: invokespecial #387                // Method ocaml_fn_85."<init>":()V
        2549: astore        139
        2551: new           #389                // class ocaml_fn_86
        2554: dup
        2555: invokespecial #390                // Method ocaml_fn_86."<init>":()V
        2558: astore        140
        2560: new           #392                // class ocaml_fn_87
        2563: dup
        2564: invokespecial #393                // Method ocaml_fn_87."<init>":()V
        2567: astore        141
        2569: new           #395                // class ocaml_fn_88
        2572: dup
        2573: invokespecial #396                // Method ocaml_fn_88."<init>":()V
        2576: astore        142
        2578: new           #398                // class ocaml_fn_89
        2581: dup
        2582: invokespecial #399                // Method ocaml_fn_89."<init>":()V
        2585: astore        143
        2587: new           #401                // class ocaml_fn_90
        2590: dup
        2591: invokespecial #402                // Method ocaml_fn_90."<init>":()V
        2594: astore        144
        2596: new           #404                // class ocaml_fn_91
        2599: dup
        2600: invokespecial #405                // Method ocaml_fn_91."<init>":()V
        2603: astore        145
        2605: new           #407                // class ocaml_fn_92
        2608: dup
        2609: invokespecial #408                // Method ocaml_fn_92."<init>":()V
        2612: astore        146
        2614: new           #410                // class ocaml_fn_93
        2617: dup
        2618: invokespecial #411                // Method ocaml_fn_93."<init>":()V
        2621: astore        147
        2623: new           #2                  // class Block
        2626: dup
        2627: iconst_0
        2628: bipush        104
        2630: anewarray     #4                  // class java/lang/Object
        2633: dup
        2634: iconst_0
        2635: aload         18
        2637: aastore
        2638: dup
        2639: iconst_1
        2640: aload         17
        2642: aastore
        2643: dup
        2644: iconst_2
        2645: aload         22
        2647: aastore
        2648: dup
        2649: iconst_3
        2650: aload         23
        2652: aastore
        2653: dup
        2654: iconst_4
        2655: aload         24
        2657: aastore
        2658: dup
        2659: iconst_5
        2660: aload         25
        2662: aastore
        2663: dup
        2664: bipush        6
        2666: aload         26
        2668: aastore
        2669: dup
        2670: bipush        7
        2672: aload         27
        2674: aastore
        2675: dup
        2676: bipush        8
        2678: aload         28
        2680: aastore
        2681: dup
        2682: bipush        9
        2684: aload         29
        2686: aastore
        2687: dup
        2688: bipush        10
        2690: aload         30
        2692: aastore
        2693: dup
        2694: bipush        11
        2696: aload         31
        2698: aastore
        2699: dup
        2700: bipush        12
        2702: aload         32
        2704: aastore
        2705: dup
        2706: bipush        13
        2708: aload         33
        2710: aastore
        2711: dup
        2712: bipush        14
        2714: aload         34
        2716: aastore
        2717: dup
        2718: bipush        15
        2720: aload         35
        2722: aastore
        2723: dup
        2724: bipush        16
        2726: aload         36
        2728: aastore
        2729: dup
        2730: bipush        17
        2732: aload         37
        2734: aastore
        2735: dup
        2736: bipush        18
        2738: iload         39
        2740: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2743: aastore
        2744: dup
        2745: bipush        19
        2747: iload         40
        2749: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2752: aastore
        2753: dup
        2754: bipush        20
        2756: aload         38
        2758: aastore
        2759: dup
        2760: bipush        21
        2762: aload         42
        2764: aastore
        2765: dup
        2766: bipush        22
        2768: aload         44
        2770: aastore
        2771: dup
        2772: bipush        23
        2774: aload         46
        2776: aastore
        2777: dup
        2778: bipush        24
        2780: aload         48
        2782: aastore
        2783: dup
        2784: bipush        25
        2786: aload         50
        2788: aastore
        2789: dup
        2790: bipush        26
        2792: aload         52
        2794: aastore
        2795: dup
        2796: bipush        27
        2798: aload         53
        2800: aastore
        2801: dup
        2802: bipush        28
        2804: aload         54
        2806: aastore
        2807: dup
        2808: bipush        29
        2810: aload         55
        2812: aastore
        2813: dup
        2814: bipush        30
        2816: aload         57
        2818: aastore
        2819: dup
        2820: bipush        31
        2822: aload         56
        2824: aastore
        2825: dup
        2826: bipush        32
        2828: aload         58
        2830: aastore
        2831: dup
        2832: bipush        33
        2834: aload         59
        2836: aastore
        2837: dup
        2838: bipush        34
        2840: aload         61
        2842: aastore
        2843: dup
        2844: bipush        35
        2846: aload         62
        2848: aastore
        2849: dup
        2850: bipush        36
        2852: aload         63
        2854: aastore
        2855: dup
        2856: bipush        37
        2858: aload         70
        2860: aastore
        2861: dup
        2862: bipush        38
        2864: aload         72
        2866: aastore
        2867: dup
        2868: bipush        39
        2870: aload         74
        2872: aastore
        2873: dup
        2874: bipush        40
        2876: aload         95
        2878: aastore
        2879: dup
        2880: bipush        41
        2882: aload         96
        2884: aastore
        2885: dup
        2886: bipush        42
        2888: aload         97
        2890: aastore
        2891: dup
        2892: bipush        43
        2894: aload         98
        2896: aastore
        2897: dup
        2898: bipush        44
        2900: aload         99
        2902: aastore
        2903: dup
        2904: bipush        45
        2906: aload         100
        2908: aastore
        2909: dup
        2910: bipush        46
        2912: aload         101
        2914: aastore
        2915: dup
        2916: bipush        47
        2918: aload         102
        2920: aastore
        2921: dup
        2922: bipush        48
        2924: aload         103
        2926: aastore
        2927: dup
        2928: bipush        49
        2930: aload         104
        2932: aastore
        2933: dup
        2934: bipush        50
        2936: aload         105
        2938: aastore
        2939: dup
        2940: bipush        51
        2942: aload         106
        2944: aastore
        2945: dup
        2946: bipush        52
        2948: aload         107
        2950: aastore
        2951: dup
        2952: bipush        53
        2954: aload         108
        2956: aastore
        2957: dup
        2958: bipush        54
        2960: aload         109
        2962: aastore
        2963: dup
        2964: bipush        55
        2966: aload         111
        2968: aastore
        2969: dup
        2970: bipush        56
        2972: aload         110
        2974: aastore
        2975: dup
        2976: bipush        57
        2978: aload         113
        2980: aastore
        2981: dup
        2982: bipush        58
        2984: aload         112
        2986: aastore
        2987: dup
        2988: bipush        59
        2990: aload         76
        2992: aastore
        2993: dup
        2994: bipush        60
        2996: aload         77
        2998: aastore
        2999: dup
        3000: bipush        61
        3002: aload         75
        3004: aastore
        3005: dup
        3006: bipush        62
        3008: aload         147
        3010: aastore
        3011: dup
        3012: bipush        63
        3014: aload         78
        3016: aastore
        3017: dup
        3018: bipush        64
        3020: aload         146
        3022: aastore
        3023: dup
        3024: bipush        65
        3026: aload         80
        3028: aastore
        3029: dup
        3030: bipush        66
        3032: aload         79
        3034: aastore
        3035: dup
        3036: bipush        67
        3038: aload         81
        3040: aastore
        3041: dup
        3042: bipush        68
        3044: aload         82
        3046: aastore
        3047: dup
        3048: bipush        69
        3050: aload         145
        3052: aastore
        3053: dup
        3054: bipush        70
        3056: aload         144
        3058: aastore
        3059: dup
        3060: bipush        71
        3062: aload         83
        3064: aastore
        3065: dup
        3066: bipush        72
        3068: aload         143
        3070: aastore
        3071: dup
        3072: bipush        73
        3074: aload         142
        3076: aastore
        3077: dup
        3078: bipush        74
        3080: aload         141
        3082: aastore
        3083: dup
        3084: bipush        75
        3086: aload         84
        3088: aastore
        3089: dup
        3090: bipush        76
        3092: aload         85
        3094: aastore
        3095: dup
        3096: bipush        77
        3098: aload         140
        3100: aastore
        3101: dup
        3102: bipush        78
        3104: aload         87
        3106: aastore
        3107: dup
        3108: bipush        79
        3110: aload         88
        3112: aastore
        3113: dup
        3114: bipush        80
        3116: aload         86
        3118: aastore
        3119: dup
        3120: bipush        81
        3122: aload         139
        3124: aastore
        3125: dup
        3126: bipush        82
        3128: aload         93
        3130: aastore
        3131: dup
        3132: bipush        83
        3134: aload         89
        3136: aastore
        3137: dup
        3138: bipush        84
        3140: aload         91
        3142: aastore
        3143: dup
        3144: bipush        85
        3146: aload         92
        3148: aastore
        3149: dup
        3150: bipush        86
        3152: aload         138
        3154: aastore
        3155: dup
        3156: bipush        87
        3158: aload         137
        3160: aastore
        3161: dup
        3162: bipush        88
        3164: aload         136
        3166: aastore
        3167: dup
        3168: bipush        89
        3170: aload         135
        3172: aastore
        3173: dup
        3174: bipush        90
        3176: aload         134
        3178: aastore
        3179: dup
        3180: bipush        91
        3182: aload         133
        3184: aastore
        3185: dup
        3186: bipush        92
        3188: aload         132
        3190: aastore
        3191: dup
        3192: bipush        93
        3194: aload         94
        3196: aastore
        3197: dup
        3198: bipush        94
        3200: aload         131
        3202: aastore
        3203: dup
        3204: bipush        95
        3206: aload         130
        3208: aastore
        3209: dup
        3210: bipush        96
        3212: aload         114
        3214: aastore
        3215: dup
        3216: bipush        97
        3218: aload         115
        3220: aastore
        3221: dup
        3222: bipush        98
        3224: aload         121
        3226: aastore
        3227: dup
        3228: bipush        99
        3230: aload         117
        3232: aastore
        3233: dup
        3234: bipush        100
        3236: aload         60
        3238: aastore
        3239: dup
        3240: bipush        101
        3242: aload         90
        3244: aastore
        3245: dup
        3246: bipush        102
        3248: aload         120
        3250: aastore
        3251: dup
        3252: bipush        103
        3254: aload         119
        3256: aastore
        3257: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3260: astore        148
        3262: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3265: bipush        45
        3267: aload         148
        3269: aastore
        3270: iconst_0
        3271: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3274: astore        149
        3276: iconst_0
        3277: istore        150
        3279: iload         150
        3281: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3284: astore        151
        3286: goto_w        3291
        3291: new           #413                // class ocaml_fn_94
        3294: dup
        3295: invokespecial #414                // Method ocaml_fn_94."<init>":()V
        3298: astore        152
        3300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3303: bipush        46
        3305: aaload
        3306: astore        153
        3308: aload         152
        3310: aload         153
        3312: invokevirtual #418                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3315: astore        154
        3317: getstatic     #422                // Field java/lang/System.out:Ljava/io/PrintStream;
        3320: aload         154
        3322: checkcast     #29                 // class java/lang/Integer
        3325: invokevirtual #426                // Method java/lang/Integer.intValue:()I
        3328: invokevirtual #432                // Method java/io/PrintStream.println:(I)V
        3331: iconst_0
        3332: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3335: astore        155
        3337: new           #2                  // class Block
        3340: dup
        3341: iconst_0
        3342: iconst_1
        3343: anewarray     #4                  // class java/lang/Object
        3346: dup
        3347: iconst_0
        3348: aload         152
        3350: aastore
        3351: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3354: astore        156
        3356: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3359: bipush        47
        3361: aload         156
        3363: aastore
        3364: iconst_0
        3365: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3368: astore        157
        3370: iconst_0
        3371: istore        158
        3373: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3376: bipush        45
        3378: aaload
        3379: checkcast     #2                  // class Block
        3382: getfield      #435                // Field Block.fields:[Ljava/lang/Object;
        3385: bipush        102
        3387: aaload
        3388: astore        159
        3390: aload         159
        3392: checkcast     #188                // class Closure
        3395: iload         158
        3397: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3400: invokevirtual #418                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3403: astore        160
        3405: new           #2                  // class Block
        3408: dup
        3409: iconst_0
        3410: iconst_0
        3411: anewarray     #4                  // class java/lang/Object
        3414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3417: astore        161
        3419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3422: bipush        48
        3424: aload         161
        3426: aastore
        3427: iconst_0
        3428: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3431: astore        162
        3433: return
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
        1069: aconst_null
        1070: astore_1
        1071: aload_1
        1072: astore_2
        1073: goto_w        1078
        1078: new           #108                // class ocaml_fn_0
        1081: dup
        1082: invokespecial #111                // Method ocaml_fn_0."<init>":()V
        1085: astore_3
        1086: new           #113                // class ocaml_fn_1
        1089: dup
        1090: invokespecial #114                // Method ocaml_fn_1."<init>":()V
        1093: astore        4
        1095: new           #116                // class ocaml_fn_2
        1098: dup
        1099: invokespecial #117                // Method ocaml_fn_2."<init>":()V
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
        1225: new           #119                // class ocaml_fn_8
        1228: dup
        1229: invokespecial #120                // Method ocaml_fn_8."<init>":()V
        1232: astore        17
        1234: new           #122                // class ocaml_fn_9
        1237: dup
        1238: invokespecial #123                // Method ocaml_fn_9."<init>":()V
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
        1376: new           #125                // class ocaml_fn_10
        1379: dup
        1380: invokespecial #126                // Method ocaml_fn_10."<init>":()V
        1383: astore        35
        1385: new           #128                // class ocaml_fn_11
        1388: dup
        1389: invokespecial #129                // Method ocaml_fn_11."<init>":()V
        1392: astore        36
        1394: new           #131                // class ocaml_fn_12
        1397: dup
        1398: invokespecial #132                // Method ocaml_fn_12."<init>":()V
        1401: astore        37
        1403: new           #134                // class ocaml_fn_13
        1406: dup
        1407: invokespecial #135                // Method ocaml_fn_13."<init>":()V
        1410: astore        38
        1412: ldc           #136                // int 2147483647
        1414: istore        39
        1416: ldc           #137                // int -2147483648
        1418: istore        40
        1420: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        38
        1425: aaload
        1426: astore        41
        1428: aload         41
        1430: checkcast     #89                 // class java/lang/Long
        1433: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1436: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1439: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        42
        1444: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        39
        1449: aaload
        1450: astore        43
        1452: aload         43
        1454: checkcast     #89                 // class java/lang/Long
        1457: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1460: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1463: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: aload         45
        1478: checkcast     #89                 // class java/lang/Long
        1481: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1484: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1487: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1490: astore        46
        1492: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1495: bipush        41
        1497: aaload
        1498: astore        47
        1500: aload         47
        1502: checkcast     #89                 // class java/lang/Long
        1505: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1508: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1511: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        48
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        42
        1521: aaload
        1522: astore        49
        1524: aload         49
        1526: checkcast     #89                 // class java/lang/Long
        1529: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1532: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1535: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1538: astore        50
        1540: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1543: bipush        43
        1545: aaload
        1546: astore        51
        1548: aload         51
        1550: checkcast     #89                 // class java/lang/Long
        1553: invokevirtual #141                // Method java/lang/Long.longValue:()J
        1556: invokestatic  #147                // Method java/lang/Double.longBitsToDouble:(J)D
        1559: invokestatic  #150                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1562: astore        52
        1564: new           #152                // class ocaml_fn_14
        1567: dup
        1568: invokespecial #153                // Method ocaml_fn_14."<init>":()V
        1571: astore        53
        1573: new           #155                // class ocaml_fn_15
        1576: dup
        1577: aload         18
        1579: invokespecial #158                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1582: astore        54
        1584: new           #160                // class ocaml_fn_16
        1587: dup
        1588: invokespecial #161                // Method ocaml_fn_16."<init>":()V
        1591: astore        55
        1593: new           #163                // class ocaml_fn_17
        1596: dup
        1597: aload         18
        1599: invokespecial #164                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1602: astore        56
        1604: new           #166                // class ocaml_fn_18
        1607: dup
        1608: invokespecial #167                // Method ocaml_fn_18."<init>":()V
        1611: astore        57
        1613: new           #169                // class ocaml_fn_19
        1616: dup
        1617: invokespecial #170                // Method ocaml_fn_19."<init>":()V
        1620: astore        58
        1622: new           #172                // class ocaml_fn_20
        1625: dup
        1626: aload         26
        1628: invokespecial #173                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1631: astore        59
        1633: new           #175                // class ocaml_fn_21
        1636: dup
        1637: aload         53
        1639: invokespecial #176                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1642: astore        60
        1644: new           #178                // class ocaml_fn_22
        1647: dup
        1648: aload         60
        1650: invokespecial #179                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1653: astore        61
        1655: new           #181                // class ocaml_fn_23
        1658: dup
        1659: aload         26
        1661: invokespecial #182                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1664: astore        62
        1666: new           #184                // class ocaml_fn_24
        1669: dup
        1670: invokespecial #185                // Method ocaml_fn_24."<init>":()V
        1673: astore        63
        1675: new           #187                // class ocaml_fn_25
        1678: dup
        1679: invokespecial #188                // Method ocaml_fn_25."<init>":()V
        1682: astore        64
        1684: aload         63
        1686: checkcast     #184                // class ocaml_fn_24
        1689: aload         63
        1691: checkcast     #190                // class Closure
        1694: putfield      #194                // Field ocaml_fn_24.sibling_0:LClosure;
        1697: iconst_0
        1698: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1701: astore        65
        1703: aload         63
        1705: checkcast     #184                // class ocaml_fn_24
        1708: aload         64
        1710: checkcast     #190                // class Closure
        1713: putfield      #197                // Field ocaml_fn_24.sibling_1:LClosure;
        1716: iconst_0
        1717: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1720: astore        66
        1722: aload         64
        1724: checkcast     #187                // class ocaml_fn_25
        1727: aload         63
        1729: checkcast     #190                // class Closure
        1732: putfield      #198                // Field ocaml_fn_25.sibling_0:LClosure;
        1735: iconst_0
        1736: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1739: astore        67
        1741: aload         64
        1743: checkcast     #187                // class ocaml_fn_25
        1746: aload         64
        1748: checkcast     #190                // class Closure
        1751: putfield      #199                // Field ocaml_fn_25.sibling_1:LClosure;
        1754: iconst_0
        1755: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1758: astore        68
        1760: iconst_0
        1761: istore        69
        1763: aconst_null
        1764: astore        70
        1766: iconst_1
        1767: istore        71
        1769: iload         71
        1771: invokestatic  #205                // Method Channel.forDescriptor:(I)LChannel;
        1774: astore        72
        1776: iconst_2
        1777: istore        73
        1779: iload         73
        1781: invokestatic  #205                // Method Channel.forDescriptor:(I)LChannel;
        1784: astore        74
        1786: new           #207                // class ocaml_fn_26
        1789: dup
        1790: invokespecial #208                // Method ocaml_fn_26."<init>":()V
        1793: astore        75
        1795: new           #210                // class ocaml_fn_27
        1798: dup
        1799: aload         75
        1801: invokespecial #211                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1804: astore        76
        1806: new           #213                // class ocaml_fn_28
        1809: dup
        1810: aload         75
        1812: invokespecial #214                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1815: astore        77
        1817: new           #216                // class ocaml_fn_29
        1820: dup
        1821: aload         30
        1823: invokespecial #217                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1826: astore        78
        1828: new           #219                // class ocaml_fn_30
        1831: dup
        1832: invokespecial #220                // Method ocaml_fn_30."<init>":()V
        1835: astore        79
        1837: new           #222                // class ocaml_fn_31
        1840: dup
        1841: invokespecial #223                // Method ocaml_fn_31."<init>":()V
        1844: astore        80
        1846: new           #225                // class ocaml_fn_32
        1849: dup
        1850: aload         18
        1852: invokespecial #226                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1855: astore        81
        1857: new           #228                // class ocaml_fn_33
        1860: dup
        1861: aload         18
        1863: invokespecial #229                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1866: astore        82
        1868: new           #231                // class ocaml_fn_34
        1871: dup
        1872: invokespecial #232                // Method ocaml_fn_34."<init>":()V
        1875: astore        83
        1877: new           #234                // class ocaml_fn_35
        1880: dup
        1881: invokespecial #235                // Method ocaml_fn_35."<init>":()V
        1884: astore        84
        1886: new           #237                // class ocaml_fn_36
        1889: dup
        1890: invokespecial #238                // Method ocaml_fn_36."<init>":()V
        1893: astore        85
        1895: new           #240                // class ocaml_fn_37
        1898: dup
        1899: invokespecial #241                // Method ocaml_fn_37."<init>":()V
        1902: astore        86
        1904: new           #243                // class ocaml_fn_38
        1907: dup
        1908: aload         86
        1910: invokespecial #244                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1913: astore        87
        1915: new           #246                // class ocaml_fn_39
        1918: dup
        1919: aload         86
        1921: invokespecial #247                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1924: astore        88
        1926: new           #249                // class ocaml_fn_40
        1929: dup
        1930: aload         18
        1932: invokespecial #250                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1935: astore        89
        1937: new           #252                // class ocaml_fn_41
        1940: dup
        1941: aload         31
        1943: invokespecial #253                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1946: astore        90
        1948: new           #255                // class ocaml_fn_42
        1951: dup
        1952: aload         18
        1954: aload         90
        1956: invokespecial #258                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1959: astore        91
        1961: new           #260                // class ocaml_fn_43
        1964: dup
        1965: aload         91
        1967: invokespecial #261                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1970: astore        92
        1972: new           #263                // class ocaml_fn_44
        1975: dup
        1976: aload         31
        1978: invokespecial #264                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1981: astore        93
        1983: new           #266                // class ocaml_fn_45
        1986: dup
        1987: invokespecial #267                // Method ocaml_fn_45."<init>":()V
        1990: astore        94
        1992: new           #269                // class ocaml_fn_46
        1995: dup
        1996: aload         72
        1998: invokespecial #270                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        2001: astore        95
        2003: new           #272                // class ocaml_fn_47
        2006: dup
        2007: aload         72
        2009: aload         80
        2011: invokespecial #273                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2014: astore        96
        2016: new           #275                // class ocaml_fn_48
        2019: dup
        2020: aload         72
        2022: aload         79
        2024: invokespecial #276                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        97
        2029: new           #278                // class ocaml_fn_49
        2032: dup
        2033: aload         58
        2035: aload         72
        2037: aload         80
        2039: invokespecial #281                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2042: astore        98
        2044: new           #283                // class ocaml_fn_50
        2047: dup
        2048: aload         61
        2050: aload         72
        2052: aload         80
        2054: invokespecial #284                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2057: astore        99
        2059: new           #286                // class ocaml_fn_51
        2062: dup
        2063: aload         72
        2065: aload         80
        2067: invokespecial #287                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2070: astore        100
        2072: new           #289                // class ocaml_fn_52
        2075: dup
        2076: aload         72
        2078: invokespecial #290                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2081: astore        101
        2083: new           #292                // class ocaml_fn_53
        2086: dup
        2087: aload         74
        2089: invokespecial #293                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2092: astore        102
        2094: new           #295                // class ocaml_fn_54
        2097: dup
        2098: aload         74
        2100: aload         80
        2102: invokespecial #296                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2105: astore        103
        2107: new           #298                // class ocaml_fn_55
        2110: dup
        2111: aload         74
        2113: aload         79
        2115: invokespecial #299                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2118: astore        104
        2120: new           #301                // class ocaml_fn_56
        2123: dup
        2124: aload         58
        2126: aload         74
        2128: aload         80
        2130: invokespecial #302                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2133: astore        105
        2135: new           #304                // class ocaml_fn_57
        2138: dup
        2139: aload         61
        2141: aload         74
        2143: aload         80
        2145: invokespecial #305                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2148: astore        106
        2150: new           #307                // class ocaml_fn_58
        2153: dup
        2154: aload         74
        2156: aload         80
        2158: invokespecial #308                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2161: astore        107
        2163: new           #310                // class ocaml_fn_59
        2166: dup
        2167: aload         74
        2169: invokespecial #311                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2172: astore        108
        2174: new           #313                // class ocaml_fn_60
        2177: dup
        2178: aload         70
        2180: aload         72
        2182: aload         93
        2184: invokespecial #314                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        109
        2189: new           #316                // class ocaml_fn_61
        2192: dup
        2193: aload         109
        2195: invokespecial #317                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2198: astore        110
        2200: new           #319                // class ocaml_fn_62
        2203: dup
        2204: aload         59
        2206: aload         109
        2208: invokespecial #320                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2211: astore        111
        2213: new           #322                // class ocaml_fn_63
        2216: dup
        2217: aload         109
        2219: invokespecial #323                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2222: astore        112
        2224: new           #325                // class ocaml_fn_64
        2227: dup
        2228: aload         62
        2230: aload         109
        2232: invokespecial #326                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2235: astore        113
        2237: new           #328                // class ocaml_fn_65
        2240: dup
        2241: invokespecial #329                // Method ocaml_fn_65."<init>":()V
        2244: astore        114
        2246: new           #331                // class ocaml_fn_66
        2249: dup
        2250: aload         53
        2252: invokespecial #332                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2255: astore        115
        2257: new           #2                  // class Block
        2260: dup
        2261: iconst_0
        2262: iconst_1
        2263: anewarray     #4                  // class java/lang/Object
        2266: dup
        2267: iconst_0
        2268: aload         78
        2270: aastore
        2271: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2274: astore        116
        2276: new           #334                // class ocaml_fn_67
        2279: dup
        2280: aload         116
        2282: invokespecial #335                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2285: astore        117
        2287: new           #337                // class ocaml_fn_68
        2290: dup
        2291: invokespecial #338                // Method ocaml_fn_68."<init>":()V
        2294: astore        118
        2296: new           #2                  // class Block
        2299: dup
        2300: iconst_0
        2301: iconst_1
        2302: anewarray     #4                  // class java/lang/Object
        2305: dup
        2306: iconst_0
        2307: aload         118
        2309: aastore
        2310: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2313: astore        119
        2315: new           #340                // class ocaml_fn_69
        2318: dup
        2319: aload         116
        2321: aload         119
        2323: invokespecial #341                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2326: astore        120
        2328: new           #343                // class ocaml_fn_70
        2331: dup
        2332: aload         120
        2334: invokespecial #344                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2337: astore        121
        2339: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2342: bipush        44
        2344: aaload
        2345: astore        122
        2347: iconst_0
        2348: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2351: astore        123
        2353: new           #346                // class ocaml_fn_71
        2356: dup
        2357: invokespecial #347                // Method ocaml_fn_71."<init>":()V
        2360: astore        124
        2362: new           #349                // class ocaml_fn_72
        2365: dup
        2366: invokespecial #350                // Method ocaml_fn_72."<init>":()V
        2369: astore        125
        2371: new           #352                // class ocaml_fn_73
        2374: dup
        2375: invokespecial #353                // Method ocaml_fn_73."<init>":()V
        2378: astore        126
        2380: new           #355                // class ocaml_fn_74
        2383: dup
        2384: invokespecial #356                // Method ocaml_fn_74."<init>":()V
        2387: astore        127
        2389: new           #358                // class ocaml_fn_75
        2392: dup
        2393: invokespecial #359                // Method ocaml_fn_75."<init>":()V
        2396: astore        128
        2398: new           #361                // class ocaml_fn_76
        2401: dup
        2402: invokespecial #362                // Method ocaml_fn_76."<init>":()V
        2405: astore        129
        2407: new           #2                  // class Block
        2410: dup
        2411: iconst_0
        2412: bipush        6
        2414: anewarray     #4                  // class java/lang/Object
        2417: dup
        2418: iconst_0
        2419: aload         129
        2421: aastore
        2422: dup
        2423: iconst_1
        2424: aload         128
        2426: aastore
        2427: dup
        2428: iconst_2
        2429: aload         127
        2431: aastore
        2432: dup
        2433: iconst_3
        2434: aload         126
        2436: aastore
        2437: dup
        2438: iconst_4
        2439: aload         125
        2441: aastore
        2442: dup
        2443: iconst_5
        2444: aload         124
        2446: aastore
        2447: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2450: astore        130
        2452: new           #364                // class ocaml_fn_77
        2455: dup
        2456: invokespecial #365                // Method ocaml_fn_77."<init>":()V
        2459: astore        131
        2461: new           #367                // class ocaml_fn_78
        2464: dup
        2465: invokespecial #368                // Method ocaml_fn_78."<init>":()V
        2468: astore        132
        2470: new           #370                // class ocaml_fn_79
        2473: dup
        2474: invokespecial #371                // Method ocaml_fn_79."<init>":()V
        2477: astore        133
        2479: new           #373                // class ocaml_fn_80
        2482: dup
        2483: invokespecial #374                // Method ocaml_fn_80."<init>":()V
        2486: astore        134
        2488: new           #376                // class ocaml_fn_81
        2491: dup
        2492: invokespecial #377                // Method ocaml_fn_81."<init>":()V
        2495: astore        135
        2497: new           #379                // class ocaml_fn_82
        2500: dup
        2501: invokespecial #380                // Method ocaml_fn_82."<init>":()V
        2504: astore        136
        2506: new           #382                // class ocaml_fn_83
        2509: dup
        2510: invokespecial #383                // Method ocaml_fn_83."<init>":()V
        2513: astore        137
        2515: new           #385                // class ocaml_fn_84
        2518: dup
        2519: invokespecial #386                // Method ocaml_fn_84."<init>":()V
        2522: astore        138
        2524: new           #388                // class ocaml_fn_85
        2527: dup
        2528: invokespecial #389                // Method ocaml_fn_85."<init>":()V
        2531: astore        139
        2533: new           #391                // class ocaml_fn_86
        2536: dup
        2537: invokespecial #392                // Method ocaml_fn_86."<init>":()V
        2540: astore        140
        2542: new           #394                // class ocaml_fn_87
        2545: dup
        2546: invokespecial #395                // Method ocaml_fn_87."<init>":()V
        2549: astore        141
        2551: new           #397                // class ocaml_fn_88
        2554: dup
        2555: invokespecial #398                // Method ocaml_fn_88."<init>":()V
        2558: astore        142
        2560: new           #400                // class ocaml_fn_89
        2563: dup
        2564: invokespecial #401                // Method ocaml_fn_89."<init>":()V
        2567: astore        143
        2569: new           #403                // class ocaml_fn_90
        2572: dup
        2573: invokespecial #404                // Method ocaml_fn_90."<init>":()V
        2576: astore        144
        2578: new           #406                // class ocaml_fn_91
        2581: dup
        2582: invokespecial #407                // Method ocaml_fn_91."<init>":()V
        2585: astore        145
        2587: new           #409                // class ocaml_fn_92
        2590: dup
        2591: invokespecial #410                // Method ocaml_fn_92."<init>":()V
        2594: astore        146
        2596: new           #412                // class ocaml_fn_93
        2599: dup
        2600: invokespecial #413                // Method ocaml_fn_93."<init>":()V
        2603: astore        147
        2605: new           #2                  // class Block
        2608: dup
        2609: iconst_0
        2610: bipush        104
        2612: anewarray     #4                  // class java/lang/Object
        2615: dup
        2616: iconst_0
        2617: aload         18
        2619: aastore
        2620: dup
        2621: iconst_1
        2622: aload         17
        2624: aastore
        2625: dup
        2626: iconst_2
        2627: aload         22
        2629: aastore
        2630: dup
        2631: iconst_3
        2632: aload         23
        2634: aastore
        2635: dup
        2636: iconst_4
        2637: aload         24
        2639: aastore
        2640: dup
        2641: iconst_5
        2642: aload         25
        2644: aastore
        2645: dup
        2646: bipush        6
        2648: aload         26
        2650: aastore
        2651: dup
        2652: bipush        7
        2654: aload         27
        2656: aastore
        2657: dup
        2658: bipush        8
        2660: aload         28
        2662: aastore
        2663: dup
        2664: bipush        9
        2666: aload         29
        2668: aastore
        2669: dup
        2670: bipush        10
        2672: aload         30
        2674: aastore
        2675: dup
        2676: bipush        11
        2678: aload         31
        2680: aastore
        2681: dup
        2682: bipush        12
        2684: aload         32
        2686: aastore
        2687: dup
        2688: bipush        13
        2690: aload         33
        2692: aastore
        2693: dup
        2694: bipush        14
        2696: aload         34
        2698: aastore
        2699: dup
        2700: bipush        15
        2702: aload         35
        2704: aastore
        2705: dup
        2706: bipush        16
        2708: aload         36
        2710: aastore
        2711: dup
        2712: bipush        17
        2714: aload         37
        2716: aastore
        2717: dup
        2718: bipush        18
        2720: iload         39
        2722: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2725: aastore
        2726: dup
        2727: bipush        19
        2729: iload         40
        2731: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2734: aastore
        2735: dup
        2736: bipush        20
        2738: aload         38
        2740: aastore
        2741: dup
        2742: bipush        21
        2744: aload         42
        2746: aastore
        2747: dup
        2748: bipush        22
        2750: aload         44
        2752: aastore
        2753: dup
        2754: bipush        23
        2756: aload         46
        2758: aastore
        2759: dup
        2760: bipush        24
        2762: aload         48
        2764: aastore
        2765: dup
        2766: bipush        25
        2768: aload         50
        2770: aastore
        2771: dup
        2772: bipush        26
        2774: aload         52
        2776: aastore
        2777: dup
        2778: bipush        27
        2780: aload         53
        2782: aastore
        2783: dup
        2784: bipush        28
        2786: aload         54
        2788: aastore
        2789: dup
        2790: bipush        29
        2792: aload         55
        2794: aastore
        2795: dup
        2796: bipush        30
        2798: aload         57
        2800: aastore
        2801: dup
        2802: bipush        31
        2804: aload         56
        2806: aastore
        2807: dup
        2808: bipush        32
        2810: aload         58
        2812: aastore
        2813: dup
        2814: bipush        33
        2816: aload         59
        2818: aastore
        2819: dup
        2820: bipush        34
        2822: aload         61
        2824: aastore
        2825: dup
        2826: bipush        35
        2828: aload         62
        2830: aastore
        2831: dup
        2832: bipush        36
        2834: aload         63
        2836: aastore
        2837: dup
        2838: bipush        37
        2840: aload         70
        2842: aastore
        2843: dup
        2844: bipush        38
        2846: aload         72
        2848: aastore
        2849: dup
        2850: bipush        39
        2852: aload         74
        2854: aastore
        2855: dup
        2856: bipush        40
        2858: aload         95
        2860: aastore
        2861: dup
        2862: bipush        41
        2864: aload         96
        2866: aastore
        2867: dup
        2868: bipush        42
        2870: aload         97
        2872: aastore
        2873: dup
        2874: bipush        43
        2876: aload         98
        2878: aastore
        2879: dup
        2880: bipush        44
        2882: aload         99
        2884: aastore
        2885: dup
        2886: bipush        45
        2888: aload         100
        2890: aastore
        2891: dup
        2892: bipush        46
        2894: aload         101
        2896: aastore
        2897: dup
        2898: bipush        47
        2900: aload         102
        2902: aastore
        2903: dup
        2904: bipush        48
        2906: aload         103
        2908: aastore
        2909: dup
        2910: bipush        49
        2912: aload         104
        2914: aastore
        2915: dup
        2916: bipush        50
        2918: aload         105
        2920: aastore
        2921: dup
        2922: bipush        51
        2924: aload         106
        2926: aastore
        2927: dup
        2928: bipush        52
        2930: aload         107
        2932: aastore
        2933: dup
        2934: bipush        53
        2936: aload         108
        2938: aastore
        2939: dup
        2940: bipush        54
        2942: aload         109
        2944: aastore
        2945: dup
        2946: bipush        55
        2948: aload         111
        2950: aastore
        2951: dup
        2952: bipush        56
        2954: aload         110
        2956: aastore
        2957: dup
        2958: bipush        57
        2960: aload         113
        2962: aastore
        2963: dup
        2964: bipush        58
        2966: aload         112
        2968: aastore
        2969: dup
        2970: bipush        59
        2972: aload         76
        2974: aastore
        2975: dup
        2976: bipush        60
        2978: aload         77
        2980: aastore
        2981: dup
        2982: bipush        61
        2984: aload         75
        2986: aastore
        2987: dup
        2988: bipush        62
        2990: aload         147
        2992: aastore
        2993: dup
        2994: bipush        63
        2996: aload         78
        2998: aastore
        2999: dup
        3000: bipush        64
        3002: aload         146
        3004: aastore
        3005: dup
        3006: bipush        65
        3008: aload         80
        3010: aastore
        3011: dup
        3012: bipush        66
        3014: aload         79
        3016: aastore
        3017: dup
        3018: bipush        67
        3020: aload         81
        3022: aastore
        3023: dup
        3024: bipush        68
        3026: aload         82
        3028: aastore
        3029: dup
        3030: bipush        69
        3032: aload         145
        3034: aastore
        3035: dup
        3036: bipush        70
        3038: aload         144
        3040: aastore
        3041: dup
        3042: bipush        71
        3044: aload         83
        3046: aastore
        3047: dup
        3048: bipush        72
        3050: aload         143
        3052: aastore
        3053: dup
        3054: bipush        73
        3056: aload         142
        3058: aastore
        3059: dup
        3060: bipush        74
        3062: aload         141
        3064: aastore
        3065: dup
        3066: bipush        75
        3068: aload         84
        3070: aastore
        3071: dup
        3072: bipush        76
        3074: aload         85
        3076: aastore
        3077: dup
        3078: bipush        77
        3080: aload         140
        3082: aastore
        3083: dup
        3084: bipush        78
        3086: aload         87
        3088: aastore
        3089: dup
        3090: bipush        79
        3092: aload         88
        3094: aastore
        3095: dup
        3096: bipush        80
        3098: aload         86
        3100: aastore
        3101: dup
        3102: bipush        81
        3104: aload         139
        3106: aastore
        3107: dup
        3108: bipush        82
        3110: aload         93
        3112: aastore
        3113: dup
        3114: bipush        83
        3116: aload         89
        3118: aastore
        3119: dup
        3120: bipush        84
        3122: aload         91
        3124: aastore
        3125: dup
        3126: bipush        85
        3128: aload         92
        3130: aastore
        3131: dup
        3132: bipush        86
        3134: aload         138
        3136: aastore
        3137: dup
        3138: bipush        87
        3140: aload         137
        3142: aastore
        3143: dup
        3144: bipush        88
        3146: aload         136
        3148: aastore
        3149: dup
        3150: bipush        89
        3152: aload         135
        3154: aastore
        3155: dup
        3156: bipush        90
        3158: aload         134
        3160: aastore
        3161: dup
        3162: bipush        91
        3164: aload         133
        3166: aastore
        3167: dup
        3168: bipush        92
        3170: aload         132
        3172: aastore
        3173: dup
        3174: bipush        93
        3176: aload         94
        3178: aastore
        3179: dup
        3180: bipush        94
        3182: aload         131
        3184: aastore
        3185: dup
        3186: bipush        95
        3188: aload         130
        3190: aastore
        3191: dup
        3192: bipush        96
        3194: aload         114
        3196: aastore
        3197: dup
        3198: bipush        97
        3200: aload         115
        3202: aastore
        3203: dup
        3204: bipush        98
        3206: aload         121
        3208: aastore
        3209: dup
        3210: bipush        99
        3212: aload         117
        3214: aastore
        3215: dup
        3216: bipush        100
        3218: aload         60
        3220: aastore
        3221: dup
        3222: bipush        101
        3224: aload         90
        3226: aastore
        3227: dup
        3228: bipush        102
        3230: aload         120
        3232: aastore
        3233: dup
        3234: bipush        103
        3236: aload         119
        3238: aastore
        3239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3242: astore        148
        3244: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3247: bipush        45
        3249: aload         148
        3251: aastore
        3252: iconst_0
        3253: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3256: astore        149
        3258: iconst_0
        3259: istore        150
        3261: iload         150
        3263: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3266: astore        151
        3268: goto_w        3273
        3273: iconst_0
        3274: istore        152
        3276: iconst_1
        3277: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3280: astore        153
        3282: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3285: bipush        46
        3287: aaload
        3288: astore        154
        3290: new           #2                  // class Block
        3293: dup
        3294: sipush        248
        3297: iconst_2
        3298: anewarray     #4                  // class java/lang/Object
        3301: dup
        3302: iconst_0
        3303: aload         154
        3305: aastore
        3306: dup
        3307: iconst_1
        3308: aload         153
        3310: aastore
        3311: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3314: astore        155
        3316: new           #415                // class ocaml_fn_94
        3319: dup
        3320: aload         155
        3322: invokespecial #416                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3325: astore        156
        3327: iconst_0
        3328: istore        157
        3330: aload         156
        3332: iload         157
        3334: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3337: invokevirtual #420                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3340: astore        158
        3342: getstatic     #424                // Field java/lang/System.out:Ljava/io/PrintStream;
        3345: aload         158
        3347: checkcast     #29                 // class java/lang/Integer
        3350: invokevirtual #428                // Method java/lang/Integer.intValue:()I
        3353: invokevirtual #434                // Method java/io/PrintStream.println:(I)V
        3356: iconst_0
        3357: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3360: astore        159
        3362: new           #2                  // class Block
        3365: dup
        3366: iconst_0
        3367: iconst_2
        3368: anewarray     #4                  // class java/lang/Object
        3371: dup
        3372: iconst_0
        3373: aload         155
        3375: aastore
        3376: dup
        3377: iconst_1
        3378: aload         156
        3380: aastore
        3381: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3384: astore        160
        3386: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3389: bipush        47
        3391: aload         160
        3393: aastore
        3394: iconst_0
        3395: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3398: astore        161
        3400: iconst_0
        3401: istore        162
        3403: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3406: bipush        45
        3408: aaload
        3409: checkcast     #2                  // class Block
        3412: getfield      #437                // Field Block.fields:[Ljava/lang/Object;
        3415: bipush        102
        3417: aaload
        3418: astore        163
        3420: aload         163
        3422: checkcast     #190                // class Closure
        3425: iload         162
        3427: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3430: invokevirtual #420                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3433: astore        164
        3435: new           #2                  // class Block
        3438: dup
        3439: iconst_0
        3440: iconst_0
        3441: anewarray     #4                  // class java/lang/Object
        3444: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3447: astore        165
        3449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3452: bipush        48
        3454: aload         165
        3456: aastore
        3457: iconst_0
        3458: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3461: astore        166
        3463: return
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
        1061: aconst_null
        1062: astore_1
        1063: aload_1
        1064: astore_2
        1065: goto_w        1070
        1070: new           #106                // class ocaml_fn_0
        1073: dup
        1074: invokespecial #109                // Method ocaml_fn_0."<init>":()V
        1077: astore_3
        1078: new           #111                // class ocaml_fn_1
        1081: dup
        1082: invokespecial #112                // Method ocaml_fn_1."<init>":()V
        1085: astore        4
        1087: new           #114                // class ocaml_fn_2
        1090: dup
        1091: invokespecial #115                // Method ocaml_fn_2."<init>":()V
        1094: astore        5
        1096: new           #2                  // class Block
        1099: dup
        1100: iconst_0
        1101: iconst_3
        1102: anewarray     #4                  // class java/lang/Object
        1105: dup
        1106: iconst_0
        1107: aload         4
        1109: aastore
        1110: dup
        1111: iconst_1
        1112: aload_3
        1113: aastore
        1114: dup
        1115: iconst_2
        1116: aload         5
        1118: aastore
        1119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1122: astore        6
        1124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        12
        1129: aload         6
        1131: aastore
        1132: iconst_0
        1133: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1136: astore        7
        1138: iconst_0
        1139: istore        8
        1141: iload         8
        1143: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1146: astore        9
        1148: goto_w        1153
        1153: sipush        199
        1156: istore        10
        1158: iconst_0
        1159: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1162: astore        11
        1164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1167: bipush        35
        1169: aaload
        1170: astore        12
        1172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1175: iconst_3
        1176: aaload
        1177: astore        13
        1179: new           #2                  // class Block
        1182: dup
        1183: iconst_0
        1184: iconst_2
        1185: anewarray     #4                  // class java/lang/Object
        1188: dup
        1189: iconst_0
        1190: aload         13
        1192: aastore
        1193: dup
        1194: iconst_1
        1195: aload         12
        1197: aastore
        1198: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1201: astore        14
        1203: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1206: bipush        36
        1208: aaload
        1209: astore        15
        1211: iconst_0
        1212: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1215: astore        16
        1217: new           #117                // class ocaml_fn_8
        1220: dup
        1221: invokespecial #118                // Method ocaml_fn_8."<init>":()V
        1224: astore        17
        1226: new           #120                // class ocaml_fn_9
        1229: dup
        1230: invokespecial #121                // Method ocaml_fn_9."<init>":()V
        1233: astore        18
        1235: iconst_0
        1236: istore        19
        1238: iconst_0
        1239: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1242: astore        20
        1244: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1247: bipush        37
        1249: aaload
        1250: astore        21
        1252: new           #2                  // class Block
        1255: dup
        1256: sipush        248
        1259: iconst_2
        1260: anewarray     #4                  // class java/lang/Object
        1263: dup
        1264: iconst_0
        1265: aload         21
        1267: aastore
        1268: dup
        1269: iconst_1
        1270: aload         20
        1272: aastore
        1273: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1276: astore        22
        1278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1281: bipush        7
        1283: aaload
        1284: astore        23
        1286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1289: bipush        10
        1291: aaload
        1292: astore        24
        1294: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1297: iconst_3
        1298: aaload
        1299: astore        25
        1301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1304: iconst_2
        1305: aaload
        1306: astore        26
        1308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1311: bipush        6
        1313: aaload
        1314: astore        27
        1316: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1319: iconst_0
        1320: aaload
        1321: astore        28
        1323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1326: bipush        8
        1328: aaload
        1329: astore        29
        1331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1334: iconst_1
        1335: aaload
        1336: astore        30
        1338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1341: iconst_4
        1342: aaload
        1343: astore        31
        1345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1348: iconst_5
        1349: aaload
        1350: astore        32
        1352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1355: bipush        9
        1357: aaload
        1358: astore        33
        1360: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1363: bipush        11
        1365: aaload
        1366: astore        34
        1368: new           #123                // class ocaml_fn_10
        1371: dup
        1372: invokespecial #124                // Method ocaml_fn_10."<init>":()V
        1375: astore        35
        1377: new           #126                // class ocaml_fn_11
        1380: dup
        1381: invokespecial #127                // Method ocaml_fn_11."<init>":()V
        1384: astore        36
        1386: new           #129                // class ocaml_fn_12
        1389: dup
        1390: invokespecial #130                // Method ocaml_fn_12."<init>":()V
        1393: astore        37
        1395: new           #132                // class ocaml_fn_13
        1398: dup
        1399: invokespecial #133                // Method ocaml_fn_13."<init>":()V
        1402: astore        38
        1404: ldc           #134                // int 2147483647
        1406: istore        39
        1408: ldc           #135                // int -2147483648
        1410: istore        40
        1412: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1415: bipush        38
        1417: aaload
        1418: astore        41
        1420: aload         41
        1422: checkcast     #89                 // class java/lang/Long
        1425: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1428: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1431: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        42
        1436: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        39
        1441: aaload
        1442: astore        43
        1444: aload         43
        1446: checkcast     #89                 // class java/lang/Long
        1449: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1452: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1455: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1458: astore        44
        1460: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1463: bipush        40
        1465: aaload
        1466: astore        45
        1468: aload         45
        1470: checkcast     #89                 // class java/lang/Long
        1473: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1476: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1479: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1482: astore        46
        1484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1487: bipush        41
        1489: aaload
        1490: astore        47
        1492: aload         47
        1494: checkcast     #89                 // class java/lang/Long
        1497: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1500: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1503: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1506: astore        48
        1508: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1511: bipush        42
        1513: aaload
        1514: astore        49
        1516: aload         49
        1518: checkcast     #89                 // class java/lang/Long
        1521: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1524: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1527: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1530: astore        50
        1532: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1535: bipush        43
        1537: aaload
        1538: astore        51
        1540: aload         51
        1542: checkcast     #89                 // class java/lang/Long
        1545: invokevirtual #139                // Method java/lang/Long.longValue:()J
        1548: invokestatic  #145                // Method java/lang/Double.longBitsToDouble:(J)D
        1551: invokestatic  #148                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1554: astore        52
        1556: new           #150                // class ocaml_fn_14
        1559: dup
        1560: invokespecial #151                // Method ocaml_fn_14."<init>":()V
        1563: astore        53
        1565: new           #153                // class ocaml_fn_15
        1568: dup
        1569: aload         18
        1571: invokespecial #156                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1574: astore        54
        1576: new           #158                // class ocaml_fn_16
        1579: dup
        1580: invokespecial #159                // Method ocaml_fn_16."<init>":()V
        1583: astore        55
        1585: new           #161                // class ocaml_fn_17
        1588: dup
        1589: aload         18
        1591: invokespecial #162                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1594: astore        56
        1596: new           #164                // class ocaml_fn_18
        1599: dup
        1600: invokespecial #165                // Method ocaml_fn_18."<init>":()V
        1603: astore        57
        1605: new           #167                // class ocaml_fn_19
        1608: dup
        1609: invokespecial #168                // Method ocaml_fn_19."<init>":()V
        1612: astore        58
        1614: new           #170                // class ocaml_fn_20
        1617: dup
        1618: aload         26
        1620: invokespecial #171                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1623: astore        59
        1625: new           #173                // class ocaml_fn_21
        1628: dup
        1629: aload         53
        1631: invokespecial #174                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1634: astore        60
        1636: new           #176                // class ocaml_fn_22
        1639: dup
        1640: aload         60
        1642: invokespecial #177                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1645: astore        61
        1647: new           #179                // class ocaml_fn_23
        1650: dup
        1651: aload         26
        1653: invokespecial #180                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1656: astore        62
        1658: new           #182                // class ocaml_fn_24
        1661: dup
        1662: invokespecial #183                // Method ocaml_fn_24."<init>":()V
        1665: astore        63
        1667: new           #185                // class ocaml_fn_25
        1670: dup
        1671: invokespecial #186                // Method ocaml_fn_25."<init>":()V
        1674: astore        64
        1676: aload         63
        1678: checkcast     #182                // class ocaml_fn_24
        1681: aload         63
        1683: checkcast     #188                // class Closure
        1686: putfield      #192                // Field ocaml_fn_24.sibling_0:LClosure;
        1689: iconst_0
        1690: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1693: astore        65
        1695: aload         63
        1697: checkcast     #182                // class ocaml_fn_24
        1700: aload         64
        1702: checkcast     #188                // class Closure
        1705: putfield      #195                // Field ocaml_fn_24.sibling_1:LClosure;
        1708: iconst_0
        1709: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1712: astore        66
        1714: aload         64
        1716: checkcast     #185                // class ocaml_fn_25
        1719: aload         63
        1721: checkcast     #188                // class Closure
        1724: putfield      #196                // Field ocaml_fn_25.sibling_0:LClosure;
        1727: iconst_0
        1728: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1731: astore        67
        1733: aload         64
        1735: checkcast     #185                // class ocaml_fn_25
        1738: aload         64
        1740: checkcast     #188                // class Closure
        1743: putfield      #197                // Field ocaml_fn_25.sibling_1:LClosure;
        1746: iconst_0
        1747: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1750: astore        68
        1752: iconst_0
        1753: istore        69
        1755: aconst_null
        1756: astore        70
        1758: iconst_1
        1759: istore        71
        1761: iload         71
        1763: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1766: astore        72
        1768: iconst_2
        1769: istore        73
        1771: iload         73
        1773: invokestatic  #203                // Method Channel.forDescriptor:(I)LChannel;
        1776: astore        74
        1778: new           #205                // class ocaml_fn_26
        1781: dup
        1782: invokespecial #206                // Method ocaml_fn_26."<init>":()V
        1785: astore        75
        1787: new           #208                // class ocaml_fn_27
        1790: dup
        1791: aload         75
        1793: invokespecial #209                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1796: astore        76
        1798: new           #211                // class ocaml_fn_28
        1801: dup
        1802: aload         75
        1804: invokespecial #212                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1807: astore        77
        1809: new           #214                // class ocaml_fn_29
        1812: dup
        1813: aload         30
        1815: invokespecial #215                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1818: astore        78
        1820: new           #217                // class ocaml_fn_30
        1823: dup
        1824: invokespecial #218                // Method ocaml_fn_30."<init>":()V
        1827: astore        79
        1829: new           #220                // class ocaml_fn_31
        1832: dup
        1833: invokespecial #221                // Method ocaml_fn_31."<init>":()V
        1836: astore        80
        1838: new           #223                // class ocaml_fn_32
        1841: dup
        1842: aload         18
        1844: invokespecial #224                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1847: astore        81
        1849: new           #226                // class ocaml_fn_33
        1852: dup
        1853: aload         18
        1855: invokespecial #227                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1858: astore        82
        1860: new           #229                // class ocaml_fn_34
        1863: dup
        1864: invokespecial #230                // Method ocaml_fn_34."<init>":()V
        1867: astore        83
        1869: new           #232                // class ocaml_fn_35
        1872: dup
        1873: invokespecial #233                // Method ocaml_fn_35."<init>":()V
        1876: astore        84
        1878: new           #235                // class ocaml_fn_36
        1881: dup
        1882: invokespecial #236                // Method ocaml_fn_36."<init>":()V
        1885: astore        85
        1887: new           #238                // class ocaml_fn_37
        1890: dup
        1891: invokespecial #239                // Method ocaml_fn_37."<init>":()V
        1894: astore        86
        1896: new           #241                // class ocaml_fn_38
        1899: dup
        1900: aload         86
        1902: invokespecial #242                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1905: astore        87
        1907: new           #244                // class ocaml_fn_39
        1910: dup
        1911: aload         86
        1913: invokespecial #245                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1916: astore        88
        1918: new           #247                // class ocaml_fn_40
        1921: dup
        1922: aload         18
        1924: invokespecial #248                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1927: astore        89
        1929: new           #250                // class ocaml_fn_41
        1932: dup
        1933: aload         31
        1935: invokespecial #251                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1938: astore        90
        1940: new           #253                // class ocaml_fn_42
        1943: dup
        1944: aload         18
        1946: aload         90
        1948: invokespecial #256                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1951: astore        91
        1953: new           #258                // class ocaml_fn_43
        1956: dup
        1957: aload         91
        1959: invokespecial #259                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1962: astore        92
        1964: new           #261                // class ocaml_fn_44
        1967: dup
        1968: aload         31
        1970: invokespecial #262                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1973: astore        93
        1975: new           #264                // class ocaml_fn_45
        1978: dup
        1979: invokespecial #265                // Method ocaml_fn_45."<init>":()V
        1982: astore        94
        1984: new           #267                // class ocaml_fn_46
        1987: dup
        1988: aload         72
        1990: invokespecial #268                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1993: astore        95
        1995: new           #270                // class ocaml_fn_47
        1998: dup
        1999: aload         72
        2001: aload         80
        2003: invokespecial #271                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2006: astore        96
        2008: new           #273                // class ocaml_fn_48
        2011: dup
        2012: aload         72
        2014: aload         79
        2016: invokespecial #274                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2019: astore        97
        2021: new           #276                // class ocaml_fn_49
        2024: dup
        2025: aload         58
        2027: aload         72
        2029: aload         80
        2031: invokespecial #279                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2034: astore        98
        2036: new           #281                // class ocaml_fn_50
        2039: dup
        2040: aload         61
        2042: aload         72
        2044: aload         80
        2046: invokespecial #282                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2049: astore        99
        2051: new           #284                // class ocaml_fn_51
        2054: dup
        2055: aload         72
        2057: aload         80
        2059: invokespecial #285                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        100
        2064: new           #287                // class ocaml_fn_52
        2067: dup
        2068: aload         72
        2070: invokespecial #288                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2073: astore        101
        2075: new           #290                // class ocaml_fn_53
        2078: dup
        2079: aload         74
        2081: invokespecial #291                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2084: astore        102
        2086: new           #293                // class ocaml_fn_54
        2089: dup
        2090: aload         74
        2092: aload         80
        2094: invokespecial #294                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2097: astore        103
        2099: new           #296                // class ocaml_fn_55
        2102: dup
        2103: aload         74
        2105: aload         79
        2107: invokespecial #297                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2110: astore        104
        2112: new           #299                // class ocaml_fn_56
        2115: dup
        2116: aload         58
        2118: aload         74
        2120: aload         80
        2122: invokespecial #300                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2125: astore        105
        2127: new           #302                // class ocaml_fn_57
        2130: dup
        2131: aload         61
        2133: aload         74
        2135: aload         80
        2137: invokespecial #303                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2140: astore        106
        2142: new           #305                // class ocaml_fn_58
        2145: dup
        2146: aload         74
        2148: aload         80
        2150: invokespecial #306                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        107
        2155: new           #308                // class ocaml_fn_59
        2158: dup
        2159: aload         74
        2161: invokespecial #309                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2164: astore        108
        2166: new           #311                // class ocaml_fn_60
        2169: dup
        2170: aload         70
        2172: aload         72
        2174: aload         93
        2176: invokespecial #312                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2179: astore        109
        2181: new           #314                // class ocaml_fn_61
        2184: dup
        2185: aload         109
        2187: invokespecial #315                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2190: astore        110
        2192: new           #317                // class ocaml_fn_62
        2195: dup
        2196: aload         59
        2198: aload         109
        2200: invokespecial #318                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2203: astore        111
        2205: new           #320                // class ocaml_fn_63
        2208: dup
        2209: aload         109
        2211: invokespecial #321                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2214: astore        112
        2216: new           #323                // class ocaml_fn_64
        2219: dup
        2220: aload         62
        2222: aload         109
        2224: invokespecial #324                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2227: astore        113
        2229: new           #326                // class ocaml_fn_65
        2232: dup
        2233: invokespecial #327                // Method ocaml_fn_65."<init>":()V
        2236: astore        114
        2238: new           #329                // class ocaml_fn_66
        2241: dup
        2242: aload         53
        2244: invokespecial #330                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2247: astore        115
        2249: new           #2                  // class Block
        2252: dup
        2253: iconst_0
        2254: iconst_1
        2255: anewarray     #4                  // class java/lang/Object
        2258: dup
        2259: iconst_0
        2260: aload         78
        2262: aastore
        2263: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2266: astore        116
        2268: new           #332                // class ocaml_fn_67
        2271: dup
        2272: aload         116
        2274: invokespecial #333                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2277: astore        117
        2279: new           #335                // class ocaml_fn_68
        2282: dup
        2283: invokespecial #336                // Method ocaml_fn_68."<init>":()V
        2286: astore        118
        2288: new           #2                  // class Block
        2291: dup
        2292: iconst_0
        2293: iconst_1
        2294: anewarray     #4                  // class java/lang/Object
        2297: dup
        2298: iconst_0
        2299: aload         118
        2301: aastore
        2302: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2305: astore        119
        2307: new           #338                // class ocaml_fn_69
        2310: dup
        2311: aload         116
        2313: aload         119
        2315: invokespecial #339                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2318: astore        120
        2320: new           #341                // class ocaml_fn_70
        2323: dup
        2324: aload         120
        2326: invokespecial #342                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2329: astore        121
        2331: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2334: bipush        44
        2336: aaload
        2337: astore        122
        2339: iconst_0
        2340: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2343: astore        123
        2345: new           #344                // class ocaml_fn_71
        2348: dup
        2349: invokespecial #345                // Method ocaml_fn_71."<init>":()V
        2352: astore        124
        2354: new           #347                // class ocaml_fn_72
        2357: dup
        2358: invokespecial #348                // Method ocaml_fn_72."<init>":()V
        2361: astore        125
        2363: new           #350                // class ocaml_fn_73
        2366: dup
        2367: invokespecial #351                // Method ocaml_fn_73."<init>":()V
        2370: astore        126
        2372: new           #353                // class ocaml_fn_74
        2375: dup
        2376: invokespecial #354                // Method ocaml_fn_74."<init>":()V
        2379: astore        127
        2381: new           #356                // class ocaml_fn_75
        2384: dup
        2385: invokespecial #357                // Method ocaml_fn_75."<init>":()V
        2388: astore        128
        2390: new           #359                // class ocaml_fn_76
        2393: dup
        2394: invokespecial #360                // Method ocaml_fn_76."<init>":()V
        2397: astore        129
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: bipush        6
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         129
        2413: aastore
        2414: dup
        2415: iconst_1
        2416: aload         128
        2418: aastore
        2419: dup
        2420: iconst_2
        2421: aload         127
        2423: aastore
        2424: dup
        2425: iconst_3
        2426: aload         126
        2428: aastore
        2429: dup
        2430: iconst_4
        2431: aload         125
        2433: aastore
        2434: dup
        2435: iconst_5
        2436: aload         124
        2438: aastore
        2439: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2442: astore        130
        2444: new           #362                // class ocaml_fn_77
        2447: dup
        2448: invokespecial #363                // Method ocaml_fn_77."<init>":()V
        2451: astore        131
        2453: new           #365                // class ocaml_fn_78
        2456: dup
        2457: invokespecial #366                // Method ocaml_fn_78."<init>":()V
        2460: astore        132
        2462: new           #368                // class ocaml_fn_79
        2465: dup
        2466: invokespecial #369                // Method ocaml_fn_79."<init>":()V
        2469: astore        133
        2471: new           #371                // class ocaml_fn_80
        2474: dup
        2475: invokespecial #372                // Method ocaml_fn_80."<init>":()V
        2478: astore        134
        2480: new           #374                // class ocaml_fn_81
        2483: dup
        2484: invokespecial #375                // Method ocaml_fn_81."<init>":()V
        2487: astore        135
        2489: new           #377                // class ocaml_fn_82
        2492: dup
        2493: invokespecial #378                // Method ocaml_fn_82."<init>":()V
        2496: astore        136
        2498: new           #380                // class ocaml_fn_83
        2501: dup
        2502: invokespecial #381                // Method ocaml_fn_83."<init>":()V
        2505: astore        137
        2507: new           #383                // class ocaml_fn_84
        2510: dup
        2511: invokespecial #384                // Method ocaml_fn_84."<init>":()V
        2514: astore        138
        2516: new           #386                // class ocaml_fn_85
        2519: dup
        2520: invokespecial #387                // Method ocaml_fn_85."<init>":()V
        2523: astore        139
        2525: new           #389                // class ocaml_fn_86
        2528: dup
        2529: invokespecial #390                // Method ocaml_fn_86."<init>":()V
        2532: astore        140
        2534: new           #392                // class ocaml_fn_87
        2537: dup
        2538: invokespecial #393                // Method ocaml_fn_87."<init>":()V
        2541: astore        141
        2543: new           #395                // class ocaml_fn_88
        2546: dup
        2547: invokespecial #396                // Method ocaml_fn_88."<init>":()V
        2550: astore        142
        2552: new           #398                // class ocaml_fn_89
        2555: dup
        2556: invokespecial #399                // Method ocaml_fn_89."<init>":()V
        2559: astore        143
        2561: new           #401                // class ocaml_fn_90
        2564: dup
        2565: invokespecial #402                // Method ocaml_fn_90."<init>":()V
        2568: astore        144
        2570: new           #404                // class ocaml_fn_91
        2573: dup
        2574: invokespecial #405                // Method ocaml_fn_91."<init>":()V
        2577: astore        145
        2579: new           #407                // class ocaml_fn_92
        2582: dup
        2583: invokespecial #408                // Method ocaml_fn_92."<init>":()V
        2586: astore        146
        2588: new           #410                // class ocaml_fn_93
        2591: dup
        2592: invokespecial #411                // Method ocaml_fn_93."<init>":()V
        2595: astore        147
        2597: new           #2                  // class Block
        2600: dup
        2601: iconst_0
        2602: bipush        104
        2604: anewarray     #4                  // class java/lang/Object
        2607: dup
        2608: iconst_0
        2609: aload         18
        2611: aastore
        2612: dup
        2613: iconst_1
        2614: aload         17
        2616: aastore
        2617: dup
        2618: iconst_2
        2619: aload         22
        2621: aastore
        2622: dup
        2623: iconst_3
        2624: aload         23
        2626: aastore
        2627: dup
        2628: iconst_4
        2629: aload         24
        2631: aastore
        2632: dup
        2633: iconst_5
        2634: aload         25
        2636: aastore
        2637: dup
        2638: bipush        6
        2640: aload         26
        2642: aastore
        2643: dup
        2644: bipush        7
        2646: aload         27
        2648: aastore
        2649: dup
        2650: bipush        8
        2652: aload         28
        2654: aastore
        2655: dup
        2656: bipush        9
        2658: aload         29
        2660: aastore
        2661: dup
        2662: bipush        10
        2664: aload         30
        2666: aastore
        2667: dup
        2668: bipush        11
        2670: aload         31
        2672: aastore
        2673: dup
        2674: bipush        12
        2676: aload         32
        2678: aastore
        2679: dup
        2680: bipush        13
        2682: aload         33
        2684: aastore
        2685: dup
        2686: bipush        14
        2688: aload         34
        2690: aastore
        2691: dup
        2692: bipush        15
        2694: aload         35
        2696: aastore
        2697: dup
        2698: bipush        16
        2700: aload         36
        2702: aastore
        2703: dup
        2704: bipush        17
        2706: aload         37
        2708: aastore
        2709: dup
        2710: bipush        18
        2712: iload         39
        2714: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2717: aastore
        2718: dup
        2719: bipush        19
        2721: iload         40
        2723: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2726: aastore
        2727: dup
        2728: bipush        20
        2730: aload         38
        2732: aastore
        2733: dup
        2734: bipush        21
        2736: aload         42
        2738: aastore
        2739: dup
        2740: bipush        22
        2742: aload         44
        2744: aastore
        2745: dup
        2746: bipush        23
        2748: aload         46
        2750: aastore
        2751: dup
        2752: bipush        24
        2754: aload         48
        2756: aastore
        2757: dup
        2758: bipush        25
        2760: aload         50
        2762: aastore
        2763: dup
        2764: bipush        26
        2766: aload         52
        2768: aastore
        2769: dup
        2770: bipush        27
        2772: aload         53
        2774: aastore
        2775: dup
        2776: bipush        28
        2778: aload         54
        2780: aastore
        2781: dup
        2782: bipush        29
        2784: aload         55
        2786: aastore
        2787: dup
        2788: bipush        30
        2790: aload         57
        2792: aastore
        2793: dup
        2794: bipush        31
        2796: aload         56
        2798: aastore
        2799: dup
        2800: bipush        32
        2802: aload         58
        2804: aastore
        2805: dup
        2806: bipush        33
        2808: aload         59
        2810: aastore
        2811: dup
        2812: bipush        34
        2814: aload         61
        2816: aastore
        2817: dup
        2818: bipush        35
        2820: aload         62
        2822: aastore
        2823: dup
        2824: bipush        36
        2826: aload         63
        2828: aastore
        2829: dup
        2830: bipush        37
        2832: aload         70
        2834: aastore
        2835: dup
        2836: bipush        38
        2838: aload         72
        2840: aastore
        2841: dup
        2842: bipush        39
        2844: aload         74
        2846: aastore
        2847: dup
        2848: bipush        40
        2850: aload         95
        2852: aastore
        2853: dup
        2854: bipush        41
        2856: aload         96
        2858: aastore
        2859: dup
        2860: bipush        42
        2862: aload         97
        2864: aastore
        2865: dup
        2866: bipush        43
        2868: aload         98
        2870: aastore
        2871: dup
        2872: bipush        44
        2874: aload         99
        2876: aastore
        2877: dup
        2878: bipush        45
        2880: aload         100
        2882: aastore
        2883: dup
        2884: bipush        46
        2886: aload         101
        2888: aastore
        2889: dup
        2890: bipush        47
        2892: aload         102
        2894: aastore
        2895: dup
        2896: bipush        48
        2898: aload         103
        2900: aastore
        2901: dup
        2902: bipush        49
        2904: aload         104
        2906: aastore
        2907: dup
        2908: bipush        50
        2910: aload         105
        2912: aastore
        2913: dup
        2914: bipush        51
        2916: aload         106
        2918: aastore
        2919: dup
        2920: bipush        52
        2922: aload         107
        2924: aastore
        2925: dup
        2926: bipush        53
        2928: aload         108
        2930: aastore
        2931: dup
        2932: bipush        54
        2934: aload         109
        2936: aastore
        2937: dup
        2938: bipush        55
        2940: aload         111
        2942: aastore
        2943: dup
        2944: bipush        56
        2946: aload         110
        2948: aastore
        2949: dup
        2950: bipush        57
        2952: aload         113
        2954: aastore
        2955: dup
        2956: bipush        58
        2958: aload         112
        2960: aastore
        2961: dup
        2962: bipush        59
        2964: aload         76
        2966: aastore
        2967: dup
        2968: bipush        60
        2970: aload         77
        2972: aastore
        2973: dup
        2974: bipush        61
        2976: aload         75
        2978: aastore
        2979: dup
        2980: bipush        62
        2982: aload         147
        2984: aastore
        2985: dup
        2986: bipush        63
        2988: aload         78
        2990: aastore
        2991: dup
        2992: bipush        64
        2994: aload         146
        2996: aastore
        2997: dup
        2998: bipush        65
        3000: aload         80
        3002: aastore
        3003: dup
        3004: bipush        66
        3006: aload         79
        3008: aastore
        3009: dup
        3010: bipush        67
        3012: aload         81
        3014: aastore
        3015: dup
        3016: bipush        68
        3018: aload         82
        3020: aastore
        3021: dup
        3022: bipush        69
        3024: aload         145
        3026: aastore
        3027: dup
        3028: bipush        70
        3030: aload         144
        3032: aastore
        3033: dup
        3034: bipush        71
        3036: aload         83
        3038: aastore
        3039: dup
        3040: bipush        72
        3042: aload         143
        3044: aastore
        3045: dup
        3046: bipush        73
        3048: aload         142
        3050: aastore
        3051: dup
        3052: bipush        74
        3054: aload         141
        3056: aastore
        3057: dup
        3058: bipush        75
        3060: aload         84
        3062: aastore
        3063: dup
        3064: bipush        76
        3066: aload         85
        3068: aastore
        3069: dup
        3070: bipush        77
        3072: aload         140
        3074: aastore
        3075: dup
        3076: bipush        78
        3078: aload         87
        3080: aastore
        3081: dup
        3082: bipush        79
        3084: aload         88
        3086: aastore
        3087: dup
        3088: bipush        80
        3090: aload         86
        3092: aastore
        3093: dup
        3094: bipush        81
        3096: aload         139
        3098: aastore
        3099: dup
        3100: bipush        82
        3102: aload         93
        3104: aastore
        3105: dup
        3106: bipush        83
        3108: aload         89
        3110: aastore
        3111: dup
        3112: bipush        84
        3114: aload         91
        3116: aastore
        3117: dup
        3118: bipush        85
        3120: aload         92
        3122: aastore
        3123: dup
        3124: bipush        86
        3126: aload         138
        3128: aastore
        3129: dup
        3130: bipush        87
        3132: aload         137
        3134: aastore
        3135: dup
        3136: bipush        88
        3138: aload         136
        3140: aastore
        3141: dup
        3142: bipush        89
        3144: aload         135
        3146: aastore
        3147: dup
        3148: bipush        90
        3150: aload         134
        3152: aastore
        3153: dup
        3154: bipush        91
        3156: aload         133
        3158: aastore
        3159: dup
        3160: bipush        92
        3162: aload         132
        3164: aastore
        3165: dup
        3166: bipush        93
        3168: aload         94
        3170: aastore
        3171: dup
        3172: bipush        94
        3174: aload         131
        3176: aastore
        3177: dup
        3178: bipush        95
        3180: aload         130
        3182: aastore
        3183: dup
        3184: bipush        96
        3186: aload         114
        3188: aastore
        3189: dup
        3190: bipush        97
        3192: aload         115
        3194: aastore
        3195: dup
        3196: bipush        98
        3198: aload         121
        3200: aastore
        3201: dup
        3202: bipush        99
        3204: aload         117
        3206: aastore
        3207: dup
        3208: bipush        100
        3210: aload         60
        3212: aastore
        3213: dup
        3214: bipush        101
        3216: aload         90
        3218: aastore
        3219: dup
        3220: bipush        102
        3222: aload         120
        3224: aastore
        3225: dup
        3226: bipush        103
        3228: aload         119
        3230: aastore
        3231: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3234: astore        148
        3236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3239: bipush        45
        3241: aload         148
        3243: aastore
        3244: iconst_0
        3245: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3248: astore        149
        3250: iconst_1
        3251: istore        150
        3253: iconst_0
        3254: istore        151
        3256: iload         151
        3258: ifeq          3273
        3261: iload         150
        3263: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3266: astore        152
        3268: goto_w        3301
        3273: iload         150
        3275: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3278: astore        153
        3280: goto_w        3285
        3285: bipush        10
        3287: istore        154
        3289: iload         154
        3291: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3294: astore        155
        3296: goto_w        3317
        3301: bipush        20
        3303: istore        156
        3305: iload         156
        3307: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3310: astore        155
        3312: goto_w        3317
        3317: getstatic     #415                // Field java/lang/System.out:Ljava/io/PrintStream;
        3320: aload         155
        3322: checkcast     #29                 // class java/lang/Integer
        3325: invokevirtual #419                // Method java/lang/Integer.intValue:()I
        3328: invokevirtual #425                // Method java/io/PrintStream.println:(I)V
        3331: iconst_0
        3332: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3335: astore        157
        3337: new           #2                  // class Block
        3340: dup
        3341: iconst_0
        3342: iconst_0
        3343: anewarray     #4                  // class java/lang/Object
        3346: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3349: astore        158
        3351: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3354: bipush        46
        3356: aload         158
        3358: aastore
        3359: iconst_0
        3360: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3363: astore        159
        3365: iconst_0
        3366: istore        160
        3368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3371: bipush        45
        3373: aaload
        3374: checkcast     #2                  // class Block
        3377: getfield      #428                // Field Block.fields:[Ljava/lang/Object;
        3380: bipush        102
        3382: aaload
        3383: astore        161
        3385: aload         161
        3387: checkcast     #188                // class Closure
        3390: iload         160
        3392: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3395: invokevirtual #432                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3398: astore        162
        3400: new           #2                  // class Block
        3403: dup
        3404: iconst_0
        3405: iconst_0
        3406: anewarray     #4                  // class java/lang/Object
        3409: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3412: astore        163
        3414: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3417: bipush        47
        3419: aload         163
        3421: aastore
        3422: iconst_0
        3423: invokestatic  #33                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3426: astore        164
        3428: return
    }
    |}]
