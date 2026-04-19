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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #342                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #344                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #346                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #348                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #350                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #352                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #354                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #356                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #358                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #360                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #362                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #364                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #366                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #368                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #370                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #372                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #374                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #376                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #378                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #380                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #382                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #384                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #382                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #384                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #386                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #384                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #382                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #388                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #390                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #392                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #394                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #395                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #395                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #396                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #397                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #398                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #399                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #401                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: ldc_w         #403                // String hi
        1047: aastore
        1048: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1051: bipush        47
        1053: iconst_0
        1054: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1057: aastore
        1058: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1061: bipush        48
        1063: iconst_0
        1064: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1067: aastore
        1068: aconst_null
        1069: astore_1
        1070: aload_1
        1071: astore_2
        1072: goto_w        1077
        1077: new           #2                  // class ocaml_fn_0
        1080: dup
        1081: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1084: astore_3
        1085: new           #8                  // class ocaml_fn_1
        1088: dup
        1089: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1092: astore        4
        1094: new           #11                 // class ocaml_fn_2
        1097: dup
        1098: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1101: astore        5
        1103: new           #14                 // class Block
        1106: dup
        1107: iconst_0
        1108: iconst_3
        1109: anewarray     #16                 // class java/lang/Object
        1112: dup
        1113: iconst_0
        1114: aload         4
        1116: aastore
        1117: dup
        1118: iconst_1
        1119: aload_3
        1120: aastore
        1121: dup
        1122: iconst_2
        1123: aload         5
        1125: aastore
        1126: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1129: astore        6
        1131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1134: bipush        12
        1136: aload         6
        1138: aastore
        1139: iconst_0
        1140: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1143: astore        7
        1145: iconst_0
        1146: istore        8
        1148: iload         8
        1150: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1153: astore        9
        1155: goto_w        1160
        1160: sipush        199
        1163: istore        10
        1165: iconst_0
        1166: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1169: astore        11
        1171: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1174: bipush        35
        1176: aaload
        1177: astore        12
        1179: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1182: iconst_3
        1183: aaload
        1184: astore        13
        1186: new           #14                 // class Block
        1189: dup
        1190: iconst_0
        1191: iconst_2
        1192: anewarray     #16                 // class java/lang/Object
        1195: dup
        1196: iconst_0
        1197: aload         13
        1199: aastore
        1200: dup
        1201: iconst_1
        1202: aload         12
        1204: aastore
        1205: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1208: astore        14
        1210: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1213: bipush        36
        1215: aaload
        1216: astore        15
        1218: iconst_0
        1219: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1222: astore        16
        1224: new           #33                 // class ocaml_fn_8
        1227: dup
        1228: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1231: astore        17
        1233: new           #36                 // class ocaml_fn_9
        1236: dup
        1237: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1240: astore        18
        1242: iconst_0
        1243: istore        19
        1245: iconst_0
        1246: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1249: astore        20
        1251: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1254: bipush        37
        1256: aaload
        1257: astore        21
        1259: new           #14                 // class Block
        1262: dup
        1263: sipush        248
        1266: iconst_2
        1267: anewarray     #16                 // class java/lang/Object
        1270: dup
        1271: iconst_0
        1272: aload         21
        1274: aastore
        1275: dup
        1276: iconst_1
        1277: aload         20
        1279: aastore
        1280: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        22
        1285: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1288: bipush        7
        1290: aaload
        1291: astore        23
        1293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1296: bipush        10
        1298: aaload
        1299: astore        24
        1301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1304: iconst_3
        1305: aaload
        1306: astore        25
        1308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1311: iconst_2
        1312: aaload
        1313: astore        26
        1315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1318: bipush        6
        1320: aaload
        1321: astore        27
        1323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1326: iconst_0
        1327: aaload
        1328: astore        28
        1330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1333: bipush        8
        1335: aaload
        1336: astore        29
        1338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1341: iconst_1
        1342: aaload
        1343: astore        30
        1345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1348: iconst_4
        1349: aaload
        1350: astore        31
        1352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1355: iconst_5
        1356: aaload
        1357: astore        32
        1359: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1362: bipush        9
        1364: aaload
        1365: astore        33
        1367: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1370: bipush        11
        1372: aaload
        1373: astore        34
        1375: new           #39                 // class ocaml_fn_10
        1378: dup
        1379: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1382: astore        35
        1384: new           #42                 // class ocaml_fn_11
        1387: dup
        1388: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1391: astore        36
        1393: new           #45                 // class ocaml_fn_12
        1396: dup
        1397: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1400: astore        37
        1402: new           #48                 // class ocaml_fn_13
        1405: dup
        1406: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1409: astore        38
        1411: iconst_1
        1412: istore        39
        1414: iconst_m1
        1415: istore        40
        1417: iload         40
        1419: iload         39
        1421: iushr
        1422: istore        41
        1424: iconst_1
        1425: istore        42
        1427: iload         41
        1429: iload         42
        1431: iadd
        1432: istore        43
        1434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1437: bipush        38
        1439: aaload
        1440: astore        44
        1442: ldc2_w        #50                 // double 0.0d
        1445: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1448: astore        45
        1450: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1453: bipush        39
        1455: aaload
        1456: astore        46
        1458: ldc2_w        #50                 // double 0.0d
        1461: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1464: astore        47
        1466: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1469: bipush        40
        1471: aaload
        1472: astore        48
        1474: ldc2_w        #50                 // double 0.0d
        1477: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1480: astore        49
        1482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1485: bipush        41
        1487: aaload
        1488: astore        50
        1490: ldc2_w        #50                 // double 0.0d
        1493: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1496: astore        51
        1498: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1501: bipush        42
        1503: aaload
        1504: astore        52
        1506: ldc2_w        #50                 // double 0.0d
        1509: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1512: astore        53
        1514: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1517: bipush        43
        1519: aaload
        1520: astore        54
        1522: ldc2_w        #50                 // double 0.0d
        1525: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1528: astore        55
        1530: new           #58                 // class ocaml_fn_14
        1533: dup
        1534: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1537: astore        56
        1539: new           #61                 // class ocaml_fn_15
        1542: dup
        1543: aload         18
        1545: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1548: astore        57
        1550: new           #66                 // class ocaml_fn_16
        1553: dup
        1554: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1557: astore        58
        1559: new           #69                 // class ocaml_fn_17
        1562: dup
        1563: aload         18
        1565: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1568: astore        59
        1570: new           #72                 // class ocaml_fn_18
        1573: dup
        1574: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1577: astore        60
        1579: new           #75                 // class ocaml_fn_19
        1582: dup
        1583: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1586: astore        61
        1588: new           #78                 // class ocaml_fn_20
        1591: dup
        1592: aload         26
        1594: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1597: astore        62
        1599: new           #81                 // class ocaml_fn_21
        1602: dup
        1603: aload         56
        1605: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1608: astore        63
        1610: new           #84                 // class ocaml_fn_22
        1613: dup
        1614: aload         63
        1616: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1619: astore        64
        1621: new           #87                 // class ocaml_fn_23
        1624: dup
        1625: aload         26
        1627: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1630: astore        65
        1632: new           #90                 // class ocaml_fn_24
        1635: dup
        1636: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1639: astore        66
        1641: new           #93                 // class ocaml_fn_25
        1644: dup
        1645: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1648: astore        67
        1650: aload         66
        1652: checkcast     #90                 // class ocaml_fn_24
        1655: aload         66
        1657: checkcast     #96                 // class Closure
        1660: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1663: iconst_0
        1664: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1667: astore        68
        1669: aload         66
        1671: checkcast     #90                 // class ocaml_fn_24
        1674: aload         67
        1676: checkcast     #96                 // class Closure
        1679: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1682: iconst_0
        1683: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1686: astore        69
        1688: aload         67
        1690: checkcast     #93                 // class ocaml_fn_25
        1693: aload         66
        1695: checkcast     #96                 // class Closure
        1698: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1701: iconst_0
        1702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1705: astore        70
        1707: aload         67
        1709: checkcast     #93                 // class ocaml_fn_25
        1712: aload         67
        1714: checkcast     #96                 // class Closure
        1717: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1720: iconst_0
        1721: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1724: astore        71
        1726: iconst_0
        1727: istore        72
        1729: aconst_null
        1730: astore        73
        1732: iconst_1
        1733: istore        74
        1735: iload         74
        1737: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1740: astore        75
        1742: iconst_2
        1743: istore        76
        1745: iload         76
        1747: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1750: astore        77
        1752: new           #113                // class ocaml_fn_26
        1755: dup
        1756: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1759: astore        78
        1761: new           #116                // class ocaml_fn_27
        1764: dup
        1765: aload         78
        1767: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1770: astore        79
        1772: new           #119                // class ocaml_fn_28
        1775: dup
        1776: aload         78
        1778: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1781: astore        80
        1783: new           #122                // class ocaml_fn_29
        1786: dup
        1787: aload         30
        1789: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1792: astore        81
        1794: new           #125                // class ocaml_fn_30
        1797: dup
        1798: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1801: astore        82
        1803: new           #128                // class ocaml_fn_31
        1806: dup
        1807: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1810: astore        83
        1812: new           #131                // class ocaml_fn_32
        1815: dup
        1816: aload         18
        1818: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1821: astore        84
        1823: new           #134                // class ocaml_fn_33
        1826: dup
        1827: aload         18
        1829: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1832: astore        85
        1834: new           #137                // class ocaml_fn_34
        1837: dup
        1838: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1841: astore        86
        1843: new           #140                // class ocaml_fn_35
        1846: dup
        1847: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1850: astore        87
        1852: new           #143                // class ocaml_fn_36
        1855: dup
        1856: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1859: astore        88
        1861: new           #146                // class ocaml_fn_37
        1864: dup
        1865: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1868: astore        89
        1870: new           #149                // class ocaml_fn_38
        1873: dup
        1874: aload         89
        1876: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1879: astore        90
        1881: new           #152                // class ocaml_fn_39
        1884: dup
        1885: aload         89
        1887: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1890: astore        91
        1892: new           #155                // class ocaml_fn_40
        1895: dup
        1896: aload         18
        1898: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1901: astore        92
        1903: new           #158                // class ocaml_fn_41
        1906: dup
        1907: aload         31
        1909: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1912: astore        93
        1914: new           #161                // class ocaml_fn_42
        1917: dup
        1918: aload         18
        1920: aload         93
        1922: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1925: astore        94
        1927: new           #166                // class ocaml_fn_43
        1930: dup
        1931: aload         94
        1933: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1936: astore        95
        1938: new           #169                // class ocaml_fn_44
        1941: dup
        1942: aload         31
        1944: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1947: astore        96
        1949: new           #172                // class ocaml_fn_45
        1952: dup
        1953: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1956: astore        97
        1958: new           #175                // class ocaml_fn_46
        1961: dup
        1962: aload         75
        1964: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1967: astore        98
        1969: new           #178                // class ocaml_fn_47
        1972: dup
        1973: aload         75
        1975: aload         83
        1977: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1980: astore        99
        1982: new           #181                // class ocaml_fn_48
        1985: dup
        1986: aload         75
        1988: aload         82
        1990: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1993: astore        100
        1995: new           #184                // class ocaml_fn_49
        1998: dup
        1999: aload         61
        2001: aload         75
        2003: aload         83
        2005: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        101
        2010: new           #189                // class ocaml_fn_50
        2013: dup
        2014: aload         64
        2016: aload         75
        2018: aload         83
        2020: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2023: astore        102
        2025: new           #192                // class ocaml_fn_51
        2028: dup
        2029: aload         75
        2031: aload         83
        2033: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2036: astore        103
        2038: new           #195                // class ocaml_fn_52
        2041: dup
        2042: aload         75
        2044: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2047: astore        104
        2049: new           #198                // class ocaml_fn_53
        2052: dup
        2053: aload         77
        2055: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2058: astore        105
        2060: new           #201                // class ocaml_fn_54
        2063: dup
        2064: aload         77
        2066: aload         83
        2068: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2071: astore        106
        2073: new           #204                // class ocaml_fn_55
        2076: dup
        2077: aload         77
        2079: aload         82
        2081: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2084: astore        107
        2086: new           #207                // class ocaml_fn_56
        2089: dup
        2090: aload         61
        2092: aload         77
        2094: aload         83
        2096: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        108
        2101: new           #210                // class ocaml_fn_57
        2104: dup
        2105: aload         64
        2107: aload         77
        2109: aload         83
        2111: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2114: astore        109
        2116: new           #213                // class ocaml_fn_58
        2119: dup
        2120: aload         77
        2122: aload         83
        2124: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2127: astore        110
        2129: new           #216                // class ocaml_fn_59
        2132: dup
        2133: aload         77
        2135: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2138: astore        111
        2140: new           #219                // class ocaml_fn_60
        2143: dup
        2144: aload         73
        2146: aload         75
        2148: aload         96
        2150: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        112
        2155: new           #222                // class ocaml_fn_61
        2158: dup
        2159: aload         112
        2161: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2164: astore        113
        2166: new           #225                // class ocaml_fn_62
        2169: dup
        2170: aload         62
        2172: aload         112
        2174: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2177: astore        114
        2179: new           #228                // class ocaml_fn_63
        2182: dup
        2183: aload         112
        2185: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2188: astore        115
        2190: new           #231                // class ocaml_fn_64
        2193: dup
        2194: aload         65
        2196: aload         112
        2198: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2201: astore        116
        2203: new           #14                 // class Block
        2206: dup
        2207: iconst_0
        2208: iconst_0
        2209: anewarray     #16                 // class java/lang/Object
        2212: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2215: astore        117
        2217: new           #234                // class ocaml_fn_65
        2220: dup
        2221: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2224: astore        118
        2226: new           #237                // class ocaml_fn_66
        2229: dup
        2230: aload         56
        2232: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2235: astore        119
        2237: new           #14                 // class Block
        2240: dup
        2241: iconst_0
        2242: iconst_1
        2243: anewarray     #16                 // class java/lang/Object
        2246: dup
        2247: iconst_0
        2248: aload         81
        2250: aastore
        2251: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2254: astore        120
        2256: new           #240                // class ocaml_fn_67
        2259: dup
        2260: aload         120
        2262: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2265: astore        121
        2267: new           #243                // class ocaml_fn_68
        2270: dup
        2271: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2274: astore        122
        2276: new           #14                 // class Block
        2279: dup
        2280: iconst_0
        2281: iconst_1
        2282: anewarray     #16                 // class java/lang/Object
        2285: dup
        2286: iconst_0
        2287: aload         122
        2289: aastore
        2290: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2293: astore        123
        2295: new           #246                // class ocaml_fn_69
        2298: dup
        2299: aload         120
        2301: aload         123
        2303: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2306: astore        124
        2308: new           #249                // class ocaml_fn_70
        2311: dup
        2312: aload         124
        2314: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2317: astore        125
        2319: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2322: bipush        44
        2324: aaload
        2325: astore        126
        2327: iconst_0
        2328: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2331: astore        127
        2333: new           #252                // class ocaml_fn_71
        2336: dup
        2337: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2340: astore        128
        2342: new           #255                // class ocaml_fn_72
        2345: dup
        2346: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2349: astore        129
        2351: new           #258                // class ocaml_fn_73
        2354: dup
        2355: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2358: astore        130
        2360: new           #261                // class ocaml_fn_74
        2363: dup
        2364: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2367: astore        131
        2369: new           #264                // class ocaml_fn_75
        2372: dup
        2373: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2376: astore        132
        2378: new           #267                // class ocaml_fn_76
        2381: dup
        2382: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2385: astore        133
        2387: new           #14                 // class Block
        2390: dup
        2391: iconst_0
        2392: bipush        6
        2394: anewarray     #16                 // class java/lang/Object
        2397: dup
        2398: iconst_0
        2399: aload         133
        2401: aastore
        2402: dup
        2403: iconst_1
        2404: aload         132
        2406: aastore
        2407: dup
        2408: iconst_2
        2409: aload         131
        2411: aastore
        2412: dup
        2413: iconst_3
        2414: aload         130
        2416: aastore
        2417: dup
        2418: iconst_4
        2419: aload         129
        2421: aastore
        2422: dup
        2423: iconst_5
        2424: aload         128
        2426: aastore
        2427: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2430: astore        134
        2432: new           #270                // class ocaml_fn_77
        2435: dup
        2436: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2439: astore        135
        2441: new           #273                // class ocaml_fn_78
        2444: dup
        2445: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2448: astore        136
        2450: new           #276                // class ocaml_fn_79
        2453: dup
        2454: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2457: astore        137
        2459: new           #279                // class ocaml_fn_80
        2462: dup
        2463: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2466: astore        138
        2468: new           #282                // class ocaml_fn_81
        2471: dup
        2472: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2475: astore        139
        2477: new           #285                // class ocaml_fn_82
        2480: dup
        2481: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2484: astore        140
        2486: new           #288                // class ocaml_fn_83
        2489: dup
        2490: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2493: astore        141
        2495: new           #291                // class ocaml_fn_84
        2498: dup
        2499: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2502: astore        142
        2504: new           #294                // class ocaml_fn_85
        2507: dup
        2508: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2511: astore        143
        2513: new           #297                // class ocaml_fn_86
        2516: dup
        2517: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2520: astore        144
        2522: new           #300                // class ocaml_fn_87
        2525: dup
        2526: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2529: astore        145
        2531: new           #303                // class ocaml_fn_88
        2534: dup
        2535: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2538: astore        146
        2540: new           #306                // class ocaml_fn_89
        2543: dup
        2544: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2547: astore        147
        2549: new           #309                // class ocaml_fn_90
        2552: dup
        2553: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2556: astore        148
        2558: new           #312                // class ocaml_fn_91
        2561: dup
        2562: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2565: astore        149
        2567: new           #315                // class ocaml_fn_92
        2570: dup
        2571: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2574: astore        150
        2576: new           #318                // class ocaml_fn_93
        2579: dup
        2580: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2583: astore        151
        2585: new           #14                 // class Block
        2588: dup
        2589: iconst_0
        2590: bipush        104
        2592: anewarray     #16                 // class java/lang/Object
        2595: dup
        2596: iconst_0
        2597: aload         18
        2599: aastore
        2600: dup
        2601: iconst_1
        2602: aload         17
        2604: aastore
        2605: dup
        2606: iconst_2
        2607: aload         22
        2609: aastore
        2610: dup
        2611: iconst_3
        2612: aload         23
        2614: aastore
        2615: dup
        2616: iconst_4
        2617: aload         24
        2619: aastore
        2620: dup
        2621: iconst_5
        2622: aload         25
        2624: aastore
        2625: dup
        2626: bipush        6
        2628: aload         26
        2630: aastore
        2631: dup
        2632: bipush        7
        2634: aload         27
        2636: aastore
        2637: dup
        2638: bipush        8
        2640: aload         28
        2642: aastore
        2643: dup
        2644: bipush        9
        2646: aload         29
        2648: aastore
        2649: dup
        2650: bipush        10
        2652: aload         30
        2654: aastore
        2655: dup
        2656: bipush        11
        2658: aload         31
        2660: aastore
        2661: dup
        2662: bipush        12
        2664: aload         32
        2666: aastore
        2667: dup
        2668: bipush        13
        2670: aload         33
        2672: aastore
        2673: dup
        2674: bipush        14
        2676: aload         34
        2678: aastore
        2679: dup
        2680: bipush        15
        2682: aload         35
        2684: aastore
        2685: dup
        2686: bipush        16
        2688: aload         36
        2690: aastore
        2691: dup
        2692: bipush        17
        2694: aload         37
        2696: aastore
        2697: dup
        2698: bipush        18
        2700: iload         41
        2702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2705: aastore
        2706: dup
        2707: bipush        19
        2709: iload         43
        2711: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2714: aastore
        2715: dup
        2716: bipush        20
        2718: aload         38
        2720: aastore
        2721: dup
        2722: bipush        21
        2724: aload         45
        2726: aastore
        2727: dup
        2728: bipush        22
        2730: aload         47
        2732: aastore
        2733: dup
        2734: bipush        23
        2736: aload         49
        2738: aastore
        2739: dup
        2740: bipush        24
        2742: aload         51
        2744: aastore
        2745: dup
        2746: bipush        25
        2748: aload         53
        2750: aastore
        2751: dup
        2752: bipush        26
        2754: aload         55
        2756: aastore
        2757: dup
        2758: bipush        27
        2760: aload         56
        2762: aastore
        2763: dup
        2764: bipush        28
        2766: aload         57
        2768: aastore
        2769: dup
        2770: bipush        29
        2772: aload         58
        2774: aastore
        2775: dup
        2776: bipush        30
        2778: aload         60
        2780: aastore
        2781: dup
        2782: bipush        31
        2784: aload         59
        2786: aastore
        2787: dup
        2788: bipush        32
        2790: aload         61
        2792: aastore
        2793: dup
        2794: bipush        33
        2796: aload         62
        2798: aastore
        2799: dup
        2800: bipush        34
        2802: aload         64
        2804: aastore
        2805: dup
        2806: bipush        35
        2808: aload         65
        2810: aastore
        2811: dup
        2812: bipush        36
        2814: aload         66
        2816: aastore
        2817: dup
        2818: bipush        37
        2820: aload         73
        2822: aastore
        2823: dup
        2824: bipush        38
        2826: aload         75
        2828: aastore
        2829: dup
        2830: bipush        39
        2832: aload         77
        2834: aastore
        2835: dup
        2836: bipush        40
        2838: aload         98
        2840: aastore
        2841: dup
        2842: bipush        41
        2844: aload         99
        2846: aastore
        2847: dup
        2848: bipush        42
        2850: aload         100
        2852: aastore
        2853: dup
        2854: bipush        43
        2856: aload         101
        2858: aastore
        2859: dup
        2860: bipush        44
        2862: aload         102
        2864: aastore
        2865: dup
        2866: bipush        45
        2868: aload         103
        2870: aastore
        2871: dup
        2872: bipush        46
        2874: aload         104
        2876: aastore
        2877: dup
        2878: bipush        47
        2880: aload         105
        2882: aastore
        2883: dup
        2884: bipush        48
        2886: aload         106
        2888: aastore
        2889: dup
        2890: bipush        49
        2892: aload         107
        2894: aastore
        2895: dup
        2896: bipush        50
        2898: aload         108
        2900: aastore
        2901: dup
        2902: bipush        51
        2904: aload         109
        2906: aastore
        2907: dup
        2908: bipush        52
        2910: aload         110
        2912: aastore
        2913: dup
        2914: bipush        53
        2916: aload         111
        2918: aastore
        2919: dup
        2920: bipush        54
        2922: aload         112
        2924: aastore
        2925: dup
        2926: bipush        55
        2928: aload         114
        2930: aastore
        2931: dup
        2932: bipush        56
        2934: aload         113
        2936: aastore
        2937: dup
        2938: bipush        57
        2940: aload         116
        2942: aastore
        2943: dup
        2944: bipush        58
        2946: aload         115
        2948: aastore
        2949: dup
        2950: bipush        59
        2952: aload         79
        2954: aastore
        2955: dup
        2956: bipush        60
        2958: aload         80
        2960: aastore
        2961: dup
        2962: bipush        61
        2964: aload         78
        2966: aastore
        2967: dup
        2968: bipush        62
        2970: aload         151
        2972: aastore
        2973: dup
        2974: bipush        63
        2976: aload         81
        2978: aastore
        2979: dup
        2980: bipush        64
        2982: aload         150
        2984: aastore
        2985: dup
        2986: bipush        65
        2988: aload         83
        2990: aastore
        2991: dup
        2992: bipush        66
        2994: aload         82
        2996: aastore
        2997: dup
        2998: bipush        67
        3000: aload         84
        3002: aastore
        3003: dup
        3004: bipush        68
        3006: aload         85
        3008: aastore
        3009: dup
        3010: bipush        69
        3012: aload         149
        3014: aastore
        3015: dup
        3016: bipush        70
        3018: aload         148
        3020: aastore
        3021: dup
        3022: bipush        71
        3024: aload         86
        3026: aastore
        3027: dup
        3028: bipush        72
        3030: aload         147
        3032: aastore
        3033: dup
        3034: bipush        73
        3036: aload         146
        3038: aastore
        3039: dup
        3040: bipush        74
        3042: aload         145
        3044: aastore
        3045: dup
        3046: bipush        75
        3048: aload         87
        3050: aastore
        3051: dup
        3052: bipush        76
        3054: aload         88
        3056: aastore
        3057: dup
        3058: bipush        77
        3060: aload         144
        3062: aastore
        3063: dup
        3064: bipush        78
        3066: aload         90
        3068: aastore
        3069: dup
        3070: bipush        79
        3072: aload         91
        3074: aastore
        3075: dup
        3076: bipush        80
        3078: aload         89
        3080: aastore
        3081: dup
        3082: bipush        81
        3084: aload         143
        3086: aastore
        3087: dup
        3088: bipush        82
        3090: aload         96
        3092: aastore
        3093: dup
        3094: bipush        83
        3096: aload         92
        3098: aastore
        3099: dup
        3100: bipush        84
        3102: aload         94
        3104: aastore
        3105: dup
        3106: bipush        85
        3108: aload         95
        3110: aastore
        3111: dup
        3112: bipush        86
        3114: aload         142
        3116: aastore
        3117: dup
        3118: bipush        87
        3120: aload         141
        3122: aastore
        3123: dup
        3124: bipush        88
        3126: aload         140
        3128: aastore
        3129: dup
        3130: bipush        89
        3132: aload         139
        3134: aastore
        3135: dup
        3136: bipush        90
        3138: aload         138
        3140: aastore
        3141: dup
        3142: bipush        91
        3144: aload         137
        3146: aastore
        3147: dup
        3148: bipush        92
        3150: aload         136
        3152: aastore
        3153: dup
        3154: bipush        93
        3156: aload         97
        3158: aastore
        3159: dup
        3160: bipush        94
        3162: aload         135
        3164: aastore
        3165: dup
        3166: bipush        95
        3168: aload         134
        3170: aastore
        3171: dup
        3172: bipush        96
        3174: aload         118
        3176: aastore
        3177: dup
        3178: bipush        97
        3180: aload         119
        3182: aastore
        3183: dup
        3184: bipush        98
        3186: aload         125
        3188: aastore
        3189: dup
        3190: bipush        99
        3192: aload         121
        3194: aastore
        3195: dup
        3196: bipush        100
        3198: aload         63
        3200: aastore
        3201: dup
        3202: bipush        101
        3204: aload         93
        3206: aastore
        3207: dup
        3208: bipush        102
        3210: aload         124
        3212: aastore
        3213: dup
        3214: bipush        103
        3216: aload         123
        3218: aastore
        3219: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3222: astore        152
        3224: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3227: bipush        45
        3229: aload         152
        3231: aastore
        3232: iconst_0
        3233: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3236: astore        153
        3238: iconst_0
        3239: istore        154
        3241: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3244: bipush        46
        3246: aaload
        3247: astore        155
        3249: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3252: aload         155
        3254: checkcast     #327                // class java/lang/String
        3257: invokevirtual #333                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3260: iconst_0
        3261: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3264: astore        156
        3266: new           #14                 // class Block
        3269: dup
        3270: iconst_0
        3271: iconst_0
        3272: anewarray     #16                 // class java/lang/Object
        3275: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3278: astore        157
        3280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3283: bipush        47
        3285: aload         157
        3287: aastore
        3288: iconst_0
        3289: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3292: astore        158
        3294: iconst_0
        3295: istore        159
        3297: iconst_0
        3298: istore        160
        3300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3303: bipush        45
        3305: aaload
        3306: checkcast     #14                 // class Block
        3309: getfield      #336                // Field Block.fields:[Ljava/lang/Object;
        3312: bipush        102
        3314: aaload
        3315: astore        161
        3317: aload         161
        3319: checkcast     #96                 // class Closure
        3322: iload         160
        3324: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3327: invokevirtual #340                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3330: astore        162
        3332: new           #14                 // class Block
        3335: dup
        3336: iconst_0
        3337: iconst_0
        3338: anewarray     #16                 // class java/lang/Object
        3341: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3344: astore        163
        3346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3349: bipush        48
        3351: aload         163
        3353: aastore
        3354: iconst_0
        3355: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3358: astore        164
        3360: iconst_0
        3361: istore        165
        3363: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #340                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #342                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #344                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #346                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #348                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #350                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #352                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #354                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #356                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #358                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #360                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #362                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #364                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #366                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #368                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #370                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #372                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #374                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #376                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #378                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #380                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #382                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #380                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #382                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #384                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #382                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #380                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #386                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #388                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #390                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #392                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #393                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #393                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #394                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #395                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #396                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #397                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #399                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: iconst_0
        1045: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1048: aastore
        1049: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1052: bipush        47
        1054: iconst_0
        1055: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1058: aastore
        1059: aconst_null
        1060: astore_1
        1061: aload_1
        1062: astore_2
        1063: goto_w        1068
        1068: new           #2                  // class ocaml_fn_0
        1071: dup
        1072: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1075: astore_3
        1076: new           #8                  // class ocaml_fn_1
        1079: dup
        1080: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1083: astore        4
        1085: new           #11                 // class ocaml_fn_2
        1088: dup
        1089: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1092: astore        5
        1094: new           #14                 // class Block
        1097: dup
        1098: iconst_0
        1099: iconst_3
        1100: anewarray     #16                 // class java/lang/Object
        1103: dup
        1104: iconst_0
        1105: aload         4
        1107: aastore
        1108: dup
        1109: iconst_1
        1110: aload_3
        1111: aastore
        1112: dup
        1113: iconst_2
        1114: aload         5
        1116: aastore
        1117: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1120: astore        6
        1122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1125: bipush        12
        1127: aload         6
        1129: aastore
        1130: iconst_0
        1131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1134: astore        7
        1136: iconst_0
        1137: istore        8
        1139: iload         8
        1141: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        9
        1146: goto_w        1151
        1151: sipush        199
        1154: istore        10
        1156: iconst_0
        1157: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1160: astore        11
        1162: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1165: bipush        35
        1167: aaload
        1168: astore        12
        1170: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1173: iconst_3
        1174: aaload
        1175: astore        13
        1177: new           #14                 // class Block
        1180: dup
        1181: iconst_0
        1182: iconst_2
        1183: anewarray     #16                 // class java/lang/Object
        1186: dup
        1187: iconst_0
        1188: aload         13
        1190: aastore
        1191: dup
        1192: iconst_1
        1193: aload         12
        1195: aastore
        1196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1199: astore        14
        1201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1204: bipush        36
        1206: aaload
        1207: astore        15
        1209: iconst_0
        1210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1213: astore        16
        1215: new           #33                 // class ocaml_fn_8
        1218: dup
        1219: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1222: astore        17
        1224: new           #36                 // class ocaml_fn_9
        1227: dup
        1228: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1231: astore        18
        1233: iconst_0
        1234: istore        19
        1236: iconst_0
        1237: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1240: astore        20
        1242: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1245: bipush        37
        1247: aaload
        1248: astore        21
        1250: new           #14                 // class Block
        1253: dup
        1254: sipush        248
        1257: iconst_2
        1258: anewarray     #16                 // class java/lang/Object
        1261: dup
        1262: iconst_0
        1263: aload         21
        1265: aastore
        1266: dup
        1267: iconst_1
        1268: aload         20
        1270: aastore
        1271: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1274: astore        22
        1276: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1279: bipush        7
        1281: aaload
        1282: astore        23
        1284: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1287: bipush        10
        1289: aaload
        1290: astore        24
        1292: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1295: iconst_3
        1296: aaload
        1297: astore        25
        1299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1302: iconst_2
        1303: aaload
        1304: astore        26
        1306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1309: bipush        6
        1311: aaload
        1312: astore        27
        1314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1317: iconst_0
        1318: aaload
        1319: astore        28
        1321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1324: bipush        8
        1326: aaload
        1327: astore        29
        1329: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1332: iconst_1
        1333: aaload
        1334: astore        30
        1336: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1339: iconst_4
        1340: aaload
        1341: astore        31
        1343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1346: iconst_5
        1347: aaload
        1348: astore        32
        1350: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1353: bipush        9
        1355: aaload
        1356: astore        33
        1358: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1361: bipush        11
        1363: aaload
        1364: astore        34
        1366: new           #39                 // class ocaml_fn_10
        1369: dup
        1370: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1373: astore        35
        1375: new           #42                 // class ocaml_fn_11
        1378: dup
        1379: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1382: astore        36
        1384: new           #45                 // class ocaml_fn_12
        1387: dup
        1388: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1391: astore        37
        1393: new           #48                 // class ocaml_fn_13
        1396: dup
        1397: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1400: astore        38
        1402: iconst_1
        1403: istore        39
        1405: iconst_m1
        1406: istore        40
        1408: iload         40
        1410: iload         39
        1412: iushr
        1413: istore        41
        1415: iconst_1
        1416: istore        42
        1418: iload         41
        1420: iload         42
        1422: iadd
        1423: istore        43
        1425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1428: bipush        38
        1430: aaload
        1431: astore        44
        1433: ldc2_w        #50                 // double 0.0d
        1436: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        45
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        46
        1449: ldc2_w        #50                 // double 0.0d
        1452: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1455: astore        47
        1457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1460: bipush        40
        1462: aaload
        1463: astore        48
        1465: ldc2_w        #50                 // double 0.0d
        1468: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1471: astore        49
        1473: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1476: bipush        41
        1478: aaload
        1479: astore        50
        1481: ldc2_w        #50                 // double 0.0d
        1484: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1487: astore        51
        1489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1492: bipush        42
        1494: aaload
        1495: astore        52
        1497: ldc2_w        #50                 // double 0.0d
        1500: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1503: astore        53
        1505: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1508: bipush        43
        1510: aaload
        1511: astore        54
        1513: ldc2_w        #50                 // double 0.0d
        1516: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1519: astore        55
        1521: new           #58                 // class ocaml_fn_14
        1524: dup
        1525: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1528: astore        56
        1530: new           #61                 // class ocaml_fn_15
        1533: dup
        1534: aload         18
        1536: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1539: astore        57
        1541: new           #66                 // class ocaml_fn_16
        1544: dup
        1545: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1548: astore        58
        1550: new           #69                 // class ocaml_fn_17
        1553: dup
        1554: aload         18
        1556: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1559: astore        59
        1561: new           #72                 // class ocaml_fn_18
        1564: dup
        1565: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1568: astore        60
        1570: new           #75                 // class ocaml_fn_19
        1573: dup
        1574: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1577: astore        61
        1579: new           #78                 // class ocaml_fn_20
        1582: dup
        1583: aload         26
        1585: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1588: astore        62
        1590: new           #81                 // class ocaml_fn_21
        1593: dup
        1594: aload         56
        1596: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1599: astore        63
        1601: new           #84                 // class ocaml_fn_22
        1604: dup
        1605: aload         63
        1607: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1610: astore        64
        1612: new           #87                 // class ocaml_fn_23
        1615: dup
        1616: aload         26
        1618: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1621: astore        65
        1623: new           #90                 // class ocaml_fn_24
        1626: dup
        1627: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1630: astore        66
        1632: new           #93                 // class ocaml_fn_25
        1635: dup
        1636: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1639: astore        67
        1641: aload         66
        1643: checkcast     #90                 // class ocaml_fn_24
        1646: aload         66
        1648: checkcast     #96                 // class Closure
        1651: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1654: iconst_0
        1655: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        68
        1660: aload         66
        1662: checkcast     #90                 // class ocaml_fn_24
        1665: aload         67
        1667: checkcast     #96                 // class Closure
        1670: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1673: iconst_0
        1674: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        69
        1679: aload         67
        1681: checkcast     #93                 // class ocaml_fn_25
        1684: aload         66
        1686: checkcast     #96                 // class Closure
        1689: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1692: iconst_0
        1693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        70
        1698: aload         67
        1700: checkcast     #93                 // class ocaml_fn_25
        1703: aload         67
        1705: checkcast     #96                 // class Closure
        1708: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1711: iconst_0
        1712: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1715: astore        71
        1717: iconst_0
        1718: istore        72
        1720: aconst_null
        1721: astore        73
        1723: iconst_1
        1724: istore        74
        1726: iload         74
        1728: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1731: astore        75
        1733: iconst_2
        1734: istore        76
        1736: iload         76
        1738: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1741: astore        77
        1743: new           #113                // class ocaml_fn_26
        1746: dup
        1747: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1750: astore        78
        1752: new           #116                // class ocaml_fn_27
        1755: dup
        1756: aload         78
        1758: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1761: astore        79
        1763: new           #119                // class ocaml_fn_28
        1766: dup
        1767: aload         78
        1769: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1772: astore        80
        1774: new           #122                // class ocaml_fn_29
        1777: dup
        1778: aload         30
        1780: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1783: astore        81
        1785: new           #125                // class ocaml_fn_30
        1788: dup
        1789: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1792: astore        82
        1794: new           #128                // class ocaml_fn_31
        1797: dup
        1798: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1801: astore        83
        1803: new           #131                // class ocaml_fn_32
        1806: dup
        1807: aload         18
        1809: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1812: astore        84
        1814: new           #134                // class ocaml_fn_33
        1817: dup
        1818: aload         18
        1820: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1823: astore        85
        1825: new           #137                // class ocaml_fn_34
        1828: dup
        1829: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1832: astore        86
        1834: new           #140                // class ocaml_fn_35
        1837: dup
        1838: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1841: astore        87
        1843: new           #143                // class ocaml_fn_36
        1846: dup
        1847: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1850: astore        88
        1852: new           #146                // class ocaml_fn_37
        1855: dup
        1856: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1859: astore        89
        1861: new           #149                // class ocaml_fn_38
        1864: dup
        1865: aload         89
        1867: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1870: astore        90
        1872: new           #152                // class ocaml_fn_39
        1875: dup
        1876: aload         89
        1878: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1881: astore        91
        1883: new           #155                // class ocaml_fn_40
        1886: dup
        1887: aload         18
        1889: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1892: astore        92
        1894: new           #158                // class ocaml_fn_41
        1897: dup
        1898: aload         31
        1900: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1903: astore        93
        1905: new           #161                // class ocaml_fn_42
        1908: dup
        1909: aload         18
        1911: aload         93
        1913: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1916: astore        94
        1918: new           #166                // class ocaml_fn_43
        1921: dup
        1922: aload         94
        1924: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1927: astore        95
        1929: new           #169                // class ocaml_fn_44
        1932: dup
        1933: aload         31
        1935: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1938: astore        96
        1940: new           #172                // class ocaml_fn_45
        1943: dup
        1944: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1947: astore        97
        1949: new           #175                // class ocaml_fn_46
        1952: dup
        1953: aload         75
        1955: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1958: astore        98
        1960: new           #178                // class ocaml_fn_47
        1963: dup
        1964: aload         75
        1966: aload         83
        1968: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        99
        1973: new           #181                // class ocaml_fn_48
        1976: dup
        1977: aload         75
        1979: aload         82
        1981: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        100
        1986: new           #184                // class ocaml_fn_49
        1989: dup
        1990: aload         61
        1992: aload         75
        1994: aload         83
        1996: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        101
        2001: new           #189                // class ocaml_fn_50
        2004: dup
        2005: aload         64
        2007: aload         75
        2009: aload         83
        2011: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2014: astore        102
        2016: new           #192                // class ocaml_fn_51
        2019: dup
        2020: aload         75
        2022: aload         83
        2024: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        103
        2029: new           #195                // class ocaml_fn_52
        2032: dup
        2033: aload         75
        2035: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2038: astore        104
        2040: new           #198                // class ocaml_fn_53
        2043: dup
        2044: aload         77
        2046: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2049: astore        105
        2051: new           #201                // class ocaml_fn_54
        2054: dup
        2055: aload         77
        2057: aload         83
        2059: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        106
        2064: new           #204                // class ocaml_fn_55
        2067: dup
        2068: aload         77
        2070: aload         82
        2072: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        107
        2077: new           #207                // class ocaml_fn_56
        2080: dup
        2081: aload         61
        2083: aload         77
        2085: aload         83
        2087: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        108
        2092: new           #210                // class ocaml_fn_57
        2095: dup
        2096: aload         64
        2098: aload         77
        2100: aload         83
        2102: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2105: astore        109
        2107: new           #213                // class ocaml_fn_58
        2110: dup
        2111: aload         77
        2113: aload         83
        2115: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2118: astore        110
        2120: new           #216                // class ocaml_fn_59
        2123: dup
        2124: aload         77
        2126: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2129: astore        111
        2131: new           #219                // class ocaml_fn_60
        2134: dup
        2135: aload         73
        2137: aload         75
        2139: aload         96
        2141: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2144: astore        112
        2146: new           #222                // class ocaml_fn_61
        2149: dup
        2150: aload         112
        2152: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2155: astore        113
        2157: new           #225                // class ocaml_fn_62
        2160: dup
        2161: aload         62
        2163: aload         112
        2165: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2168: astore        114
        2170: new           #228                // class ocaml_fn_63
        2173: dup
        2174: aload         112
        2176: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2179: astore        115
        2181: new           #231                // class ocaml_fn_64
        2184: dup
        2185: aload         65
        2187: aload         112
        2189: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2192: astore        116
        2194: new           #14                 // class Block
        2197: dup
        2198: iconst_0
        2199: iconst_0
        2200: anewarray     #16                 // class java/lang/Object
        2203: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2206: astore        117
        2208: new           #234                // class ocaml_fn_65
        2211: dup
        2212: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2215: astore        118
        2217: new           #237                // class ocaml_fn_66
        2220: dup
        2221: aload         56
        2223: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2226: astore        119
        2228: new           #14                 // class Block
        2231: dup
        2232: iconst_0
        2233: iconst_1
        2234: anewarray     #16                 // class java/lang/Object
        2237: dup
        2238: iconst_0
        2239: aload         81
        2241: aastore
        2242: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2245: astore        120
        2247: new           #240                // class ocaml_fn_67
        2250: dup
        2251: aload         120
        2253: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2256: astore        121
        2258: new           #243                // class ocaml_fn_68
        2261: dup
        2262: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2265: astore        122
        2267: new           #14                 // class Block
        2270: dup
        2271: iconst_0
        2272: iconst_1
        2273: anewarray     #16                 // class java/lang/Object
        2276: dup
        2277: iconst_0
        2278: aload         122
        2280: aastore
        2281: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2284: astore        123
        2286: new           #246                // class ocaml_fn_69
        2289: dup
        2290: aload         120
        2292: aload         123
        2294: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2297: astore        124
        2299: new           #249                // class ocaml_fn_70
        2302: dup
        2303: aload         124
        2305: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2308: astore        125
        2310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2313: bipush        44
        2315: aaload
        2316: astore        126
        2318: iconst_0
        2319: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2322: astore        127
        2324: new           #252                // class ocaml_fn_71
        2327: dup
        2328: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2331: astore        128
        2333: new           #255                // class ocaml_fn_72
        2336: dup
        2337: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2340: astore        129
        2342: new           #258                // class ocaml_fn_73
        2345: dup
        2346: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2349: astore        130
        2351: new           #261                // class ocaml_fn_74
        2354: dup
        2355: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2358: astore        131
        2360: new           #264                // class ocaml_fn_75
        2363: dup
        2364: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2367: astore        132
        2369: new           #267                // class ocaml_fn_76
        2372: dup
        2373: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2376: astore        133
        2378: new           #14                 // class Block
        2381: dup
        2382: iconst_0
        2383: bipush        6
        2385: anewarray     #16                 // class java/lang/Object
        2388: dup
        2389: iconst_0
        2390: aload         133
        2392: aastore
        2393: dup
        2394: iconst_1
        2395: aload         132
        2397: aastore
        2398: dup
        2399: iconst_2
        2400: aload         131
        2402: aastore
        2403: dup
        2404: iconst_3
        2405: aload         130
        2407: aastore
        2408: dup
        2409: iconst_4
        2410: aload         129
        2412: aastore
        2413: dup
        2414: iconst_5
        2415: aload         128
        2417: aastore
        2418: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2421: astore        134
        2423: new           #270                // class ocaml_fn_77
        2426: dup
        2427: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2430: astore        135
        2432: new           #273                // class ocaml_fn_78
        2435: dup
        2436: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2439: astore        136
        2441: new           #276                // class ocaml_fn_79
        2444: dup
        2445: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2448: astore        137
        2450: new           #279                // class ocaml_fn_80
        2453: dup
        2454: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2457: astore        138
        2459: new           #282                // class ocaml_fn_81
        2462: dup
        2463: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2466: astore        139
        2468: new           #285                // class ocaml_fn_82
        2471: dup
        2472: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2475: astore        140
        2477: new           #288                // class ocaml_fn_83
        2480: dup
        2481: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2484: astore        141
        2486: new           #291                // class ocaml_fn_84
        2489: dup
        2490: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2493: astore        142
        2495: new           #294                // class ocaml_fn_85
        2498: dup
        2499: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2502: astore        143
        2504: new           #297                // class ocaml_fn_86
        2507: dup
        2508: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2511: astore        144
        2513: new           #300                // class ocaml_fn_87
        2516: dup
        2517: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2520: astore        145
        2522: new           #303                // class ocaml_fn_88
        2525: dup
        2526: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2529: astore        146
        2531: new           #306                // class ocaml_fn_89
        2534: dup
        2535: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2538: astore        147
        2540: new           #309                // class ocaml_fn_90
        2543: dup
        2544: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2547: astore        148
        2549: new           #312                // class ocaml_fn_91
        2552: dup
        2553: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2556: astore        149
        2558: new           #315                // class ocaml_fn_92
        2561: dup
        2562: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2565: astore        150
        2567: new           #318                // class ocaml_fn_93
        2570: dup
        2571: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2574: astore        151
        2576: new           #14                 // class Block
        2579: dup
        2580: iconst_0
        2581: bipush        104
        2583: anewarray     #16                 // class java/lang/Object
        2586: dup
        2587: iconst_0
        2588: aload         18
        2590: aastore
        2591: dup
        2592: iconst_1
        2593: aload         17
        2595: aastore
        2596: dup
        2597: iconst_2
        2598: aload         22
        2600: aastore
        2601: dup
        2602: iconst_3
        2603: aload         23
        2605: aastore
        2606: dup
        2607: iconst_4
        2608: aload         24
        2610: aastore
        2611: dup
        2612: iconst_5
        2613: aload         25
        2615: aastore
        2616: dup
        2617: bipush        6
        2619: aload         26
        2621: aastore
        2622: dup
        2623: bipush        7
        2625: aload         27
        2627: aastore
        2628: dup
        2629: bipush        8
        2631: aload         28
        2633: aastore
        2634: dup
        2635: bipush        9
        2637: aload         29
        2639: aastore
        2640: dup
        2641: bipush        10
        2643: aload         30
        2645: aastore
        2646: dup
        2647: bipush        11
        2649: aload         31
        2651: aastore
        2652: dup
        2653: bipush        12
        2655: aload         32
        2657: aastore
        2658: dup
        2659: bipush        13
        2661: aload         33
        2663: aastore
        2664: dup
        2665: bipush        14
        2667: aload         34
        2669: aastore
        2670: dup
        2671: bipush        15
        2673: aload         35
        2675: aastore
        2676: dup
        2677: bipush        16
        2679: aload         36
        2681: aastore
        2682: dup
        2683: bipush        17
        2685: aload         37
        2687: aastore
        2688: dup
        2689: bipush        18
        2691: iload         41
        2693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2696: aastore
        2697: dup
        2698: bipush        19
        2700: iload         43
        2702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2705: aastore
        2706: dup
        2707: bipush        20
        2709: aload         38
        2711: aastore
        2712: dup
        2713: bipush        21
        2715: aload         45
        2717: aastore
        2718: dup
        2719: bipush        22
        2721: aload         47
        2723: aastore
        2724: dup
        2725: bipush        23
        2727: aload         49
        2729: aastore
        2730: dup
        2731: bipush        24
        2733: aload         51
        2735: aastore
        2736: dup
        2737: bipush        25
        2739: aload         53
        2741: aastore
        2742: dup
        2743: bipush        26
        2745: aload         55
        2747: aastore
        2748: dup
        2749: bipush        27
        2751: aload         56
        2753: aastore
        2754: dup
        2755: bipush        28
        2757: aload         57
        2759: aastore
        2760: dup
        2761: bipush        29
        2763: aload         58
        2765: aastore
        2766: dup
        2767: bipush        30
        2769: aload         60
        2771: aastore
        2772: dup
        2773: bipush        31
        2775: aload         59
        2777: aastore
        2778: dup
        2779: bipush        32
        2781: aload         61
        2783: aastore
        2784: dup
        2785: bipush        33
        2787: aload         62
        2789: aastore
        2790: dup
        2791: bipush        34
        2793: aload         64
        2795: aastore
        2796: dup
        2797: bipush        35
        2799: aload         65
        2801: aastore
        2802: dup
        2803: bipush        36
        2805: aload         66
        2807: aastore
        2808: dup
        2809: bipush        37
        2811: aload         73
        2813: aastore
        2814: dup
        2815: bipush        38
        2817: aload         75
        2819: aastore
        2820: dup
        2821: bipush        39
        2823: aload         77
        2825: aastore
        2826: dup
        2827: bipush        40
        2829: aload         98
        2831: aastore
        2832: dup
        2833: bipush        41
        2835: aload         99
        2837: aastore
        2838: dup
        2839: bipush        42
        2841: aload         100
        2843: aastore
        2844: dup
        2845: bipush        43
        2847: aload         101
        2849: aastore
        2850: dup
        2851: bipush        44
        2853: aload         102
        2855: aastore
        2856: dup
        2857: bipush        45
        2859: aload         103
        2861: aastore
        2862: dup
        2863: bipush        46
        2865: aload         104
        2867: aastore
        2868: dup
        2869: bipush        47
        2871: aload         105
        2873: aastore
        2874: dup
        2875: bipush        48
        2877: aload         106
        2879: aastore
        2880: dup
        2881: bipush        49
        2883: aload         107
        2885: aastore
        2886: dup
        2887: bipush        50
        2889: aload         108
        2891: aastore
        2892: dup
        2893: bipush        51
        2895: aload         109
        2897: aastore
        2898: dup
        2899: bipush        52
        2901: aload         110
        2903: aastore
        2904: dup
        2905: bipush        53
        2907: aload         111
        2909: aastore
        2910: dup
        2911: bipush        54
        2913: aload         112
        2915: aastore
        2916: dup
        2917: bipush        55
        2919: aload         114
        2921: aastore
        2922: dup
        2923: bipush        56
        2925: aload         113
        2927: aastore
        2928: dup
        2929: bipush        57
        2931: aload         116
        2933: aastore
        2934: dup
        2935: bipush        58
        2937: aload         115
        2939: aastore
        2940: dup
        2941: bipush        59
        2943: aload         79
        2945: aastore
        2946: dup
        2947: bipush        60
        2949: aload         80
        2951: aastore
        2952: dup
        2953: bipush        61
        2955: aload         78
        2957: aastore
        2958: dup
        2959: bipush        62
        2961: aload         151
        2963: aastore
        2964: dup
        2965: bipush        63
        2967: aload         81
        2969: aastore
        2970: dup
        2971: bipush        64
        2973: aload         150
        2975: aastore
        2976: dup
        2977: bipush        65
        2979: aload         83
        2981: aastore
        2982: dup
        2983: bipush        66
        2985: aload         82
        2987: aastore
        2988: dup
        2989: bipush        67
        2991: aload         84
        2993: aastore
        2994: dup
        2995: bipush        68
        2997: aload         85
        2999: aastore
        3000: dup
        3001: bipush        69
        3003: aload         149
        3005: aastore
        3006: dup
        3007: bipush        70
        3009: aload         148
        3011: aastore
        3012: dup
        3013: bipush        71
        3015: aload         86
        3017: aastore
        3018: dup
        3019: bipush        72
        3021: aload         147
        3023: aastore
        3024: dup
        3025: bipush        73
        3027: aload         146
        3029: aastore
        3030: dup
        3031: bipush        74
        3033: aload         145
        3035: aastore
        3036: dup
        3037: bipush        75
        3039: aload         87
        3041: aastore
        3042: dup
        3043: bipush        76
        3045: aload         88
        3047: aastore
        3048: dup
        3049: bipush        77
        3051: aload         144
        3053: aastore
        3054: dup
        3055: bipush        78
        3057: aload         90
        3059: aastore
        3060: dup
        3061: bipush        79
        3063: aload         91
        3065: aastore
        3066: dup
        3067: bipush        80
        3069: aload         89
        3071: aastore
        3072: dup
        3073: bipush        81
        3075: aload         143
        3077: aastore
        3078: dup
        3079: bipush        82
        3081: aload         96
        3083: aastore
        3084: dup
        3085: bipush        83
        3087: aload         92
        3089: aastore
        3090: dup
        3091: bipush        84
        3093: aload         94
        3095: aastore
        3096: dup
        3097: bipush        85
        3099: aload         95
        3101: aastore
        3102: dup
        3103: bipush        86
        3105: aload         142
        3107: aastore
        3108: dup
        3109: bipush        87
        3111: aload         141
        3113: aastore
        3114: dup
        3115: bipush        88
        3117: aload         140
        3119: aastore
        3120: dup
        3121: bipush        89
        3123: aload         139
        3125: aastore
        3126: dup
        3127: bipush        90
        3129: aload         138
        3131: aastore
        3132: dup
        3133: bipush        91
        3135: aload         137
        3137: aastore
        3138: dup
        3139: bipush        92
        3141: aload         136
        3143: aastore
        3144: dup
        3145: bipush        93
        3147: aload         97
        3149: aastore
        3150: dup
        3151: bipush        94
        3153: aload         135
        3155: aastore
        3156: dup
        3157: bipush        95
        3159: aload         134
        3161: aastore
        3162: dup
        3163: bipush        96
        3165: aload         118
        3167: aastore
        3168: dup
        3169: bipush        97
        3171: aload         119
        3173: aastore
        3174: dup
        3175: bipush        98
        3177: aload         125
        3179: aastore
        3180: dup
        3181: bipush        99
        3183: aload         121
        3185: aastore
        3186: dup
        3187: bipush        100
        3189: aload         63
        3191: aastore
        3192: dup
        3193: bipush        101
        3195: aload         93
        3197: aastore
        3198: dup
        3199: bipush        102
        3201: aload         124
        3203: aastore
        3204: dup
        3205: bipush        103
        3207: aload         123
        3209: aastore
        3210: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3213: astore        152
        3215: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3218: bipush        45
        3220: aload         152
        3222: aastore
        3223: iconst_0
        3224: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3227: astore        153
        3229: iconst_0
        3230: istore        154
        3232: iconst_4
        3233: istore        155
        3235: bipush        9
        3237: istore        156
        3239: iload         156
        3241: iload         155
        3243: irem
        3244: istore        157
        3246: iconst_2
        3247: istore        158
        3249: bipush        10
        3251: istore        159
        3253: iload         159
        3255: iload         158
        3257: idiv
        3258: istore        160
        3260: iconst_4
        3261: istore        161
        3263: iconst_3
        3264: istore        162
        3266: iload         162
        3268: iload         161
        3270: imul
        3271: istore        163
        3273: iload         163
        3275: iload         160
        3277: isub
        3278: istore        164
        3280: iload         164
        3282: iload         157
        3284: iadd
        3285: istore        165
        3287: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3290: iload         165
        3292: invokevirtual #331                // Method java/io/PrintStream.println:(I)V
        3295: iconst_0
        3296: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3299: astore        166
        3301: new           #14                 // class Block
        3304: dup
        3305: iconst_0
        3306: iconst_0
        3307: anewarray     #16                 // class java/lang/Object
        3310: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3313: astore        167
        3315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3318: bipush        46
        3320: aload         167
        3322: aastore
        3323: iconst_0
        3324: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3327: astore        168
        3329: iconst_0
        3330: istore        169
        3332: iconst_0
        3333: istore        170
        3335: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3338: bipush        45
        3340: aaload
        3341: checkcast     #14                 // class Block
        3344: getfield      #334                // Field Block.fields:[Ljava/lang/Object;
        3347: bipush        102
        3349: aaload
        3350: astore        171
        3352: aload         171
        3354: checkcast     #96                 // class Closure
        3357: iload         170
        3359: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3362: invokevirtual #338                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3365: astore        172
        3367: new           #14                 // class Block
        3370: dup
        3371: iconst_0
        3372: iconst_0
        3373: anewarray     #16                 // class java/lang/Object
        3376: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3379: astore        173
        3381: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3384: bipush        47
        3386: aload         173
        3388: aastore
        3389: iconst_0
        3390: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3393: astore        174
        3395: iconst_0
        3396: istore        175
        3398: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #347                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #349                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #351                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #353                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #355                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #357                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #359                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #361                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #363                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #365                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #367                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #369                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #371                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #373                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #375                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #377                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #379                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #381                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #383                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #385                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #387                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #389                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #387                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #389                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #391                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #389                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #387                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #393                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #395                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #397                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #399                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #400                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #400                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #401                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #402                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #403                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #404                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #406                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: iconst_0
        1045: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1048: aastore
        1049: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1052: bipush        47
        1054: iconst_0
        1055: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1058: aastore
        1059: aconst_null
        1060: astore_1
        1061: aload_1
        1062: astore_2
        1063: goto_w        1068
        1068: new           #2                  // class ocaml_fn_0
        1071: dup
        1072: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1075: astore_3
        1076: new           #8                  // class ocaml_fn_1
        1079: dup
        1080: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1083: astore        4
        1085: new           #11                 // class ocaml_fn_2
        1088: dup
        1089: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1092: astore        5
        1094: new           #14                 // class Block
        1097: dup
        1098: iconst_0
        1099: iconst_3
        1100: anewarray     #16                 // class java/lang/Object
        1103: dup
        1104: iconst_0
        1105: aload         4
        1107: aastore
        1108: dup
        1109: iconst_1
        1110: aload_3
        1111: aastore
        1112: dup
        1113: iconst_2
        1114: aload         5
        1116: aastore
        1117: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1120: astore        6
        1122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1125: bipush        12
        1127: aload         6
        1129: aastore
        1130: iconst_0
        1131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1134: astore        7
        1136: iconst_0
        1137: istore        8
        1139: iload         8
        1141: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        9
        1146: goto_w        1151
        1151: sipush        199
        1154: istore        10
        1156: iconst_0
        1157: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1160: astore        11
        1162: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1165: bipush        35
        1167: aaload
        1168: astore        12
        1170: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1173: iconst_3
        1174: aaload
        1175: astore        13
        1177: new           #14                 // class Block
        1180: dup
        1181: iconst_0
        1182: iconst_2
        1183: anewarray     #16                 // class java/lang/Object
        1186: dup
        1187: iconst_0
        1188: aload         13
        1190: aastore
        1191: dup
        1192: iconst_1
        1193: aload         12
        1195: aastore
        1196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1199: astore        14
        1201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1204: bipush        36
        1206: aaload
        1207: astore        15
        1209: iconst_0
        1210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1213: astore        16
        1215: new           #33                 // class ocaml_fn_8
        1218: dup
        1219: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1222: astore        17
        1224: new           #36                 // class ocaml_fn_9
        1227: dup
        1228: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1231: astore        18
        1233: iconst_0
        1234: istore        19
        1236: iconst_0
        1237: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1240: astore        20
        1242: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1245: bipush        37
        1247: aaload
        1248: astore        21
        1250: new           #14                 // class Block
        1253: dup
        1254: sipush        248
        1257: iconst_2
        1258: anewarray     #16                 // class java/lang/Object
        1261: dup
        1262: iconst_0
        1263: aload         21
        1265: aastore
        1266: dup
        1267: iconst_1
        1268: aload         20
        1270: aastore
        1271: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1274: astore        22
        1276: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1279: bipush        7
        1281: aaload
        1282: astore        23
        1284: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1287: bipush        10
        1289: aaload
        1290: astore        24
        1292: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1295: iconst_3
        1296: aaload
        1297: astore        25
        1299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1302: iconst_2
        1303: aaload
        1304: astore        26
        1306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1309: bipush        6
        1311: aaload
        1312: astore        27
        1314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1317: iconst_0
        1318: aaload
        1319: astore        28
        1321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1324: bipush        8
        1326: aaload
        1327: astore        29
        1329: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1332: iconst_1
        1333: aaload
        1334: astore        30
        1336: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1339: iconst_4
        1340: aaload
        1341: astore        31
        1343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1346: iconst_5
        1347: aaload
        1348: astore        32
        1350: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1353: bipush        9
        1355: aaload
        1356: astore        33
        1358: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1361: bipush        11
        1363: aaload
        1364: astore        34
        1366: new           #39                 // class ocaml_fn_10
        1369: dup
        1370: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1373: astore        35
        1375: new           #42                 // class ocaml_fn_11
        1378: dup
        1379: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1382: astore        36
        1384: new           #45                 // class ocaml_fn_12
        1387: dup
        1388: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1391: astore        37
        1393: new           #48                 // class ocaml_fn_13
        1396: dup
        1397: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1400: astore        38
        1402: iconst_1
        1403: istore        39
        1405: iconst_m1
        1406: istore        40
        1408: iload         40
        1410: iload         39
        1412: iushr
        1413: istore        41
        1415: iconst_1
        1416: istore        42
        1418: iload         41
        1420: iload         42
        1422: iadd
        1423: istore        43
        1425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1428: bipush        38
        1430: aaload
        1431: astore        44
        1433: ldc2_w        #50                 // double 0.0d
        1436: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        45
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        46
        1449: ldc2_w        #50                 // double 0.0d
        1452: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1455: astore        47
        1457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1460: bipush        40
        1462: aaload
        1463: astore        48
        1465: ldc2_w        #50                 // double 0.0d
        1468: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1471: astore        49
        1473: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1476: bipush        41
        1478: aaload
        1479: astore        50
        1481: ldc2_w        #50                 // double 0.0d
        1484: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1487: astore        51
        1489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1492: bipush        42
        1494: aaload
        1495: astore        52
        1497: ldc2_w        #50                 // double 0.0d
        1500: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1503: astore        53
        1505: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1508: bipush        43
        1510: aaload
        1511: astore        54
        1513: ldc2_w        #50                 // double 0.0d
        1516: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1519: astore        55
        1521: new           #58                 // class ocaml_fn_14
        1524: dup
        1525: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1528: astore        56
        1530: new           #61                 // class ocaml_fn_15
        1533: dup
        1534: aload         18
        1536: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1539: astore        57
        1541: new           #66                 // class ocaml_fn_16
        1544: dup
        1545: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1548: astore        58
        1550: new           #69                 // class ocaml_fn_17
        1553: dup
        1554: aload         18
        1556: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1559: astore        59
        1561: new           #72                 // class ocaml_fn_18
        1564: dup
        1565: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1568: astore        60
        1570: new           #75                 // class ocaml_fn_19
        1573: dup
        1574: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1577: astore        61
        1579: new           #78                 // class ocaml_fn_20
        1582: dup
        1583: aload         26
        1585: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1588: astore        62
        1590: new           #81                 // class ocaml_fn_21
        1593: dup
        1594: aload         56
        1596: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1599: astore        63
        1601: new           #84                 // class ocaml_fn_22
        1604: dup
        1605: aload         63
        1607: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1610: astore        64
        1612: new           #87                 // class ocaml_fn_23
        1615: dup
        1616: aload         26
        1618: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1621: astore        65
        1623: new           #90                 // class ocaml_fn_24
        1626: dup
        1627: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1630: astore        66
        1632: new           #93                 // class ocaml_fn_25
        1635: dup
        1636: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1639: astore        67
        1641: aload         66
        1643: checkcast     #90                 // class ocaml_fn_24
        1646: aload         66
        1648: checkcast     #96                 // class Closure
        1651: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1654: iconst_0
        1655: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        68
        1660: aload         66
        1662: checkcast     #90                 // class ocaml_fn_24
        1665: aload         67
        1667: checkcast     #96                 // class Closure
        1670: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1673: iconst_0
        1674: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        69
        1679: aload         67
        1681: checkcast     #93                 // class ocaml_fn_25
        1684: aload         66
        1686: checkcast     #96                 // class Closure
        1689: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1692: iconst_0
        1693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        70
        1698: aload         67
        1700: checkcast     #93                 // class ocaml_fn_25
        1703: aload         67
        1705: checkcast     #96                 // class Closure
        1708: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1711: iconst_0
        1712: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1715: astore        71
        1717: iconst_0
        1718: istore        72
        1720: aconst_null
        1721: astore        73
        1723: iconst_1
        1724: istore        74
        1726: iload         74
        1728: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1731: astore        75
        1733: iconst_2
        1734: istore        76
        1736: iload         76
        1738: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1741: astore        77
        1743: new           #113                // class ocaml_fn_26
        1746: dup
        1747: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1750: astore        78
        1752: new           #116                // class ocaml_fn_27
        1755: dup
        1756: aload         78
        1758: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1761: astore        79
        1763: new           #119                // class ocaml_fn_28
        1766: dup
        1767: aload         78
        1769: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1772: astore        80
        1774: new           #122                // class ocaml_fn_29
        1777: dup
        1778: aload         30
        1780: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1783: astore        81
        1785: new           #125                // class ocaml_fn_30
        1788: dup
        1789: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1792: astore        82
        1794: new           #128                // class ocaml_fn_31
        1797: dup
        1798: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1801: astore        83
        1803: new           #131                // class ocaml_fn_32
        1806: dup
        1807: aload         18
        1809: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1812: astore        84
        1814: new           #134                // class ocaml_fn_33
        1817: dup
        1818: aload         18
        1820: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1823: astore        85
        1825: new           #137                // class ocaml_fn_34
        1828: dup
        1829: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1832: astore        86
        1834: new           #140                // class ocaml_fn_35
        1837: dup
        1838: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1841: astore        87
        1843: new           #143                // class ocaml_fn_36
        1846: dup
        1847: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1850: astore        88
        1852: new           #146                // class ocaml_fn_37
        1855: dup
        1856: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1859: astore        89
        1861: new           #149                // class ocaml_fn_38
        1864: dup
        1865: aload         89
        1867: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1870: astore        90
        1872: new           #152                // class ocaml_fn_39
        1875: dup
        1876: aload         89
        1878: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1881: astore        91
        1883: new           #155                // class ocaml_fn_40
        1886: dup
        1887: aload         18
        1889: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1892: astore        92
        1894: new           #158                // class ocaml_fn_41
        1897: dup
        1898: aload         31
        1900: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1903: astore        93
        1905: new           #161                // class ocaml_fn_42
        1908: dup
        1909: aload         18
        1911: aload         93
        1913: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1916: astore        94
        1918: new           #166                // class ocaml_fn_43
        1921: dup
        1922: aload         94
        1924: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1927: astore        95
        1929: new           #169                // class ocaml_fn_44
        1932: dup
        1933: aload         31
        1935: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1938: astore        96
        1940: new           #172                // class ocaml_fn_45
        1943: dup
        1944: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1947: astore        97
        1949: new           #175                // class ocaml_fn_46
        1952: dup
        1953: aload         75
        1955: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1958: astore        98
        1960: new           #178                // class ocaml_fn_47
        1963: dup
        1964: aload         75
        1966: aload         83
        1968: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        99
        1973: new           #181                // class ocaml_fn_48
        1976: dup
        1977: aload         75
        1979: aload         82
        1981: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        100
        1986: new           #184                // class ocaml_fn_49
        1989: dup
        1990: aload         61
        1992: aload         75
        1994: aload         83
        1996: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        101
        2001: new           #189                // class ocaml_fn_50
        2004: dup
        2005: aload         64
        2007: aload         75
        2009: aload         83
        2011: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2014: astore        102
        2016: new           #192                // class ocaml_fn_51
        2019: dup
        2020: aload         75
        2022: aload         83
        2024: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        103
        2029: new           #195                // class ocaml_fn_52
        2032: dup
        2033: aload         75
        2035: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2038: astore        104
        2040: new           #198                // class ocaml_fn_53
        2043: dup
        2044: aload         77
        2046: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2049: astore        105
        2051: new           #201                // class ocaml_fn_54
        2054: dup
        2055: aload         77
        2057: aload         83
        2059: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        106
        2064: new           #204                // class ocaml_fn_55
        2067: dup
        2068: aload         77
        2070: aload         82
        2072: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        107
        2077: new           #207                // class ocaml_fn_56
        2080: dup
        2081: aload         61
        2083: aload         77
        2085: aload         83
        2087: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        108
        2092: new           #210                // class ocaml_fn_57
        2095: dup
        2096: aload         64
        2098: aload         77
        2100: aload         83
        2102: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2105: astore        109
        2107: new           #213                // class ocaml_fn_58
        2110: dup
        2111: aload         77
        2113: aload         83
        2115: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2118: astore        110
        2120: new           #216                // class ocaml_fn_59
        2123: dup
        2124: aload         77
        2126: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2129: astore        111
        2131: new           #219                // class ocaml_fn_60
        2134: dup
        2135: aload         73
        2137: aload         75
        2139: aload         96
        2141: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2144: astore        112
        2146: new           #222                // class ocaml_fn_61
        2149: dup
        2150: aload         112
        2152: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2155: astore        113
        2157: new           #225                // class ocaml_fn_62
        2160: dup
        2161: aload         62
        2163: aload         112
        2165: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2168: astore        114
        2170: new           #228                // class ocaml_fn_63
        2173: dup
        2174: aload         112
        2176: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2179: astore        115
        2181: new           #231                // class ocaml_fn_64
        2184: dup
        2185: aload         65
        2187: aload         112
        2189: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2192: astore        116
        2194: new           #14                 // class Block
        2197: dup
        2198: iconst_0
        2199: iconst_0
        2200: anewarray     #16                 // class java/lang/Object
        2203: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2206: astore        117
        2208: new           #234                // class ocaml_fn_65
        2211: dup
        2212: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2215: astore        118
        2217: new           #237                // class ocaml_fn_66
        2220: dup
        2221: aload         56
        2223: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2226: astore        119
        2228: new           #14                 // class Block
        2231: dup
        2232: iconst_0
        2233: iconst_1
        2234: anewarray     #16                 // class java/lang/Object
        2237: dup
        2238: iconst_0
        2239: aload         81
        2241: aastore
        2242: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2245: astore        120
        2247: new           #240                // class ocaml_fn_67
        2250: dup
        2251: aload         120
        2253: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2256: astore        121
        2258: new           #243                // class ocaml_fn_68
        2261: dup
        2262: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2265: astore        122
        2267: new           #14                 // class Block
        2270: dup
        2271: iconst_0
        2272: iconst_1
        2273: anewarray     #16                 // class java/lang/Object
        2276: dup
        2277: iconst_0
        2278: aload         122
        2280: aastore
        2281: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2284: astore        123
        2286: new           #246                // class ocaml_fn_69
        2289: dup
        2290: aload         120
        2292: aload         123
        2294: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2297: astore        124
        2299: new           #249                // class ocaml_fn_70
        2302: dup
        2303: aload         124
        2305: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2308: astore        125
        2310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2313: bipush        44
        2315: aaload
        2316: astore        126
        2318: iconst_0
        2319: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2322: astore        127
        2324: new           #252                // class ocaml_fn_71
        2327: dup
        2328: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2331: astore        128
        2333: new           #255                // class ocaml_fn_72
        2336: dup
        2337: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2340: astore        129
        2342: new           #258                // class ocaml_fn_73
        2345: dup
        2346: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2349: astore        130
        2351: new           #261                // class ocaml_fn_74
        2354: dup
        2355: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2358: astore        131
        2360: new           #264                // class ocaml_fn_75
        2363: dup
        2364: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2367: astore        132
        2369: new           #267                // class ocaml_fn_76
        2372: dup
        2373: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2376: astore        133
        2378: new           #14                 // class Block
        2381: dup
        2382: iconst_0
        2383: bipush        6
        2385: anewarray     #16                 // class java/lang/Object
        2388: dup
        2389: iconst_0
        2390: aload         133
        2392: aastore
        2393: dup
        2394: iconst_1
        2395: aload         132
        2397: aastore
        2398: dup
        2399: iconst_2
        2400: aload         131
        2402: aastore
        2403: dup
        2404: iconst_3
        2405: aload         130
        2407: aastore
        2408: dup
        2409: iconst_4
        2410: aload         129
        2412: aastore
        2413: dup
        2414: iconst_5
        2415: aload         128
        2417: aastore
        2418: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2421: astore        134
        2423: new           #270                // class ocaml_fn_77
        2426: dup
        2427: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2430: astore        135
        2432: new           #273                // class ocaml_fn_78
        2435: dup
        2436: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2439: astore        136
        2441: new           #276                // class ocaml_fn_79
        2444: dup
        2445: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2448: astore        137
        2450: new           #279                // class ocaml_fn_80
        2453: dup
        2454: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2457: astore        138
        2459: new           #282                // class ocaml_fn_81
        2462: dup
        2463: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2466: astore        139
        2468: new           #285                // class ocaml_fn_82
        2471: dup
        2472: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2475: astore        140
        2477: new           #288                // class ocaml_fn_83
        2480: dup
        2481: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2484: astore        141
        2486: new           #291                // class ocaml_fn_84
        2489: dup
        2490: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2493: astore        142
        2495: new           #294                // class ocaml_fn_85
        2498: dup
        2499: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2502: astore        143
        2504: new           #297                // class ocaml_fn_86
        2507: dup
        2508: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2511: astore        144
        2513: new           #300                // class ocaml_fn_87
        2516: dup
        2517: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2520: astore        145
        2522: new           #303                // class ocaml_fn_88
        2525: dup
        2526: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2529: astore        146
        2531: new           #306                // class ocaml_fn_89
        2534: dup
        2535: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2538: astore        147
        2540: new           #309                // class ocaml_fn_90
        2543: dup
        2544: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2547: astore        148
        2549: new           #312                // class ocaml_fn_91
        2552: dup
        2553: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2556: astore        149
        2558: new           #315                // class ocaml_fn_92
        2561: dup
        2562: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2565: astore        150
        2567: new           #318                // class ocaml_fn_93
        2570: dup
        2571: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2574: astore        151
        2576: new           #14                 // class Block
        2579: dup
        2580: iconst_0
        2581: bipush        104
        2583: anewarray     #16                 // class java/lang/Object
        2586: dup
        2587: iconst_0
        2588: aload         18
        2590: aastore
        2591: dup
        2592: iconst_1
        2593: aload         17
        2595: aastore
        2596: dup
        2597: iconst_2
        2598: aload         22
        2600: aastore
        2601: dup
        2602: iconst_3
        2603: aload         23
        2605: aastore
        2606: dup
        2607: iconst_4
        2608: aload         24
        2610: aastore
        2611: dup
        2612: iconst_5
        2613: aload         25
        2615: aastore
        2616: dup
        2617: bipush        6
        2619: aload         26
        2621: aastore
        2622: dup
        2623: bipush        7
        2625: aload         27
        2627: aastore
        2628: dup
        2629: bipush        8
        2631: aload         28
        2633: aastore
        2634: dup
        2635: bipush        9
        2637: aload         29
        2639: aastore
        2640: dup
        2641: bipush        10
        2643: aload         30
        2645: aastore
        2646: dup
        2647: bipush        11
        2649: aload         31
        2651: aastore
        2652: dup
        2653: bipush        12
        2655: aload         32
        2657: aastore
        2658: dup
        2659: bipush        13
        2661: aload         33
        2663: aastore
        2664: dup
        2665: bipush        14
        2667: aload         34
        2669: aastore
        2670: dup
        2671: bipush        15
        2673: aload         35
        2675: aastore
        2676: dup
        2677: bipush        16
        2679: aload         36
        2681: aastore
        2682: dup
        2683: bipush        17
        2685: aload         37
        2687: aastore
        2688: dup
        2689: bipush        18
        2691: iload         41
        2693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2696: aastore
        2697: dup
        2698: bipush        19
        2700: iload         43
        2702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2705: aastore
        2706: dup
        2707: bipush        20
        2709: aload         38
        2711: aastore
        2712: dup
        2713: bipush        21
        2715: aload         45
        2717: aastore
        2718: dup
        2719: bipush        22
        2721: aload         47
        2723: aastore
        2724: dup
        2725: bipush        23
        2727: aload         49
        2729: aastore
        2730: dup
        2731: bipush        24
        2733: aload         51
        2735: aastore
        2736: dup
        2737: bipush        25
        2739: aload         53
        2741: aastore
        2742: dup
        2743: bipush        26
        2745: aload         55
        2747: aastore
        2748: dup
        2749: bipush        27
        2751: aload         56
        2753: aastore
        2754: dup
        2755: bipush        28
        2757: aload         57
        2759: aastore
        2760: dup
        2761: bipush        29
        2763: aload         58
        2765: aastore
        2766: dup
        2767: bipush        30
        2769: aload         60
        2771: aastore
        2772: dup
        2773: bipush        31
        2775: aload         59
        2777: aastore
        2778: dup
        2779: bipush        32
        2781: aload         61
        2783: aastore
        2784: dup
        2785: bipush        33
        2787: aload         62
        2789: aastore
        2790: dup
        2791: bipush        34
        2793: aload         64
        2795: aastore
        2796: dup
        2797: bipush        35
        2799: aload         65
        2801: aastore
        2802: dup
        2803: bipush        36
        2805: aload         66
        2807: aastore
        2808: dup
        2809: bipush        37
        2811: aload         73
        2813: aastore
        2814: dup
        2815: bipush        38
        2817: aload         75
        2819: aastore
        2820: dup
        2821: bipush        39
        2823: aload         77
        2825: aastore
        2826: dup
        2827: bipush        40
        2829: aload         98
        2831: aastore
        2832: dup
        2833: bipush        41
        2835: aload         99
        2837: aastore
        2838: dup
        2839: bipush        42
        2841: aload         100
        2843: aastore
        2844: dup
        2845: bipush        43
        2847: aload         101
        2849: aastore
        2850: dup
        2851: bipush        44
        2853: aload         102
        2855: aastore
        2856: dup
        2857: bipush        45
        2859: aload         103
        2861: aastore
        2862: dup
        2863: bipush        46
        2865: aload         104
        2867: aastore
        2868: dup
        2869: bipush        47
        2871: aload         105
        2873: aastore
        2874: dup
        2875: bipush        48
        2877: aload         106
        2879: aastore
        2880: dup
        2881: bipush        49
        2883: aload         107
        2885: aastore
        2886: dup
        2887: bipush        50
        2889: aload         108
        2891: aastore
        2892: dup
        2893: bipush        51
        2895: aload         109
        2897: aastore
        2898: dup
        2899: bipush        52
        2901: aload         110
        2903: aastore
        2904: dup
        2905: bipush        53
        2907: aload         111
        2909: aastore
        2910: dup
        2911: bipush        54
        2913: aload         112
        2915: aastore
        2916: dup
        2917: bipush        55
        2919: aload         114
        2921: aastore
        2922: dup
        2923: bipush        56
        2925: aload         113
        2927: aastore
        2928: dup
        2929: bipush        57
        2931: aload         116
        2933: aastore
        2934: dup
        2935: bipush        58
        2937: aload         115
        2939: aastore
        2940: dup
        2941: bipush        59
        2943: aload         79
        2945: aastore
        2946: dup
        2947: bipush        60
        2949: aload         80
        2951: aastore
        2952: dup
        2953: bipush        61
        2955: aload         78
        2957: aastore
        2958: dup
        2959: bipush        62
        2961: aload         151
        2963: aastore
        2964: dup
        2965: bipush        63
        2967: aload         81
        2969: aastore
        2970: dup
        2971: bipush        64
        2973: aload         150
        2975: aastore
        2976: dup
        2977: bipush        65
        2979: aload         83
        2981: aastore
        2982: dup
        2983: bipush        66
        2985: aload         82
        2987: aastore
        2988: dup
        2989: bipush        67
        2991: aload         84
        2993: aastore
        2994: dup
        2995: bipush        68
        2997: aload         85
        2999: aastore
        3000: dup
        3001: bipush        69
        3003: aload         149
        3005: aastore
        3006: dup
        3007: bipush        70
        3009: aload         148
        3011: aastore
        3012: dup
        3013: bipush        71
        3015: aload         86
        3017: aastore
        3018: dup
        3019: bipush        72
        3021: aload         147
        3023: aastore
        3024: dup
        3025: bipush        73
        3027: aload         146
        3029: aastore
        3030: dup
        3031: bipush        74
        3033: aload         145
        3035: aastore
        3036: dup
        3037: bipush        75
        3039: aload         87
        3041: aastore
        3042: dup
        3043: bipush        76
        3045: aload         88
        3047: aastore
        3048: dup
        3049: bipush        77
        3051: aload         144
        3053: aastore
        3054: dup
        3055: bipush        78
        3057: aload         90
        3059: aastore
        3060: dup
        3061: bipush        79
        3063: aload         91
        3065: aastore
        3066: dup
        3067: bipush        80
        3069: aload         89
        3071: aastore
        3072: dup
        3073: bipush        81
        3075: aload         143
        3077: aastore
        3078: dup
        3079: bipush        82
        3081: aload         96
        3083: aastore
        3084: dup
        3085: bipush        83
        3087: aload         92
        3089: aastore
        3090: dup
        3091: bipush        84
        3093: aload         94
        3095: aastore
        3096: dup
        3097: bipush        85
        3099: aload         95
        3101: aastore
        3102: dup
        3103: bipush        86
        3105: aload         142
        3107: aastore
        3108: dup
        3109: bipush        87
        3111: aload         141
        3113: aastore
        3114: dup
        3115: bipush        88
        3117: aload         140
        3119: aastore
        3120: dup
        3121: bipush        89
        3123: aload         139
        3125: aastore
        3126: dup
        3127: bipush        90
        3129: aload         138
        3131: aastore
        3132: dup
        3133: bipush        91
        3135: aload         137
        3137: aastore
        3138: dup
        3139: bipush        92
        3141: aload         136
        3143: aastore
        3144: dup
        3145: bipush        93
        3147: aload         97
        3149: aastore
        3150: dup
        3151: bipush        94
        3153: aload         135
        3155: aastore
        3156: dup
        3157: bipush        95
        3159: aload         134
        3161: aastore
        3162: dup
        3163: bipush        96
        3165: aload         118
        3167: aastore
        3168: dup
        3169: bipush        97
        3171: aload         119
        3173: aastore
        3174: dup
        3175: bipush        98
        3177: aload         125
        3179: aastore
        3180: dup
        3181: bipush        99
        3183: aload         121
        3185: aastore
        3186: dup
        3187: bipush        100
        3189: aload         63
        3191: aastore
        3192: dup
        3193: bipush        101
        3195: aload         93
        3197: aastore
        3198: dup
        3199: bipush        102
        3201: aload         124
        3203: aastore
        3204: dup
        3205: bipush        103
        3207: aload         123
        3209: aastore
        3210: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3213: astore        152
        3215: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3218: bipush        45
        3220: aload         152
        3222: aastore
        3223: iconst_0
        3224: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3227: astore        153
        3229: iconst_0
        3230: istore        154
        3232: iload         154
        3234: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3237: astore        155
        3239: goto_w        3244
        3244: new           #321                // class ocaml_fn_95
        3247: dup
        3248: invokespecial #322                // Method ocaml_fn_95."<init>":()V
        3251: astore        156
        3253: bipush        10
        3255: istore        157
        3257: aload         156
        3259: iload         157
        3261: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3264: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3267: astore        158
        3269: bipush        32
        3271: istore        159
        3273: aload         158
        3275: checkcast     #96                 // class Closure
        3278: iload         159
        3280: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3283: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3286: astore        160
        3288: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3291: aload         160
        3293: checkcast     #27                 // class java/lang/Integer
        3296: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3299: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3302: iconst_0
        3303: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3306: astore        161
        3308: new           #14                 // class Block
        3311: dup
        3312: iconst_0
        3313: iconst_1
        3314: anewarray     #16                 // class java/lang/Object
        3317: dup
        3318: iconst_0
        3319: aload         156
        3321: aastore
        3322: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3325: astore        162
        3327: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3330: bipush        46
        3332: aload         162
        3334: aastore
        3335: iconst_0
        3336: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3339: astore        163
        3341: iconst_0
        3342: istore        164
        3344: iconst_0
        3345: istore        165
        3347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3350: bipush        45
        3352: aaload
        3353: checkcast     #14                 // class Block
        3356: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3359: bipush        102
        3361: aaload
        3362: astore        166
        3364: aload         166
        3366: checkcast     #96                 // class Closure
        3369: iload         165
        3371: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3374: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3377: astore        167
        3379: new           #14                 // class Block
        3382: dup
        3383: iconst_0
        3384: iconst_0
        3385: anewarray     #16                 // class java/lang/Object
        3388: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3391: astore        168
        3393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3396: bipush        47
        3398: aload         168
        3400: aastore
        3401: iconst_0
        3402: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3405: astore        169
        3407: iconst_0
        3408: istore        170
        3410: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #347                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #349                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #351                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #353                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #355                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #357                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #359                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #361                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #363                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #365                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #367                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #369                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #371                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #373                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #375                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #377                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #379                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #381                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #383                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #385                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #387                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #389                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #387                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #389                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #391                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #389                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #387                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #393                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #395                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #397                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #399                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #400                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #400                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #401                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #402                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #403                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #404                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #406                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: new           #14                 // class Block
        1047: dup
        1048: iconst_0
        1049: iconst_1
        1050: anewarray     #16                 // class java/lang/Object
        1053: dup
        1054: iconst_0
        1055: bipush        42
        1057: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1060: aastore
        1061: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1064: aastore
        1065: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1068: bipush        47
        1070: iconst_0
        1071: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1074: aastore
        1075: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1078: bipush        48
        1080: iconst_0
        1081: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1084: aastore
        1085: aconst_null
        1086: astore_1
        1087: aload_1
        1088: astore_2
        1089: goto_w        1094
        1094: new           #2                  // class ocaml_fn_0
        1097: dup
        1098: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1101: astore_3
        1102: new           #8                  // class ocaml_fn_1
        1105: dup
        1106: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1109: astore        4
        1111: new           #11                 // class ocaml_fn_2
        1114: dup
        1115: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1118: astore        5
        1120: new           #14                 // class Block
        1123: dup
        1124: iconst_0
        1125: iconst_3
        1126: anewarray     #16                 // class java/lang/Object
        1129: dup
        1130: iconst_0
        1131: aload         4
        1133: aastore
        1134: dup
        1135: iconst_1
        1136: aload_3
        1137: aastore
        1138: dup
        1139: iconst_2
        1140: aload         5
        1142: aastore
        1143: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1146: astore        6
        1148: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1151: bipush        12
        1153: aload         6
        1155: aastore
        1156: iconst_0
        1157: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1160: astore        7
        1162: iconst_0
        1163: istore        8
        1165: iload         8
        1167: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1170: astore        9
        1172: goto_w        1177
        1177: sipush        199
        1180: istore        10
        1182: iconst_0
        1183: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1186: astore        11
        1188: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1191: bipush        35
        1193: aaload
        1194: astore        12
        1196: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1199: iconst_3
        1200: aaload
        1201: astore        13
        1203: new           #14                 // class Block
        1206: dup
        1207: iconst_0
        1208: iconst_2
        1209: anewarray     #16                 // class java/lang/Object
        1212: dup
        1213: iconst_0
        1214: aload         13
        1216: aastore
        1217: dup
        1218: iconst_1
        1219: aload         12
        1221: aastore
        1222: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1225: astore        14
        1227: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1230: bipush        36
        1232: aaload
        1233: astore        15
        1235: iconst_0
        1236: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1239: astore        16
        1241: new           #33                 // class ocaml_fn_8
        1244: dup
        1245: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1248: astore        17
        1250: new           #36                 // class ocaml_fn_9
        1253: dup
        1254: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1257: astore        18
        1259: iconst_0
        1260: istore        19
        1262: iconst_0
        1263: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1266: astore        20
        1268: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1271: bipush        37
        1273: aaload
        1274: astore        21
        1276: new           #14                 // class Block
        1279: dup
        1280: sipush        248
        1283: iconst_2
        1284: anewarray     #16                 // class java/lang/Object
        1287: dup
        1288: iconst_0
        1289: aload         21
        1291: aastore
        1292: dup
        1293: iconst_1
        1294: aload         20
        1296: aastore
        1297: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1300: astore        22
        1302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1305: bipush        7
        1307: aaload
        1308: astore        23
        1310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1313: bipush        10
        1315: aaload
        1316: astore        24
        1318: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1321: iconst_3
        1322: aaload
        1323: astore        25
        1325: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1328: iconst_2
        1329: aaload
        1330: astore        26
        1332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1335: bipush        6
        1337: aaload
        1338: astore        27
        1340: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1343: iconst_0
        1344: aaload
        1345: astore        28
        1347: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1350: bipush        8
        1352: aaload
        1353: astore        29
        1355: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1358: iconst_1
        1359: aaload
        1360: astore        30
        1362: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1365: iconst_4
        1366: aaload
        1367: astore        31
        1369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1372: iconst_5
        1373: aaload
        1374: astore        32
        1376: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1379: bipush        9
        1381: aaload
        1382: astore        33
        1384: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1387: bipush        11
        1389: aaload
        1390: astore        34
        1392: new           #39                 // class ocaml_fn_10
        1395: dup
        1396: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1399: astore        35
        1401: new           #42                 // class ocaml_fn_11
        1404: dup
        1405: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1408: astore        36
        1410: new           #45                 // class ocaml_fn_12
        1413: dup
        1414: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1417: astore        37
        1419: new           #48                 // class ocaml_fn_13
        1422: dup
        1423: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1426: astore        38
        1428: iconst_1
        1429: istore        39
        1431: iconst_m1
        1432: istore        40
        1434: iload         40
        1436: iload         39
        1438: iushr
        1439: istore        41
        1441: iconst_1
        1442: istore        42
        1444: iload         41
        1446: iload         42
        1448: iadd
        1449: istore        43
        1451: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1454: bipush        38
        1456: aaload
        1457: astore        44
        1459: ldc2_w        #50                 // double 0.0d
        1462: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1465: astore        45
        1467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1470: bipush        39
        1472: aaload
        1473: astore        46
        1475: ldc2_w        #50                 // double 0.0d
        1478: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        47
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        40
        1488: aaload
        1489: astore        48
        1491: ldc2_w        #50                 // double 0.0d
        1494: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1497: astore        49
        1499: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1502: bipush        41
        1504: aaload
        1505: astore        50
        1507: ldc2_w        #50                 // double 0.0d
        1510: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1513: astore        51
        1515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1518: bipush        42
        1520: aaload
        1521: astore        52
        1523: ldc2_w        #50                 // double 0.0d
        1526: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1529: astore        53
        1531: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1534: bipush        43
        1536: aaload
        1537: astore        54
        1539: ldc2_w        #50                 // double 0.0d
        1542: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1545: astore        55
        1547: new           #58                 // class ocaml_fn_14
        1550: dup
        1551: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1554: astore        56
        1556: new           #61                 // class ocaml_fn_15
        1559: dup
        1560: aload         18
        1562: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1565: astore        57
        1567: new           #66                 // class ocaml_fn_16
        1570: dup
        1571: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1574: astore        58
        1576: new           #69                 // class ocaml_fn_17
        1579: dup
        1580: aload         18
        1582: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1585: astore        59
        1587: new           #72                 // class ocaml_fn_18
        1590: dup
        1591: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1594: astore        60
        1596: new           #75                 // class ocaml_fn_19
        1599: dup
        1600: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1603: astore        61
        1605: new           #78                 // class ocaml_fn_20
        1608: dup
        1609: aload         26
        1611: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1614: astore        62
        1616: new           #81                 // class ocaml_fn_21
        1619: dup
        1620: aload         56
        1622: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1625: astore        63
        1627: new           #84                 // class ocaml_fn_22
        1630: dup
        1631: aload         63
        1633: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1636: astore        64
        1638: new           #87                 // class ocaml_fn_23
        1641: dup
        1642: aload         26
        1644: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1647: astore        65
        1649: new           #90                 // class ocaml_fn_24
        1652: dup
        1653: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1656: astore        66
        1658: new           #93                 // class ocaml_fn_25
        1661: dup
        1662: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1665: astore        67
        1667: aload         66
        1669: checkcast     #90                 // class ocaml_fn_24
        1672: aload         66
        1674: checkcast     #96                 // class Closure
        1677: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1680: iconst_0
        1681: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1684: astore        68
        1686: aload         66
        1688: checkcast     #90                 // class ocaml_fn_24
        1691: aload         67
        1693: checkcast     #96                 // class Closure
        1696: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1699: iconst_0
        1700: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1703: astore        69
        1705: aload         67
        1707: checkcast     #93                 // class ocaml_fn_25
        1710: aload         66
        1712: checkcast     #96                 // class Closure
        1715: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1718: iconst_0
        1719: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1722: astore        70
        1724: aload         67
        1726: checkcast     #93                 // class ocaml_fn_25
        1729: aload         67
        1731: checkcast     #96                 // class Closure
        1734: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1737: iconst_0
        1738: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1741: astore        71
        1743: iconst_0
        1744: istore        72
        1746: aconst_null
        1747: astore        73
        1749: iconst_1
        1750: istore        74
        1752: iload         74
        1754: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1757: astore        75
        1759: iconst_2
        1760: istore        76
        1762: iload         76
        1764: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1767: astore        77
        1769: new           #113                // class ocaml_fn_26
        1772: dup
        1773: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1776: astore        78
        1778: new           #116                // class ocaml_fn_27
        1781: dup
        1782: aload         78
        1784: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1787: astore        79
        1789: new           #119                // class ocaml_fn_28
        1792: dup
        1793: aload         78
        1795: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1798: astore        80
        1800: new           #122                // class ocaml_fn_29
        1803: dup
        1804: aload         30
        1806: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1809: astore        81
        1811: new           #125                // class ocaml_fn_30
        1814: dup
        1815: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1818: astore        82
        1820: new           #128                // class ocaml_fn_31
        1823: dup
        1824: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1827: astore        83
        1829: new           #131                // class ocaml_fn_32
        1832: dup
        1833: aload         18
        1835: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1838: astore        84
        1840: new           #134                // class ocaml_fn_33
        1843: dup
        1844: aload         18
        1846: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1849: astore        85
        1851: new           #137                // class ocaml_fn_34
        1854: dup
        1855: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1858: astore        86
        1860: new           #140                // class ocaml_fn_35
        1863: dup
        1864: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1867: astore        87
        1869: new           #143                // class ocaml_fn_36
        1872: dup
        1873: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1876: astore        88
        1878: new           #146                // class ocaml_fn_37
        1881: dup
        1882: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1885: astore        89
        1887: new           #149                // class ocaml_fn_38
        1890: dup
        1891: aload         89
        1893: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1896: astore        90
        1898: new           #152                // class ocaml_fn_39
        1901: dup
        1902: aload         89
        1904: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1907: astore        91
        1909: new           #155                // class ocaml_fn_40
        1912: dup
        1913: aload         18
        1915: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1918: astore        92
        1920: new           #158                // class ocaml_fn_41
        1923: dup
        1924: aload         31
        1926: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1929: astore        93
        1931: new           #161                // class ocaml_fn_42
        1934: dup
        1935: aload         18
        1937: aload         93
        1939: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1942: astore        94
        1944: new           #166                // class ocaml_fn_43
        1947: dup
        1948: aload         94
        1950: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1953: astore        95
        1955: new           #169                // class ocaml_fn_44
        1958: dup
        1959: aload         31
        1961: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1964: astore        96
        1966: new           #172                // class ocaml_fn_45
        1969: dup
        1970: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1973: astore        97
        1975: new           #175                // class ocaml_fn_46
        1978: dup
        1979: aload         75
        1981: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1984: astore        98
        1986: new           #178                // class ocaml_fn_47
        1989: dup
        1990: aload         75
        1992: aload         83
        1994: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1997: astore        99
        1999: new           #181                // class ocaml_fn_48
        2002: dup
        2003: aload         75
        2005: aload         82
        2007: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2010: astore        100
        2012: new           #184                // class ocaml_fn_49
        2015: dup
        2016: aload         61
        2018: aload         75
        2020: aload         83
        2022: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2025: astore        101
        2027: new           #189                // class ocaml_fn_50
        2030: dup
        2031: aload         64
        2033: aload         75
        2035: aload         83
        2037: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2040: astore        102
        2042: new           #192                // class ocaml_fn_51
        2045: dup
        2046: aload         75
        2048: aload         83
        2050: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        103
        2055: new           #195                // class ocaml_fn_52
        2058: dup
        2059: aload         75
        2061: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2064: astore        104
        2066: new           #198                // class ocaml_fn_53
        2069: dup
        2070: aload         77
        2072: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2075: astore        105
        2077: new           #201                // class ocaml_fn_54
        2080: dup
        2081: aload         77
        2083: aload         83
        2085: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2088: astore        106
        2090: new           #204                // class ocaml_fn_55
        2093: dup
        2094: aload         77
        2096: aload         82
        2098: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        107
        2103: new           #207                // class ocaml_fn_56
        2106: dup
        2107: aload         61
        2109: aload         77
        2111: aload         83
        2113: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2116: astore        108
        2118: new           #210                // class ocaml_fn_57
        2121: dup
        2122: aload         64
        2124: aload         77
        2126: aload         83
        2128: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2131: astore        109
        2133: new           #213                // class ocaml_fn_58
        2136: dup
        2137: aload         77
        2139: aload         83
        2141: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2144: astore        110
        2146: new           #216                // class ocaml_fn_59
        2149: dup
        2150: aload         77
        2152: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2155: astore        111
        2157: new           #219                // class ocaml_fn_60
        2160: dup
        2161: aload         73
        2163: aload         75
        2165: aload         96
        2167: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2170: astore        112
        2172: new           #222                // class ocaml_fn_61
        2175: dup
        2176: aload         112
        2178: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2181: astore        113
        2183: new           #225                // class ocaml_fn_62
        2186: dup
        2187: aload         62
        2189: aload         112
        2191: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2194: astore        114
        2196: new           #228                // class ocaml_fn_63
        2199: dup
        2200: aload         112
        2202: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2205: astore        115
        2207: new           #231                // class ocaml_fn_64
        2210: dup
        2211: aload         65
        2213: aload         112
        2215: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2218: astore        116
        2220: new           #14                 // class Block
        2223: dup
        2224: iconst_0
        2225: iconst_0
        2226: anewarray     #16                 // class java/lang/Object
        2229: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2232: astore        117
        2234: new           #234                // class ocaml_fn_65
        2237: dup
        2238: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2241: astore        118
        2243: new           #237                // class ocaml_fn_66
        2246: dup
        2247: aload         56
        2249: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2252: astore        119
        2254: new           #14                 // class Block
        2257: dup
        2258: iconst_0
        2259: iconst_1
        2260: anewarray     #16                 // class java/lang/Object
        2263: dup
        2264: iconst_0
        2265: aload         81
        2267: aastore
        2268: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2271: astore        120
        2273: new           #240                // class ocaml_fn_67
        2276: dup
        2277: aload         120
        2279: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2282: astore        121
        2284: new           #243                // class ocaml_fn_68
        2287: dup
        2288: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2291: astore        122
        2293: new           #14                 // class Block
        2296: dup
        2297: iconst_0
        2298: iconst_1
        2299: anewarray     #16                 // class java/lang/Object
        2302: dup
        2303: iconst_0
        2304: aload         122
        2306: aastore
        2307: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2310: astore        123
        2312: new           #246                // class ocaml_fn_69
        2315: dup
        2316: aload         120
        2318: aload         123
        2320: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2323: astore        124
        2325: new           #249                // class ocaml_fn_70
        2328: dup
        2329: aload         124
        2331: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2334: astore        125
        2336: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2339: bipush        44
        2341: aaload
        2342: astore        126
        2344: iconst_0
        2345: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2348: astore        127
        2350: new           #252                // class ocaml_fn_71
        2353: dup
        2354: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2357: astore        128
        2359: new           #255                // class ocaml_fn_72
        2362: dup
        2363: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2366: astore        129
        2368: new           #258                // class ocaml_fn_73
        2371: dup
        2372: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2375: astore        130
        2377: new           #261                // class ocaml_fn_74
        2380: dup
        2381: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2384: astore        131
        2386: new           #264                // class ocaml_fn_75
        2389: dup
        2390: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2393: astore        132
        2395: new           #267                // class ocaml_fn_76
        2398: dup
        2399: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2402: astore        133
        2404: new           #14                 // class Block
        2407: dup
        2408: iconst_0
        2409: bipush        6
        2411: anewarray     #16                 // class java/lang/Object
        2414: dup
        2415: iconst_0
        2416: aload         133
        2418: aastore
        2419: dup
        2420: iconst_1
        2421: aload         132
        2423: aastore
        2424: dup
        2425: iconst_2
        2426: aload         131
        2428: aastore
        2429: dup
        2430: iconst_3
        2431: aload         130
        2433: aastore
        2434: dup
        2435: iconst_4
        2436: aload         129
        2438: aastore
        2439: dup
        2440: iconst_5
        2441: aload         128
        2443: aastore
        2444: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2447: astore        134
        2449: new           #270                // class ocaml_fn_77
        2452: dup
        2453: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2456: astore        135
        2458: new           #273                // class ocaml_fn_78
        2461: dup
        2462: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2465: astore        136
        2467: new           #276                // class ocaml_fn_79
        2470: dup
        2471: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2474: astore        137
        2476: new           #279                // class ocaml_fn_80
        2479: dup
        2480: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2483: astore        138
        2485: new           #282                // class ocaml_fn_81
        2488: dup
        2489: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2492: astore        139
        2494: new           #285                // class ocaml_fn_82
        2497: dup
        2498: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2501: astore        140
        2503: new           #288                // class ocaml_fn_83
        2506: dup
        2507: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2510: astore        141
        2512: new           #291                // class ocaml_fn_84
        2515: dup
        2516: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2519: astore        142
        2521: new           #294                // class ocaml_fn_85
        2524: dup
        2525: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2528: astore        143
        2530: new           #297                // class ocaml_fn_86
        2533: dup
        2534: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2537: astore        144
        2539: new           #300                // class ocaml_fn_87
        2542: dup
        2543: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2546: astore        145
        2548: new           #303                // class ocaml_fn_88
        2551: dup
        2552: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2555: astore        146
        2557: new           #306                // class ocaml_fn_89
        2560: dup
        2561: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2564: astore        147
        2566: new           #309                // class ocaml_fn_90
        2569: dup
        2570: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2573: astore        148
        2575: new           #312                // class ocaml_fn_91
        2578: dup
        2579: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2582: astore        149
        2584: new           #315                // class ocaml_fn_92
        2587: dup
        2588: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2591: astore        150
        2593: new           #318                // class ocaml_fn_93
        2596: dup
        2597: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2600: astore        151
        2602: new           #14                 // class Block
        2605: dup
        2606: iconst_0
        2607: bipush        104
        2609: anewarray     #16                 // class java/lang/Object
        2612: dup
        2613: iconst_0
        2614: aload         18
        2616: aastore
        2617: dup
        2618: iconst_1
        2619: aload         17
        2621: aastore
        2622: dup
        2623: iconst_2
        2624: aload         22
        2626: aastore
        2627: dup
        2628: iconst_3
        2629: aload         23
        2631: aastore
        2632: dup
        2633: iconst_4
        2634: aload         24
        2636: aastore
        2637: dup
        2638: iconst_5
        2639: aload         25
        2641: aastore
        2642: dup
        2643: bipush        6
        2645: aload         26
        2647: aastore
        2648: dup
        2649: bipush        7
        2651: aload         27
        2653: aastore
        2654: dup
        2655: bipush        8
        2657: aload         28
        2659: aastore
        2660: dup
        2661: bipush        9
        2663: aload         29
        2665: aastore
        2666: dup
        2667: bipush        10
        2669: aload         30
        2671: aastore
        2672: dup
        2673: bipush        11
        2675: aload         31
        2677: aastore
        2678: dup
        2679: bipush        12
        2681: aload         32
        2683: aastore
        2684: dup
        2685: bipush        13
        2687: aload         33
        2689: aastore
        2690: dup
        2691: bipush        14
        2693: aload         34
        2695: aastore
        2696: dup
        2697: bipush        15
        2699: aload         35
        2701: aastore
        2702: dup
        2703: bipush        16
        2705: aload         36
        2707: aastore
        2708: dup
        2709: bipush        17
        2711: aload         37
        2713: aastore
        2714: dup
        2715: bipush        18
        2717: iload         41
        2719: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2722: aastore
        2723: dup
        2724: bipush        19
        2726: iload         43
        2728: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2731: aastore
        2732: dup
        2733: bipush        20
        2735: aload         38
        2737: aastore
        2738: dup
        2739: bipush        21
        2741: aload         45
        2743: aastore
        2744: dup
        2745: bipush        22
        2747: aload         47
        2749: aastore
        2750: dup
        2751: bipush        23
        2753: aload         49
        2755: aastore
        2756: dup
        2757: bipush        24
        2759: aload         51
        2761: aastore
        2762: dup
        2763: bipush        25
        2765: aload         53
        2767: aastore
        2768: dup
        2769: bipush        26
        2771: aload         55
        2773: aastore
        2774: dup
        2775: bipush        27
        2777: aload         56
        2779: aastore
        2780: dup
        2781: bipush        28
        2783: aload         57
        2785: aastore
        2786: dup
        2787: bipush        29
        2789: aload         58
        2791: aastore
        2792: dup
        2793: bipush        30
        2795: aload         60
        2797: aastore
        2798: dup
        2799: bipush        31
        2801: aload         59
        2803: aastore
        2804: dup
        2805: bipush        32
        2807: aload         61
        2809: aastore
        2810: dup
        2811: bipush        33
        2813: aload         62
        2815: aastore
        2816: dup
        2817: bipush        34
        2819: aload         64
        2821: aastore
        2822: dup
        2823: bipush        35
        2825: aload         65
        2827: aastore
        2828: dup
        2829: bipush        36
        2831: aload         66
        2833: aastore
        2834: dup
        2835: bipush        37
        2837: aload         73
        2839: aastore
        2840: dup
        2841: bipush        38
        2843: aload         75
        2845: aastore
        2846: dup
        2847: bipush        39
        2849: aload         77
        2851: aastore
        2852: dup
        2853: bipush        40
        2855: aload         98
        2857: aastore
        2858: dup
        2859: bipush        41
        2861: aload         99
        2863: aastore
        2864: dup
        2865: bipush        42
        2867: aload         100
        2869: aastore
        2870: dup
        2871: bipush        43
        2873: aload         101
        2875: aastore
        2876: dup
        2877: bipush        44
        2879: aload         102
        2881: aastore
        2882: dup
        2883: bipush        45
        2885: aload         103
        2887: aastore
        2888: dup
        2889: bipush        46
        2891: aload         104
        2893: aastore
        2894: dup
        2895: bipush        47
        2897: aload         105
        2899: aastore
        2900: dup
        2901: bipush        48
        2903: aload         106
        2905: aastore
        2906: dup
        2907: bipush        49
        2909: aload         107
        2911: aastore
        2912: dup
        2913: bipush        50
        2915: aload         108
        2917: aastore
        2918: dup
        2919: bipush        51
        2921: aload         109
        2923: aastore
        2924: dup
        2925: bipush        52
        2927: aload         110
        2929: aastore
        2930: dup
        2931: bipush        53
        2933: aload         111
        2935: aastore
        2936: dup
        2937: bipush        54
        2939: aload         112
        2941: aastore
        2942: dup
        2943: bipush        55
        2945: aload         114
        2947: aastore
        2948: dup
        2949: bipush        56
        2951: aload         113
        2953: aastore
        2954: dup
        2955: bipush        57
        2957: aload         116
        2959: aastore
        2960: dup
        2961: bipush        58
        2963: aload         115
        2965: aastore
        2966: dup
        2967: bipush        59
        2969: aload         79
        2971: aastore
        2972: dup
        2973: bipush        60
        2975: aload         80
        2977: aastore
        2978: dup
        2979: bipush        61
        2981: aload         78
        2983: aastore
        2984: dup
        2985: bipush        62
        2987: aload         151
        2989: aastore
        2990: dup
        2991: bipush        63
        2993: aload         81
        2995: aastore
        2996: dup
        2997: bipush        64
        2999: aload         150
        3001: aastore
        3002: dup
        3003: bipush        65
        3005: aload         83
        3007: aastore
        3008: dup
        3009: bipush        66
        3011: aload         82
        3013: aastore
        3014: dup
        3015: bipush        67
        3017: aload         84
        3019: aastore
        3020: dup
        3021: bipush        68
        3023: aload         85
        3025: aastore
        3026: dup
        3027: bipush        69
        3029: aload         149
        3031: aastore
        3032: dup
        3033: bipush        70
        3035: aload         148
        3037: aastore
        3038: dup
        3039: bipush        71
        3041: aload         86
        3043: aastore
        3044: dup
        3045: bipush        72
        3047: aload         147
        3049: aastore
        3050: dup
        3051: bipush        73
        3053: aload         146
        3055: aastore
        3056: dup
        3057: bipush        74
        3059: aload         145
        3061: aastore
        3062: dup
        3063: bipush        75
        3065: aload         87
        3067: aastore
        3068: dup
        3069: bipush        76
        3071: aload         88
        3073: aastore
        3074: dup
        3075: bipush        77
        3077: aload         144
        3079: aastore
        3080: dup
        3081: bipush        78
        3083: aload         90
        3085: aastore
        3086: dup
        3087: bipush        79
        3089: aload         91
        3091: aastore
        3092: dup
        3093: bipush        80
        3095: aload         89
        3097: aastore
        3098: dup
        3099: bipush        81
        3101: aload         143
        3103: aastore
        3104: dup
        3105: bipush        82
        3107: aload         96
        3109: aastore
        3110: dup
        3111: bipush        83
        3113: aload         92
        3115: aastore
        3116: dup
        3117: bipush        84
        3119: aload         94
        3121: aastore
        3122: dup
        3123: bipush        85
        3125: aload         95
        3127: aastore
        3128: dup
        3129: bipush        86
        3131: aload         142
        3133: aastore
        3134: dup
        3135: bipush        87
        3137: aload         141
        3139: aastore
        3140: dup
        3141: bipush        88
        3143: aload         140
        3145: aastore
        3146: dup
        3147: bipush        89
        3149: aload         139
        3151: aastore
        3152: dup
        3153: bipush        90
        3155: aload         138
        3157: aastore
        3158: dup
        3159: bipush        91
        3161: aload         137
        3163: aastore
        3164: dup
        3165: bipush        92
        3167: aload         136
        3169: aastore
        3170: dup
        3171: bipush        93
        3173: aload         97
        3175: aastore
        3176: dup
        3177: bipush        94
        3179: aload         135
        3181: aastore
        3182: dup
        3183: bipush        95
        3185: aload         134
        3187: aastore
        3188: dup
        3189: bipush        96
        3191: aload         118
        3193: aastore
        3194: dup
        3195: bipush        97
        3197: aload         119
        3199: aastore
        3200: dup
        3201: bipush        98
        3203: aload         125
        3205: aastore
        3206: dup
        3207: bipush        99
        3209: aload         121
        3211: aastore
        3212: dup
        3213: bipush        100
        3215: aload         63
        3217: aastore
        3218: dup
        3219: bipush        101
        3221: aload         93
        3223: aastore
        3224: dup
        3225: bipush        102
        3227: aload         124
        3229: aastore
        3230: dup
        3231: bipush        103
        3233: aload         123
        3235: aastore
        3236: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3239: astore        152
        3241: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3244: bipush        45
        3246: aload         152
        3248: aastore
        3249: iconst_0
        3250: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3253: astore        153
        3255: iconst_0
        3256: istore        154
        3258: iload         154
        3260: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3263: astore        155
        3265: goto_w        3270
        3270: new           #321                // class ocaml_fn_94
        3273: dup
        3274: invokespecial #322                // Method ocaml_fn_94."<init>":()V
        3277: astore        156
        3279: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3282: bipush        46
        3284: aaload
        3285: astore        157
        3287: aload         156
        3289: aload         157
        3291: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3294: astore        158
        3296: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3299: aload         158
        3301: checkcast     #27                 // class java/lang/Integer
        3304: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3307: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3310: iconst_0
        3311: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3314: astore        159
        3316: new           #14                 // class Block
        3319: dup
        3320: iconst_0
        3321: iconst_1
        3322: anewarray     #16                 // class java/lang/Object
        3325: dup
        3326: iconst_0
        3327: aload         156
        3329: aastore
        3330: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3333: astore        160
        3335: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3338: bipush        47
        3340: aload         160
        3342: aastore
        3343: iconst_0
        3344: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3347: astore        161
        3349: iconst_0
        3350: istore        162
        3352: iconst_0
        3353: istore        163
        3355: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3358: bipush        45
        3360: aaload
        3361: checkcast     #14                 // class Block
        3364: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3367: bipush        102
        3369: aaload
        3370: astore        164
        3372: aload         164
        3374: checkcast     #96                 // class Closure
        3377: iload         163
        3379: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3382: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3385: astore        165
        3387: new           #14                 // class Block
        3390: dup
        3391: iconst_0
        3392: iconst_0
        3393: anewarray     #16                 // class java/lang/Object
        3396: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3399: astore        166
        3401: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3404: bipush        48
        3406: aload         166
        3408: aastore
        3409: iconst_0
        3410: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3413: astore        167
        3415: iconst_0
        3416: istore        168
        3418: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #347                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #349                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #351                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #353                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #355                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #357                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #359                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #361                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #363                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #365                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #367                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #369                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #371                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #373                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #375                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #377                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #379                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #381                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #383                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #385                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #387                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #389                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #387                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #389                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #391                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #389                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #387                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #393                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #395                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #397                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #399                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #400                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #400                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #401                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #402                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #403                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #404                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #406                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: ldc_w         #408                // String Test.Oops
        1047: aastore
        1048: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1051: bipush        47
        1053: iconst_0
        1054: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1057: aastore
        1058: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1061: bipush        48
        1063: iconst_0
        1064: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1067: aastore
        1068: aconst_null
        1069: astore_1
        1070: aload_1
        1071: astore_2
        1072: goto_w        1077
        1077: new           #2                  // class ocaml_fn_0
        1080: dup
        1081: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1084: astore_3
        1085: new           #8                  // class ocaml_fn_1
        1088: dup
        1089: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1092: astore        4
        1094: new           #11                 // class ocaml_fn_2
        1097: dup
        1098: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1101: astore        5
        1103: new           #14                 // class Block
        1106: dup
        1107: iconst_0
        1108: iconst_3
        1109: anewarray     #16                 // class java/lang/Object
        1112: dup
        1113: iconst_0
        1114: aload         4
        1116: aastore
        1117: dup
        1118: iconst_1
        1119: aload_3
        1120: aastore
        1121: dup
        1122: iconst_2
        1123: aload         5
        1125: aastore
        1126: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1129: astore        6
        1131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1134: bipush        12
        1136: aload         6
        1138: aastore
        1139: iconst_0
        1140: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1143: astore        7
        1145: iconst_0
        1146: istore        8
        1148: iload         8
        1150: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1153: astore        9
        1155: goto_w        1160
        1160: sipush        199
        1163: istore        10
        1165: iconst_0
        1166: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1169: astore        11
        1171: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1174: bipush        35
        1176: aaload
        1177: astore        12
        1179: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1182: iconst_3
        1183: aaload
        1184: astore        13
        1186: new           #14                 // class Block
        1189: dup
        1190: iconst_0
        1191: iconst_2
        1192: anewarray     #16                 // class java/lang/Object
        1195: dup
        1196: iconst_0
        1197: aload         13
        1199: aastore
        1200: dup
        1201: iconst_1
        1202: aload         12
        1204: aastore
        1205: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1208: astore        14
        1210: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1213: bipush        36
        1215: aaload
        1216: astore        15
        1218: iconst_0
        1219: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1222: astore        16
        1224: new           #33                 // class ocaml_fn_8
        1227: dup
        1228: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1231: astore        17
        1233: new           #36                 // class ocaml_fn_9
        1236: dup
        1237: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1240: astore        18
        1242: iconst_0
        1243: istore        19
        1245: iconst_0
        1246: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1249: astore        20
        1251: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1254: bipush        37
        1256: aaload
        1257: astore        21
        1259: new           #14                 // class Block
        1262: dup
        1263: sipush        248
        1266: iconst_2
        1267: anewarray     #16                 // class java/lang/Object
        1270: dup
        1271: iconst_0
        1272: aload         21
        1274: aastore
        1275: dup
        1276: iconst_1
        1277: aload         20
        1279: aastore
        1280: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        22
        1285: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1288: bipush        7
        1290: aaload
        1291: astore        23
        1293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1296: bipush        10
        1298: aaload
        1299: astore        24
        1301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1304: iconst_3
        1305: aaload
        1306: astore        25
        1308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1311: iconst_2
        1312: aaload
        1313: astore        26
        1315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1318: bipush        6
        1320: aaload
        1321: astore        27
        1323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1326: iconst_0
        1327: aaload
        1328: astore        28
        1330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1333: bipush        8
        1335: aaload
        1336: astore        29
        1338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1341: iconst_1
        1342: aaload
        1343: astore        30
        1345: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1348: iconst_4
        1349: aaload
        1350: astore        31
        1352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1355: iconst_5
        1356: aaload
        1357: astore        32
        1359: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1362: bipush        9
        1364: aaload
        1365: astore        33
        1367: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1370: bipush        11
        1372: aaload
        1373: astore        34
        1375: new           #39                 // class ocaml_fn_10
        1378: dup
        1379: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1382: astore        35
        1384: new           #42                 // class ocaml_fn_11
        1387: dup
        1388: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1391: astore        36
        1393: new           #45                 // class ocaml_fn_12
        1396: dup
        1397: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1400: astore        37
        1402: new           #48                 // class ocaml_fn_13
        1405: dup
        1406: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1409: astore        38
        1411: iconst_1
        1412: istore        39
        1414: iconst_m1
        1415: istore        40
        1417: iload         40
        1419: iload         39
        1421: iushr
        1422: istore        41
        1424: iconst_1
        1425: istore        42
        1427: iload         41
        1429: iload         42
        1431: iadd
        1432: istore        43
        1434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1437: bipush        38
        1439: aaload
        1440: astore        44
        1442: ldc2_w        #50                 // double 0.0d
        1445: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1448: astore        45
        1450: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1453: bipush        39
        1455: aaload
        1456: astore        46
        1458: ldc2_w        #50                 // double 0.0d
        1461: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1464: astore        47
        1466: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1469: bipush        40
        1471: aaload
        1472: astore        48
        1474: ldc2_w        #50                 // double 0.0d
        1477: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1480: astore        49
        1482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1485: bipush        41
        1487: aaload
        1488: astore        50
        1490: ldc2_w        #50                 // double 0.0d
        1493: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1496: astore        51
        1498: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1501: bipush        42
        1503: aaload
        1504: astore        52
        1506: ldc2_w        #50                 // double 0.0d
        1509: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1512: astore        53
        1514: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1517: bipush        43
        1519: aaload
        1520: astore        54
        1522: ldc2_w        #50                 // double 0.0d
        1525: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1528: astore        55
        1530: new           #58                 // class ocaml_fn_14
        1533: dup
        1534: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1537: astore        56
        1539: new           #61                 // class ocaml_fn_15
        1542: dup
        1543: aload         18
        1545: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1548: astore        57
        1550: new           #66                 // class ocaml_fn_16
        1553: dup
        1554: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1557: astore        58
        1559: new           #69                 // class ocaml_fn_17
        1562: dup
        1563: aload         18
        1565: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1568: astore        59
        1570: new           #72                 // class ocaml_fn_18
        1573: dup
        1574: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1577: astore        60
        1579: new           #75                 // class ocaml_fn_19
        1582: dup
        1583: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1586: astore        61
        1588: new           #78                 // class ocaml_fn_20
        1591: dup
        1592: aload         26
        1594: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1597: astore        62
        1599: new           #81                 // class ocaml_fn_21
        1602: dup
        1603: aload         56
        1605: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1608: astore        63
        1610: new           #84                 // class ocaml_fn_22
        1613: dup
        1614: aload         63
        1616: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1619: astore        64
        1621: new           #87                 // class ocaml_fn_23
        1624: dup
        1625: aload         26
        1627: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1630: astore        65
        1632: new           #90                 // class ocaml_fn_24
        1635: dup
        1636: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1639: astore        66
        1641: new           #93                 // class ocaml_fn_25
        1644: dup
        1645: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1648: astore        67
        1650: aload         66
        1652: checkcast     #90                 // class ocaml_fn_24
        1655: aload         66
        1657: checkcast     #96                 // class Closure
        1660: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1663: iconst_0
        1664: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1667: astore        68
        1669: aload         66
        1671: checkcast     #90                 // class ocaml_fn_24
        1674: aload         67
        1676: checkcast     #96                 // class Closure
        1679: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1682: iconst_0
        1683: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1686: astore        69
        1688: aload         67
        1690: checkcast     #93                 // class ocaml_fn_25
        1693: aload         66
        1695: checkcast     #96                 // class Closure
        1698: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1701: iconst_0
        1702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1705: astore        70
        1707: aload         67
        1709: checkcast     #93                 // class ocaml_fn_25
        1712: aload         67
        1714: checkcast     #96                 // class Closure
        1717: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1720: iconst_0
        1721: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1724: astore        71
        1726: iconst_0
        1727: istore        72
        1729: aconst_null
        1730: astore        73
        1732: iconst_1
        1733: istore        74
        1735: iload         74
        1737: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1740: astore        75
        1742: iconst_2
        1743: istore        76
        1745: iload         76
        1747: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1750: astore        77
        1752: new           #113                // class ocaml_fn_26
        1755: dup
        1756: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1759: astore        78
        1761: new           #116                // class ocaml_fn_27
        1764: dup
        1765: aload         78
        1767: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1770: astore        79
        1772: new           #119                // class ocaml_fn_28
        1775: dup
        1776: aload         78
        1778: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1781: astore        80
        1783: new           #122                // class ocaml_fn_29
        1786: dup
        1787: aload         30
        1789: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1792: astore        81
        1794: new           #125                // class ocaml_fn_30
        1797: dup
        1798: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1801: astore        82
        1803: new           #128                // class ocaml_fn_31
        1806: dup
        1807: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1810: astore        83
        1812: new           #131                // class ocaml_fn_32
        1815: dup
        1816: aload         18
        1818: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1821: astore        84
        1823: new           #134                // class ocaml_fn_33
        1826: dup
        1827: aload         18
        1829: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1832: astore        85
        1834: new           #137                // class ocaml_fn_34
        1837: dup
        1838: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1841: astore        86
        1843: new           #140                // class ocaml_fn_35
        1846: dup
        1847: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1850: astore        87
        1852: new           #143                // class ocaml_fn_36
        1855: dup
        1856: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1859: astore        88
        1861: new           #146                // class ocaml_fn_37
        1864: dup
        1865: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1868: astore        89
        1870: new           #149                // class ocaml_fn_38
        1873: dup
        1874: aload         89
        1876: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1879: astore        90
        1881: new           #152                // class ocaml_fn_39
        1884: dup
        1885: aload         89
        1887: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1890: astore        91
        1892: new           #155                // class ocaml_fn_40
        1895: dup
        1896: aload         18
        1898: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1901: astore        92
        1903: new           #158                // class ocaml_fn_41
        1906: dup
        1907: aload         31
        1909: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1912: astore        93
        1914: new           #161                // class ocaml_fn_42
        1917: dup
        1918: aload         18
        1920: aload         93
        1922: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1925: astore        94
        1927: new           #166                // class ocaml_fn_43
        1930: dup
        1931: aload         94
        1933: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1936: astore        95
        1938: new           #169                // class ocaml_fn_44
        1941: dup
        1942: aload         31
        1944: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1947: astore        96
        1949: new           #172                // class ocaml_fn_45
        1952: dup
        1953: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1956: astore        97
        1958: new           #175                // class ocaml_fn_46
        1961: dup
        1962: aload         75
        1964: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1967: astore        98
        1969: new           #178                // class ocaml_fn_47
        1972: dup
        1973: aload         75
        1975: aload         83
        1977: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1980: astore        99
        1982: new           #181                // class ocaml_fn_48
        1985: dup
        1986: aload         75
        1988: aload         82
        1990: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1993: astore        100
        1995: new           #184                // class ocaml_fn_49
        1998: dup
        1999: aload         61
        2001: aload         75
        2003: aload         83
        2005: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        101
        2010: new           #189                // class ocaml_fn_50
        2013: dup
        2014: aload         64
        2016: aload         75
        2018: aload         83
        2020: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2023: astore        102
        2025: new           #192                // class ocaml_fn_51
        2028: dup
        2029: aload         75
        2031: aload         83
        2033: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2036: astore        103
        2038: new           #195                // class ocaml_fn_52
        2041: dup
        2042: aload         75
        2044: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2047: astore        104
        2049: new           #198                // class ocaml_fn_53
        2052: dup
        2053: aload         77
        2055: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2058: astore        105
        2060: new           #201                // class ocaml_fn_54
        2063: dup
        2064: aload         77
        2066: aload         83
        2068: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2071: astore        106
        2073: new           #204                // class ocaml_fn_55
        2076: dup
        2077: aload         77
        2079: aload         82
        2081: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2084: astore        107
        2086: new           #207                // class ocaml_fn_56
        2089: dup
        2090: aload         61
        2092: aload         77
        2094: aload         83
        2096: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        108
        2101: new           #210                // class ocaml_fn_57
        2104: dup
        2105: aload         64
        2107: aload         77
        2109: aload         83
        2111: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2114: astore        109
        2116: new           #213                // class ocaml_fn_58
        2119: dup
        2120: aload         77
        2122: aload         83
        2124: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2127: astore        110
        2129: new           #216                // class ocaml_fn_59
        2132: dup
        2133: aload         77
        2135: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2138: astore        111
        2140: new           #219                // class ocaml_fn_60
        2143: dup
        2144: aload         73
        2146: aload         75
        2148: aload         96
        2150: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        112
        2155: new           #222                // class ocaml_fn_61
        2158: dup
        2159: aload         112
        2161: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2164: astore        113
        2166: new           #225                // class ocaml_fn_62
        2169: dup
        2170: aload         62
        2172: aload         112
        2174: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2177: astore        114
        2179: new           #228                // class ocaml_fn_63
        2182: dup
        2183: aload         112
        2185: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2188: astore        115
        2190: new           #231                // class ocaml_fn_64
        2193: dup
        2194: aload         65
        2196: aload         112
        2198: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2201: astore        116
        2203: new           #14                 // class Block
        2206: dup
        2207: iconst_0
        2208: iconst_0
        2209: anewarray     #16                 // class java/lang/Object
        2212: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2215: astore        117
        2217: new           #234                // class ocaml_fn_65
        2220: dup
        2221: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2224: astore        118
        2226: new           #237                // class ocaml_fn_66
        2229: dup
        2230: aload         56
        2232: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2235: astore        119
        2237: new           #14                 // class Block
        2240: dup
        2241: iconst_0
        2242: iconst_1
        2243: anewarray     #16                 // class java/lang/Object
        2246: dup
        2247: iconst_0
        2248: aload         81
        2250: aastore
        2251: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2254: astore        120
        2256: new           #240                // class ocaml_fn_67
        2259: dup
        2260: aload         120
        2262: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2265: astore        121
        2267: new           #243                // class ocaml_fn_68
        2270: dup
        2271: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2274: astore        122
        2276: new           #14                 // class Block
        2279: dup
        2280: iconst_0
        2281: iconst_1
        2282: anewarray     #16                 // class java/lang/Object
        2285: dup
        2286: iconst_0
        2287: aload         122
        2289: aastore
        2290: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2293: astore        123
        2295: new           #246                // class ocaml_fn_69
        2298: dup
        2299: aload         120
        2301: aload         123
        2303: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2306: astore        124
        2308: new           #249                // class ocaml_fn_70
        2311: dup
        2312: aload         124
        2314: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2317: astore        125
        2319: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2322: bipush        44
        2324: aaload
        2325: astore        126
        2327: iconst_0
        2328: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2331: astore        127
        2333: new           #252                // class ocaml_fn_71
        2336: dup
        2337: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2340: astore        128
        2342: new           #255                // class ocaml_fn_72
        2345: dup
        2346: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2349: astore        129
        2351: new           #258                // class ocaml_fn_73
        2354: dup
        2355: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2358: astore        130
        2360: new           #261                // class ocaml_fn_74
        2363: dup
        2364: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2367: astore        131
        2369: new           #264                // class ocaml_fn_75
        2372: dup
        2373: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2376: astore        132
        2378: new           #267                // class ocaml_fn_76
        2381: dup
        2382: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2385: astore        133
        2387: new           #14                 // class Block
        2390: dup
        2391: iconst_0
        2392: bipush        6
        2394: anewarray     #16                 // class java/lang/Object
        2397: dup
        2398: iconst_0
        2399: aload         133
        2401: aastore
        2402: dup
        2403: iconst_1
        2404: aload         132
        2406: aastore
        2407: dup
        2408: iconst_2
        2409: aload         131
        2411: aastore
        2412: dup
        2413: iconst_3
        2414: aload         130
        2416: aastore
        2417: dup
        2418: iconst_4
        2419: aload         129
        2421: aastore
        2422: dup
        2423: iconst_5
        2424: aload         128
        2426: aastore
        2427: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2430: astore        134
        2432: new           #270                // class ocaml_fn_77
        2435: dup
        2436: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2439: astore        135
        2441: new           #273                // class ocaml_fn_78
        2444: dup
        2445: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2448: astore        136
        2450: new           #276                // class ocaml_fn_79
        2453: dup
        2454: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2457: astore        137
        2459: new           #279                // class ocaml_fn_80
        2462: dup
        2463: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2466: astore        138
        2468: new           #282                // class ocaml_fn_81
        2471: dup
        2472: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2475: astore        139
        2477: new           #285                // class ocaml_fn_82
        2480: dup
        2481: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2484: astore        140
        2486: new           #288                // class ocaml_fn_83
        2489: dup
        2490: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2493: astore        141
        2495: new           #291                // class ocaml_fn_84
        2498: dup
        2499: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2502: astore        142
        2504: new           #294                // class ocaml_fn_85
        2507: dup
        2508: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2511: astore        143
        2513: new           #297                // class ocaml_fn_86
        2516: dup
        2517: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2520: astore        144
        2522: new           #300                // class ocaml_fn_87
        2525: dup
        2526: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2529: astore        145
        2531: new           #303                // class ocaml_fn_88
        2534: dup
        2535: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2538: astore        146
        2540: new           #306                // class ocaml_fn_89
        2543: dup
        2544: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2547: astore        147
        2549: new           #309                // class ocaml_fn_90
        2552: dup
        2553: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2556: astore        148
        2558: new           #312                // class ocaml_fn_91
        2561: dup
        2562: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2565: astore        149
        2567: new           #315                // class ocaml_fn_92
        2570: dup
        2571: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2574: astore        150
        2576: new           #318                // class ocaml_fn_93
        2579: dup
        2580: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2583: astore        151
        2585: new           #14                 // class Block
        2588: dup
        2589: iconst_0
        2590: bipush        104
        2592: anewarray     #16                 // class java/lang/Object
        2595: dup
        2596: iconst_0
        2597: aload         18
        2599: aastore
        2600: dup
        2601: iconst_1
        2602: aload         17
        2604: aastore
        2605: dup
        2606: iconst_2
        2607: aload         22
        2609: aastore
        2610: dup
        2611: iconst_3
        2612: aload         23
        2614: aastore
        2615: dup
        2616: iconst_4
        2617: aload         24
        2619: aastore
        2620: dup
        2621: iconst_5
        2622: aload         25
        2624: aastore
        2625: dup
        2626: bipush        6
        2628: aload         26
        2630: aastore
        2631: dup
        2632: bipush        7
        2634: aload         27
        2636: aastore
        2637: dup
        2638: bipush        8
        2640: aload         28
        2642: aastore
        2643: dup
        2644: bipush        9
        2646: aload         29
        2648: aastore
        2649: dup
        2650: bipush        10
        2652: aload         30
        2654: aastore
        2655: dup
        2656: bipush        11
        2658: aload         31
        2660: aastore
        2661: dup
        2662: bipush        12
        2664: aload         32
        2666: aastore
        2667: dup
        2668: bipush        13
        2670: aload         33
        2672: aastore
        2673: dup
        2674: bipush        14
        2676: aload         34
        2678: aastore
        2679: dup
        2680: bipush        15
        2682: aload         35
        2684: aastore
        2685: dup
        2686: bipush        16
        2688: aload         36
        2690: aastore
        2691: dup
        2692: bipush        17
        2694: aload         37
        2696: aastore
        2697: dup
        2698: bipush        18
        2700: iload         41
        2702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2705: aastore
        2706: dup
        2707: bipush        19
        2709: iload         43
        2711: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2714: aastore
        2715: dup
        2716: bipush        20
        2718: aload         38
        2720: aastore
        2721: dup
        2722: bipush        21
        2724: aload         45
        2726: aastore
        2727: dup
        2728: bipush        22
        2730: aload         47
        2732: aastore
        2733: dup
        2734: bipush        23
        2736: aload         49
        2738: aastore
        2739: dup
        2740: bipush        24
        2742: aload         51
        2744: aastore
        2745: dup
        2746: bipush        25
        2748: aload         53
        2750: aastore
        2751: dup
        2752: bipush        26
        2754: aload         55
        2756: aastore
        2757: dup
        2758: bipush        27
        2760: aload         56
        2762: aastore
        2763: dup
        2764: bipush        28
        2766: aload         57
        2768: aastore
        2769: dup
        2770: bipush        29
        2772: aload         58
        2774: aastore
        2775: dup
        2776: bipush        30
        2778: aload         60
        2780: aastore
        2781: dup
        2782: bipush        31
        2784: aload         59
        2786: aastore
        2787: dup
        2788: bipush        32
        2790: aload         61
        2792: aastore
        2793: dup
        2794: bipush        33
        2796: aload         62
        2798: aastore
        2799: dup
        2800: bipush        34
        2802: aload         64
        2804: aastore
        2805: dup
        2806: bipush        35
        2808: aload         65
        2810: aastore
        2811: dup
        2812: bipush        36
        2814: aload         66
        2816: aastore
        2817: dup
        2818: bipush        37
        2820: aload         73
        2822: aastore
        2823: dup
        2824: bipush        38
        2826: aload         75
        2828: aastore
        2829: dup
        2830: bipush        39
        2832: aload         77
        2834: aastore
        2835: dup
        2836: bipush        40
        2838: aload         98
        2840: aastore
        2841: dup
        2842: bipush        41
        2844: aload         99
        2846: aastore
        2847: dup
        2848: bipush        42
        2850: aload         100
        2852: aastore
        2853: dup
        2854: bipush        43
        2856: aload         101
        2858: aastore
        2859: dup
        2860: bipush        44
        2862: aload         102
        2864: aastore
        2865: dup
        2866: bipush        45
        2868: aload         103
        2870: aastore
        2871: dup
        2872: bipush        46
        2874: aload         104
        2876: aastore
        2877: dup
        2878: bipush        47
        2880: aload         105
        2882: aastore
        2883: dup
        2884: bipush        48
        2886: aload         106
        2888: aastore
        2889: dup
        2890: bipush        49
        2892: aload         107
        2894: aastore
        2895: dup
        2896: bipush        50
        2898: aload         108
        2900: aastore
        2901: dup
        2902: bipush        51
        2904: aload         109
        2906: aastore
        2907: dup
        2908: bipush        52
        2910: aload         110
        2912: aastore
        2913: dup
        2914: bipush        53
        2916: aload         111
        2918: aastore
        2919: dup
        2920: bipush        54
        2922: aload         112
        2924: aastore
        2925: dup
        2926: bipush        55
        2928: aload         114
        2930: aastore
        2931: dup
        2932: bipush        56
        2934: aload         113
        2936: aastore
        2937: dup
        2938: bipush        57
        2940: aload         116
        2942: aastore
        2943: dup
        2944: bipush        58
        2946: aload         115
        2948: aastore
        2949: dup
        2950: bipush        59
        2952: aload         79
        2954: aastore
        2955: dup
        2956: bipush        60
        2958: aload         80
        2960: aastore
        2961: dup
        2962: bipush        61
        2964: aload         78
        2966: aastore
        2967: dup
        2968: bipush        62
        2970: aload         151
        2972: aastore
        2973: dup
        2974: bipush        63
        2976: aload         81
        2978: aastore
        2979: dup
        2980: bipush        64
        2982: aload         150
        2984: aastore
        2985: dup
        2986: bipush        65
        2988: aload         83
        2990: aastore
        2991: dup
        2992: bipush        66
        2994: aload         82
        2996: aastore
        2997: dup
        2998: bipush        67
        3000: aload         84
        3002: aastore
        3003: dup
        3004: bipush        68
        3006: aload         85
        3008: aastore
        3009: dup
        3010: bipush        69
        3012: aload         149
        3014: aastore
        3015: dup
        3016: bipush        70
        3018: aload         148
        3020: aastore
        3021: dup
        3022: bipush        71
        3024: aload         86
        3026: aastore
        3027: dup
        3028: bipush        72
        3030: aload         147
        3032: aastore
        3033: dup
        3034: bipush        73
        3036: aload         146
        3038: aastore
        3039: dup
        3040: bipush        74
        3042: aload         145
        3044: aastore
        3045: dup
        3046: bipush        75
        3048: aload         87
        3050: aastore
        3051: dup
        3052: bipush        76
        3054: aload         88
        3056: aastore
        3057: dup
        3058: bipush        77
        3060: aload         144
        3062: aastore
        3063: dup
        3064: bipush        78
        3066: aload         90
        3068: aastore
        3069: dup
        3070: bipush        79
        3072: aload         91
        3074: aastore
        3075: dup
        3076: bipush        80
        3078: aload         89
        3080: aastore
        3081: dup
        3082: bipush        81
        3084: aload         143
        3086: aastore
        3087: dup
        3088: bipush        82
        3090: aload         96
        3092: aastore
        3093: dup
        3094: bipush        83
        3096: aload         92
        3098: aastore
        3099: dup
        3100: bipush        84
        3102: aload         94
        3104: aastore
        3105: dup
        3106: bipush        85
        3108: aload         95
        3110: aastore
        3111: dup
        3112: bipush        86
        3114: aload         142
        3116: aastore
        3117: dup
        3118: bipush        87
        3120: aload         141
        3122: aastore
        3123: dup
        3124: bipush        88
        3126: aload         140
        3128: aastore
        3129: dup
        3130: bipush        89
        3132: aload         139
        3134: aastore
        3135: dup
        3136: bipush        90
        3138: aload         138
        3140: aastore
        3141: dup
        3142: bipush        91
        3144: aload         137
        3146: aastore
        3147: dup
        3148: bipush        92
        3150: aload         136
        3152: aastore
        3153: dup
        3154: bipush        93
        3156: aload         97
        3158: aastore
        3159: dup
        3160: bipush        94
        3162: aload         135
        3164: aastore
        3165: dup
        3166: bipush        95
        3168: aload         134
        3170: aastore
        3171: dup
        3172: bipush        96
        3174: aload         118
        3176: aastore
        3177: dup
        3178: bipush        97
        3180: aload         119
        3182: aastore
        3183: dup
        3184: bipush        98
        3186: aload         125
        3188: aastore
        3189: dup
        3190: bipush        99
        3192: aload         121
        3194: aastore
        3195: dup
        3196: bipush        100
        3198: aload         63
        3200: aastore
        3201: dup
        3202: bipush        101
        3204: aload         93
        3206: aastore
        3207: dup
        3208: bipush        102
        3210: aload         124
        3212: aastore
        3213: dup
        3214: bipush        103
        3216: aload         123
        3218: aastore
        3219: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3222: astore        152
        3224: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3227: bipush        45
        3229: aload         152
        3231: aastore
        3232: iconst_0
        3233: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3236: astore        153
        3238: iconst_0
        3239: istore        154
        3241: iload         154
        3243: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3246: astore        155
        3248: goto_w        3253
        3253: iconst_0
        3254: istore        156
        3256: iconst_1
        3257: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        157
        3262: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3265: bipush        46
        3267: aaload
        3268: astore        158
        3270: new           #14                 // class Block
        3273: dup
        3274: sipush        248
        3277: iconst_2
        3278: anewarray     #16                 // class java/lang/Object
        3281: dup
        3282: iconst_0
        3283: aload         158
        3285: aastore
        3286: dup
        3287: iconst_1
        3288: aload         157
        3290: aastore
        3291: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3294: astore        159
        3296: new           #321                // class ocaml_fn_94
        3299: dup
        3300: aload         159
        3302: invokespecial #322                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3305: astore        160
        3307: iconst_0
        3308: istore        161
        3310: aload         160
        3312: iload         161
        3314: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3317: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3320: astore        162
        3322: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3325: aload         162
        3327: checkcast     #27                 // class java/lang/Integer
        3330: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3333: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3336: iconst_0
        3337: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3340: astore        163
        3342: new           #14                 // class Block
        3345: dup
        3346: iconst_0
        3347: iconst_2
        3348: anewarray     #16                 // class java/lang/Object
        3351: dup
        3352: iconst_0
        3353: aload         159
        3355: aastore
        3356: dup
        3357: iconst_1
        3358: aload         160
        3360: aastore
        3361: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3364: astore        164
        3366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3369: bipush        47
        3371: aload         164
        3373: aastore
        3374: iconst_0
        3375: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3378: astore        165
        3380: iconst_0
        3381: istore        166
        3383: iconst_0
        3384: istore        167
        3386: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3389: bipush        45
        3391: aaload
        3392: checkcast     #14                 // class Block
        3395: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3398: bipush        102
        3400: aaload
        3401: astore        168
        3403: aload         168
        3405: checkcast     #96                 // class Closure
        3408: iload         167
        3410: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3413: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3416: astore        169
        3418: new           #14                 // class Block
        3421: dup
        3422: iconst_0
        3423: iconst_0
        3424: anewarray     #16                 // class java/lang/Object
        3427: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3430: astore        170
        3432: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3435: bipush        48
        3437: aload         170
        3439: aastore
        3440: iconst_0
        3441: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3444: astore        171
        3446: iconst_0
        3447: istore        172
        3449: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #16                 // class java/lang/Object
           5: putstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #14                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #16                 // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc_w         #344                // String Out_of_memory
          28: aastore
          29: dup
          30: iconst_1
          31: iconst_m1
          32: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          35: aastore
          36: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          39: aastore
          40: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          43: iconst_1
          44: new           #14                 // class Block
          47: dup
          48: sipush        248
          51: iconst_2
          52: anewarray     #16                 // class java/lang/Object
          55: dup
          56: iconst_0
          57: ldc_w         #346                // String Sys_error
          60: aastore
          61: dup
          62: iconst_1
          63: bipush        -2
          65: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          68: aastore
          69: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          72: aastore
          73: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_2
          77: new           #14                 // class Block
          80: dup
          81: sipush        248
          84: iconst_2
          85: anewarray     #16                 // class java/lang/Object
          88: dup
          89: iconst_0
          90: ldc_w         #348                // String Failure
          93: aastore
          94: dup
          95: iconst_1
          96: bipush        -3
          98: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         101: aastore
         102: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         105: aastore
         106: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         109: iconst_3
         110: new           #14                 // class Block
         113: dup
         114: sipush        248
         117: iconst_2
         118: anewarray     #16                 // class java/lang/Object
         121: dup
         122: iconst_0
         123: ldc_w         #350                // String Invalid_argument
         126: aastore
         127: dup
         128: iconst_1
         129: bipush        -4
         131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         134: aastore
         135: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         138: aastore
         139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         142: iconst_4
         143: new           #14                 // class Block
         146: dup
         147: sipush        248
         150: iconst_2
         151: anewarray     #16                 // class java/lang/Object
         154: dup
         155: iconst_0
         156: ldc_w         #352                // String End_of_file
         159: aastore
         160: dup
         161: iconst_1
         162: bipush        -5
         164: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         167: aastore
         168: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         171: aastore
         172: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         175: iconst_5
         176: new           #14                 // class Block
         179: dup
         180: sipush        248
         183: iconst_2
         184: anewarray     #16                 // class java/lang/Object
         187: dup
         188: iconst_0
         189: ldc_w         #354                // String Division_by_zero
         192: aastore
         193: dup
         194: iconst_1
         195: bipush        -6
         197: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         200: aastore
         201: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         204: aastore
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        6
         210: new           #14                 // class Block
         213: dup
         214: sipush        248
         217: iconst_2
         218: anewarray     #16                 // class java/lang/Object
         221: dup
         222: iconst_0
         223: ldc_w         #356                // String Not_found
         226: aastore
         227: dup
         228: iconst_1
         229: bipush        -7
         231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: aastore
         235: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         238: aastore
         239: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         242: bipush        7
         244: new           #14                 // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #16                 // class java/lang/Object
         255: dup
         256: iconst_0
         257: ldc_w         #358                // String Match_failure
         260: aastore
         261: dup
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         272: aastore
         273: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         276: bipush        8
         278: new           #14                 // class Block
         281: dup
         282: sipush        248
         285: iconst_2
         286: anewarray     #16                 // class java/lang/Object
         289: dup
         290: iconst_0
         291: ldc_w         #360                // String Stack_overflow
         294: aastore
         295: dup
         296: iconst_1
         297: bipush        -9
         299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         302: aastore
         303: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         306: aastore
         307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         310: bipush        9
         312: new           #14                 // class Block
         315: dup
         316: sipush        248
         319: iconst_2
         320: anewarray     #16                 // class java/lang/Object
         323: dup
         324: iconst_0
         325: ldc_w         #362                // String Sys_blocked_io
         328: aastore
         329: dup
         330: iconst_1
         331: bipush        -10
         333: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         336: aastore
         337: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: new           #14                 // class Block
         349: dup
         350: sipush        248
         353: iconst_2
         354: anewarray     #16                 // class java/lang/Object
         357: dup
         358: iconst_0
         359: ldc_w         #364                // String Assert_failure
         362: aastore
         363: dup
         364: iconst_1
         365: bipush        -11
         367: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         370: aastore
         371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         374: aastore
         375: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         378: bipush        11
         380: new           #14                 // class Block
         383: dup
         384: sipush        248
         387: iconst_2
         388: anewarray     #16                 // class java/lang/Object
         391: dup
         392: iconst_0
         393: ldc_w         #366                // String Undefined_recursive_module
         396: aastore
         397: dup
         398: iconst_1
         399: bipush        -12
         401: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         404: aastore
         405: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         408: aastore
         409: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         412: bipush        12
         414: iconst_0
         415: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         418: aastore
         419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         422: bipush        13
         424: ldc_w         #368                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #370                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #372                // String input
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        16
         451: new           #14                 // class Block
         454: dup
         455: iconst_0
         456: iconst_2
         457: anewarray     #16                 // class java/lang/Object
         460: dup
         461: iconst_0
         462: iconst_0
         463: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         466: aastore
         467: dup
         468: iconst_1
         469: new           #14                 // class Block
         472: dup
         473: iconst_0
         474: iconst_2
         475: anewarray     #16                 // class java/lang/Object
         478: dup
         479: iconst_0
         480: bipush        6
         482: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         485: aastore
         486: dup
         487: iconst_1
         488: iconst_0
         489: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         492: aastore
         493: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         496: aastore
         497: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         500: aastore
         501: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         504: bipush        17
         506: new           #14                 // class Block
         509: dup
         510: iconst_0
         511: iconst_2
         512: anewarray     #16                 // class java/lang/Object
         515: dup
         516: iconst_0
         517: iconst_0
         518: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         521: aastore
         522: dup
         523: iconst_1
         524: new           #14                 // class Block
         527: dup
         528: iconst_0
         529: iconst_2
         530: anewarray     #16                 // class java/lang/Object
         533: dup
         534: iconst_0
         535: bipush        7
         537: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         540: aastore
         541: dup
         542: iconst_1
         543: iconst_0
         544: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         547: aastore
         548: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         551: aastore
         552: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        18
         561: ldc_w         #374                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #376                // String output
         573: aastore
         574: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         577: bipush        20
         579: new           #14                 // class Block
         582: dup
         583: iconst_0
         584: iconst_2
         585: anewarray     #16                 // class java/lang/Object
         588: dup
         589: iconst_0
         590: iconst_1
         591: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         594: aastore
         595: dup
         596: iconst_1
         597: new           #14                 // class Block
         600: dup
         601: iconst_0
         602: iconst_2
         603: anewarray     #16                 // class java/lang/Object
         606: dup
         607: iconst_0
         608: iconst_3
         609: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         612: aastore
         613: dup
         614: iconst_1
         615: new           #14                 // class Block
         618: dup
         619: iconst_0
         620: iconst_2
         621: anewarray     #16                 // class java/lang/Object
         624: dup
         625: iconst_0
         626: iconst_4
         627: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         630: aastore
         631: dup
         632: iconst_1
         633: new           #14                 // class Block
         636: dup
         637: iconst_0
         638: iconst_2
         639: anewarray     #16                 // class java/lang/Object
         642: dup
         643: iconst_0
         644: bipush        6
         646: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         649: aastore
         650: dup
         651: iconst_1
         652: iconst_0
         653: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         656: aastore
         657: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         660: aastore
         661: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         664: aastore
         665: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         668: aastore
         669: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         672: aastore
         673: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         676: bipush        21
         678: new           #14                 // class Block
         681: dup
         682: iconst_0
         683: iconst_2
         684: anewarray     #16                 // class java/lang/Object
         687: dup
         688: iconst_0
         689: iconst_1
         690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         693: aastore
         694: dup
         695: iconst_1
         696: new           #14                 // class Block
         699: dup
         700: iconst_0
         701: iconst_2
         702: anewarray     #16                 // class java/lang/Object
         705: dup
         706: iconst_0
         707: iconst_3
         708: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         711: aastore
         712: dup
         713: iconst_1
         714: new           #14                 // class Block
         717: dup
         718: iconst_0
         719: iconst_2
         720: anewarray     #16                 // class java/lang/Object
         723: dup
         724: iconst_0
         725: iconst_4
         726: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         729: aastore
         730: dup
         731: iconst_1
         732: new           #14                 // class Block
         735: dup
         736: iconst_0
         737: iconst_2
         738: anewarray     #16                 // class java/lang/Object
         741: dup
         742: iconst_0
         743: bipush        7
         745: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         748: aastore
         749: dup
         750: iconst_1
         751: iconst_0
         752: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         755: aastore
         756: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         759: aastore
         760: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         763: aastore
         764: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         767: aastore
         768: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         771: aastore
         772: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         775: bipush        22
         777: ldc_w         #378                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #380                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #382                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #384                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #386                // String true
         816: aastore
         817: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        27
         822: new           #14                 // class Block
         825: dup
         826: iconst_0
         827: iconst_1
         828: anewarray     #16                 // class java/lang/Object
         831: dup
         832: iconst_0
         833: iconst_1
         834: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         837: aastore
         838: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         841: aastore
         842: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         845: bipush        28
         847: new           #14                 // class Block
         850: dup
         851: iconst_0
         852: iconst_1
         853: anewarray     #16                 // class java/lang/Object
         856: dup
         857: iconst_0
         858: iconst_0
         859: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         862: aastore
         863: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         866: aastore
         867: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         870: bipush        29
         872: ldc_w         #384                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #386                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #388                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #386                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #384                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #390                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #392                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #394                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #396                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #397                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #397                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #398                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #399                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #400                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #401                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #403                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: iconst_0
        1045: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1048: aastore
        1049: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1052: bipush        47
        1054: iconst_0
        1055: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1058: aastore
        1059: aconst_null
        1060: astore_1
        1061: aload_1
        1062: astore_2
        1063: goto_w        1068
        1068: new           #2                  // class ocaml_fn_0
        1071: dup
        1072: invokespecial #6                  // Method ocaml_fn_0."<init>":()V
        1075: astore_3
        1076: new           #8                  // class ocaml_fn_1
        1079: dup
        1080: invokespecial #9                  // Method ocaml_fn_1."<init>":()V
        1083: astore        4
        1085: new           #11                 // class ocaml_fn_2
        1088: dup
        1089: invokespecial #12                 // Method ocaml_fn_2."<init>":()V
        1092: astore        5
        1094: new           #14                 // class Block
        1097: dup
        1098: iconst_0
        1099: iconst_3
        1100: anewarray     #16                 // class java/lang/Object
        1103: dup
        1104: iconst_0
        1105: aload         4
        1107: aastore
        1108: dup
        1109: iconst_1
        1110: aload_3
        1111: aastore
        1112: dup
        1113: iconst_2
        1114: aload         5
        1116: aastore
        1117: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1120: astore        6
        1122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1125: bipush        12
        1127: aload         6
        1129: aastore
        1130: iconst_0
        1131: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1134: astore        7
        1136: iconst_0
        1137: istore        8
        1139: iload         8
        1141: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1144: astore        9
        1146: goto_w        1151
        1151: sipush        199
        1154: istore        10
        1156: iconst_0
        1157: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1160: astore        11
        1162: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1165: bipush        35
        1167: aaload
        1168: astore        12
        1170: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1173: iconst_3
        1174: aaload
        1175: astore        13
        1177: new           #14                 // class Block
        1180: dup
        1181: iconst_0
        1182: iconst_2
        1183: anewarray     #16                 // class java/lang/Object
        1186: dup
        1187: iconst_0
        1188: aload         13
        1190: aastore
        1191: dup
        1192: iconst_1
        1193: aload         12
        1195: aastore
        1196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1199: astore        14
        1201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1204: bipush        36
        1206: aaload
        1207: astore        15
        1209: iconst_0
        1210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1213: astore        16
        1215: new           #33                 // class ocaml_fn_8
        1218: dup
        1219: invokespecial #34                 // Method ocaml_fn_8."<init>":()V
        1222: astore        17
        1224: new           #36                 // class ocaml_fn_9
        1227: dup
        1228: invokespecial #37                 // Method ocaml_fn_9."<init>":()V
        1231: astore        18
        1233: iconst_0
        1234: istore        19
        1236: iconst_0
        1237: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1240: astore        20
        1242: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1245: bipush        37
        1247: aaload
        1248: astore        21
        1250: new           #14                 // class Block
        1253: dup
        1254: sipush        248
        1257: iconst_2
        1258: anewarray     #16                 // class java/lang/Object
        1261: dup
        1262: iconst_0
        1263: aload         21
        1265: aastore
        1266: dup
        1267: iconst_1
        1268: aload         20
        1270: aastore
        1271: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1274: astore        22
        1276: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1279: bipush        7
        1281: aaload
        1282: astore        23
        1284: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1287: bipush        10
        1289: aaload
        1290: astore        24
        1292: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1295: iconst_3
        1296: aaload
        1297: astore        25
        1299: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1302: iconst_2
        1303: aaload
        1304: astore        26
        1306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1309: bipush        6
        1311: aaload
        1312: astore        27
        1314: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1317: iconst_0
        1318: aaload
        1319: astore        28
        1321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1324: bipush        8
        1326: aaload
        1327: astore        29
        1329: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1332: iconst_1
        1333: aaload
        1334: astore        30
        1336: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1339: iconst_4
        1340: aaload
        1341: astore        31
        1343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1346: iconst_5
        1347: aaload
        1348: astore        32
        1350: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1353: bipush        9
        1355: aaload
        1356: astore        33
        1358: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1361: bipush        11
        1363: aaload
        1364: astore        34
        1366: new           #39                 // class ocaml_fn_10
        1369: dup
        1370: invokespecial #40                 // Method ocaml_fn_10."<init>":()V
        1373: astore        35
        1375: new           #42                 // class ocaml_fn_11
        1378: dup
        1379: invokespecial #43                 // Method ocaml_fn_11."<init>":()V
        1382: astore        36
        1384: new           #45                 // class ocaml_fn_12
        1387: dup
        1388: invokespecial #46                 // Method ocaml_fn_12."<init>":()V
        1391: astore        37
        1393: new           #48                 // class ocaml_fn_13
        1396: dup
        1397: invokespecial #49                 // Method ocaml_fn_13."<init>":()V
        1400: astore        38
        1402: iconst_1
        1403: istore        39
        1405: iconst_m1
        1406: istore        40
        1408: iload         40
        1410: iload         39
        1412: iushr
        1413: istore        41
        1415: iconst_1
        1416: istore        42
        1418: iload         41
        1420: iload         42
        1422: iadd
        1423: istore        43
        1425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1428: bipush        38
        1430: aaload
        1431: astore        44
        1433: ldc2_w        #50                 // double 0.0d
        1436: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1439: astore        45
        1441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1444: bipush        39
        1446: aaload
        1447: astore        46
        1449: ldc2_w        #50                 // double 0.0d
        1452: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1455: astore        47
        1457: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1460: bipush        40
        1462: aaload
        1463: astore        48
        1465: ldc2_w        #50                 // double 0.0d
        1468: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1471: astore        49
        1473: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1476: bipush        41
        1478: aaload
        1479: astore        50
        1481: ldc2_w        #50                 // double 0.0d
        1484: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1487: astore        51
        1489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1492: bipush        42
        1494: aaload
        1495: astore        52
        1497: ldc2_w        #50                 // double 0.0d
        1500: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1503: astore        53
        1505: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1508: bipush        43
        1510: aaload
        1511: astore        54
        1513: ldc2_w        #50                 // double 0.0d
        1516: invokestatic  #56                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1519: astore        55
        1521: new           #58                 // class ocaml_fn_14
        1524: dup
        1525: invokespecial #59                 // Method ocaml_fn_14."<init>":()V
        1528: astore        56
        1530: new           #61                 // class ocaml_fn_15
        1533: dup
        1534: aload         18
        1536: invokespecial #64                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1539: astore        57
        1541: new           #66                 // class ocaml_fn_16
        1544: dup
        1545: invokespecial #67                 // Method ocaml_fn_16."<init>":()V
        1548: astore        58
        1550: new           #69                 // class ocaml_fn_17
        1553: dup
        1554: aload         18
        1556: invokespecial #70                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1559: astore        59
        1561: new           #72                 // class ocaml_fn_18
        1564: dup
        1565: invokespecial #73                 // Method ocaml_fn_18."<init>":()V
        1568: astore        60
        1570: new           #75                 // class ocaml_fn_19
        1573: dup
        1574: invokespecial #76                 // Method ocaml_fn_19."<init>":()V
        1577: astore        61
        1579: new           #78                 // class ocaml_fn_20
        1582: dup
        1583: aload         26
        1585: invokespecial #79                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1588: astore        62
        1590: new           #81                 // class ocaml_fn_21
        1593: dup
        1594: aload         56
        1596: invokespecial #82                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1599: astore        63
        1601: new           #84                 // class ocaml_fn_22
        1604: dup
        1605: aload         63
        1607: invokespecial #85                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1610: astore        64
        1612: new           #87                 // class ocaml_fn_23
        1615: dup
        1616: aload         26
        1618: invokespecial #88                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1621: astore        65
        1623: new           #90                 // class ocaml_fn_24
        1626: dup
        1627: invokespecial #91                 // Method ocaml_fn_24."<init>":()V
        1630: astore        66
        1632: new           #93                 // class ocaml_fn_25
        1635: dup
        1636: invokespecial #94                 // Method ocaml_fn_25."<init>":()V
        1639: astore        67
        1641: aload         66
        1643: checkcast     #90                 // class ocaml_fn_24
        1646: aload         66
        1648: checkcast     #96                 // class Closure
        1651: putfield      #100                // Field ocaml_fn_24.sibling_0:LClosure;
        1654: iconst_0
        1655: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1658: astore        68
        1660: aload         66
        1662: checkcast     #90                 // class ocaml_fn_24
        1665: aload         67
        1667: checkcast     #96                 // class Closure
        1670: putfield      #103                // Field ocaml_fn_24.sibling_1:LClosure;
        1673: iconst_0
        1674: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1677: astore        69
        1679: aload         67
        1681: checkcast     #93                 // class ocaml_fn_25
        1684: aload         66
        1686: checkcast     #96                 // class Closure
        1689: putfield      #104                // Field ocaml_fn_25.sibling_0:LClosure;
        1692: iconst_0
        1693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1696: astore        70
        1698: aload         67
        1700: checkcast     #93                 // class ocaml_fn_25
        1703: aload         67
        1705: checkcast     #96                 // class Closure
        1708: putfield      #105                // Field ocaml_fn_25.sibling_1:LClosure;
        1711: iconst_0
        1712: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1715: astore        71
        1717: iconst_0
        1718: istore        72
        1720: aconst_null
        1721: astore        73
        1723: iconst_1
        1724: istore        74
        1726: iload         74
        1728: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1731: astore        75
        1733: iconst_2
        1734: istore        76
        1736: iload         76
        1738: invokestatic  #111                // Method Channel.forDescriptor:(I)LChannel;
        1741: astore        77
        1743: new           #113                // class ocaml_fn_26
        1746: dup
        1747: invokespecial #114                // Method ocaml_fn_26."<init>":()V
        1750: astore        78
        1752: new           #116                // class ocaml_fn_27
        1755: dup
        1756: aload         78
        1758: invokespecial #117                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1761: astore        79
        1763: new           #119                // class ocaml_fn_28
        1766: dup
        1767: aload         78
        1769: invokespecial #120                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1772: astore        80
        1774: new           #122                // class ocaml_fn_29
        1777: dup
        1778: aload         30
        1780: invokespecial #123                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1783: astore        81
        1785: new           #125                // class ocaml_fn_30
        1788: dup
        1789: invokespecial #126                // Method ocaml_fn_30."<init>":()V
        1792: astore        82
        1794: new           #128                // class ocaml_fn_31
        1797: dup
        1798: invokespecial #129                // Method ocaml_fn_31."<init>":()V
        1801: astore        83
        1803: new           #131                // class ocaml_fn_32
        1806: dup
        1807: aload         18
        1809: invokespecial #132                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1812: astore        84
        1814: new           #134                // class ocaml_fn_33
        1817: dup
        1818: aload         18
        1820: invokespecial #135                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1823: astore        85
        1825: new           #137                // class ocaml_fn_34
        1828: dup
        1829: invokespecial #138                // Method ocaml_fn_34."<init>":()V
        1832: astore        86
        1834: new           #140                // class ocaml_fn_35
        1837: dup
        1838: invokespecial #141                // Method ocaml_fn_35."<init>":()V
        1841: astore        87
        1843: new           #143                // class ocaml_fn_36
        1846: dup
        1847: invokespecial #144                // Method ocaml_fn_36."<init>":()V
        1850: astore        88
        1852: new           #146                // class ocaml_fn_37
        1855: dup
        1856: invokespecial #147                // Method ocaml_fn_37."<init>":()V
        1859: astore        89
        1861: new           #149                // class ocaml_fn_38
        1864: dup
        1865: aload         89
        1867: invokespecial #150                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1870: astore        90
        1872: new           #152                // class ocaml_fn_39
        1875: dup
        1876: aload         89
        1878: invokespecial #153                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1881: astore        91
        1883: new           #155                // class ocaml_fn_40
        1886: dup
        1887: aload         18
        1889: invokespecial #156                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1892: astore        92
        1894: new           #158                // class ocaml_fn_41
        1897: dup
        1898: aload         31
        1900: invokespecial #159                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1903: astore        93
        1905: new           #161                // class ocaml_fn_42
        1908: dup
        1909: aload         18
        1911: aload         93
        1913: invokespecial #164                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1916: astore        94
        1918: new           #166                // class ocaml_fn_43
        1921: dup
        1922: aload         94
        1924: invokespecial #167                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1927: astore        95
        1929: new           #169                // class ocaml_fn_44
        1932: dup
        1933: aload         31
        1935: invokespecial #170                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1938: astore        96
        1940: new           #172                // class ocaml_fn_45
        1943: dup
        1944: invokespecial #173                // Method ocaml_fn_45."<init>":()V
        1947: astore        97
        1949: new           #175                // class ocaml_fn_46
        1952: dup
        1953: aload         75
        1955: invokespecial #176                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1958: astore        98
        1960: new           #178                // class ocaml_fn_47
        1963: dup
        1964: aload         75
        1966: aload         83
        1968: invokespecial #179                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1971: astore        99
        1973: new           #181                // class ocaml_fn_48
        1976: dup
        1977: aload         75
        1979: aload         82
        1981: invokespecial #182                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        100
        1986: new           #184                // class ocaml_fn_49
        1989: dup
        1990: aload         61
        1992: aload         75
        1994: aload         83
        1996: invokespecial #187                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        101
        2001: new           #189                // class ocaml_fn_50
        2004: dup
        2005: aload         64
        2007: aload         75
        2009: aload         83
        2011: invokespecial #190                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2014: astore        102
        2016: new           #192                // class ocaml_fn_51
        2019: dup
        2020: aload         75
        2022: aload         83
        2024: invokespecial #193                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        103
        2029: new           #195                // class ocaml_fn_52
        2032: dup
        2033: aload         75
        2035: invokespecial #196                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2038: astore        104
        2040: new           #198                // class ocaml_fn_53
        2043: dup
        2044: aload         77
        2046: invokespecial #199                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2049: astore        105
        2051: new           #201                // class ocaml_fn_54
        2054: dup
        2055: aload         77
        2057: aload         83
        2059: invokespecial #202                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2062: astore        106
        2064: new           #204                // class ocaml_fn_55
        2067: dup
        2068: aload         77
        2070: aload         82
        2072: invokespecial #205                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        107
        2077: new           #207                // class ocaml_fn_56
        2080: dup
        2081: aload         61
        2083: aload         77
        2085: aload         83
        2087: invokespecial #208                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        108
        2092: new           #210                // class ocaml_fn_57
        2095: dup
        2096: aload         64
        2098: aload         77
        2100: aload         83
        2102: invokespecial #211                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2105: astore        109
        2107: new           #213                // class ocaml_fn_58
        2110: dup
        2111: aload         77
        2113: aload         83
        2115: invokespecial #214                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2118: astore        110
        2120: new           #216                // class ocaml_fn_59
        2123: dup
        2124: aload         77
        2126: invokespecial #217                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2129: astore        111
        2131: new           #219                // class ocaml_fn_60
        2134: dup
        2135: aload         73
        2137: aload         75
        2139: aload         96
        2141: invokespecial #220                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2144: astore        112
        2146: new           #222                // class ocaml_fn_61
        2149: dup
        2150: aload         112
        2152: invokespecial #223                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2155: astore        113
        2157: new           #225                // class ocaml_fn_62
        2160: dup
        2161: aload         62
        2163: aload         112
        2165: invokespecial #226                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2168: astore        114
        2170: new           #228                // class ocaml_fn_63
        2173: dup
        2174: aload         112
        2176: invokespecial #229                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2179: astore        115
        2181: new           #231                // class ocaml_fn_64
        2184: dup
        2185: aload         65
        2187: aload         112
        2189: invokespecial #232                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2192: astore        116
        2194: new           #14                 // class Block
        2197: dup
        2198: iconst_0
        2199: iconst_0
        2200: anewarray     #16                 // class java/lang/Object
        2203: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2206: astore        117
        2208: new           #234                // class ocaml_fn_65
        2211: dup
        2212: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2215: astore        118
        2217: new           #237                // class ocaml_fn_66
        2220: dup
        2221: aload         56
        2223: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2226: astore        119
        2228: new           #14                 // class Block
        2231: dup
        2232: iconst_0
        2233: iconst_1
        2234: anewarray     #16                 // class java/lang/Object
        2237: dup
        2238: iconst_0
        2239: aload         81
        2241: aastore
        2242: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2245: astore        120
        2247: new           #240                // class ocaml_fn_67
        2250: dup
        2251: aload         120
        2253: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2256: astore        121
        2258: new           #243                // class ocaml_fn_68
        2261: dup
        2262: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2265: astore        122
        2267: new           #14                 // class Block
        2270: dup
        2271: iconst_0
        2272: iconst_1
        2273: anewarray     #16                 // class java/lang/Object
        2276: dup
        2277: iconst_0
        2278: aload         122
        2280: aastore
        2281: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2284: astore        123
        2286: new           #246                // class ocaml_fn_69
        2289: dup
        2290: aload         120
        2292: aload         123
        2294: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2297: astore        124
        2299: new           #249                // class ocaml_fn_70
        2302: dup
        2303: aload         124
        2305: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2308: astore        125
        2310: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2313: bipush        44
        2315: aaload
        2316: astore        126
        2318: iconst_0
        2319: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2322: astore        127
        2324: new           #252                // class ocaml_fn_71
        2327: dup
        2328: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2331: astore        128
        2333: new           #255                // class ocaml_fn_72
        2336: dup
        2337: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2340: astore        129
        2342: new           #258                // class ocaml_fn_73
        2345: dup
        2346: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2349: astore        130
        2351: new           #261                // class ocaml_fn_74
        2354: dup
        2355: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2358: astore        131
        2360: new           #264                // class ocaml_fn_75
        2363: dup
        2364: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2367: astore        132
        2369: new           #267                // class ocaml_fn_76
        2372: dup
        2373: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2376: astore        133
        2378: new           #14                 // class Block
        2381: dup
        2382: iconst_0
        2383: bipush        6
        2385: anewarray     #16                 // class java/lang/Object
        2388: dup
        2389: iconst_0
        2390: aload         133
        2392: aastore
        2393: dup
        2394: iconst_1
        2395: aload         132
        2397: aastore
        2398: dup
        2399: iconst_2
        2400: aload         131
        2402: aastore
        2403: dup
        2404: iconst_3
        2405: aload         130
        2407: aastore
        2408: dup
        2409: iconst_4
        2410: aload         129
        2412: aastore
        2413: dup
        2414: iconst_5
        2415: aload         128
        2417: aastore
        2418: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2421: astore        134
        2423: new           #270                // class ocaml_fn_77
        2426: dup
        2427: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2430: astore        135
        2432: new           #273                // class ocaml_fn_78
        2435: dup
        2436: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2439: astore        136
        2441: new           #276                // class ocaml_fn_79
        2444: dup
        2445: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2448: astore        137
        2450: new           #279                // class ocaml_fn_80
        2453: dup
        2454: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2457: astore        138
        2459: new           #282                // class ocaml_fn_81
        2462: dup
        2463: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2466: astore        139
        2468: new           #285                // class ocaml_fn_82
        2471: dup
        2472: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2475: astore        140
        2477: new           #288                // class ocaml_fn_83
        2480: dup
        2481: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2484: astore        141
        2486: new           #291                // class ocaml_fn_84
        2489: dup
        2490: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2493: astore        142
        2495: new           #294                // class ocaml_fn_85
        2498: dup
        2499: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2502: astore        143
        2504: new           #297                // class ocaml_fn_86
        2507: dup
        2508: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2511: astore        144
        2513: new           #300                // class ocaml_fn_87
        2516: dup
        2517: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2520: astore        145
        2522: new           #303                // class ocaml_fn_88
        2525: dup
        2526: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2529: astore        146
        2531: new           #306                // class ocaml_fn_89
        2534: dup
        2535: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2538: astore        147
        2540: new           #309                // class ocaml_fn_90
        2543: dup
        2544: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2547: astore        148
        2549: new           #312                // class ocaml_fn_91
        2552: dup
        2553: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2556: astore        149
        2558: new           #315                // class ocaml_fn_92
        2561: dup
        2562: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2565: astore        150
        2567: new           #318                // class ocaml_fn_93
        2570: dup
        2571: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2574: astore        151
        2576: new           #14                 // class Block
        2579: dup
        2580: iconst_0
        2581: bipush        104
        2583: anewarray     #16                 // class java/lang/Object
        2586: dup
        2587: iconst_0
        2588: aload         18
        2590: aastore
        2591: dup
        2592: iconst_1
        2593: aload         17
        2595: aastore
        2596: dup
        2597: iconst_2
        2598: aload         22
        2600: aastore
        2601: dup
        2602: iconst_3
        2603: aload         23
        2605: aastore
        2606: dup
        2607: iconst_4
        2608: aload         24
        2610: aastore
        2611: dup
        2612: iconst_5
        2613: aload         25
        2615: aastore
        2616: dup
        2617: bipush        6
        2619: aload         26
        2621: aastore
        2622: dup
        2623: bipush        7
        2625: aload         27
        2627: aastore
        2628: dup
        2629: bipush        8
        2631: aload         28
        2633: aastore
        2634: dup
        2635: bipush        9
        2637: aload         29
        2639: aastore
        2640: dup
        2641: bipush        10
        2643: aload         30
        2645: aastore
        2646: dup
        2647: bipush        11
        2649: aload         31
        2651: aastore
        2652: dup
        2653: bipush        12
        2655: aload         32
        2657: aastore
        2658: dup
        2659: bipush        13
        2661: aload         33
        2663: aastore
        2664: dup
        2665: bipush        14
        2667: aload         34
        2669: aastore
        2670: dup
        2671: bipush        15
        2673: aload         35
        2675: aastore
        2676: dup
        2677: bipush        16
        2679: aload         36
        2681: aastore
        2682: dup
        2683: bipush        17
        2685: aload         37
        2687: aastore
        2688: dup
        2689: bipush        18
        2691: iload         41
        2693: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2696: aastore
        2697: dup
        2698: bipush        19
        2700: iload         43
        2702: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2705: aastore
        2706: dup
        2707: bipush        20
        2709: aload         38
        2711: aastore
        2712: dup
        2713: bipush        21
        2715: aload         45
        2717: aastore
        2718: dup
        2719: bipush        22
        2721: aload         47
        2723: aastore
        2724: dup
        2725: bipush        23
        2727: aload         49
        2729: aastore
        2730: dup
        2731: bipush        24
        2733: aload         51
        2735: aastore
        2736: dup
        2737: bipush        25
        2739: aload         53
        2741: aastore
        2742: dup
        2743: bipush        26
        2745: aload         55
        2747: aastore
        2748: dup
        2749: bipush        27
        2751: aload         56
        2753: aastore
        2754: dup
        2755: bipush        28
        2757: aload         57
        2759: aastore
        2760: dup
        2761: bipush        29
        2763: aload         58
        2765: aastore
        2766: dup
        2767: bipush        30
        2769: aload         60
        2771: aastore
        2772: dup
        2773: bipush        31
        2775: aload         59
        2777: aastore
        2778: dup
        2779: bipush        32
        2781: aload         61
        2783: aastore
        2784: dup
        2785: bipush        33
        2787: aload         62
        2789: aastore
        2790: dup
        2791: bipush        34
        2793: aload         64
        2795: aastore
        2796: dup
        2797: bipush        35
        2799: aload         65
        2801: aastore
        2802: dup
        2803: bipush        36
        2805: aload         66
        2807: aastore
        2808: dup
        2809: bipush        37
        2811: aload         73
        2813: aastore
        2814: dup
        2815: bipush        38
        2817: aload         75
        2819: aastore
        2820: dup
        2821: bipush        39
        2823: aload         77
        2825: aastore
        2826: dup
        2827: bipush        40
        2829: aload         98
        2831: aastore
        2832: dup
        2833: bipush        41
        2835: aload         99
        2837: aastore
        2838: dup
        2839: bipush        42
        2841: aload         100
        2843: aastore
        2844: dup
        2845: bipush        43
        2847: aload         101
        2849: aastore
        2850: dup
        2851: bipush        44
        2853: aload         102
        2855: aastore
        2856: dup
        2857: bipush        45
        2859: aload         103
        2861: aastore
        2862: dup
        2863: bipush        46
        2865: aload         104
        2867: aastore
        2868: dup
        2869: bipush        47
        2871: aload         105
        2873: aastore
        2874: dup
        2875: bipush        48
        2877: aload         106
        2879: aastore
        2880: dup
        2881: bipush        49
        2883: aload         107
        2885: aastore
        2886: dup
        2887: bipush        50
        2889: aload         108
        2891: aastore
        2892: dup
        2893: bipush        51
        2895: aload         109
        2897: aastore
        2898: dup
        2899: bipush        52
        2901: aload         110
        2903: aastore
        2904: dup
        2905: bipush        53
        2907: aload         111
        2909: aastore
        2910: dup
        2911: bipush        54
        2913: aload         112
        2915: aastore
        2916: dup
        2917: bipush        55
        2919: aload         114
        2921: aastore
        2922: dup
        2923: bipush        56
        2925: aload         113
        2927: aastore
        2928: dup
        2929: bipush        57
        2931: aload         116
        2933: aastore
        2934: dup
        2935: bipush        58
        2937: aload         115
        2939: aastore
        2940: dup
        2941: bipush        59
        2943: aload         79
        2945: aastore
        2946: dup
        2947: bipush        60
        2949: aload         80
        2951: aastore
        2952: dup
        2953: bipush        61
        2955: aload         78
        2957: aastore
        2958: dup
        2959: bipush        62
        2961: aload         151
        2963: aastore
        2964: dup
        2965: bipush        63
        2967: aload         81
        2969: aastore
        2970: dup
        2971: bipush        64
        2973: aload         150
        2975: aastore
        2976: dup
        2977: bipush        65
        2979: aload         83
        2981: aastore
        2982: dup
        2983: bipush        66
        2985: aload         82
        2987: aastore
        2988: dup
        2989: bipush        67
        2991: aload         84
        2993: aastore
        2994: dup
        2995: bipush        68
        2997: aload         85
        2999: aastore
        3000: dup
        3001: bipush        69
        3003: aload         149
        3005: aastore
        3006: dup
        3007: bipush        70
        3009: aload         148
        3011: aastore
        3012: dup
        3013: bipush        71
        3015: aload         86
        3017: aastore
        3018: dup
        3019: bipush        72
        3021: aload         147
        3023: aastore
        3024: dup
        3025: bipush        73
        3027: aload         146
        3029: aastore
        3030: dup
        3031: bipush        74
        3033: aload         145
        3035: aastore
        3036: dup
        3037: bipush        75
        3039: aload         87
        3041: aastore
        3042: dup
        3043: bipush        76
        3045: aload         88
        3047: aastore
        3048: dup
        3049: bipush        77
        3051: aload         144
        3053: aastore
        3054: dup
        3055: bipush        78
        3057: aload         90
        3059: aastore
        3060: dup
        3061: bipush        79
        3063: aload         91
        3065: aastore
        3066: dup
        3067: bipush        80
        3069: aload         89
        3071: aastore
        3072: dup
        3073: bipush        81
        3075: aload         143
        3077: aastore
        3078: dup
        3079: bipush        82
        3081: aload         96
        3083: aastore
        3084: dup
        3085: bipush        83
        3087: aload         92
        3089: aastore
        3090: dup
        3091: bipush        84
        3093: aload         94
        3095: aastore
        3096: dup
        3097: bipush        85
        3099: aload         95
        3101: aastore
        3102: dup
        3103: bipush        86
        3105: aload         142
        3107: aastore
        3108: dup
        3109: bipush        87
        3111: aload         141
        3113: aastore
        3114: dup
        3115: bipush        88
        3117: aload         140
        3119: aastore
        3120: dup
        3121: bipush        89
        3123: aload         139
        3125: aastore
        3126: dup
        3127: bipush        90
        3129: aload         138
        3131: aastore
        3132: dup
        3133: bipush        91
        3135: aload         137
        3137: aastore
        3138: dup
        3139: bipush        92
        3141: aload         136
        3143: aastore
        3144: dup
        3145: bipush        93
        3147: aload         97
        3149: aastore
        3150: dup
        3151: bipush        94
        3153: aload         135
        3155: aastore
        3156: dup
        3157: bipush        95
        3159: aload         134
        3161: aastore
        3162: dup
        3163: bipush        96
        3165: aload         118
        3167: aastore
        3168: dup
        3169: bipush        97
        3171: aload         119
        3173: aastore
        3174: dup
        3175: bipush        98
        3177: aload         125
        3179: aastore
        3180: dup
        3181: bipush        99
        3183: aload         121
        3185: aastore
        3186: dup
        3187: bipush        100
        3189: aload         63
        3191: aastore
        3192: dup
        3193: bipush        101
        3195: aload         93
        3197: aastore
        3198: dup
        3199: bipush        102
        3201: aload         124
        3203: aastore
        3204: dup
        3205: bipush        103
        3207: aload         123
        3209: aastore
        3210: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3213: astore        152
        3215: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3218: bipush        45
        3220: aload         152
        3222: aastore
        3223: iconst_0
        3224: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3227: astore        153
        3229: iconst_0
        3230: istore        154
        3232: iconst_1
        3233: istore        155
        3235: iconst_2
        3236: istore        156
        3238: iload         156
        3240: iload         155
        3242: if_icmple     3251
        3245: iconst_0
        3246: goto_w        3252
        3251: iconst_1
        3252: istore        157
        3254: iload         157
        3256: ifeq          3271
        3259: iload         155
        3261: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3264: astore        158
        3266: goto_w        3299
        3271: iload         155
        3273: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3276: astore        159
        3278: goto_w        3283
        3283: bipush        10
        3285: istore        160
        3287: iload         160
        3289: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3292: astore        161
        3294: goto_w        3315
        3299: bipush        20
        3301: istore        162
        3303: iload         162
        3305: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3308: astore        161
        3310: goto_w        3315
        3315: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3318: aload         161
        3320: checkcast     #27                 // class java/lang/Integer
        3323: invokevirtual #329                // Method java/lang/Integer.intValue:()I
        3326: invokevirtual #335                // Method java/io/PrintStream.println:(I)V
        3329: iconst_0
        3330: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3333: astore        163
        3335: new           #14                 // class Block
        3338: dup
        3339: iconst_0
        3340: iconst_0
        3341: anewarray     #16                 // class java/lang/Object
        3344: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3347: astore        164
        3349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3352: bipush        46
        3354: aload         164
        3356: aastore
        3357: iconst_0
        3358: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3361: astore        165
        3363: iconst_0
        3364: istore        166
        3366: iconst_0
        3367: istore        167
        3369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3372: bipush        45
        3374: aaload
        3375: checkcast     #14                 // class Block
        3378: getfield      #338                // Field Block.fields:[Ljava/lang/Object;
        3381: bipush        102
        3383: aaload
        3384: astore        168
        3386: aload         168
        3388: checkcast     #96                 // class Closure
        3391: iload         167
        3393: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3396: invokevirtual #342                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3399: astore        169
        3401: new           #14                 // class Block
        3404: dup
        3405: iconst_0
        3406: iconst_0
        3407: anewarray     #16                 // class java/lang/Object
        3410: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3413: astore        170
        3415: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3418: bipush        47
        3420: aload         170
        3422: aastore
        3423: iconst_0
        3424: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3427: astore        171
        3429: iconst_0
        3430: istore        172
        3432: return
    }
    |}]
