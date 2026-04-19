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
        2203: new           #234                // class ocaml_fn_65
        2206: dup
        2207: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2210: astore        117
        2212: new           #237                // class ocaml_fn_66
        2215: dup
        2216: aload         56
        2218: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2221: astore        118
        2223: new           #14                 // class Block
        2226: dup
        2227: iconst_0
        2228: iconst_1
        2229: anewarray     #16                 // class java/lang/Object
        2232: dup
        2233: iconst_0
        2234: aload         81
        2236: aastore
        2237: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2240: astore        119
        2242: new           #240                // class ocaml_fn_67
        2245: dup
        2246: aload         119
        2248: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2251: astore        120
        2253: new           #243                // class ocaml_fn_68
        2256: dup
        2257: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2260: astore        121
        2262: new           #14                 // class Block
        2265: dup
        2266: iconst_0
        2267: iconst_1
        2268: anewarray     #16                 // class java/lang/Object
        2271: dup
        2272: iconst_0
        2273: aload         121
        2275: aastore
        2276: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2279: astore        122
        2281: new           #246                // class ocaml_fn_69
        2284: dup
        2285: aload         119
        2287: aload         122
        2289: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2292: astore        123
        2294: new           #249                // class ocaml_fn_70
        2297: dup
        2298: aload         123
        2300: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2303: astore        124
        2305: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2308: bipush        44
        2310: aaload
        2311: astore        125
        2313: iconst_0
        2314: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2317: astore        126
        2319: new           #252                // class ocaml_fn_71
        2322: dup
        2323: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2326: astore        127
        2328: new           #255                // class ocaml_fn_72
        2331: dup
        2332: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2335: astore        128
        2337: new           #258                // class ocaml_fn_73
        2340: dup
        2341: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2344: astore        129
        2346: new           #261                // class ocaml_fn_74
        2349: dup
        2350: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2353: astore        130
        2355: new           #264                // class ocaml_fn_75
        2358: dup
        2359: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2362: astore        131
        2364: new           #267                // class ocaml_fn_76
        2367: dup
        2368: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2371: astore        132
        2373: new           #14                 // class Block
        2376: dup
        2377: iconst_0
        2378: bipush        6
        2380: anewarray     #16                 // class java/lang/Object
        2383: dup
        2384: iconst_0
        2385: aload         132
        2387: aastore
        2388: dup
        2389: iconst_1
        2390: aload         131
        2392: aastore
        2393: dup
        2394: iconst_2
        2395: aload         130
        2397: aastore
        2398: dup
        2399: iconst_3
        2400: aload         129
        2402: aastore
        2403: dup
        2404: iconst_4
        2405: aload         128
        2407: aastore
        2408: dup
        2409: iconst_5
        2410: aload         127
        2412: aastore
        2413: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        133
        2418: new           #270                // class ocaml_fn_77
        2421: dup
        2422: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2425: astore        134
        2427: new           #273                // class ocaml_fn_78
        2430: dup
        2431: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2434: astore        135
        2436: new           #276                // class ocaml_fn_79
        2439: dup
        2440: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2443: astore        136
        2445: new           #279                // class ocaml_fn_80
        2448: dup
        2449: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2452: astore        137
        2454: new           #282                // class ocaml_fn_81
        2457: dup
        2458: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2461: astore        138
        2463: new           #285                // class ocaml_fn_82
        2466: dup
        2467: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2470: astore        139
        2472: new           #288                // class ocaml_fn_83
        2475: dup
        2476: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2479: astore        140
        2481: new           #291                // class ocaml_fn_84
        2484: dup
        2485: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2488: astore        141
        2490: new           #294                // class ocaml_fn_85
        2493: dup
        2494: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2497: astore        142
        2499: new           #297                // class ocaml_fn_86
        2502: dup
        2503: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2506: astore        143
        2508: new           #300                // class ocaml_fn_87
        2511: dup
        2512: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2515: astore        144
        2517: new           #303                // class ocaml_fn_88
        2520: dup
        2521: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2524: astore        145
        2526: new           #306                // class ocaml_fn_89
        2529: dup
        2530: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2533: astore        146
        2535: new           #309                // class ocaml_fn_90
        2538: dup
        2539: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2542: astore        147
        2544: new           #312                // class ocaml_fn_91
        2547: dup
        2548: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2551: astore        148
        2553: new           #315                // class ocaml_fn_92
        2556: dup
        2557: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2560: astore        149
        2562: new           #318                // class ocaml_fn_93
        2565: dup
        2566: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2569: astore        150
        2571: new           #14                 // class Block
        2574: dup
        2575: iconst_0
        2576: bipush        104
        2578: anewarray     #16                 // class java/lang/Object
        2581: dup
        2582: iconst_0
        2583: aload         18
        2585: aastore
        2586: dup
        2587: iconst_1
        2588: aload         17
        2590: aastore
        2591: dup
        2592: iconst_2
        2593: aload         22
        2595: aastore
        2596: dup
        2597: iconst_3
        2598: aload         23
        2600: aastore
        2601: dup
        2602: iconst_4
        2603: aload         24
        2605: aastore
        2606: dup
        2607: iconst_5
        2608: aload         25
        2610: aastore
        2611: dup
        2612: bipush        6
        2614: aload         26
        2616: aastore
        2617: dup
        2618: bipush        7
        2620: aload         27
        2622: aastore
        2623: dup
        2624: bipush        8
        2626: aload         28
        2628: aastore
        2629: dup
        2630: bipush        9
        2632: aload         29
        2634: aastore
        2635: dup
        2636: bipush        10
        2638: aload         30
        2640: aastore
        2641: dup
        2642: bipush        11
        2644: aload         31
        2646: aastore
        2647: dup
        2648: bipush        12
        2650: aload         32
        2652: aastore
        2653: dup
        2654: bipush        13
        2656: aload         33
        2658: aastore
        2659: dup
        2660: bipush        14
        2662: aload         34
        2664: aastore
        2665: dup
        2666: bipush        15
        2668: aload         35
        2670: aastore
        2671: dup
        2672: bipush        16
        2674: aload         36
        2676: aastore
        2677: dup
        2678: bipush        17
        2680: aload         37
        2682: aastore
        2683: dup
        2684: bipush        18
        2686: iload         41
        2688: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2691: aastore
        2692: dup
        2693: bipush        19
        2695: iload         43
        2697: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2700: aastore
        2701: dup
        2702: bipush        20
        2704: aload         38
        2706: aastore
        2707: dup
        2708: bipush        21
        2710: aload         45
        2712: aastore
        2713: dup
        2714: bipush        22
        2716: aload         47
        2718: aastore
        2719: dup
        2720: bipush        23
        2722: aload         49
        2724: aastore
        2725: dup
        2726: bipush        24
        2728: aload         51
        2730: aastore
        2731: dup
        2732: bipush        25
        2734: aload         53
        2736: aastore
        2737: dup
        2738: bipush        26
        2740: aload         55
        2742: aastore
        2743: dup
        2744: bipush        27
        2746: aload         56
        2748: aastore
        2749: dup
        2750: bipush        28
        2752: aload         57
        2754: aastore
        2755: dup
        2756: bipush        29
        2758: aload         58
        2760: aastore
        2761: dup
        2762: bipush        30
        2764: aload         60
        2766: aastore
        2767: dup
        2768: bipush        31
        2770: aload         59
        2772: aastore
        2773: dup
        2774: bipush        32
        2776: aload         61
        2778: aastore
        2779: dup
        2780: bipush        33
        2782: aload         62
        2784: aastore
        2785: dup
        2786: bipush        34
        2788: aload         64
        2790: aastore
        2791: dup
        2792: bipush        35
        2794: aload         65
        2796: aastore
        2797: dup
        2798: bipush        36
        2800: aload         66
        2802: aastore
        2803: dup
        2804: bipush        37
        2806: aload         73
        2808: aastore
        2809: dup
        2810: bipush        38
        2812: aload         75
        2814: aastore
        2815: dup
        2816: bipush        39
        2818: aload         77
        2820: aastore
        2821: dup
        2822: bipush        40
        2824: aload         98
        2826: aastore
        2827: dup
        2828: bipush        41
        2830: aload         99
        2832: aastore
        2833: dup
        2834: bipush        42
        2836: aload         100
        2838: aastore
        2839: dup
        2840: bipush        43
        2842: aload         101
        2844: aastore
        2845: dup
        2846: bipush        44
        2848: aload         102
        2850: aastore
        2851: dup
        2852: bipush        45
        2854: aload         103
        2856: aastore
        2857: dup
        2858: bipush        46
        2860: aload         104
        2862: aastore
        2863: dup
        2864: bipush        47
        2866: aload         105
        2868: aastore
        2869: dup
        2870: bipush        48
        2872: aload         106
        2874: aastore
        2875: dup
        2876: bipush        49
        2878: aload         107
        2880: aastore
        2881: dup
        2882: bipush        50
        2884: aload         108
        2886: aastore
        2887: dup
        2888: bipush        51
        2890: aload         109
        2892: aastore
        2893: dup
        2894: bipush        52
        2896: aload         110
        2898: aastore
        2899: dup
        2900: bipush        53
        2902: aload         111
        2904: aastore
        2905: dup
        2906: bipush        54
        2908: aload         112
        2910: aastore
        2911: dup
        2912: bipush        55
        2914: aload         114
        2916: aastore
        2917: dup
        2918: bipush        56
        2920: aload         113
        2922: aastore
        2923: dup
        2924: bipush        57
        2926: aload         116
        2928: aastore
        2929: dup
        2930: bipush        58
        2932: aload         115
        2934: aastore
        2935: dup
        2936: bipush        59
        2938: aload         79
        2940: aastore
        2941: dup
        2942: bipush        60
        2944: aload         80
        2946: aastore
        2947: dup
        2948: bipush        61
        2950: aload         78
        2952: aastore
        2953: dup
        2954: bipush        62
        2956: aload         150
        2958: aastore
        2959: dup
        2960: bipush        63
        2962: aload         81
        2964: aastore
        2965: dup
        2966: bipush        64
        2968: aload         149
        2970: aastore
        2971: dup
        2972: bipush        65
        2974: aload         83
        2976: aastore
        2977: dup
        2978: bipush        66
        2980: aload         82
        2982: aastore
        2983: dup
        2984: bipush        67
        2986: aload         84
        2988: aastore
        2989: dup
        2990: bipush        68
        2992: aload         85
        2994: aastore
        2995: dup
        2996: bipush        69
        2998: aload         148
        3000: aastore
        3001: dup
        3002: bipush        70
        3004: aload         147
        3006: aastore
        3007: dup
        3008: bipush        71
        3010: aload         86
        3012: aastore
        3013: dup
        3014: bipush        72
        3016: aload         146
        3018: aastore
        3019: dup
        3020: bipush        73
        3022: aload         145
        3024: aastore
        3025: dup
        3026: bipush        74
        3028: aload         144
        3030: aastore
        3031: dup
        3032: bipush        75
        3034: aload         87
        3036: aastore
        3037: dup
        3038: bipush        76
        3040: aload         88
        3042: aastore
        3043: dup
        3044: bipush        77
        3046: aload         143
        3048: aastore
        3049: dup
        3050: bipush        78
        3052: aload         90
        3054: aastore
        3055: dup
        3056: bipush        79
        3058: aload         91
        3060: aastore
        3061: dup
        3062: bipush        80
        3064: aload         89
        3066: aastore
        3067: dup
        3068: bipush        81
        3070: aload         142
        3072: aastore
        3073: dup
        3074: bipush        82
        3076: aload         96
        3078: aastore
        3079: dup
        3080: bipush        83
        3082: aload         92
        3084: aastore
        3085: dup
        3086: bipush        84
        3088: aload         94
        3090: aastore
        3091: dup
        3092: bipush        85
        3094: aload         95
        3096: aastore
        3097: dup
        3098: bipush        86
        3100: aload         141
        3102: aastore
        3103: dup
        3104: bipush        87
        3106: aload         140
        3108: aastore
        3109: dup
        3110: bipush        88
        3112: aload         139
        3114: aastore
        3115: dup
        3116: bipush        89
        3118: aload         138
        3120: aastore
        3121: dup
        3122: bipush        90
        3124: aload         137
        3126: aastore
        3127: dup
        3128: bipush        91
        3130: aload         136
        3132: aastore
        3133: dup
        3134: bipush        92
        3136: aload         135
        3138: aastore
        3139: dup
        3140: bipush        93
        3142: aload         97
        3144: aastore
        3145: dup
        3146: bipush        94
        3148: aload         134
        3150: aastore
        3151: dup
        3152: bipush        95
        3154: aload         133
        3156: aastore
        3157: dup
        3158: bipush        96
        3160: aload         117
        3162: aastore
        3163: dup
        3164: bipush        97
        3166: aload         118
        3168: aastore
        3169: dup
        3170: bipush        98
        3172: aload         124
        3174: aastore
        3175: dup
        3176: bipush        99
        3178: aload         120
        3180: aastore
        3181: dup
        3182: bipush        100
        3184: aload         63
        3186: aastore
        3187: dup
        3188: bipush        101
        3190: aload         93
        3192: aastore
        3193: dup
        3194: bipush        102
        3196: aload         123
        3198: aastore
        3199: dup
        3200: bipush        103
        3202: aload         122
        3204: aastore
        3205: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3208: astore        151
        3210: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3213: bipush        45
        3215: aload         151
        3217: aastore
        3218: iconst_0
        3219: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3222: astore        152
        3224: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3227: bipush        46
        3229: aaload
        3230: astore        153
        3232: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3235: aload         153
        3237: checkcast     #327                // class java/lang/String
        3240: invokevirtual #333                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3243: iconst_0
        3244: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3247: astore        154
        3249: new           #14                 // class Block
        3252: dup
        3253: iconst_0
        3254: iconst_0
        3255: anewarray     #16                 // class java/lang/Object
        3258: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3261: astore        155
        3263: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3266: bipush        47
        3268: aload         155
        3270: aastore
        3271: iconst_0
        3272: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3275: astore        156
        3277: iconst_0
        3278: istore        157
        3280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3283: bipush        45
        3285: aaload
        3286: checkcast     #14                 // class Block
        3289: getfield      #336                // Field Block.fields:[Ljava/lang/Object;
        3292: bipush        102
        3294: aaload
        3295: astore        158
        3297: aload         158
        3299: checkcast     #96                 // class Closure
        3302: iload         157
        3304: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3307: invokevirtual #340                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3310: astore        159
        3312: new           #14                 // class Block
        3315: dup
        3316: iconst_0
        3317: iconst_0
        3318: anewarray     #16                 // class java/lang/Object
        3321: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3324: astore        160
        3326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3329: bipush        48
        3331: aload         160
        3333: aastore
        3334: iconst_0
        3335: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3338: astore        161
        3340: return
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
        2194: new           #234                // class ocaml_fn_65
        2197: dup
        2198: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2201: astore        117
        2203: new           #237                // class ocaml_fn_66
        2206: dup
        2207: aload         56
        2209: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2212: astore        118
        2214: new           #14                 // class Block
        2217: dup
        2218: iconst_0
        2219: iconst_1
        2220: anewarray     #16                 // class java/lang/Object
        2223: dup
        2224: iconst_0
        2225: aload         81
        2227: aastore
        2228: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2231: astore        119
        2233: new           #240                // class ocaml_fn_67
        2236: dup
        2237: aload         119
        2239: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2242: astore        120
        2244: new           #243                // class ocaml_fn_68
        2247: dup
        2248: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2251: astore        121
        2253: new           #14                 // class Block
        2256: dup
        2257: iconst_0
        2258: iconst_1
        2259: anewarray     #16                 // class java/lang/Object
        2262: dup
        2263: iconst_0
        2264: aload         121
        2266: aastore
        2267: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2270: astore        122
        2272: new           #246                // class ocaml_fn_69
        2275: dup
        2276: aload         119
        2278: aload         122
        2280: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2283: astore        123
        2285: new           #249                // class ocaml_fn_70
        2288: dup
        2289: aload         123
        2291: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2294: astore        124
        2296: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2299: bipush        44
        2301: aaload
        2302: astore        125
        2304: iconst_0
        2305: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2308: astore        126
        2310: new           #252                // class ocaml_fn_71
        2313: dup
        2314: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2317: astore        127
        2319: new           #255                // class ocaml_fn_72
        2322: dup
        2323: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2326: astore        128
        2328: new           #258                // class ocaml_fn_73
        2331: dup
        2332: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2335: astore        129
        2337: new           #261                // class ocaml_fn_74
        2340: dup
        2341: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2344: astore        130
        2346: new           #264                // class ocaml_fn_75
        2349: dup
        2350: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2353: astore        131
        2355: new           #267                // class ocaml_fn_76
        2358: dup
        2359: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2362: astore        132
        2364: new           #14                 // class Block
        2367: dup
        2368: iconst_0
        2369: bipush        6
        2371: anewarray     #16                 // class java/lang/Object
        2374: dup
        2375: iconst_0
        2376: aload         132
        2378: aastore
        2379: dup
        2380: iconst_1
        2381: aload         131
        2383: aastore
        2384: dup
        2385: iconst_2
        2386: aload         130
        2388: aastore
        2389: dup
        2390: iconst_3
        2391: aload         129
        2393: aastore
        2394: dup
        2395: iconst_4
        2396: aload         128
        2398: aastore
        2399: dup
        2400: iconst_5
        2401: aload         127
        2403: aastore
        2404: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2407: astore        133
        2409: new           #270                // class ocaml_fn_77
        2412: dup
        2413: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2416: astore        134
        2418: new           #273                // class ocaml_fn_78
        2421: dup
        2422: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2425: astore        135
        2427: new           #276                // class ocaml_fn_79
        2430: dup
        2431: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2434: astore        136
        2436: new           #279                // class ocaml_fn_80
        2439: dup
        2440: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2443: astore        137
        2445: new           #282                // class ocaml_fn_81
        2448: dup
        2449: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2452: astore        138
        2454: new           #285                // class ocaml_fn_82
        2457: dup
        2458: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2461: astore        139
        2463: new           #288                // class ocaml_fn_83
        2466: dup
        2467: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2470: astore        140
        2472: new           #291                // class ocaml_fn_84
        2475: dup
        2476: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2479: astore        141
        2481: new           #294                // class ocaml_fn_85
        2484: dup
        2485: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2488: astore        142
        2490: new           #297                // class ocaml_fn_86
        2493: dup
        2494: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2497: astore        143
        2499: new           #300                // class ocaml_fn_87
        2502: dup
        2503: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2506: astore        144
        2508: new           #303                // class ocaml_fn_88
        2511: dup
        2512: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2515: astore        145
        2517: new           #306                // class ocaml_fn_89
        2520: dup
        2521: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2524: astore        146
        2526: new           #309                // class ocaml_fn_90
        2529: dup
        2530: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2533: astore        147
        2535: new           #312                // class ocaml_fn_91
        2538: dup
        2539: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2542: astore        148
        2544: new           #315                // class ocaml_fn_92
        2547: dup
        2548: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2551: astore        149
        2553: new           #318                // class ocaml_fn_93
        2556: dup
        2557: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2560: astore        150
        2562: new           #14                 // class Block
        2565: dup
        2566: iconst_0
        2567: bipush        104
        2569: anewarray     #16                 // class java/lang/Object
        2572: dup
        2573: iconst_0
        2574: aload         18
        2576: aastore
        2577: dup
        2578: iconst_1
        2579: aload         17
        2581: aastore
        2582: dup
        2583: iconst_2
        2584: aload         22
        2586: aastore
        2587: dup
        2588: iconst_3
        2589: aload         23
        2591: aastore
        2592: dup
        2593: iconst_4
        2594: aload         24
        2596: aastore
        2597: dup
        2598: iconst_5
        2599: aload         25
        2601: aastore
        2602: dup
        2603: bipush        6
        2605: aload         26
        2607: aastore
        2608: dup
        2609: bipush        7
        2611: aload         27
        2613: aastore
        2614: dup
        2615: bipush        8
        2617: aload         28
        2619: aastore
        2620: dup
        2621: bipush        9
        2623: aload         29
        2625: aastore
        2626: dup
        2627: bipush        10
        2629: aload         30
        2631: aastore
        2632: dup
        2633: bipush        11
        2635: aload         31
        2637: aastore
        2638: dup
        2639: bipush        12
        2641: aload         32
        2643: aastore
        2644: dup
        2645: bipush        13
        2647: aload         33
        2649: aastore
        2650: dup
        2651: bipush        14
        2653: aload         34
        2655: aastore
        2656: dup
        2657: bipush        15
        2659: aload         35
        2661: aastore
        2662: dup
        2663: bipush        16
        2665: aload         36
        2667: aastore
        2668: dup
        2669: bipush        17
        2671: aload         37
        2673: aastore
        2674: dup
        2675: bipush        18
        2677: iload         41
        2679: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2682: aastore
        2683: dup
        2684: bipush        19
        2686: iload         43
        2688: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2691: aastore
        2692: dup
        2693: bipush        20
        2695: aload         38
        2697: aastore
        2698: dup
        2699: bipush        21
        2701: aload         45
        2703: aastore
        2704: dup
        2705: bipush        22
        2707: aload         47
        2709: aastore
        2710: dup
        2711: bipush        23
        2713: aload         49
        2715: aastore
        2716: dup
        2717: bipush        24
        2719: aload         51
        2721: aastore
        2722: dup
        2723: bipush        25
        2725: aload         53
        2727: aastore
        2728: dup
        2729: bipush        26
        2731: aload         55
        2733: aastore
        2734: dup
        2735: bipush        27
        2737: aload         56
        2739: aastore
        2740: dup
        2741: bipush        28
        2743: aload         57
        2745: aastore
        2746: dup
        2747: bipush        29
        2749: aload         58
        2751: aastore
        2752: dup
        2753: bipush        30
        2755: aload         60
        2757: aastore
        2758: dup
        2759: bipush        31
        2761: aload         59
        2763: aastore
        2764: dup
        2765: bipush        32
        2767: aload         61
        2769: aastore
        2770: dup
        2771: bipush        33
        2773: aload         62
        2775: aastore
        2776: dup
        2777: bipush        34
        2779: aload         64
        2781: aastore
        2782: dup
        2783: bipush        35
        2785: aload         65
        2787: aastore
        2788: dup
        2789: bipush        36
        2791: aload         66
        2793: aastore
        2794: dup
        2795: bipush        37
        2797: aload         73
        2799: aastore
        2800: dup
        2801: bipush        38
        2803: aload         75
        2805: aastore
        2806: dup
        2807: bipush        39
        2809: aload         77
        2811: aastore
        2812: dup
        2813: bipush        40
        2815: aload         98
        2817: aastore
        2818: dup
        2819: bipush        41
        2821: aload         99
        2823: aastore
        2824: dup
        2825: bipush        42
        2827: aload         100
        2829: aastore
        2830: dup
        2831: bipush        43
        2833: aload         101
        2835: aastore
        2836: dup
        2837: bipush        44
        2839: aload         102
        2841: aastore
        2842: dup
        2843: bipush        45
        2845: aload         103
        2847: aastore
        2848: dup
        2849: bipush        46
        2851: aload         104
        2853: aastore
        2854: dup
        2855: bipush        47
        2857: aload         105
        2859: aastore
        2860: dup
        2861: bipush        48
        2863: aload         106
        2865: aastore
        2866: dup
        2867: bipush        49
        2869: aload         107
        2871: aastore
        2872: dup
        2873: bipush        50
        2875: aload         108
        2877: aastore
        2878: dup
        2879: bipush        51
        2881: aload         109
        2883: aastore
        2884: dup
        2885: bipush        52
        2887: aload         110
        2889: aastore
        2890: dup
        2891: bipush        53
        2893: aload         111
        2895: aastore
        2896: dup
        2897: bipush        54
        2899: aload         112
        2901: aastore
        2902: dup
        2903: bipush        55
        2905: aload         114
        2907: aastore
        2908: dup
        2909: bipush        56
        2911: aload         113
        2913: aastore
        2914: dup
        2915: bipush        57
        2917: aload         116
        2919: aastore
        2920: dup
        2921: bipush        58
        2923: aload         115
        2925: aastore
        2926: dup
        2927: bipush        59
        2929: aload         79
        2931: aastore
        2932: dup
        2933: bipush        60
        2935: aload         80
        2937: aastore
        2938: dup
        2939: bipush        61
        2941: aload         78
        2943: aastore
        2944: dup
        2945: bipush        62
        2947: aload         150
        2949: aastore
        2950: dup
        2951: bipush        63
        2953: aload         81
        2955: aastore
        2956: dup
        2957: bipush        64
        2959: aload         149
        2961: aastore
        2962: dup
        2963: bipush        65
        2965: aload         83
        2967: aastore
        2968: dup
        2969: bipush        66
        2971: aload         82
        2973: aastore
        2974: dup
        2975: bipush        67
        2977: aload         84
        2979: aastore
        2980: dup
        2981: bipush        68
        2983: aload         85
        2985: aastore
        2986: dup
        2987: bipush        69
        2989: aload         148
        2991: aastore
        2992: dup
        2993: bipush        70
        2995: aload         147
        2997: aastore
        2998: dup
        2999: bipush        71
        3001: aload         86
        3003: aastore
        3004: dup
        3005: bipush        72
        3007: aload         146
        3009: aastore
        3010: dup
        3011: bipush        73
        3013: aload         145
        3015: aastore
        3016: dup
        3017: bipush        74
        3019: aload         144
        3021: aastore
        3022: dup
        3023: bipush        75
        3025: aload         87
        3027: aastore
        3028: dup
        3029: bipush        76
        3031: aload         88
        3033: aastore
        3034: dup
        3035: bipush        77
        3037: aload         143
        3039: aastore
        3040: dup
        3041: bipush        78
        3043: aload         90
        3045: aastore
        3046: dup
        3047: bipush        79
        3049: aload         91
        3051: aastore
        3052: dup
        3053: bipush        80
        3055: aload         89
        3057: aastore
        3058: dup
        3059: bipush        81
        3061: aload         142
        3063: aastore
        3064: dup
        3065: bipush        82
        3067: aload         96
        3069: aastore
        3070: dup
        3071: bipush        83
        3073: aload         92
        3075: aastore
        3076: dup
        3077: bipush        84
        3079: aload         94
        3081: aastore
        3082: dup
        3083: bipush        85
        3085: aload         95
        3087: aastore
        3088: dup
        3089: bipush        86
        3091: aload         141
        3093: aastore
        3094: dup
        3095: bipush        87
        3097: aload         140
        3099: aastore
        3100: dup
        3101: bipush        88
        3103: aload         139
        3105: aastore
        3106: dup
        3107: bipush        89
        3109: aload         138
        3111: aastore
        3112: dup
        3113: bipush        90
        3115: aload         137
        3117: aastore
        3118: dup
        3119: bipush        91
        3121: aload         136
        3123: aastore
        3124: dup
        3125: bipush        92
        3127: aload         135
        3129: aastore
        3130: dup
        3131: bipush        93
        3133: aload         97
        3135: aastore
        3136: dup
        3137: bipush        94
        3139: aload         134
        3141: aastore
        3142: dup
        3143: bipush        95
        3145: aload         133
        3147: aastore
        3148: dup
        3149: bipush        96
        3151: aload         117
        3153: aastore
        3154: dup
        3155: bipush        97
        3157: aload         118
        3159: aastore
        3160: dup
        3161: bipush        98
        3163: aload         124
        3165: aastore
        3166: dup
        3167: bipush        99
        3169: aload         120
        3171: aastore
        3172: dup
        3173: bipush        100
        3175: aload         63
        3177: aastore
        3178: dup
        3179: bipush        101
        3181: aload         93
        3183: aastore
        3184: dup
        3185: bipush        102
        3187: aload         123
        3189: aastore
        3190: dup
        3191: bipush        103
        3193: aload         122
        3195: aastore
        3196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3199: astore        151
        3201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3204: bipush        45
        3206: aload         151
        3208: aastore
        3209: iconst_0
        3210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3213: astore        152
        3215: iconst_4
        3216: istore        153
        3218: bipush        9
        3220: istore        154
        3222: iload         154
        3224: iload         153
        3226: irem
        3227: istore        155
        3229: iconst_2
        3230: istore        156
        3232: bipush        10
        3234: istore        157
        3236: iload         157
        3238: iload         156
        3240: idiv
        3241: istore        158
        3243: iconst_4
        3244: istore        159
        3246: iconst_3
        3247: istore        160
        3249: iload         160
        3251: iload         159
        3253: imul
        3254: istore        161
        3256: iload         161
        3258: iload         158
        3260: isub
        3261: istore        162
        3263: iload         162
        3265: iload         155
        3267: iadd
        3268: istore        163
        3270: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3273: iload         163
        3275: invokevirtual #331                // Method java/io/PrintStream.println:(I)V
        3278: iconst_0
        3279: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3282: astore        164
        3284: new           #14                 // class Block
        3287: dup
        3288: iconst_0
        3289: iconst_0
        3290: anewarray     #16                 // class java/lang/Object
        3293: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3296: astore        165
        3298: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3301: bipush        46
        3303: aload         165
        3305: aastore
        3306: iconst_0
        3307: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3310: astore        166
        3312: iconst_0
        3313: istore        167
        3315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3318: bipush        45
        3320: aaload
        3321: checkcast     #14                 // class Block
        3324: getfield      #334                // Field Block.fields:[Ljava/lang/Object;
        3327: bipush        102
        3329: aaload
        3330: astore        168
        3332: aload         168
        3334: checkcast     #96                 // class Closure
        3337: iload         167
        3339: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3342: invokevirtual #338                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3345: astore        169
        3347: new           #14                 // class Block
        3350: dup
        3351: iconst_0
        3352: iconst_0
        3353: anewarray     #16                 // class java/lang/Object
        3356: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3359: astore        170
        3361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3364: bipush        47
        3366: aload         170
        3368: aastore
        3369: iconst_0
        3370: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3373: astore        171
        3375: return
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
        2194: new           #234                // class ocaml_fn_65
        2197: dup
        2198: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2201: astore        117
        2203: new           #237                // class ocaml_fn_66
        2206: dup
        2207: aload         56
        2209: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2212: astore        118
        2214: new           #14                 // class Block
        2217: dup
        2218: iconst_0
        2219: iconst_1
        2220: anewarray     #16                 // class java/lang/Object
        2223: dup
        2224: iconst_0
        2225: aload         81
        2227: aastore
        2228: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2231: astore        119
        2233: new           #240                // class ocaml_fn_67
        2236: dup
        2237: aload         119
        2239: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2242: astore        120
        2244: new           #243                // class ocaml_fn_68
        2247: dup
        2248: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2251: astore        121
        2253: new           #14                 // class Block
        2256: dup
        2257: iconst_0
        2258: iconst_1
        2259: anewarray     #16                 // class java/lang/Object
        2262: dup
        2263: iconst_0
        2264: aload         121
        2266: aastore
        2267: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2270: astore        122
        2272: new           #246                // class ocaml_fn_69
        2275: dup
        2276: aload         119
        2278: aload         122
        2280: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2283: astore        123
        2285: new           #249                // class ocaml_fn_70
        2288: dup
        2289: aload         123
        2291: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2294: astore        124
        2296: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2299: bipush        44
        2301: aaload
        2302: astore        125
        2304: iconst_0
        2305: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2308: astore        126
        2310: new           #252                // class ocaml_fn_71
        2313: dup
        2314: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2317: astore        127
        2319: new           #255                // class ocaml_fn_72
        2322: dup
        2323: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2326: astore        128
        2328: new           #258                // class ocaml_fn_73
        2331: dup
        2332: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2335: astore        129
        2337: new           #261                // class ocaml_fn_74
        2340: dup
        2341: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2344: astore        130
        2346: new           #264                // class ocaml_fn_75
        2349: dup
        2350: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2353: astore        131
        2355: new           #267                // class ocaml_fn_76
        2358: dup
        2359: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2362: astore        132
        2364: new           #14                 // class Block
        2367: dup
        2368: iconst_0
        2369: bipush        6
        2371: anewarray     #16                 // class java/lang/Object
        2374: dup
        2375: iconst_0
        2376: aload         132
        2378: aastore
        2379: dup
        2380: iconst_1
        2381: aload         131
        2383: aastore
        2384: dup
        2385: iconst_2
        2386: aload         130
        2388: aastore
        2389: dup
        2390: iconst_3
        2391: aload         129
        2393: aastore
        2394: dup
        2395: iconst_4
        2396: aload         128
        2398: aastore
        2399: dup
        2400: iconst_5
        2401: aload         127
        2403: aastore
        2404: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2407: astore        133
        2409: new           #270                // class ocaml_fn_77
        2412: dup
        2413: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2416: astore        134
        2418: new           #273                // class ocaml_fn_78
        2421: dup
        2422: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2425: astore        135
        2427: new           #276                // class ocaml_fn_79
        2430: dup
        2431: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2434: astore        136
        2436: new           #279                // class ocaml_fn_80
        2439: dup
        2440: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2443: astore        137
        2445: new           #282                // class ocaml_fn_81
        2448: dup
        2449: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2452: astore        138
        2454: new           #285                // class ocaml_fn_82
        2457: dup
        2458: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2461: astore        139
        2463: new           #288                // class ocaml_fn_83
        2466: dup
        2467: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2470: astore        140
        2472: new           #291                // class ocaml_fn_84
        2475: dup
        2476: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2479: astore        141
        2481: new           #294                // class ocaml_fn_85
        2484: dup
        2485: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2488: astore        142
        2490: new           #297                // class ocaml_fn_86
        2493: dup
        2494: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2497: astore        143
        2499: new           #300                // class ocaml_fn_87
        2502: dup
        2503: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2506: astore        144
        2508: new           #303                // class ocaml_fn_88
        2511: dup
        2512: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2515: astore        145
        2517: new           #306                // class ocaml_fn_89
        2520: dup
        2521: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2524: astore        146
        2526: new           #309                // class ocaml_fn_90
        2529: dup
        2530: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2533: astore        147
        2535: new           #312                // class ocaml_fn_91
        2538: dup
        2539: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2542: astore        148
        2544: new           #315                // class ocaml_fn_92
        2547: dup
        2548: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2551: astore        149
        2553: new           #318                // class ocaml_fn_93
        2556: dup
        2557: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2560: astore        150
        2562: new           #14                 // class Block
        2565: dup
        2566: iconst_0
        2567: bipush        104
        2569: anewarray     #16                 // class java/lang/Object
        2572: dup
        2573: iconst_0
        2574: aload         18
        2576: aastore
        2577: dup
        2578: iconst_1
        2579: aload         17
        2581: aastore
        2582: dup
        2583: iconst_2
        2584: aload         22
        2586: aastore
        2587: dup
        2588: iconst_3
        2589: aload         23
        2591: aastore
        2592: dup
        2593: iconst_4
        2594: aload         24
        2596: aastore
        2597: dup
        2598: iconst_5
        2599: aload         25
        2601: aastore
        2602: dup
        2603: bipush        6
        2605: aload         26
        2607: aastore
        2608: dup
        2609: bipush        7
        2611: aload         27
        2613: aastore
        2614: dup
        2615: bipush        8
        2617: aload         28
        2619: aastore
        2620: dup
        2621: bipush        9
        2623: aload         29
        2625: aastore
        2626: dup
        2627: bipush        10
        2629: aload         30
        2631: aastore
        2632: dup
        2633: bipush        11
        2635: aload         31
        2637: aastore
        2638: dup
        2639: bipush        12
        2641: aload         32
        2643: aastore
        2644: dup
        2645: bipush        13
        2647: aload         33
        2649: aastore
        2650: dup
        2651: bipush        14
        2653: aload         34
        2655: aastore
        2656: dup
        2657: bipush        15
        2659: aload         35
        2661: aastore
        2662: dup
        2663: bipush        16
        2665: aload         36
        2667: aastore
        2668: dup
        2669: bipush        17
        2671: aload         37
        2673: aastore
        2674: dup
        2675: bipush        18
        2677: iload         41
        2679: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2682: aastore
        2683: dup
        2684: bipush        19
        2686: iload         43
        2688: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2691: aastore
        2692: dup
        2693: bipush        20
        2695: aload         38
        2697: aastore
        2698: dup
        2699: bipush        21
        2701: aload         45
        2703: aastore
        2704: dup
        2705: bipush        22
        2707: aload         47
        2709: aastore
        2710: dup
        2711: bipush        23
        2713: aload         49
        2715: aastore
        2716: dup
        2717: bipush        24
        2719: aload         51
        2721: aastore
        2722: dup
        2723: bipush        25
        2725: aload         53
        2727: aastore
        2728: dup
        2729: bipush        26
        2731: aload         55
        2733: aastore
        2734: dup
        2735: bipush        27
        2737: aload         56
        2739: aastore
        2740: dup
        2741: bipush        28
        2743: aload         57
        2745: aastore
        2746: dup
        2747: bipush        29
        2749: aload         58
        2751: aastore
        2752: dup
        2753: bipush        30
        2755: aload         60
        2757: aastore
        2758: dup
        2759: bipush        31
        2761: aload         59
        2763: aastore
        2764: dup
        2765: bipush        32
        2767: aload         61
        2769: aastore
        2770: dup
        2771: bipush        33
        2773: aload         62
        2775: aastore
        2776: dup
        2777: bipush        34
        2779: aload         64
        2781: aastore
        2782: dup
        2783: bipush        35
        2785: aload         65
        2787: aastore
        2788: dup
        2789: bipush        36
        2791: aload         66
        2793: aastore
        2794: dup
        2795: bipush        37
        2797: aload         73
        2799: aastore
        2800: dup
        2801: bipush        38
        2803: aload         75
        2805: aastore
        2806: dup
        2807: bipush        39
        2809: aload         77
        2811: aastore
        2812: dup
        2813: bipush        40
        2815: aload         98
        2817: aastore
        2818: dup
        2819: bipush        41
        2821: aload         99
        2823: aastore
        2824: dup
        2825: bipush        42
        2827: aload         100
        2829: aastore
        2830: dup
        2831: bipush        43
        2833: aload         101
        2835: aastore
        2836: dup
        2837: bipush        44
        2839: aload         102
        2841: aastore
        2842: dup
        2843: bipush        45
        2845: aload         103
        2847: aastore
        2848: dup
        2849: bipush        46
        2851: aload         104
        2853: aastore
        2854: dup
        2855: bipush        47
        2857: aload         105
        2859: aastore
        2860: dup
        2861: bipush        48
        2863: aload         106
        2865: aastore
        2866: dup
        2867: bipush        49
        2869: aload         107
        2871: aastore
        2872: dup
        2873: bipush        50
        2875: aload         108
        2877: aastore
        2878: dup
        2879: bipush        51
        2881: aload         109
        2883: aastore
        2884: dup
        2885: bipush        52
        2887: aload         110
        2889: aastore
        2890: dup
        2891: bipush        53
        2893: aload         111
        2895: aastore
        2896: dup
        2897: bipush        54
        2899: aload         112
        2901: aastore
        2902: dup
        2903: bipush        55
        2905: aload         114
        2907: aastore
        2908: dup
        2909: bipush        56
        2911: aload         113
        2913: aastore
        2914: dup
        2915: bipush        57
        2917: aload         116
        2919: aastore
        2920: dup
        2921: bipush        58
        2923: aload         115
        2925: aastore
        2926: dup
        2927: bipush        59
        2929: aload         79
        2931: aastore
        2932: dup
        2933: bipush        60
        2935: aload         80
        2937: aastore
        2938: dup
        2939: bipush        61
        2941: aload         78
        2943: aastore
        2944: dup
        2945: bipush        62
        2947: aload         150
        2949: aastore
        2950: dup
        2951: bipush        63
        2953: aload         81
        2955: aastore
        2956: dup
        2957: bipush        64
        2959: aload         149
        2961: aastore
        2962: dup
        2963: bipush        65
        2965: aload         83
        2967: aastore
        2968: dup
        2969: bipush        66
        2971: aload         82
        2973: aastore
        2974: dup
        2975: bipush        67
        2977: aload         84
        2979: aastore
        2980: dup
        2981: bipush        68
        2983: aload         85
        2985: aastore
        2986: dup
        2987: bipush        69
        2989: aload         148
        2991: aastore
        2992: dup
        2993: bipush        70
        2995: aload         147
        2997: aastore
        2998: dup
        2999: bipush        71
        3001: aload         86
        3003: aastore
        3004: dup
        3005: bipush        72
        3007: aload         146
        3009: aastore
        3010: dup
        3011: bipush        73
        3013: aload         145
        3015: aastore
        3016: dup
        3017: bipush        74
        3019: aload         144
        3021: aastore
        3022: dup
        3023: bipush        75
        3025: aload         87
        3027: aastore
        3028: dup
        3029: bipush        76
        3031: aload         88
        3033: aastore
        3034: dup
        3035: bipush        77
        3037: aload         143
        3039: aastore
        3040: dup
        3041: bipush        78
        3043: aload         90
        3045: aastore
        3046: dup
        3047: bipush        79
        3049: aload         91
        3051: aastore
        3052: dup
        3053: bipush        80
        3055: aload         89
        3057: aastore
        3058: dup
        3059: bipush        81
        3061: aload         142
        3063: aastore
        3064: dup
        3065: bipush        82
        3067: aload         96
        3069: aastore
        3070: dup
        3071: bipush        83
        3073: aload         92
        3075: aastore
        3076: dup
        3077: bipush        84
        3079: aload         94
        3081: aastore
        3082: dup
        3083: bipush        85
        3085: aload         95
        3087: aastore
        3088: dup
        3089: bipush        86
        3091: aload         141
        3093: aastore
        3094: dup
        3095: bipush        87
        3097: aload         140
        3099: aastore
        3100: dup
        3101: bipush        88
        3103: aload         139
        3105: aastore
        3106: dup
        3107: bipush        89
        3109: aload         138
        3111: aastore
        3112: dup
        3113: bipush        90
        3115: aload         137
        3117: aastore
        3118: dup
        3119: bipush        91
        3121: aload         136
        3123: aastore
        3124: dup
        3125: bipush        92
        3127: aload         135
        3129: aastore
        3130: dup
        3131: bipush        93
        3133: aload         97
        3135: aastore
        3136: dup
        3137: bipush        94
        3139: aload         134
        3141: aastore
        3142: dup
        3143: bipush        95
        3145: aload         133
        3147: aastore
        3148: dup
        3149: bipush        96
        3151: aload         117
        3153: aastore
        3154: dup
        3155: bipush        97
        3157: aload         118
        3159: aastore
        3160: dup
        3161: bipush        98
        3163: aload         124
        3165: aastore
        3166: dup
        3167: bipush        99
        3169: aload         120
        3171: aastore
        3172: dup
        3173: bipush        100
        3175: aload         63
        3177: aastore
        3178: dup
        3179: bipush        101
        3181: aload         93
        3183: aastore
        3184: dup
        3185: bipush        102
        3187: aload         123
        3189: aastore
        3190: dup
        3191: bipush        103
        3193: aload         122
        3195: aastore
        3196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3199: astore        151
        3201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3204: bipush        45
        3206: aload         151
        3208: aastore
        3209: iconst_0
        3210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3213: astore        152
        3215: iconst_0
        3216: istore        153
        3218: iload         153
        3220: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3223: astore        154
        3225: goto_w        3230
        3230: new           #321                // class ocaml_fn_95
        3233: dup
        3234: invokespecial #322                // Method ocaml_fn_95."<init>":()V
        3237: astore        155
        3239: bipush        10
        3241: istore        156
        3243: aload         155
        3245: iload         156
        3247: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3250: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3253: astore        157
        3255: bipush        32
        3257: istore        158
        3259: aload         157
        3261: checkcast     #96                 // class Closure
        3264: iload         158
        3266: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3269: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3272: astore        159
        3274: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3277: aload         159
        3279: checkcast     #27                 // class java/lang/Integer
        3282: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3285: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3288: iconst_0
        3289: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3292: astore        160
        3294: new           #14                 // class Block
        3297: dup
        3298: iconst_0
        3299: iconst_1
        3300: anewarray     #16                 // class java/lang/Object
        3303: dup
        3304: iconst_0
        3305: aload         155
        3307: aastore
        3308: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3311: astore        161
        3313: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3316: bipush        46
        3318: aload         161
        3320: aastore
        3321: iconst_0
        3322: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3325: astore        162
        3327: iconst_0
        3328: istore        163
        3330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3333: bipush        45
        3335: aaload
        3336: checkcast     #14                 // class Block
        3339: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3342: bipush        102
        3344: aaload
        3345: astore        164
        3347: aload         164
        3349: checkcast     #96                 // class Closure
        3352: iload         163
        3354: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3357: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3360: astore        165
        3362: new           #14                 // class Block
        3365: dup
        3366: iconst_0
        3367: iconst_0
        3368: anewarray     #16                 // class java/lang/Object
        3371: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3374: astore        166
        3376: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3379: bipush        47
        3381: aload         166
        3383: aastore
        3384: iconst_0
        3385: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3388: astore        167
        3390: return
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
        2220: new           #234                // class ocaml_fn_65
        2223: dup
        2224: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2227: astore        117
        2229: new           #237                // class ocaml_fn_66
        2232: dup
        2233: aload         56
        2235: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2238: astore        118
        2240: new           #14                 // class Block
        2243: dup
        2244: iconst_0
        2245: iconst_1
        2246: anewarray     #16                 // class java/lang/Object
        2249: dup
        2250: iconst_0
        2251: aload         81
        2253: aastore
        2254: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2257: astore        119
        2259: new           #240                // class ocaml_fn_67
        2262: dup
        2263: aload         119
        2265: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2268: astore        120
        2270: new           #243                // class ocaml_fn_68
        2273: dup
        2274: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2277: astore        121
        2279: new           #14                 // class Block
        2282: dup
        2283: iconst_0
        2284: iconst_1
        2285: anewarray     #16                 // class java/lang/Object
        2288: dup
        2289: iconst_0
        2290: aload         121
        2292: aastore
        2293: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2296: astore        122
        2298: new           #246                // class ocaml_fn_69
        2301: dup
        2302: aload         119
        2304: aload         122
        2306: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2309: astore        123
        2311: new           #249                // class ocaml_fn_70
        2314: dup
        2315: aload         123
        2317: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2320: astore        124
        2322: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2325: bipush        44
        2327: aaload
        2328: astore        125
        2330: iconst_0
        2331: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2334: astore        126
        2336: new           #252                // class ocaml_fn_71
        2339: dup
        2340: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2343: astore        127
        2345: new           #255                // class ocaml_fn_72
        2348: dup
        2349: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2352: astore        128
        2354: new           #258                // class ocaml_fn_73
        2357: dup
        2358: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2361: astore        129
        2363: new           #261                // class ocaml_fn_74
        2366: dup
        2367: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2370: astore        130
        2372: new           #264                // class ocaml_fn_75
        2375: dup
        2376: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2379: astore        131
        2381: new           #267                // class ocaml_fn_76
        2384: dup
        2385: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2388: astore        132
        2390: new           #14                 // class Block
        2393: dup
        2394: iconst_0
        2395: bipush        6
        2397: anewarray     #16                 // class java/lang/Object
        2400: dup
        2401: iconst_0
        2402: aload         132
        2404: aastore
        2405: dup
        2406: iconst_1
        2407: aload         131
        2409: aastore
        2410: dup
        2411: iconst_2
        2412: aload         130
        2414: aastore
        2415: dup
        2416: iconst_3
        2417: aload         129
        2419: aastore
        2420: dup
        2421: iconst_4
        2422: aload         128
        2424: aastore
        2425: dup
        2426: iconst_5
        2427: aload         127
        2429: aastore
        2430: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2433: astore        133
        2435: new           #270                // class ocaml_fn_77
        2438: dup
        2439: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2442: astore        134
        2444: new           #273                // class ocaml_fn_78
        2447: dup
        2448: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2451: astore        135
        2453: new           #276                // class ocaml_fn_79
        2456: dup
        2457: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2460: astore        136
        2462: new           #279                // class ocaml_fn_80
        2465: dup
        2466: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2469: astore        137
        2471: new           #282                // class ocaml_fn_81
        2474: dup
        2475: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2478: astore        138
        2480: new           #285                // class ocaml_fn_82
        2483: dup
        2484: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2487: astore        139
        2489: new           #288                // class ocaml_fn_83
        2492: dup
        2493: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2496: astore        140
        2498: new           #291                // class ocaml_fn_84
        2501: dup
        2502: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2505: astore        141
        2507: new           #294                // class ocaml_fn_85
        2510: dup
        2511: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2514: astore        142
        2516: new           #297                // class ocaml_fn_86
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2523: astore        143
        2525: new           #300                // class ocaml_fn_87
        2528: dup
        2529: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2532: astore        144
        2534: new           #303                // class ocaml_fn_88
        2537: dup
        2538: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2541: astore        145
        2543: new           #306                // class ocaml_fn_89
        2546: dup
        2547: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2550: astore        146
        2552: new           #309                // class ocaml_fn_90
        2555: dup
        2556: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2559: astore        147
        2561: new           #312                // class ocaml_fn_91
        2564: dup
        2565: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2568: astore        148
        2570: new           #315                // class ocaml_fn_92
        2573: dup
        2574: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2577: astore        149
        2579: new           #318                // class ocaml_fn_93
        2582: dup
        2583: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2586: astore        150
        2588: new           #14                 // class Block
        2591: dup
        2592: iconst_0
        2593: bipush        104
        2595: anewarray     #16                 // class java/lang/Object
        2598: dup
        2599: iconst_0
        2600: aload         18
        2602: aastore
        2603: dup
        2604: iconst_1
        2605: aload         17
        2607: aastore
        2608: dup
        2609: iconst_2
        2610: aload         22
        2612: aastore
        2613: dup
        2614: iconst_3
        2615: aload         23
        2617: aastore
        2618: dup
        2619: iconst_4
        2620: aload         24
        2622: aastore
        2623: dup
        2624: iconst_5
        2625: aload         25
        2627: aastore
        2628: dup
        2629: bipush        6
        2631: aload         26
        2633: aastore
        2634: dup
        2635: bipush        7
        2637: aload         27
        2639: aastore
        2640: dup
        2641: bipush        8
        2643: aload         28
        2645: aastore
        2646: dup
        2647: bipush        9
        2649: aload         29
        2651: aastore
        2652: dup
        2653: bipush        10
        2655: aload         30
        2657: aastore
        2658: dup
        2659: bipush        11
        2661: aload         31
        2663: aastore
        2664: dup
        2665: bipush        12
        2667: aload         32
        2669: aastore
        2670: dup
        2671: bipush        13
        2673: aload         33
        2675: aastore
        2676: dup
        2677: bipush        14
        2679: aload         34
        2681: aastore
        2682: dup
        2683: bipush        15
        2685: aload         35
        2687: aastore
        2688: dup
        2689: bipush        16
        2691: aload         36
        2693: aastore
        2694: dup
        2695: bipush        17
        2697: aload         37
        2699: aastore
        2700: dup
        2701: bipush        18
        2703: iload         41
        2705: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2708: aastore
        2709: dup
        2710: bipush        19
        2712: iload         43
        2714: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2717: aastore
        2718: dup
        2719: bipush        20
        2721: aload         38
        2723: aastore
        2724: dup
        2725: bipush        21
        2727: aload         45
        2729: aastore
        2730: dup
        2731: bipush        22
        2733: aload         47
        2735: aastore
        2736: dup
        2737: bipush        23
        2739: aload         49
        2741: aastore
        2742: dup
        2743: bipush        24
        2745: aload         51
        2747: aastore
        2748: dup
        2749: bipush        25
        2751: aload         53
        2753: aastore
        2754: dup
        2755: bipush        26
        2757: aload         55
        2759: aastore
        2760: dup
        2761: bipush        27
        2763: aload         56
        2765: aastore
        2766: dup
        2767: bipush        28
        2769: aload         57
        2771: aastore
        2772: dup
        2773: bipush        29
        2775: aload         58
        2777: aastore
        2778: dup
        2779: bipush        30
        2781: aload         60
        2783: aastore
        2784: dup
        2785: bipush        31
        2787: aload         59
        2789: aastore
        2790: dup
        2791: bipush        32
        2793: aload         61
        2795: aastore
        2796: dup
        2797: bipush        33
        2799: aload         62
        2801: aastore
        2802: dup
        2803: bipush        34
        2805: aload         64
        2807: aastore
        2808: dup
        2809: bipush        35
        2811: aload         65
        2813: aastore
        2814: dup
        2815: bipush        36
        2817: aload         66
        2819: aastore
        2820: dup
        2821: bipush        37
        2823: aload         73
        2825: aastore
        2826: dup
        2827: bipush        38
        2829: aload         75
        2831: aastore
        2832: dup
        2833: bipush        39
        2835: aload         77
        2837: aastore
        2838: dup
        2839: bipush        40
        2841: aload         98
        2843: aastore
        2844: dup
        2845: bipush        41
        2847: aload         99
        2849: aastore
        2850: dup
        2851: bipush        42
        2853: aload         100
        2855: aastore
        2856: dup
        2857: bipush        43
        2859: aload         101
        2861: aastore
        2862: dup
        2863: bipush        44
        2865: aload         102
        2867: aastore
        2868: dup
        2869: bipush        45
        2871: aload         103
        2873: aastore
        2874: dup
        2875: bipush        46
        2877: aload         104
        2879: aastore
        2880: dup
        2881: bipush        47
        2883: aload         105
        2885: aastore
        2886: dup
        2887: bipush        48
        2889: aload         106
        2891: aastore
        2892: dup
        2893: bipush        49
        2895: aload         107
        2897: aastore
        2898: dup
        2899: bipush        50
        2901: aload         108
        2903: aastore
        2904: dup
        2905: bipush        51
        2907: aload         109
        2909: aastore
        2910: dup
        2911: bipush        52
        2913: aload         110
        2915: aastore
        2916: dup
        2917: bipush        53
        2919: aload         111
        2921: aastore
        2922: dup
        2923: bipush        54
        2925: aload         112
        2927: aastore
        2928: dup
        2929: bipush        55
        2931: aload         114
        2933: aastore
        2934: dup
        2935: bipush        56
        2937: aload         113
        2939: aastore
        2940: dup
        2941: bipush        57
        2943: aload         116
        2945: aastore
        2946: dup
        2947: bipush        58
        2949: aload         115
        2951: aastore
        2952: dup
        2953: bipush        59
        2955: aload         79
        2957: aastore
        2958: dup
        2959: bipush        60
        2961: aload         80
        2963: aastore
        2964: dup
        2965: bipush        61
        2967: aload         78
        2969: aastore
        2970: dup
        2971: bipush        62
        2973: aload         150
        2975: aastore
        2976: dup
        2977: bipush        63
        2979: aload         81
        2981: aastore
        2982: dup
        2983: bipush        64
        2985: aload         149
        2987: aastore
        2988: dup
        2989: bipush        65
        2991: aload         83
        2993: aastore
        2994: dup
        2995: bipush        66
        2997: aload         82
        2999: aastore
        3000: dup
        3001: bipush        67
        3003: aload         84
        3005: aastore
        3006: dup
        3007: bipush        68
        3009: aload         85
        3011: aastore
        3012: dup
        3013: bipush        69
        3015: aload         148
        3017: aastore
        3018: dup
        3019: bipush        70
        3021: aload         147
        3023: aastore
        3024: dup
        3025: bipush        71
        3027: aload         86
        3029: aastore
        3030: dup
        3031: bipush        72
        3033: aload         146
        3035: aastore
        3036: dup
        3037: bipush        73
        3039: aload         145
        3041: aastore
        3042: dup
        3043: bipush        74
        3045: aload         144
        3047: aastore
        3048: dup
        3049: bipush        75
        3051: aload         87
        3053: aastore
        3054: dup
        3055: bipush        76
        3057: aload         88
        3059: aastore
        3060: dup
        3061: bipush        77
        3063: aload         143
        3065: aastore
        3066: dup
        3067: bipush        78
        3069: aload         90
        3071: aastore
        3072: dup
        3073: bipush        79
        3075: aload         91
        3077: aastore
        3078: dup
        3079: bipush        80
        3081: aload         89
        3083: aastore
        3084: dup
        3085: bipush        81
        3087: aload         142
        3089: aastore
        3090: dup
        3091: bipush        82
        3093: aload         96
        3095: aastore
        3096: dup
        3097: bipush        83
        3099: aload         92
        3101: aastore
        3102: dup
        3103: bipush        84
        3105: aload         94
        3107: aastore
        3108: dup
        3109: bipush        85
        3111: aload         95
        3113: aastore
        3114: dup
        3115: bipush        86
        3117: aload         141
        3119: aastore
        3120: dup
        3121: bipush        87
        3123: aload         140
        3125: aastore
        3126: dup
        3127: bipush        88
        3129: aload         139
        3131: aastore
        3132: dup
        3133: bipush        89
        3135: aload         138
        3137: aastore
        3138: dup
        3139: bipush        90
        3141: aload         137
        3143: aastore
        3144: dup
        3145: bipush        91
        3147: aload         136
        3149: aastore
        3150: dup
        3151: bipush        92
        3153: aload         135
        3155: aastore
        3156: dup
        3157: bipush        93
        3159: aload         97
        3161: aastore
        3162: dup
        3163: bipush        94
        3165: aload         134
        3167: aastore
        3168: dup
        3169: bipush        95
        3171: aload         133
        3173: aastore
        3174: dup
        3175: bipush        96
        3177: aload         117
        3179: aastore
        3180: dup
        3181: bipush        97
        3183: aload         118
        3185: aastore
        3186: dup
        3187: bipush        98
        3189: aload         124
        3191: aastore
        3192: dup
        3193: bipush        99
        3195: aload         120
        3197: aastore
        3198: dup
        3199: bipush        100
        3201: aload         63
        3203: aastore
        3204: dup
        3205: bipush        101
        3207: aload         93
        3209: aastore
        3210: dup
        3211: bipush        102
        3213: aload         123
        3215: aastore
        3216: dup
        3217: bipush        103
        3219: aload         122
        3221: aastore
        3222: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3225: astore        151
        3227: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3230: bipush        45
        3232: aload         151
        3234: aastore
        3235: iconst_0
        3236: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3239: astore        152
        3241: iconst_0
        3242: istore        153
        3244: iload         153
        3246: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3249: astore        154
        3251: goto_w        3256
        3256: new           #321                // class ocaml_fn_94
        3259: dup
        3260: invokespecial #322                // Method ocaml_fn_94."<init>":()V
        3263: astore        155
        3265: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3268: bipush        46
        3270: aaload
        3271: astore        156
        3273: aload         155
        3275: aload         156
        3277: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3280: astore        157
        3282: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3285: aload         157
        3287: checkcast     #27                 // class java/lang/Integer
        3290: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3293: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3296: iconst_0
        3297: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3300: astore        158
        3302: new           #14                 // class Block
        3305: dup
        3306: iconst_0
        3307: iconst_1
        3308: anewarray     #16                 // class java/lang/Object
        3311: dup
        3312: iconst_0
        3313: aload         155
        3315: aastore
        3316: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3319: astore        159
        3321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3324: bipush        47
        3326: aload         159
        3328: aastore
        3329: iconst_0
        3330: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3333: astore        160
        3335: iconst_0
        3336: istore        161
        3338: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3341: bipush        45
        3343: aaload
        3344: checkcast     #14                 // class Block
        3347: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3350: bipush        102
        3352: aaload
        3353: astore        162
        3355: aload         162
        3357: checkcast     #96                 // class Closure
        3360: iload         161
        3362: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3365: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3368: astore        163
        3370: new           #14                 // class Block
        3373: dup
        3374: iconst_0
        3375: iconst_0
        3376: anewarray     #16                 // class java/lang/Object
        3379: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3382: astore        164
        3384: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3387: bipush        48
        3389: aload         164
        3391: aastore
        3392: iconst_0
        3393: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3396: astore        165
        3398: return
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
        2203: new           #234                // class ocaml_fn_65
        2206: dup
        2207: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2210: astore        117
        2212: new           #237                // class ocaml_fn_66
        2215: dup
        2216: aload         56
        2218: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2221: astore        118
        2223: new           #14                 // class Block
        2226: dup
        2227: iconst_0
        2228: iconst_1
        2229: anewarray     #16                 // class java/lang/Object
        2232: dup
        2233: iconst_0
        2234: aload         81
        2236: aastore
        2237: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2240: astore        119
        2242: new           #240                // class ocaml_fn_67
        2245: dup
        2246: aload         119
        2248: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2251: astore        120
        2253: new           #243                // class ocaml_fn_68
        2256: dup
        2257: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2260: astore        121
        2262: new           #14                 // class Block
        2265: dup
        2266: iconst_0
        2267: iconst_1
        2268: anewarray     #16                 // class java/lang/Object
        2271: dup
        2272: iconst_0
        2273: aload         121
        2275: aastore
        2276: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2279: astore        122
        2281: new           #246                // class ocaml_fn_69
        2284: dup
        2285: aload         119
        2287: aload         122
        2289: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2292: astore        123
        2294: new           #249                // class ocaml_fn_70
        2297: dup
        2298: aload         123
        2300: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2303: astore        124
        2305: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2308: bipush        44
        2310: aaload
        2311: astore        125
        2313: iconst_0
        2314: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2317: astore        126
        2319: new           #252                // class ocaml_fn_71
        2322: dup
        2323: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2326: astore        127
        2328: new           #255                // class ocaml_fn_72
        2331: dup
        2332: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2335: astore        128
        2337: new           #258                // class ocaml_fn_73
        2340: dup
        2341: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2344: astore        129
        2346: new           #261                // class ocaml_fn_74
        2349: dup
        2350: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2353: astore        130
        2355: new           #264                // class ocaml_fn_75
        2358: dup
        2359: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2362: astore        131
        2364: new           #267                // class ocaml_fn_76
        2367: dup
        2368: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2371: astore        132
        2373: new           #14                 // class Block
        2376: dup
        2377: iconst_0
        2378: bipush        6
        2380: anewarray     #16                 // class java/lang/Object
        2383: dup
        2384: iconst_0
        2385: aload         132
        2387: aastore
        2388: dup
        2389: iconst_1
        2390: aload         131
        2392: aastore
        2393: dup
        2394: iconst_2
        2395: aload         130
        2397: aastore
        2398: dup
        2399: iconst_3
        2400: aload         129
        2402: aastore
        2403: dup
        2404: iconst_4
        2405: aload         128
        2407: aastore
        2408: dup
        2409: iconst_5
        2410: aload         127
        2412: aastore
        2413: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        133
        2418: new           #270                // class ocaml_fn_77
        2421: dup
        2422: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2425: astore        134
        2427: new           #273                // class ocaml_fn_78
        2430: dup
        2431: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2434: astore        135
        2436: new           #276                // class ocaml_fn_79
        2439: dup
        2440: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2443: astore        136
        2445: new           #279                // class ocaml_fn_80
        2448: dup
        2449: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2452: astore        137
        2454: new           #282                // class ocaml_fn_81
        2457: dup
        2458: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2461: astore        138
        2463: new           #285                // class ocaml_fn_82
        2466: dup
        2467: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2470: astore        139
        2472: new           #288                // class ocaml_fn_83
        2475: dup
        2476: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2479: astore        140
        2481: new           #291                // class ocaml_fn_84
        2484: dup
        2485: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2488: astore        141
        2490: new           #294                // class ocaml_fn_85
        2493: dup
        2494: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2497: astore        142
        2499: new           #297                // class ocaml_fn_86
        2502: dup
        2503: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2506: astore        143
        2508: new           #300                // class ocaml_fn_87
        2511: dup
        2512: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2515: astore        144
        2517: new           #303                // class ocaml_fn_88
        2520: dup
        2521: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2524: astore        145
        2526: new           #306                // class ocaml_fn_89
        2529: dup
        2530: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2533: astore        146
        2535: new           #309                // class ocaml_fn_90
        2538: dup
        2539: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2542: astore        147
        2544: new           #312                // class ocaml_fn_91
        2547: dup
        2548: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2551: astore        148
        2553: new           #315                // class ocaml_fn_92
        2556: dup
        2557: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2560: astore        149
        2562: new           #318                // class ocaml_fn_93
        2565: dup
        2566: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2569: astore        150
        2571: new           #14                 // class Block
        2574: dup
        2575: iconst_0
        2576: bipush        104
        2578: anewarray     #16                 // class java/lang/Object
        2581: dup
        2582: iconst_0
        2583: aload         18
        2585: aastore
        2586: dup
        2587: iconst_1
        2588: aload         17
        2590: aastore
        2591: dup
        2592: iconst_2
        2593: aload         22
        2595: aastore
        2596: dup
        2597: iconst_3
        2598: aload         23
        2600: aastore
        2601: dup
        2602: iconst_4
        2603: aload         24
        2605: aastore
        2606: dup
        2607: iconst_5
        2608: aload         25
        2610: aastore
        2611: dup
        2612: bipush        6
        2614: aload         26
        2616: aastore
        2617: dup
        2618: bipush        7
        2620: aload         27
        2622: aastore
        2623: dup
        2624: bipush        8
        2626: aload         28
        2628: aastore
        2629: dup
        2630: bipush        9
        2632: aload         29
        2634: aastore
        2635: dup
        2636: bipush        10
        2638: aload         30
        2640: aastore
        2641: dup
        2642: bipush        11
        2644: aload         31
        2646: aastore
        2647: dup
        2648: bipush        12
        2650: aload         32
        2652: aastore
        2653: dup
        2654: bipush        13
        2656: aload         33
        2658: aastore
        2659: dup
        2660: bipush        14
        2662: aload         34
        2664: aastore
        2665: dup
        2666: bipush        15
        2668: aload         35
        2670: aastore
        2671: dup
        2672: bipush        16
        2674: aload         36
        2676: aastore
        2677: dup
        2678: bipush        17
        2680: aload         37
        2682: aastore
        2683: dup
        2684: bipush        18
        2686: iload         41
        2688: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2691: aastore
        2692: dup
        2693: bipush        19
        2695: iload         43
        2697: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2700: aastore
        2701: dup
        2702: bipush        20
        2704: aload         38
        2706: aastore
        2707: dup
        2708: bipush        21
        2710: aload         45
        2712: aastore
        2713: dup
        2714: bipush        22
        2716: aload         47
        2718: aastore
        2719: dup
        2720: bipush        23
        2722: aload         49
        2724: aastore
        2725: dup
        2726: bipush        24
        2728: aload         51
        2730: aastore
        2731: dup
        2732: bipush        25
        2734: aload         53
        2736: aastore
        2737: dup
        2738: bipush        26
        2740: aload         55
        2742: aastore
        2743: dup
        2744: bipush        27
        2746: aload         56
        2748: aastore
        2749: dup
        2750: bipush        28
        2752: aload         57
        2754: aastore
        2755: dup
        2756: bipush        29
        2758: aload         58
        2760: aastore
        2761: dup
        2762: bipush        30
        2764: aload         60
        2766: aastore
        2767: dup
        2768: bipush        31
        2770: aload         59
        2772: aastore
        2773: dup
        2774: bipush        32
        2776: aload         61
        2778: aastore
        2779: dup
        2780: bipush        33
        2782: aload         62
        2784: aastore
        2785: dup
        2786: bipush        34
        2788: aload         64
        2790: aastore
        2791: dup
        2792: bipush        35
        2794: aload         65
        2796: aastore
        2797: dup
        2798: bipush        36
        2800: aload         66
        2802: aastore
        2803: dup
        2804: bipush        37
        2806: aload         73
        2808: aastore
        2809: dup
        2810: bipush        38
        2812: aload         75
        2814: aastore
        2815: dup
        2816: bipush        39
        2818: aload         77
        2820: aastore
        2821: dup
        2822: bipush        40
        2824: aload         98
        2826: aastore
        2827: dup
        2828: bipush        41
        2830: aload         99
        2832: aastore
        2833: dup
        2834: bipush        42
        2836: aload         100
        2838: aastore
        2839: dup
        2840: bipush        43
        2842: aload         101
        2844: aastore
        2845: dup
        2846: bipush        44
        2848: aload         102
        2850: aastore
        2851: dup
        2852: bipush        45
        2854: aload         103
        2856: aastore
        2857: dup
        2858: bipush        46
        2860: aload         104
        2862: aastore
        2863: dup
        2864: bipush        47
        2866: aload         105
        2868: aastore
        2869: dup
        2870: bipush        48
        2872: aload         106
        2874: aastore
        2875: dup
        2876: bipush        49
        2878: aload         107
        2880: aastore
        2881: dup
        2882: bipush        50
        2884: aload         108
        2886: aastore
        2887: dup
        2888: bipush        51
        2890: aload         109
        2892: aastore
        2893: dup
        2894: bipush        52
        2896: aload         110
        2898: aastore
        2899: dup
        2900: bipush        53
        2902: aload         111
        2904: aastore
        2905: dup
        2906: bipush        54
        2908: aload         112
        2910: aastore
        2911: dup
        2912: bipush        55
        2914: aload         114
        2916: aastore
        2917: dup
        2918: bipush        56
        2920: aload         113
        2922: aastore
        2923: dup
        2924: bipush        57
        2926: aload         116
        2928: aastore
        2929: dup
        2930: bipush        58
        2932: aload         115
        2934: aastore
        2935: dup
        2936: bipush        59
        2938: aload         79
        2940: aastore
        2941: dup
        2942: bipush        60
        2944: aload         80
        2946: aastore
        2947: dup
        2948: bipush        61
        2950: aload         78
        2952: aastore
        2953: dup
        2954: bipush        62
        2956: aload         150
        2958: aastore
        2959: dup
        2960: bipush        63
        2962: aload         81
        2964: aastore
        2965: dup
        2966: bipush        64
        2968: aload         149
        2970: aastore
        2971: dup
        2972: bipush        65
        2974: aload         83
        2976: aastore
        2977: dup
        2978: bipush        66
        2980: aload         82
        2982: aastore
        2983: dup
        2984: bipush        67
        2986: aload         84
        2988: aastore
        2989: dup
        2990: bipush        68
        2992: aload         85
        2994: aastore
        2995: dup
        2996: bipush        69
        2998: aload         148
        3000: aastore
        3001: dup
        3002: bipush        70
        3004: aload         147
        3006: aastore
        3007: dup
        3008: bipush        71
        3010: aload         86
        3012: aastore
        3013: dup
        3014: bipush        72
        3016: aload         146
        3018: aastore
        3019: dup
        3020: bipush        73
        3022: aload         145
        3024: aastore
        3025: dup
        3026: bipush        74
        3028: aload         144
        3030: aastore
        3031: dup
        3032: bipush        75
        3034: aload         87
        3036: aastore
        3037: dup
        3038: bipush        76
        3040: aload         88
        3042: aastore
        3043: dup
        3044: bipush        77
        3046: aload         143
        3048: aastore
        3049: dup
        3050: bipush        78
        3052: aload         90
        3054: aastore
        3055: dup
        3056: bipush        79
        3058: aload         91
        3060: aastore
        3061: dup
        3062: bipush        80
        3064: aload         89
        3066: aastore
        3067: dup
        3068: bipush        81
        3070: aload         142
        3072: aastore
        3073: dup
        3074: bipush        82
        3076: aload         96
        3078: aastore
        3079: dup
        3080: bipush        83
        3082: aload         92
        3084: aastore
        3085: dup
        3086: bipush        84
        3088: aload         94
        3090: aastore
        3091: dup
        3092: bipush        85
        3094: aload         95
        3096: aastore
        3097: dup
        3098: bipush        86
        3100: aload         141
        3102: aastore
        3103: dup
        3104: bipush        87
        3106: aload         140
        3108: aastore
        3109: dup
        3110: bipush        88
        3112: aload         139
        3114: aastore
        3115: dup
        3116: bipush        89
        3118: aload         138
        3120: aastore
        3121: dup
        3122: bipush        90
        3124: aload         137
        3126: aastore
        3127: dup
        3128: bipush        91
        3130: aload         136
        3132: aastore
        3133: dup
        3134: bipush        92
        3136: aload         135
        3138: aastore
        3139: dup
        3140: bipush        93
        3142: aload         97
        3144: aastore
        3145: dup
        3146: bipush        94
        3148: aload         134
        3150: aastore
        3151: dup
        3152: bipush        95
        3154: aload         133
        3156: aastore
        3157: dup
        3158: bipush        96
        3160: aload         117
        3162: aastore
        3163: dup
        3164: bipush        97
        3166: aload         118
        3168: aastore
        3169: dup
        3170: bipush        98
        3172: aload         124
        3174: aastore
        3175: dup
        3176: bipush        99
        3178: aload         120
        3180: aastore
        3181: dup
        3182: bipush        100
        3184: aload         63
        3186: aastore
        3187: dup
        3188: bipush        101
        3190: aload         93
        3192: aastore
        3193: dup
        3194: bipush        102
        3196: aload         123
        3198: aastore
        3199: dup
        3200: bipush        103
        3202: aload         122
        3204: aastore
        3205: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3208: astore        151
        3210: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3213: bipush        45
        3215: aload         151
        3217: aastore
        3218: iconst_0
        3219: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3222: astore        152
        3224: iconst_0
        3225: istore        153
        3227: iload         153
        3229: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3232: astore        154
        3234: goto_w        3239
        3239: iconst_0
        3240: istore        155
        3242: iconst_1
        3243: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3246: astore        156
        3248: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3251: bipush        46
        3253: aaload
        3254: astore        157
        3256: new           #14                 // class Block
        3259: dup
        3260: sipush        248
        3263: iconst_2
        3264: anewarray     #16                 // class java/lang/Object
        3267: dup
        3268: iconst_0
        3269: aload         157
        3271: aastore
        3272: dup
        3273: iconst_1
        3274: aload         156
        3276: aastore
        3277: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3280: astore        158
        3282: new           #321                // class ocaml_fn_94
        3285: dup
        3286: aload         158
        3288: invokespecial #322                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3291: astore        159
        3293: iconst_0
        3294: istore        160
        3296: aload         159
        3298: iload         160
        3300: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3303: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3306: astore        161
        3308: getstatic     #332                // Field java/lang/System.out:Ljava/io/PrintStream;
        3311: aload         161
        3313: checkcast     #27                 // class java/lang/Integer
        3316: invokevirtual #336                // Method java/lang/Integer.intValue:()I
        3319: invokevirtual #342                // Method java/io/PrintStream.println:(I)V
        3322: iconst_0
        3323: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3326: astore        162
        3328: new           #14                 // class Block
        3331: dup
        3332: iconst_0
        3333: iconst_2
        3334: anewarray     #16                 // class java/lang/Object
        3337: dup
        3338: iconst_0
        3339: aload         158
        3341: aastore
        3342: dup
        3343: iconst_1
        3344: aload         159
        3346: aastore
        3347: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3350: astore        163
        3352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3355: bipush        47
        3357: aload         163
        3359: aastore
        3360: iconst_0
        3361: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3364: astore        164
        3366: iconst_0
        3367: istore        165
        3369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3372: bipush        45
        3374: aaload
        3375: checkcast     #14                 // class Block
        3378: getfield      #345                // Field Block.fields:[Ljava/lang/Object;
        3381: bipush        102
        3383: aaload
        3384: astore        166
        3386: aload         166
        3388: checkcast     #96                 // class Closure
        3391: iload         165
        3393: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3396: invokevirtual #326                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3399: astore        167
        3401: new           #14                 // class Block
        3404: dup
        3405: iconst_0
        3406: iconst_0
        3407: anewarray     #16                 // class java/lang/Object
        3410: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3413: astore        168
        3415: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3418: bipush        48
        3420: aload         168
        3422: aastore
        3423: iconst_0
        3424: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3427: astore        169
        3429: return
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
        2194: new           #234                // class ocaml_fn_65
        2197: dup
        2198: invokespecial #235                // Method ocaml_fn_65."<init>":()V
        2201: astore        117
        2203: new           #237                // class ocaml_fn_66
        2206: dup
        2207: aload         56
        2209: invokespecial #238                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2212: astore        118
        2214: new           #14                 // class Block
        2217: dup
        2218: iconst_0
        2219: iconst_1
        2220: anewarray     #16                 // class java/lang/Object
        2223: dup
        2224: iconst_0
        2225: aload         81
        2227: aastore
        2228: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2231: astore        119
        2233: new           #240                // class ocaml_fn_67
        2236: dup
        2237: aload         119
        2239: invokespecial #241                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2242: astore        120
        2244: new           #243                // class ocaml_fn_68
        2247: dup
        2248: invokespecial #244                // Method ocaml_fn_68."<init>":()V
        2251: astore        121
        2253: new           #14                 // class Block
        2256: dup
        2257: iconst_0
        2258: iconst_1
        2259: anewarray     #16                 // class java/lang/Object
        2262: dup
        2263: iconst_0
        2264: aload         121
        2266: aastore
        2267: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2270: astore        122
        2272: new           #246                // class ocaml_fn_69
        2275: dup
        2276: aload         119
        2278: aload         122
        2280: invokespecial #247                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2283: astore        123
        2285: new           #249                // class ocaml_fn_70
        2288: dup
        2289: aload         123
        2291: invokespecial #250                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2294: astore        124
        2296: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2299: bipush        44
        2301: aaload
        2302: astore        125
        2304: iconst_0
        2305: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2308: astore        126
        2310: new           #252                // class ocaml_fn_71
        2313: dup
        2314: invokespecial #253                // Method ocaml_fn_71."<init>":()V
        2317: astore        127
        2319: new           #255                // class ocaml_fn_72
        2322: dup
        2323: invokespecial #256                // Method ocaml_fn_72."<init>":()V
        2326: astore        128
        2328: new           #258                // class ocaml_fn_73
        2331: dup
        2332: invokespecial #259                // Method ocaml_fn_73."<init>":()V
        2335: astore        129
        2337: new           #261                // class ocaml_fn_74
        2340: dup
        2341: invokespecial #262                // Method ocaml_fn_74."<init>":()V
        2344: astore        130
        2346: new           #264                // class ocaml_fn_75
        2349: dup
        2350: invokespecial #265                // Method ocaml_fn_75."<init>":()V
        2353: astore        131
        2355: new           #267                // class ocaml_fn_76
        2358: dup
        2359: invokespecial #268                // Method ocaml_fn_76."<init>":()V
        2362: astore        132
        2364: new           #14                 // class Block
        2367: dup
        2368: iconst_0
        2369: bipush        6
        2371: anewarray     #16                 // class java/lang/Object
        2374: dup
        2375: iconst_0
        2376: aload         132
        2378: aastore
        2379: dup
        2380: iconst_1
        2381: aload         131
        2383: aastore
        2384: dup
        2385: iconst_2
        2386: aload         130
        2388: aastore
        2389: dup
        2390: iconst_3
        2391: aload         129
        2393: aastore
        2394: dup
        2395: iconst_4
        2396: aload         128
        2398: aastore
        2399: dup
        2400: iconst_5
        2401: aload         127
        2403: aastore
        2404: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2407: astore        133
        2409: new           #270                // class ocaml_fn_77
        2412: dup
        2413: invokespecial #271                // Method ocaml_fn_77."<init>":()V
        2416: astore        134
        2418: new           #273                // class ocaml_fn_78
        2421: dup
        2422: invokespecial #274                // Method ocaml_fn_78."<init>":()V
        2425: astore        135
        2427: new           #276                // class ocaml_fn_79
        2430: dup
        2431: invokespecial #277                // Method ocaml_fn_79."<init>":()V
        2434: astore        136
        2436: new           #279                // class ocaml_fn_80
        2439: dup
        2440: invokespecial #280                // Method ocaml_fn_80."<init>":()V
        2443: astore        137
        2445: new           #282                // class ocaml_fn_81
        2448: dup
        2449: invokespecial #283                // Method ocaml_fn_81."<init>":()V
        2452: astore        138
        2454: new           #285                // class ocaml_fn_82
        2457: dup
        2458: invokespecial #286                // Method ocaml_fn_82."<init>":()V
        2461: astore        139
        2463: new           #288                // class ocaml_fn_83
        2466: dup
        2467: invokespecial #289                // Method ocaml_fn_83."<init>":()V
        2470: astore        140
        2472: new           #291                // class ocaml_fn_84
        2475: dup
        2476: invokespecial #292                // Method ocaml_fn_84."<init>":()V
        2479: astore        141
        2481: new           #294                // class ocaml_fn_85
        2484: dup
        2485: invokespecial #295                // Method ocaml_fn_85."<init>":()V
        2488: astore        142
        2490: new           #297                // class ocaml_fn_86
        2493: dup
        2494: invokespecial #298                // Method ocaml_fn_86."<init>":()V
        2497: astore        143
        2499: new           #300                // class ocaml_fn_87
        2502: dup
        2503: invokespecial #301                // Method ocaml_fn_87."<init>":()V
        2506: astore        144
        2508: new           #303                // class ocaml_fn_88
        2511: dup
        2512: invokespecial #304                // Method ocaml_fn_88."<init>":()V
        2515: astore        145
        2517: new           #306                // class ocaml_fn_89
        2520: dup
        2521: invokespecial #307                // Method ocaml_fn_89."<init>":()V
        2524: astore        146
        2526: new           #309                // class ocaml_fn_90
        2529: dup
        2530: invokespecial #310                // Method ocaml_fn_90."<init>":()V
        2533: astore        147
        2535: new           #312                // class ocaml_fn_91
        2538: dup
        2539: invokespecial #313                // Method ocaml_fn_91."<init>":()V
        2542: astore        148
        2544: new           #315                // class ocaml_fn_92
        2547: dup
        2548: invokespecial #316                // Method ocaml_fn_92."<init>":()V
        2551: astore        149
        2553: new           #318                // class ocaml_fn_93
        2556: dup
        2557: invokespecial #319                // Method ocaml_fn_93."<init>":()V
        2560: astore        150
        2562: new           #14                 // class Block
        2565: dup
        2566: iconst_0
        2567: bipush        104
        2569: anewarray     #16                 // class java/lang/Object
        2572: dup
        2573: iconst_0
        2574: aload         18
        2576: aastore
        2577: dup
        2578: iconst_1
        2579: aload         17
        2581: aastore
        2582: dup
        2583: iconst_2
        2584: aload         22
        2586: aastore
        2587: dup
        2588: iconst_3
        2589: aload         23
        2591: aastore
        2592: dup
        2593: iconst_4
        2594: aload         24
        2596: aastore
        2597: dup
        2598: iconst_5
        2599: aload         25
        2601: aastore
        2602: dup
        2603: bipush        6
        2605: aload         26
        2607: aastore
        2608: dup
        2609: bipush        7
        2611: aload         27
        2613: aastore
        2614: dup
        2615: bipush        8
        2617: aload         28
        2619: aastore
        2620: dup
        2621: bipush        9
        2623: aload         29
        2625: aastore
        2626: dup
        2627: bipush        10
        2629: aload         30
        2631: aastore
        2632: dup
        2633: bipush        11
        2635: aload         31
        2637: aastore
        2638: dup
        2639: bipush        12
        2641: aload         32
        2643: aastore
        2644: dup
        2645: bipush        13
        2647: aload         33
        2649: aastore
        2650: dup
        2651: bipush        14
        2653: aload         34
        2655: aastore
        2656: dup
        2657: bipush        15
        2659: aload         35
        2661: aastore
        2662: dup
        2663: bipush        16
        2665: aload         36
        2667: aastore
        2668: dup
        2669: bipush        17
        2671: aload         37
        2673: aastore
        2674: dup
        2675: bipush        18
        2677: iload         41
        2679: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2682: aastore
        2683: dup
        2684: bipush        19
        2686: iload         43
        2688: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2691: aastore
        2692: dup
        2693: bipush        20
        2695: aload         38
        2697: aastore
        2698: dup
        2699: bipush        21
        2701: aload         45
        2703: aastore
        2704: dup
        2705: bipush        22
        2707: aload         47
        2709: aastore
        2710: dup
        2711: bipush        23
        2713: aload         49
        2715: aastore
        2716: dup
        2717: bipush        24
        2719: aload         51
        2721: aastore
        2722: dup
        2723: bipush        25
        2725: aload         53
        2727: aastore
        2728: dup
        2729: bipush        26
        2731: aload         55
        2733: aastore
        2734: dup
        2735: bipush        27
        2737: aload         56
        2739: aastore
        2740: dup
        2741: bipush        28
        2743: aload         57
        2745: aastore
        2746: dup
        2747: bipush        29
        2749: aload         58
        2751: aastore
        2752: dup
        2753: bipush        30
        2755: aload         60
        2757: aastore
        2758: dup
        2759: bipush        31
        2761: aload         59
        2763: aastore
        2764: dup
        2765: bipush        32
        2767: aload         61
        2769: aastore
        2770: dup
        2771: bipush        33
        2773: aload         62
        2775: aastore
        2776: dup
        2777: bipush        34
        2779: aload         64
        2781: aastore
        2782: dup
        2783: bipush        35
        2785: aload         65
        2787: aastore
        2788: dup
        2789: bipush        36
        2791: aload         66
        2793: aastore
        2794: dup
        2795: bipush        37
        2797: aload         73
        2799: aastore
        2800: dup
        2801: bipush        38
        2803: aload         75
        2805: aastore
        2806: dup
        2807: bipush        39
        2809: aload         77
        2811: aastore
        2812: dup
        2813: bipush        40
        2815: aload         98
        2817: aastore
        2818: dup
        2819: bipush        41
        2821: aload         99
        2823: aastore
        2824: dup
        2825: bipush        42
        2827: aload         100
        2829: aastore
        2830: dup
        2831: bipush        43
        2833: aload         101
        2835: aastore
        2836: dup
        2837: bipush        44
        2839: aload         102
        2841: aastore
        2842: dup
        2843: bipush        45
        2845: aload         103
        2847: aastore
        2848: dup
        2849: bipush        46
        2851: aload         104
        2853: aastore
        2854: dup
        2855: bipush        47
        2857: aload         105
        2859: aastore
        2860: dup
        2861: bipush        48
        2863: aload         106
        2865: aastore
        2866: dup
        2867: bipush        49
        2869: aload         107
        2871: aastore
        2872: dup
        2873: bipush        50
        2875: aload         108
        2877: aastore
        2878: dup
        2879: bipush        51
        2881: aload         109
        2883: aastore
        2884: dup
        2885: bipush        52
        2887: aload         110
        2889: aastore
        2890: dup
        2891: bipush        53
        2893: aload         111
        2895: aastore
        2896: dup
        2897: bipush        54
        2899: aload         112
        2901: aastore
        2902: dup
        2903: bipush        55
        2905: aload         114
        2907: aastore
        2908: dup
        2909: bipush        56
        2911: aload         113
        2913: aastore
        2914: dup
        2915: bipush        57
        2917: aload         116
        2919: aastore
        2920: dup
        2921: bipush        58
        2923: aload         115
        2925: aastore
        2926: dup
        2927: bipush        59
        2929: aload         79
        2931: aastore
        2932: dup
        2933: bipush        60
        2935: aload         80
        2937: aastore
        2938: dup
        2939: bipush        61
        2941: aload         78
        2943: aastore
        2944: dup
        2945: bipush        62
        2947: aload         150
        2949: aastore
        2950: dup
        2951: bipush        63
        2953: aload         81
        2955: aastore
        2956: dup
        2957: bipush        64
        2959: aload         149
        2961: aastore
        2962: dup
        2963: bipush        65
        2965: aload         83
        2967: aastore
        2968: dup
        2969: bipush        66
        2971: aload         82
        2973: aastore
        2974: dup
        2975: bipush        67
        2977: aload         84
        2979: aastore
        2980: dup
        2981: bipush        68
        2983: aload         85
        2985: aastore
        2986: dup
        2987: bipush        69
        2989: aload         148
        2991: aastore
        2992: dup
        2993: bipush        70
        2995: aload         147
        2997: aastore
        2998: dup
        2999: bipush        71
        3001: aload         86
        3003: aastore
        3004: dup
        3005: bipush        72
        3007: aload         146
        3009: aastore
        3010: dup
        3011: bipush        73
        3013: aload         145
        3015: aastore
        3016: dup
        3017: bipush        74
        3019: aload         144
        3021: aastore
        3022: dup
        3023: bipush        75
        3025: aload         87
        3027: aastore
        3028: dup
        3029: bipush        76
        3031: aload         88
        3033: aastore
        3034: dup
        3035: bipush        77
        3037: aload         143
        3039: aastore
        3040: dup
        3041: bipush        78
        3043: aload         90
        3045: aastore
        3046: dup
        3047: bipush        79
        3049: aload         91
        3051: aastore
        3052: dup
        3053: bipush        80
        3055: aload         89
        3057: aastore
        3058: dup
        3059: bipush        81
        3061: aload         142
        3063: aastore
        3064: dup
        3065: bipush        82
        3067: aload         96
        3069: aastore
        3070: dup
        3071: bipush        83
        3073: aload         92
        3075: aastore
        3076: dup
        3077: bipush        84
        3079: aload         94
        3081: aastore
        3082: dup
        3083: bipush        85
        3085: aload         95
        3087: aastore
        3088: dup
        3089: bipush        86
        3091: aload         141
        3093: aastore
        3094: dup
        3095: bipush        87
        3097: aload         140
        3099: aastore
        3100: dup
        3101: bipush        88
        3103: aload         139
        3105: aastore
        3106: dup
        3107: bipush        89
        3109: aload         138
        3111: aastore
        3112: dup
        3113: bipush        90
        3115: aload         137
        3117: aastore
        3118: dup
        3119: bipush        91
        3121: aload         136
        3123: aastore
        3124: dup
        3125: bipush        92
        3127: aload         135
        3129: aastore
        3130: dup
        3131: bipush        93
        3133: aload         97
        3135: aastore
        3136: dup
        3137: bipush        94
        3139: aload         134
        3141: aastore
        3142: dup
        3143: bipush        95
        3145: aload         133
        3147: aastore
        3148: dup
        3149: bipush        96
        3151: aload         117
        3153: aastore
        3154: dup
        3155: bipush        97
        3157: aload         118
        3159: aastore
        3160: dup
        3161: bipush        98
        3163: aload         124
        3165: aastore
        3166: dup
        3167: bipush        99
        3169: aload         120
        3171: aastore
        3172: dup
        3173: bipush        100
        3175: aload         63
        3177: aastore
        3178: dup
        3179: bipush        101
        3181: aload         93
        3183: aastore
        3184: dup
        3185: bipush        102
        3187: aload         123
        3189: aastore
        3190: dup
        3191: bipush        103
        3193: aload         122
        3195: aastore
        3196: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3199: astore        151
        3201: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3204: bipush        45
        3206: aload         151
        3208: aastore
        3209: iconst_0
        3210: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3213: astore        152
        3215: iconst_1
        3216: istore        153
        3218: iconst_2
        3219: istore        154
        3221: iload         154
        3223: iload         153
        3225: if_icmple     3234
        3228: iconst_0
        3229: goto_w        3235
        3234: iconst_1
        3235: istore        155
        3237: iload         155
        3239: ifeq          3254
        3242: iload         153
        3244: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3247: astore        156
        3249: goto_w        3282
        3254: iload         153
        3256: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3259: astore        157
        3261: goto_w        3266
        3266: bipush        10
        3268: istore        158
        3270: iload         158
        3272: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3275: astore        159
        3277: goto_w        3298
        3282: bipush        20
        3284: istore        160
        3286: iload         160
        3288: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3291: astore        159
        3293: goto_w        3298
        3298: getstatic     #325                // Field java/lang/System.out:Ljava/io/PrintStream;
        3301: aload         159
        3303: checkcast     #27                 // class java/lang/Integer
        3306: invokevirtual #329                // Method java/lang/Integer.intValue:()I
        3309: invokevirtual #335                // Method java/io/PrintStream.println:(I)V
        3312: iconst_0
        3313: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3316: astore        161
        3318: new           #14                 // class Block
        3321: dup
        3322: iconst_0
        3323: iconst_0
        3324: anewarray     #16                 // class java/lang/Object
        3327: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3330: astore        162
        3332: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3335: bipush        46
        3337: aload         162
        3339: aastore
        3340: iconst_0
        3341: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3344: astore        163
        3346: iconst_0
        3347: istore        164
        3349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3352: bipush        45
        3354: aaload
        3355: checkcast     #14                 // class Block
        3358: getfield      #338                // Field Block.fields:[Ljava/lang/Object;
        3361: bipush        102
        3363: aaload
        3364: astore        165
        3366: aload         165
        3368: checkcast     #96                 // class Closure
        3371: iload         164
        3373: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3376: invokevirtual #342                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3379: astore        166
        3381: new           #14                 // class Block
        3384: dup
        3385: iconst_0
        3386: iconst_0
        3387: anewarray     #16                 // class java/lang/Object
        3390: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3393: astore        167
        3395: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3398: bipush        47
        3400: aload         167
        3402: aastore
        3403: iconst_0
        3404: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3407: astore        168
        3409: return
    }
    |}]
