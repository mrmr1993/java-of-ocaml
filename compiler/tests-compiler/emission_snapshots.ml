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
        1044: ldc_w         #405                // String hi
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
        1411: ldc           #50                 // int 2147483647
        1413: istore        39
        1415: ldc           #51                 // int -2147483648
        1417: istore        40
        1419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1422: bipush        38
        1424: aaload
        1425: astore        41
        1427: ldc2_w        #52                 // double 0.0d
        1430: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1433: astore        42
        1435: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1438: bipush        39
        1440: aaload
        1441: astore        43
        1443: ldc2_w        #52                 // double 0.0d
        1446: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1449: astore        44
        1451: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1454: bipush        40
        1456: aaload
        1457: astore        45
        1459: ldc2_w        #52                 // double 0.0d
        1462: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1465: astore        46
        1467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1470: bipush        41
        1472: aaload
        1473: astore        47
        1475: ldc2_w        #52                 // double 0.0d
        1478: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        48
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        42
        1488: aaload
        1489: astore        49
        1491: ldc2_w        #52                 // double 0.0d
        1494: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1497: astore        50
        1499: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1502: bipush        43
        1504: aaload
        1505: astore        51
        1507: ldc2_w        #52                 // double 0.0d
        1510: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1513: astore        52
        1515: new           #60                 // class ocaml_fn_14
        1518: dup
        1519: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1522: astore        53
        1524: new           #63                 // class ocaml_fn_15
        1527: dup
        1528: aload         18
        1530: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1533: astore        54
        1535: new           #68                 // class ocaml_fn_16
        1538: dup
        1539: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1542: astore        55
        1544: new           #71                 // class ocaml_fn_17
        1547: dup
        1548: aload         18
        1550: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1553: astore        56
        1555: new           #74                 // class ocaml_fn_18
        1558: dup
        1559: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1562: astore        57
        1564: new           #77                 // class ocaml_fn_19
        1567: dup
        1568: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1571: astore        58
        1573: new           #80                 // class ocaml_fn_20
        1576: dup
        1577: aload         26
        1579: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1582: astore        59
        1584: new           #83                 // class ocaml_fn_21
        1587: dup
        1588: aload         53
        1590: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1593: astore        60
        1595: new           #86                 // class ocaml_fn_22
        1598: dup
        1599: aload         60
        1601: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1604: astore        61
        1606: new           #89                 // class ocaml_fn_23
        1609: dup
        1610: aload         26
        1612: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1615: astore        62
        1617: new           #92                 // class ocaml_fn_24
        1620: dup
        1621: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1624: astore        63
        1626: new           #95                 // class ocaml_fn_25
        1629: dup
        1630: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1633: astore        64
        1635: aload         63
        1637: checkcast     #92                 // class ocaml_fn_24
        1640: aload         63
        1642: checkcast     #98                 // class Closure
        1645: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1648: iconst_0
        1649: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1652: astore        65
        1654: aload         63
        1656: checkcast     #92                 // class ocaml_fn_24
        1659: aload         64
        1661: checkcast     #98                 // class Closure
        1664: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1667: iconst_0
        1668: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1671: astore        66
        1673: aload         64
        1675: checkcast     #95                 // class ocaml_fn_25
        1678: aload         63
        1680: checkcast     #98                 // class Closure
        1683: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1686: iconst_0
        1687: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1690: astore        67
        1692: aload         64
        1694: checkcast     #95                 // class ocaml_fn_25
        1697: aload         64
        1699: checkcast     #98                 // class Closure
        1702: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1705: iconst_0
        1706: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1709: astore        68
        1711: iconst_0
        1712: istore        69
        1714: aconst_null
        1715: astore        70
        1717: iconst_1
        1718: istore        71
        1720: iload         71
        1722: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1725: astore        72
        1727: iconst_2
        1728: istore        73
        1730: iload         73
        1732: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1735: astore        74
        1737: new           #115                // class ocaml_fn_26
        1740: dup
        1741: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1744: astore        75
        1746: new           #118                // class ocaml_fn_27
        1749: dup
        1750: aload         75
        1752: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1755: astore        76
        1757: new           #121                // class ocaml_fn_28
        1760: dup
        1761: aload         75
        1763: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1766: astore        77
        1768: new           #124                // class ocaml_fn_29
        1771: dup
        1772: aload         30
        1774: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1777: astore        78
        1779: new           #127                // class ocaml_fn_30
        1782: dup
        1783: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1786: astore        79
        1788: new           #130                // class ocaml_fn_31
        1791: dup
        1792: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1795: astore        80
        1797: new           #133                // class ocaml_fn_32
        1800: dup
        1801: aload         18
        1803: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1806: astore        81
        1808: new           #136                // class ocaml_fn_33
        1811: dup
        1812: aload         18
        1814: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1817: astore        82
        1819: new           #139                // class ocaml_fn_34
        1822: dup
        1823: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1826: astore        83
        1828: new           #142                // class ocaml_fn_35
        1831: dup
        1832: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1835: astore        84
        1837: new           #145                // class ocaml_fn_36
        1840: dup
        1841: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1844: astore        85
        1846: new           #148                // class ocaml_fn_37
        1849: dup
        1850: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1853: astore        86
        1855: new           #151                // class ocaml_fn_38
        1858: dup
        1859: aload         86
        1861: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1864: astore        87
        1866: new           #154                // class ocaml_fn_39
        1869: dup
        1870: aload         86
        1872: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1875: astore        88
        1877: new           #157                // class ocaml_fn_40
        1880: dup
        1881: aload         18
        1883: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1886: astore        89
        1888: new           #160                // class ocaml_fn_41
        1891: dup
        1892: aload         31
        1894: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1897: astore        90
        1899: new           #163                // class ocaml_fn_42
        1902: dup
        1903: aload         18
        1905: aload         90
        1907: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        91
        1912: new           #168                // class ocaml_fn_43
        1915: dup
        1916: aload         91
        1918: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1921: astore        92
        1923: new           #171                // class ocaml_fn_44
        1926: dup
        1927: aload         31
        1929: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1932: astore        93
        1934: new           #174                // class ocaml_fn_45
        1937: dup
        1938: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1941: astore        94
        1943: new           #177                // class ocaml_fn_46
        1946: dup
        1947: aload         72
        1949: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1952: astore        95
        1954: new           #180                // class ocaml_fn_47
        1957: dup
        1958: aload         72
        1960: aload         80
        1962: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1965: astore        96
        1967: new           #183                // class ocaml_fn_48
        1970: dup
        1971: aload         72
        1973: aload         79
        1975: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1978: astore        97
        1980: new           #186                // class ocaml_fn_49
        1983: dup
        1984: aload         58
        1986: aload         72
        1988: aload         80
        1990: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1993: astore        98
        1995: new           #191                // class ocaml_fn_50
        1998: dup
        1999: aload         61
        2001: aload         72
        2003: aload         80
        2005: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        99
        2010: new           #194                // class ocaml_fn_51
        2013: dup
        2014: aload         72
        2016: aload         80
        2018: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        100
        2023: new           #197                // class ocaml_fn_52
        2026: dup
        2027: aload         72
        2029: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2032: astore        101
        2034: new           #200                // class ocaml_fn_53
        2037: dup
        2038: aload         74
        2040: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2043: astore        102
        2045: new           #203                // class ocaml_fn_54
        2048: dup
        2049: aload         74
        2051: aload         80
        2053: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        103
        2058: new           #206                // class ocaml_fn_55
        2061: dup
        2062: aload         74
        2064: aload         79
        2066: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        104
        2071: new           #209                // class ocaml_fn_56
        2074: dup
        2075: aload         58
        2077: aload         74
        2079: aload         80
        2081: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2084: astore        105
        2086: new           #212                // class ocaml_fn_57
        2089: dup
        2090: aload         61
        2092: aload         74
        2094: aload         80
        2096: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        106
        2101: new           #215                // class ocaml_fn_58
        2104: dup
        2105: aload         74
        2107: aload         80
        2109: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        107
        2114: new           #218                // class ocaml_fn_59
        2117: dup
        2118: aload         74
        2120: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2123: astore        108
        2125: new           #221                // class ocaml_fn_60
        2128: dup
        2129: aload         70
        2131: aload         72
        2133: aload         93
        2135: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2138: astore        109
        2140: new           #224                // class ocaml_fn_61
        2143: dup
        2144: aload         109
        2146: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2149: astore        110
        2151: new           #227                // class ocaml_fn_62
        2154: dup
        2155: aload         59
        2157: aload         109
        2159: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2162: astore        111
        2164: new           #230                // class ocaml_fn_63
        2167: dup
        2168: aload         109
        2170: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2173: astore        112
        2175: new           #233                // class ocaml_fn_64
        2178: dup
        2179: aload         62
        2181: aload         109
        2183: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        113
        2188: new           #236                // class ocaml_fn_65
        2191: dup
        2192: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2195: astore        114
        2197: new           #239                // class ocaml_fn_66
        2200: dup
        2201: aload         53
        2203: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2206: astore        115
        2208: new           #14                 // class Block
        2211: dup
        2212: iconst_0
        2213: iconst_1
        2214: anewarray     #16                 // class java/lang/Object
        2217: dup
        2218: iconst_0
        2219: aload         78
        2221: aastore
        2222: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2225: astore        116
        2227: new           #242                // class ocaml_fn_67
        2230: dup
        2231: aload         116
        2233: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2236: astore        117
        2238: new           #245                // class ocaml_fn_68
        2241: dup
        2242: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2245: astore        118
        2247: new           #14                 // class Block
        2250: dup
        2251: iconst_0
        2252: iconst_1
        2253: anewarray     #16                 // class java/lang/Object
        2256: dup
        2257: iconst_0
        2258: aload         118
        2260: aastore
        2261: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2264: astore        119
        2266: new           #248                // class ocaml_fn_69
        2269: dup
        2270: aload         116
        2272: aload         119
        2274: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2277: astore        120
        2279: new           #251                // class ocaml_fn_70
        2282: dup
        2283: aload         120
        2285: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2288: astore        121
        2290: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2293: bipush        44
        2295: aaload
        2296: astore        122
        2298: iconst_0
        2299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2302: astore        123
        2304: new           #254                // class ocaml_fn_71
        2307: dup
        2308: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2311: astore        124
        2313: new           #257                // class ocaml_fn_72
        2316: dup
        2317: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2320: astore        125
        2322: new           #260                // class ocaml_fn_73
        2325: dup
        2326: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2329: astore        126
        2331: new           #263                // class ocaml_fn_74
        2334: dup
        2335: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2338: astore        127
        2340: new           #266                // class ocaml_fn_75
        2343: dup
        2344: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2347: astore        128
        2349: new           #269                // class ocaml_fn_76
        2352: dup
        2353: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2356: astore        129
        2358: new           #14                 // class Block
        2361: dup
        2362: iconst_0
        2363: bipush        6
        2365: anewarray     #16                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         129
        2372: aastore
        2373: dup
        2374: iconst_1
        2375: aload         128
        2377: aastore
        2378: dup
        2379: iconst_2
        2380: aload         127
        2382: aastore
        2383: dup
        2384: iconst_3
        2385: aload         126
        2387: aastore
        2388: dup
        2389: iconst_4
        2390: aload         125
        2392: aastore
        2393: dup
        2394: iconst_5
        2395: aload         124
        2397: aastore
        2398: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2401: astore        130
        2403: new           #272                // class ocaml_fn_77
        2406: dup
        2407: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2410: astore        131
        2412: new           #275                // class ocaml_fn_78
        2415: dup
        2416: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2419: astore        132
        2421: new           #278                // class ocaml_fn_79
        2424: dup
        2425: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2428: astore        133
        2430: new           #281                // class ocaml_fn_80
        2433: dup
        2434: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2437: astore        134
        2439: new           #284                // class ocaml_fn_81
        2442: dup
        2443: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2446: astore        135
        2448: new           #287                // class ocaml_fn_82
        2451: dup
        2452: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2455: astore        136
        2457: new           #290                // class ocaml_fn_83
        2460: dup
        2461: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2464: astore        137
        2466: new           #293                // class ocaml_fn_84
        2469: dup
        2470: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2473: astore        138
        2475: new           #296                // class ocaml_fn_85
        2478: dup
        2479: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2482: astore        139
        2484: new           #299                // class ocaml_fn_86
        2487: dup
        2488: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2491: astore        140
        2493: new           #302                // class ocaml_fn_87
        2496: dup
        2497: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2500: astore        141
        2502: new           #305                // class ocaml_fn_88
        2505: dup
        2506: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2509: astore        142
        2511: new           #308                // class ocaml_fn_89
        2514: dup
        2515: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2518: astore        143
        2520: new           #311                // class ocaml_fn_90
        2523: dup
        2524: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2527: astore        144
        2529: new           #314                // class ocaml_fn_91
        2532: dup
        2533: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2536: astore        145
        2538: new           #317                // class ocaml_fn_92
        2541: dup
        2542: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2545: astore        146
        2547: new           #320                // class ocaml_fn_93
        2550: dup
        2551: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2554: astore        147
        2556: new           #14                 // class Block
        2559: dup
        2560: iconst_0
        2561: bipush        104
        2563: anewarray     #16                 // class java/lang/Object
        2566: dup
        2567: iconst_0
        2568: aload         18
        2570: aastore
        2571: dup
        2572: iconst_1
        2573: aload         17
        2575: aastore
        2576: dup
        2577: iconst_2
        2578: aload         22
        2580: aastore
        2581: dup
        2582: iconst_3
        2583: aload         23
        2585: aastore
        2586: dup
        2587: iconst_4
        2588: aload         24
        2590: aastore
        2591: dup
        2592: iconst_5
        2593: aload         25
        2595: aastore
        2596: dup
        2597: bipush        6
        2599: aload         26
        2601: aastore
        2602: dup
        2603: bipush        7
        2605: aload         27
        2607: aastore
        2608: dup
        2609: bipush        8
        2611: aload         28
        2613: aastore
        2614: dup
        2615: bipush        9
        2617: aload         29
        2619: aastore
        2620: dup
        2621: bipush        10
        2623: aload         30
        2625: aastore
        2626: dup
        2627: bipush        11
        2629: aload         31
        2631: aastore
        2632: dup
        2633: bipush        12
        2635: aload         32
        2637: aastore
        2638: dup
        2639: bipush        13
        2641: aload         33
        2643: aastore
        2644: dup
        2645: bipush        14
        2647: aload         34
        2649: aastore
        2650: dup
        2651: bipush        15
        2653: aload         35
        2655: aastore
        2656: dup
        2657: bipush        16
        2659: aload         36
        2661: aastore
        2662: dup
        2663: bipush        17
        2665: aload         37
        2667: aastore
        2668: dup
        2669: bipush        18
        2671: iload         39
        2673: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2676: aastore
        2677: dup
        2678: bipush        19
        2680: iload         40
        2682: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2685: aastore
        2686: dup
        2687: bipush        20
        2689: aload         38
        2691: aastore
        2692: dup
        2693: bipush        21
        2695: aload         42
        2697: aastore
        2698: dup
        2699: bipush        22
        2701: aload         44
        2703: aastore
        2704: dup
        2705: bipush        23
        2707: aload         46
        2709: aastore
        2710: dup
        2711: bipush        24
        2713: aload         48
        2715: aastore
        2716: dup
        2717: bipush        25
        2719: aload         50
        2721: aastore
        2722: dup
        2723: bipush        26
        2725: aload         52
        2727: aastore
        2728: dup
        2729: bipush        27
        2731: aload         53
        2733: aastore
        2734: dup
        2735: bipush        28
        2737: aload         54
        2739: aastore
        2740: dup
        2741: bipush        29
        2743: aload         55
        2745: aastore
        2746: dup
        2747: bipush        30
        2749: aload         57
        2751: aastore
        2752: dup
        2753: bipush        31
        2755: aload         56
        2757: aastore
        2758: dup
        2759: bipush        32
        2761: aload         58
        2763: aastore
        2764: dup
        2765: bipush        33
        2767: aload         59
        2769: aastore
        2770: dup
        2771: bipush        34
        2773: aload         61
        2775: aastore
        2776: dup
        2777: bipush        35
        2779: aload         62
        2781: aastore
        2782: dup
        2783: bipush        36
        2785: aload         63
        2787: aastore
        2788: dup
        2789: bipush        37
        2791: aload         70
        2793: aastore
        2794: dup
        2795: bipush        38
        2797: aload         72
        2799: aastore
        2800: dup
        2801: bipush        39
        2803: aload         74
        2805: aastore
        2806: dup
        2807: bipush        40
        2809: aload         95
        2811: aastore
        2812: dup
        2813: bipush        41
        2815: aload         96
        2817: aastore
        2818: dup
        2819: bipush        42
        2821: aload         97
        2823: aastore
        2824: dup
        2825: bipush        43
        2827: aload         98
        2829: aastore
        2830: dup
        2831: bipush        44
        2833: aload         99
        2835: aastore
        2836: dup
        2837: bipush        45
        2839: aload         100
        2841: aastore
        2842: dup
        2843: bipush        46
        2845: aload         101
        2847: aastore
        2848: dup
        2849: bipush        47
        2851: aload         102
        2853: aastore
        2854: dup
        2855: bipush        48
        2857: aload         103
        2859: aastore
        2860: dup
        2861: bipush        49
        2863: aload         104
        2865: aastore
        2866: dup
        2867: bipush        50
        2869: aload         105
        2871: aastore
        2872: dup
        2873: bipush        51
        2875: aload         106
        2877: aastore
        2878: dup
        2879: bipush        52
        2881: aload         107
        2883: aastore
        2884: dup
        2885: bipush        53
        2887: aload         108
        2889: aastore
        2890: dup
        2891: bipush        54
        2893: aload         109
        2895: aastore
        2896: dup
        2897: bipush        55
        2899: aload         111
        2901: aastore
        2902: dup
        2903: bipush        56
        2905: aload         110
        2907: aastore
        2908: dup
        2909: bipush        57
        2911: aload         113
        2913: aastore
        2914: dup
        2915: bipush        58
        2917: aload         112
        2919: aastore
        2920: dup
        2921: bipush        59
        2923: aload         76
        2925: aastore
        2926: dup
        2927: bipush        60
        2929: aload         77
        2931: aastore
        2932: dup
        2933: bipush        61
        2935: aload         75
        2937: aastore
        2938: dup
        2939: bipush        62
        2941: aload         147
        2943: aastore
        2944: dup
        2945: bipush        63
        2947: aload         78
        2949: aastore
        2950: dup
        2951: bipush        64
        2953: aload         146
        2955: aastore
        2956: dup
        2957: bipush        65
        2959: aload         80
        2961: aastore
        2962: dup
        2963: bipush        66
        2965: aload         79
        2967: aastore
        2968: dup
        2969: bipush        67
        2971: aload         81
        2973: aastore
        2974: dup
        2975: bipush        68
        2977: aload         82
        2979: aastore
        2980: dup
        2981: bipush        69
        2983: aload         145
        2985: aastore
        2986: dup
        2987: bipush        70
        2989: aload         144
        2991: aastore
        2992: dup
        2993: bipush        71
        2995: aload         83
        2997: aastore
        2998: dup
        2999: bipush        72
        3001: aload         143
        3003: aastore
        3004: dup
        3005: bipush        73
        3007: aload         142
        3009: aastore
        3010: dup
        3011: bipush        74
        3013: aload         141
        3015: aastore
        3016: dup
        3017: bipush        75
        3019: aload         84
        3021: aastore
        3022: dup
        3023: bipush        76
        3025: aload         85
        3027: aastore
        3028: dup
        3029: bipush        77
        3031: aload         140
        3033: aastore
        3034: dup
        3035: bipush        78
        3037: aload         87
        3039: aastore
        3040: dup
        3041: bipush        79
        3043: aload         88
        3045: aastore
        3046: dup
        3047: bipush        80
        3049: aload         86
        3051: aastore
        3052: dup
        3053: bipush        81
        3055: aload         139
        3057: aastore
        3058: dup
        3059: bipush        82
        3061: aload         93
        3063: aastore
        3064: dup
        3065: bipush        83
        3067: aload         89
        3069: aastore
        3070: dup
        3071: bipush        84
        3073: aload         91
        3075: aastore
        3076: dup
        3077: bipush        85
        3079: aload         92
        3081: aastore
        3082: dup
        3083: bipush        86
        3085: aload         138
        3087: aastore
        3088: dup
        3089: bipush        87
        3091: aload         137
        3093: aastore
        3094: dup
        3095: bipush        88
        3097: aload         136
        3099: aastore
        3100: dup
        3101: bipush        89
        3103: aload         135
        3105: aastore
        3106: dup
        3107: bipush        90
        3109: aload         134
        3111: aastore
        3112: dup
        3113: bipush        91
        3115: aload         133
        3117: aastore
        3118: dup
        3119: bipush        92
        3121: aload         132
        3123: aastore
        3124: dup
        3125: bipush        93
        3127: aload         94
        3129: aastore
        3130: dup
        3131: bipush        94
        3133: aload         131
        3135: aastore
        3136: dup
        3137: bipush        95
        3139: aload         130
        3141: aastore
        3142: dup
        3143: bipush        96
        3145: aload         114
        3147: aastore
        3148: dup
        3149: bipush        97
        3151: aload         115
        3153: aastore
        3154: dup
        3155: bipush        98
        3157: aload         121
        3159: aastore
        3160: dup
        3161: bipush        99
        3163: aload         117
        3165: aastore
        3166: dup
        3167: bipush        100
        3169: aload         60
        3171: aastore
        3172: dup
        3173: bipush        101
        3175: aload         90
        3177: aastore
        3178: dup
        3179: bipush        102
        3181: aload         120
        3183: aastore
        3184: dup
        3185: bipush        103
        3187: aload         119
        3189: aastore
        3190: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3193: astore        148
        3195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3198: bipush        45
        3200: aload         148
        3202: aastore
        3203: iconst_0
        3204: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3207: astore        149
        3209: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3212: bipush        46
        3214: aaload
        3215: astore        150
        3217: getstatic     #327                // Field java/lang/System.out:Ljava/io/PrintStream;
        3220: aload         150
        3222: checkcast     #329                // class java/lang/String
        3225: invokevirtual #335                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3228: iconst_0
        3229: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3232: astore        151
        3234: new           #14                 // class Block
        3237: dup
        3238: iconst_0
        3239: iconst_0
        3240: anewarray     #16                 // class java/lang/Object
        3243: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3246: astore        152
        3248: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3251: bipush        47
        3253: aload         152
        3255: aastore
        3256: iconst_0
        3257: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        153
        3262: iconst_0
        3263: istore        154
        3265: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3268: bipush        45
        3270: aaload
        3271: checkcast     #14                 // class Block
        3274: getfield      #338                // Field Block.fields:[Ljava/lang/Object;
        3277: bipush        102
        3279: aaload
        3280: astore        155
        3282: aload         155
        3284: checkcast     #98                 // class Closure
        3287: iload         154
        3289: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3292: invokevirtual #342                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3295: astore        156
        3297: new           #14                 // class Block
        3300: dup
        3301: iconst_0
        3302: iconst_0
        3303: anewarray     #16                 // class java/lang/Object
        3306: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3309: astore        157
        3311: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3314: bipush        48
        3316: aload         157
        3318: aastore
        3319: iconst_0
        3320: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3323: astore        158
        3325: return
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
        1402: ldc           #50                 // int 2147483647
        1404: istore        39
        1406: ldc           #51                 // int -2147483648
        1408: istore        40
        1410: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1413: bipush        38
        1415: aaload
        1416: astore        41
        1418: ldc2_w        #52                 // double 0.0d
        1421: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1424: astore        42
        1426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1429: bipush        39
        1431: aaload
        1432: astore        43
        1434: ldc2_w        #52                 // double 0.0d
        1437: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1440: astore        44
        1442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1445: bipush        40
        1447: aaload
        1448: astore        45
        1450: ldc2_w        #52                 // double 0.0d
        1453: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1456: astore        46
        1458: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1461: bipush        41
        1463: aaload
        1464: astore        47
        1466: ldc2_w        #52                 // double 0.0d
        1469: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1472: astore        48
        1474: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1477: bipush        42
        1479: aaload
        1480: astore        49
        1482: ldc2_w        #52                 // double 0.0d
        1485: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1488: astore        50
        1490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1493: bipush        43
        1495: aaload
        1496: astore        51
        1498: ldc2_w        #52                 // double 0.0d
        1501: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1504: astore        52
        1506: new           #60                 // class ocaml_fn_14
        1509: dup
        1510: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1513: astore        53
        1515: new           #63                 // class ocaml_fn_15
        1518: dup
        1519: aload         18
        1521: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1524: astore        54
        1526: new           #68                 // class ocaml_fn_16
        1529: dup
        1530: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1533: astore        55
        1535: new           #71                 // class ocaml_fn_17
        1538: dup
        1539: aload         18
        1541: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1544: astore        56
        1546: new           #74                 // class ocaml_fn_18
        1549: dup
        1550: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1553: astore        57
        1555: new           #77                 // class ocaml_fn_19
        1558: dup
        1559: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1562: astore        58
        1564: new           #80                 // class ocaml_fn_20
        1567: dup
        1568: aload         26
        1570: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1573: astore        59
        1575: new           #83                 // class ocaml_fn_21
        1578: dup
        1579: aload         53
        1581: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1584: astore        60
        1586: new           #86                 // class ocaml_fn_22
        1589: dup
        1590: aload         60
        1592: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1595: astore        61
        1597: new           #89                 // class ocaml_fn_23
        1600: dup
        1601: aload         26
        1603: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1606: astore        62
        1608: new           #92                 // class ocaml_fn_24
        1611: dup
        1612: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1615: astore        63
        1617: new           #95                 // class ocaml_fn_25
        1620: dup
        1621: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1624: astore        64
        1626: aload         63
        1628: checkcast     #92                 // class ocaml_fn_24
        1631: aload         63
        1633: checkcast     #98                 // class Closure
        1636: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        65
        1645: aload         63
        1647: checkcast     #92                 // class ocaml_fn_24
        1650: aload         64
        1652: checkcast     #98                 // class Closure
        1655: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        66
        1664: aload         64
        1666: checkcast     #95                 // class ocaml_fn_25
        1669: aload         63
        1671: checkcast     #98                 // class Closure
        1674: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1677: iconst_0
        1678: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1681: astore        67
        1683: aload         64
        1685: checkcast     #95                 // class ocaml_fn_25
        1688: aload         64
        1690: checkcast     #98                 // class Closure
        1693: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1696: iconst_0
        1697: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1700: astore        68
        1702: iconst_0
        1703: istore        69
        1705: aconst_null
        1706: astore        70
        1708: iconst_1
        1709: istore        71
        1711: iload         71
        1713: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1716: astore        72
        1718: iconst_2
        1719: istore        73
        1721: iload         73
        1723: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1726: astore        74
        1728: new           #115                // class ocaml_fn_26
        1731: dup
        1732: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1735: astore        75
        1737: new           #118                // class ocaml_fn_27
        1740: dup
        1741: aload         75
        1743: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1746: astore        76
        1748: new           #121                // class ocaml_fn_28
        1751: dup
        1752: aload         75
        1754: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1757: astore        77
        1759: new           #124                // class ocaml_fn_29
        1762: dup
        1763: aload         30
        1765: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1768: astore        78
        1770: new           #127                // class ocaml_fn_30
        1773: dup
        1774: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1777: astore        79
        1779: new           #130                // class ocaml_fn_31
        1782: dup
        1783: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1786: astore        80
        1788: new           #133                // class ocaml_fn_32
        1791: dup
        1792: aload         18
        1794: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1797: astore        81
        1799: new           #136                // class ocaml_fn_33
        1802: dup
        1803: aload         18
        1805: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1808: astore        82
        1810: new           #139                // class ocaml_fn_34
        1813: dup
        1814: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1817: astore        83
        1819: new           #142                // class ocaml_fn_35
        1822: dup
        1823: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1826: astore        84
        1828: new           #145                // class ocaml_fn_36
        1831: dup
        1832: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1835: astore        85
        1837: new           #148                // class ocaml_fn_37
        1840: dup
        1841: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1844: astore        86
        1846: new           #151                // class ocaml_fn_38
        1849: dup
        1850: aload         86
        1852: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1855: astore        87
        1857: new           #154                // class ocaml_fn_39
        1860: dup
        1861: aload         86
        1863: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1866: astore        88
        1868: new           #157                // class ocaml_fn_40
        1871: dup
        1872: aload         18
        1874: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1877: astore        89
        1879: new           #160                // class ocaml_fn_41
        1882: dup
        1883: aload         31
        1885: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1888: astore        90
        1890: new           #163                // class ocaml_fn_42
        1893: dup
        1894: aload         18
        1896: aload         90
        1898: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1901: astore        91
        1903: new           #168                // class ocaml_fn_43
        1906: dup
        1907: aload         91
        1909: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1912: astore        92
        1914: new           #171                // class ocaml_fn_44
        1917: dup
        1918: aload         31
        1920: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1923: astore        93
        1925: new           #174                // class ocaml_fn_45
        1928: dup
        1929: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1932: astore        94
        1934: new           #177                // class ocaml_fn_46
        1937: dup
        1938: aload         72
        1940: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1943: astore        95
        1945: new           #180                // class ocaml_fn_47
        1948: dup
        1949: aload         72
        1951: aload         80
        1953: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1956: astore        96
        1958: new           #183                // class ocaml_fn_48
        1961: dup
        1962: aload         72
        1964: aload         79
        1966: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1969: astore        97
        1971: new           #186                // class ocaml_fn_49
        1974: dup
        1975: aload         58
        1977: aload         72
        1979: aload         80
        1981: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        98
        1986: new           #191                // class ocaml_fn_50
        1989: dup
        1990: aload         61
        1992: aload         72
        1994: aload         80
        1996: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        99
        2001: new           #194                // class ocaml_fn_51
        2004: dup
        2005: aload         72
        2007: aload         80
        2009: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        100
        2014: new           #197                // class ocaml_fn_52
        2017: dup
        2018: aload         72
        2020: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2023: astore        101
        2025: new           #200                // class ocaml_fn_53
        2028: dup
        2029: aload         74
        2031: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2034: astore        102
        2036: new           #203                // class ocaml_fn_54
        2039: dup
        2040: aload         74
        2042: aload         80
        2044: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        103
        2049: new           #206                // class ocaml_fn_55
        2052: dup
        2053: aload         74
        2055: aload         79
        2057: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        104
        2062: new           #209                // class ocaml_fn_56
        2065: dup
        2066: aload         58
        2068: aload         74
        2070: aload         80
        2072: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        105
        2077: new           #212                // class ocaml_fn_57
        2080: dup
        2081: aload         61
        2083: aload         74
        2085: aload         80
        2087: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        106
        2092: new           #215                // class ocaml_fn_58
        2095: dup
        2096: aload         74
        2098: aload         80
        2100: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        107
        2105: new           #218                // class ocaml_fn_59
        2108: dup
        2109: aload         74
        2111: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2114: astore        108
        2116: new           #221                // class ocaml_fn_60
        2119: dup
        2120: aload         70
        2122: aload         72
        2124: aload         93
        2126: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        109
        2131: new           #224                // class ocaml_fn_61
        2134: dup
        2135: aload         109
        2137: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2140: astore        110
        2142: new           #227                // class ocaml_fn_62
        2145: dup
        2146: aload         59
        2148: aload         109
        2150: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        111
        2155: new           #230                // class ocaml_fn_63
        2158: dup
        2159: aload         109
        2161: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2164: astore        112
        2166: new           #233                // class ocaml_fn_64
        2169: dup
        2170: aload         62
        2172: aload         109
        2174: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2177: astore        113
        2179: new           #236                // class ocaml_fn_65
        2182: dup
        2183: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2186: astore        114
        2188: new           #239                // class ocaml_fn_66
        2191: dup
        2192: aload         53
        2194: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2197: astore        115
        2199: new           #14                 // class Block
        2202: dup
        2203: iconst_0
        2204: iconst_1
        2205: anewarray     #16                 // class java/lang/Object
        2208: dup
        2209: iconst_0
        2210: aload         78
        2212: aastore
        2213: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2216: astore        116
        2218: new           #242                // class ocaml_fn_67
        2221: dup
        2222: aload         116
        2224: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2227: astore        117
        2229: new           #245                // class ocaml_fn_68
        2232: dup
        2233: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2236: astore        118
        2238: new           #14                 // class Block
        2241: dup
        2242: iconst_0
        2243: iconst_1
        2244: anewarray     #16                 // class java/lang/Object
        2247: dup
        2248: iconst_0
        2249: aload         118
        2251: aastore
        2252: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2255: astore        119
        2257: new           #248                // class ocaml_fn_69
        2260: dup
        2261: aload         116
        2263: aload         119
        2265: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2268: astore        120
        2270: new           #251                // class ocaml_fn_70
        2273: dup
        2274: aload         120
        2276: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2279: astore        121
        2281: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2284: bipush        44
        2286: aaload
        2287: astore        122
        2289: iconst_0
        2290: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2293: astore        123
        2295: new           #254                // class ocaml_fn_71
        2298: dup
        2299: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2302: astore        124
        2304: new           #257                // class ocaml_fn_72
        2307: dup
        2308: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2311: astore        125
        2313: new           #260                // class ocaml_fn_73
        2316: dup
        2317: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2320: astore        126
        2322: new           #263                // class ocaml_fn_74
        2325: dup
        2326: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2329: astore        127
        2331: new           #266                // class ocaml_fn_75
        2334: dup
        2335: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2338: astore        128
        2340: new           #269                // class ocaml_fn_76
        2343: dup
        2344: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2347: astore        129
        2349: new           #14                 // class Block
        2352: dup
        2353: iconst_0
        2354: bipush        6
        2356: anewarray     #16                 // class java/lang/Object
        2359: dup
        2360: iconst_0
        2361: aload         129
        2363: aastore
        2364: dup
        2365: iconst_1
        2366: aload         128
        2368: aastore
        2369: dup
        2370: iconst_2
        2371: aload         127
        2373: aastore
        2374: dup
        2375: iconst_3
        2376: aload         126
        2378: aastore
        2379: dup
        2380: iconst_4
        2381: aload         125
        2383: aastore
        2384: dup
        2385: iconst_5
        2386: aload         124
        2388: aastore
        2389: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2392: astore        130
        2394: new           #272                // class ocaml_fn_77
        2397: dup
        2398: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2401: astore        131
        2403: new           #275                // class ocaml_fn_78
        2406: dup
        2407: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2410: astore        132
        2412: new           #278                // class ocaml_fn_79
        2415: dup
        2416: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2419: astore        133
        2421: new           #281                // class ocaml_fn_80
        2424: dup
        2425: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2428: astore        134
        2430: new           #284                // class ocaml_fn_81
        2433: dup
        2434: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2437: astore        135
        2439: new           #287                // class ocaml_fn_82
        2442: dup
        2443: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2446: astore        136
        2448: new           #290                // class ocaml_fn_83
        2451: dup
        2452: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2455: astore        137
        2457: new           #293                // class ocaml_fn_84
        2460: dup
        2461: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2464: astore        138
        2466: new           #296                // class ocaml_fn_85
        2469: dup
        2470: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2473: astore        139
        2475: new           #299                // class ocaml_fn_86
        2478: dup
        2479: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2482: astore        140
        2484: new           #302                // class ocaml_fn_87
        2487: dup
        2488: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2491: astore        141
        2493: new           #305                // class ocaml_fn_88
        2496: dup
        2497: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2500: astore        142
        2502: new           #308                // class ocaml_fn_89
        2505: dup
        2506: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2509: astore        143
        2511: new           #311                // class ocaml_fn_90
        2514: dup
        2515: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2518: astore        144
        2520: new           #314                // class ocaml_fn_91
        2523: dup
        2524: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2527: astore        145
        2529: new           #317                // class ocaml_fn_92
        2532: dup
        2533: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2536: astore        146
        2538: new           #320                // class ocaml_fn_93
        2541: dup
        2542: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2545: astore        147
        2547: new           #14                 // class Block
        2550: dup
        2551: iconst_0
        2552: bipush        104
        2554: anewarray     #16                 // class java/lang/Object
        2557: dup
        2558: iconst_0
        2559: aload         18
        2561: aastore
        2562: dup
        2563: iconst_1
        2564: aload         17
        2566: aastore
        2567: dup
        2568: iconst_2
        2569: aload         22
        2571: aastore
        2572: dup
        2573: iconst_3
        2574: aload         23
        2576: aastore
        2577: dup
        2578: iconst_4
        2579: aload         24
        2581: aastore
        2582: dup
        2583: iconst_5
        2584: aload         25
        2586: aastore
        2587: dup
        2588: bipush        6
        2590: aload         26
        2592: aastore
        2593: dup
        2594: bipush        7
        2596: aload         27
        2598: aastore
        2599: dup
        2600: bipush        8
        2602: aload         28
        2604: aastore
        2605: dup
        2606: bipush        9
        2608: aload         29
        2610: aastore
        2611: dup
        2612: bipush        10
        2614: aload         30
        2616: aastore
        2617: dup
        2618: bipush        11
        2620: aload         31
        2622: aastore
        2623: dup
        2624: bipush        12
        2626: aload         32
        2628: aastore
        2629: dup
        2630: bipush        13
        2632: aload         33
        2634: aastore
        2635: dup
        2636: bipush        14
        2638: aload         34
        2640: aastore
        2641: dup
        2642: bipush        15
        2644: aload         35
        2646: aastore
        2647: dup
        2648: bipush        16
        2650: aload         36
        2652: aastore
        2653: dup
        2654: bipush        17
        2656: aload         37
        2658: aastore
        2659: dup
        2660: bipush        18
        2662: iload         39
        2664: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2667: aastore
        2668: dup
        2669: bipush        19
        2671: iload         40
        2673: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2676: aastore
        2677: dup
        2678: bipush        20
        2680: aload         38
        2682: aastore
        2683: dup
        2684: bipush        21
        2686: aload         42
        2688: aastore
        2689: dup
        2690: bipush        22
        2692: aload         44
        2694: aastore
        2695: dup
        2696: bipush        23
        2698: aload         46
        2700: aastore
        2701: dup
        2702: bipush        24
        2704: aload         48
        2706: aastore
        2707: dup
        2708: bipush        25
        2710: aload         50
        2712: aastore
        2713: dup
        2714: bipush        26
        2716: aload         52
        2718: aastore
        2719: dup
        2720: bipush        27
        2722: aload         53
        2724: aastore
        2725: dup
        2726: bipush        28
        2728: aload         54
        2730: aastore
        2731: dup
        2732: bipush        29
        2734: aload         55
        2736: aastore
        2737: dup
        2738: bipush        30
        2740: aload         57
        2742: aastore
        2743: dup
        2744: bipush        31
        2746: aload         56
        2748: aastore
        2749: dup
        2750: bipush        32
        2752: aload         58
        2754: aastore
        2755: dup
        2756: bipush        33
        2758: aload         59
        2760: aastore
        2761: dup
        2762: bipush        34
        2764: aload         61
        2766: aastore
        2767: dup
        2768: bipush        35
        2770: aload         62
        2772: aastore
        2773: dup
        2774: bipush        36
        2776: aload         63
        2778: aastore
        2779: dup
        2780: bipush        37
        2782: aload         70
        2784: aastore
        2785: dup
        2786: bipush        38
        2788: aload         72
        2790: aastore
        2791: dup
        2792: bipush        39
        2794: aload         74
        2796: aastore
        2797: dup
        2798: bipush        40
        2800: aload         95
        2802: aastore
        2803: dup
        2804: bipush        41
        2806: aload         96
        2808: aastore
        2809: dup
        2810: bipush        42
        2812: aload         97
        2814: aastore
        2815: dup
        2816: bipush        43
        2818: aload         98
        2820: aastore
        2821: dup
        2822: bipush        44
        2824: aload         99
        2826: aastore
        2827: dup
        2828: bipush        45
        2830: aload         100
        2832: aastore
        2833: dup
        2834: bipush        46
        2836: aload         101
        2838: aastore
        2839: dup
        2840: bipush        47
        2842: aload         102
        2844: aastore
        2845: dup
        2846: bipush        48
        2848: aload         103
        2850: aastore
        2851: dup
        2852: bipush        49
        2854: aload         104
        2856: aastore
        2857: dup
        2858: bipush        50
        2860: aload         105
        2862: aastore
        2863: dup
        2864: bipush        51
        2866: aload         106
        2868: aastore
        2869: dup
        2870: bipush        52
        2872: aload         107
        2874: aastore
        2875: dup
        2876: bipush        53
        2878: aload         108
        2880: aastore
        2881: dup
        2882: bipush        54
        2884: aload         109
        2886: aastore
        2887: dup
        2888: bipush        55
        2890: aload         111
        2892: aastore
        2893: dup
        2894: bipush        56
        2896: aload         110
        2898: aastore
        2899: dup
        2900: bipush        57
        2902: aload         113
        2904: aastore
        2905: dup
        2906: bipush        58
        2908: aload         112
        2910: aastore
        2911: dup
        2912: bipush        59
        2914: aload         76
        2916: aastore
        2917: dup
        2918: bipush        60
        2920: aload         77
        2922: aastore
        2923: dup
        2924: bipush        61
        2926: aload         75
        2928: aastore
        2929: dup
        2930: bipush        62
        2932: aload         147
        2934: aastore
        2935: dup
        2936: bipush        63
        2938: aload         78
        2940: aastore
        2941: dup
        2942: bipush        64
        2944: aload         146
        2946: aastore
        2947: dup
        2948: bipush        65
        2950: aload         80
        2952: aastore
        2953: dup
        2954: bipush        66
        2956: aload         79
        2958: aastore
        2959: dup
        2960: bipush        67
        2962: aload         81
        2964: aastore
        2965: dup
        2966: bipush        68
        2968: aload         82
        2970: aastore
        2971: dup
        2972: bipush        69
        2974: aload         145
        2976: aastore
        2977: dup
        2978: bipush        70
        2980: aload         144
        2982: aastore
        2983: dup
        2984: bipush        71
        2986: aload         83
        2988: aastore
        2989: dup
        2990: bipush        72
        2992: aload         143
        2994: aastore
        2995: dup
        2996: bipush        73
        2998: aload         142
        3000: aastore
        3001: dup
        3002: bipush        74
        3004: aload         141
        3006: aastore
        3007: dup
        3008: bipush        75
        3010: aload         84
        3012: aastore
        3013: dup
        3014: bipush        76
        3016: aload         85
        3018: aastore
        3019: dup
        3020: bipush        77
        3022: aload         140
        3024: aastore
        3025: dup
        3026: bipush        78
        3028: aload         87
        3030: aastore
        3031: dup
        3032: bipush        79
        3034: aload         88
        3036: aastore
        3037: dup
        3038: bipush        80
        3040: aload         86
        3042: aastore
        3043: dup
        3044: bipush        81
        3046: aload         139
        3048: aastore
        3049: dup
        3050: bipush        82
        3052: aload         93
        3054: aastore
        3055: dup
        3056: bipush        83
        3058: aload         89
        3060: aastore
        3061: dup
        3062: bipush        84
        3064: aload         91
        3066: aastore
        3067: dup
        3068: bipush        85
        3070: aload         92
        3072: aastore
        3073: dup
        3074: bipush        86
        3076: aload         138
        3078: aastore
        3079: dup
        3080: bipush        87
        3082: aload         137
        3084: aastore
        3085: dup
        3086: bipush        88
        3088: aload         136
        3090: aastore
        3091: dup
        3092: bipush        89
        3094: aload         135
        3096: aastore
        3097: dup
        3098: bipush        90
        3100: aload         134
        3102: aastore
        3103: dup
        3104: bipush        91
        3106: aload         133
        3108: aastore
        3109: dup
        3110: bipush        92
        3112: aload         132
        3114: aastore
        3115: dup
        3116: bipush        93
        3118: aload         94
        3120: aastore
        3121: dup
        3122: bipush        94
        3124: aload         131
        3126: aastore
        3127: dup
        3128: bipush        95
        3130: aload         130
        3132: aastore
        3133: dup
        3134: bipush        96
        3136: aload         114
        3138: aastore
        3139: dup
        3140: bipush        97
        3142: aload         115
        3144: aastore
        3145: dup
        3146: bipush        98
        3148: aload         121
        3150: aastore
        3151: dup
        3152: bipush        99
        3154: aload         117
        3156: aastore
        3157: dup
        3158: bipush        100
        3160: aload         60
        3162: aastore
        3163: dup
        3164: bipush        101
        3166: aload         90
        3168: aastore
        3169: dup
        3170: bipush        102
        3172: aload         120
        3174: aastore
        3175: dup
        3176: bipush        103
        3178: aload         119
        3180: aastore
        3181: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3184: astore        148
        3186: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3189: bipush        45
        3191: aload         148
        3193: aastore
        3194: iconst_0
        3195: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3198: astore        149
        3200: bipush        8
        3202: istore        150
        3204: getstatic     #327                // Field java/lang/System.out:Ljava/io/PrintStream;
        3207: iload         150
        3209: invokevirtual #333                // Method java/io/PrintStream.println:(I)V
        3212: iconst_0
        3213: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3216: astore        151
        3218: new           #14                 // class Block
        3221: dup
        3222: iconst_0
        3223: iconst_0
        3224: anewarray     #16                 // class java/lang/Object
        3227: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3230: astore        152
        3232: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3235: bipush        46
        3237: aload         152
        3239: aastore
        3240: iconst_0
        3241: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3244: astore        153
        3246: iconst_0
        3247: istore        154
        3249: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3252: bipush        45
        3254: aaload
        3255: checkcast     #14                 // class Block
        3258: getfield      #336                // Field Block.fields:[Ljava/lang/Object;
        3261: bipush        102
        3263: aaload
        3264: astore        155
        3266: aload         155
        3268: checkcast     #98                 // class Closure
        3271: iload         154
        3273: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3276: invokevirtual #340                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3279: astore        156
        3281: new           #14                 // class Block
        3284: dup
        3285: iconst_0
        3286: iconst_0
        3287: anewarray     #16                 // class java/lang/Object
        3290: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3293: astore        157
        3295: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3298: bipush        47
        3300: aload         157
        3302: aastore
        3303: iconst_0
        3304: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3307: astore        158
        3309: return
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
          25: ldc_w         #349                // String Out_of_memory
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
          57: ldc_w         #351                // String Sys_error
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
          90: ldc_w         #353                // String Failure
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
         123: ldc_w         #355                // String Invalid_argument
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
         156: ldc_w         #357                // String End_of_file
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
         189: ldc_w         #359                // String Division_by_zero
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
         223: ldc_w         #361                // String Not_found
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
         257: ldc_w         #363                // String Match_failure
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
         291: ldc_w         #365                // String Stack_overflow
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
         325: ldc_w         #367                // String Sys_blocked_io
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
         359: ldc_w         #369                // String Assert_failure
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
         393: ldc_w         #371                // String Undefined_recursive_module
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
         424: ldc_w         #373                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #375                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #377                // String input
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
         561: ldc_w         #379                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #381                // String output
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
         777: ldc_w         #383                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #385                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #387                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #389                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #391                // String true
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
         872: ldc_w         #389                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #391                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #393                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #391                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #389                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #395                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #397                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #399                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #401                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #402                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #402                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #403                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #404                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #405                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #406                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #408                // String Pervasives.do_at_exit
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
        1402: ldc           #50                 // int 2147483647
        1404: istore        39
        1406: ldc           #51                 // int -2147483648
        1408: istore        40
        1410: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1413: bipush        38
        1415: aaload
        1416: astore        41
        1418: ldc2_w        #52                 // double 0.0d
        1421: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1424: astore        42
        1426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1429: bipush        39
        1431: aaload
        1432: astore        43
        1434: ldc2_w        #52                 // double 0.0d
        1437: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1440: astore        44
        1442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1445: bipush        40
        1447: aaload
        1448: astore        45
        1450: ldc2_w        #52                 // double 0.0d
        1453: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1456: astore        46
        1458: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1461: bipush        41
        1463: aaload
        1464: astore        47
        1466: ldc2_w        #52                 // double 0.0d
        1469: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1472: astore        48
        1474: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1477: bipush        42
        1479: aaload
        1480: astore        49
        1482: ldc2_w        #52                 // double 0.0d
        1485: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1488: astore        50
        1490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1493: bipush        43
        1495: aaload
        1496: astore        51
        1498: ldc2_w        #52                 // double 0.0d
        1501: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1504: astore        52
        1506: new           #60                 // class ocaml_fn_14
        1509: dup
        1510: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1513: astore        53
        1515: new           #63                 // class ocaml_fn_15
        1518: dup
        1519: aload         18
        1521: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1524: astore        54
        1526: new           #68                 // class ocaml_fn_16
        1529: dup
        1530: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1533: astore        55
        1535: new           #71                 // class ocaml_fn_17
        1538: dup
        1539: aload         18
        1541: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1544: astore        56
        1546: new           #74                 // class ocaml_fn_18
        1549: dup
        1550: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1553: astore        57
        1555: new           #77                 // class ocaml_fn_19
        1558: dup
        1559: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1562: astore        58
        1564: new           #80                 // class ocaml_fn_20
        1567: dup
        1568: aload         26
        1570: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1573: astore        59
        1575: new           #83                 // class ocaml_fn_21
        1578: dup
        1579: aload         53
        1581: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1584: astore        60
        1586: new           #86                 // class ocaml_fn_22
        1589: dup
        1590: aload         60
        1592: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1595: astore        61
        1597: new           #89                 // class ocaml_fn_23
        1600: dup
        1601: aload         26
        1603: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1606: astore        62
        1608: new           #92                 // class ocaml_fn_24
        1611: dup
        1612: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1615: astore        63
        1617: new           #95                 // class ocaml_fn_25
        1620: dup
        1621: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1624: astore        64
        1626: aload         63
        1628: checkcast     #92                 // class ocaml_fn_24
        1631: aload         63
        1633: checkcast     #98                 // class Closure
        1636: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        65
        1645: aload         63
        1647: checkcast     #92                 // class ocaml_fn_24
        1650: aload         64
        1652: checkcast     #98                 // class Closure
        1655: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        66
        1664: aload         64
        1666: checkcast     #95                 // class ocaml_fn_25
        1669: aload         63
        1671: checkcast     #98                 // class Closure
        1674: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1677: iconst_0
        1678: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1681: astore        67
        1683: aload         64
        1685: checkcast     #95                 // class ocaml_fn_25
        1688: aload         64
        1690: checkcast     #98                 // class Closure
        1693: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1696: iconst_0
        1697: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1700: astore        68
        1702: iconst_0
        1703: istore        69
        1705: aconst_null
        1706: astore        70
        1708: iconst_1
        1709: istore        71
        1711: iload         71
        1713: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1716: astore        72
        1718: iconst_2
        1719: istore        73
        1721: iload         73
        1723: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1726: astore        74
        1728: new           #115                // class ocaml_fn_26
        1731: dup
        1732: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1735: astore        75
        1737: new           #118                // class ocaml_fn_27
        1740: dup
        1741: aload         75
        1743: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1746: astore        76
        1748: new           #121                // class ocaml_fn_28
        1751: dup
        1752: aload         75
        1754: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1757: astore        77
        1759: new           #124                // class ocaml_fn_29
        1762: dup
        1763: aload         30
        1765: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1768: astore        78
        1770: new           #127                // class ocaml_fn_30
        1773: dup
        1774: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1777: astore        79
        1779: new           #130                // class ocaml_fn_31
        1782: dup
        1783: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1786: astore        80
        1788: new           #133                // class ocaml_fn_32
        1791: dup
        1792: aload         18
        1794: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1797: astore        81
        1799: new           #136                // class ocaml_fn_33
        1802: dup
        1803: aload         18
        1805: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1808: astore        82
        1810: new           #139                // class ocaml_fn_34
        1813: dup
        1814: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1817: astore        83
        1819: new           #142                // class ocaml_fn_35
        1822: dup
        1823: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1826: astore        84
        1828: new           #145                // class ocaml_fn_36
        1831: dup
        1832: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1835: astore        85
        1837: new           #148                // class ocaml_fn_37
        1840: dup
        1841: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1844: astore        86
        1846: new           #151                // class ocaml_fn_38
        1849: dup
        1850: aload         86
        1852: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1855: astore        87
        1857: new           #154                // class ocaml_fn_39
        1860: dup
        1861: aload         86
        1863: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1866: astore        88
        1868: new           #157                // class ocaml_fn_40
        1871: dup
        1872: aload         18
        1874: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1877: astore        89
        1879: new           #160                // class ocaml_fn_41
        1882: dup
        1883: aload         31
        1885: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1888: astore        90
        1890: new           #163                // class ocaml_fn_42
        1893: dup
        1894: aload         18
        1896: aload         90
        1898: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1901: astore        91
        1903: new           #168                // class ocaml_fn_43
        1906: dup
        1907: aload         91
        1909: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1912: astore        92
        1914: new           #171                // class ocaml_fn_44
        1917: dup
        1918: aload         31
        1920: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1923: astore        93
        1925: new           #174                // class ocaml_fn_45
        1928: dup
        1929: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1932: astore        94
        1934: new           #177                // class ocaml_fn_46
        1937: dup
        1938: aload         72
        1940: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1943: astore        95
        1945: new           #180                // class ocaml_fn_47
        1948: dup
        1949: aload         72
        1951: aload         80
        1953: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1956: astore        96
        1958: new           #183                // class ocaml_fn_48
        1961: dup
        1962: aload         72
        1964: aload         79
        1966: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1969: astore        97
        1971: new           #186                // class ocaml_fn_49
        1974: dup
        1975: aload         58
        1977: aload         72
        1979: aload         80
        1981: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        98
        1986: new           #191                // class ocaml_fn_50
        1989: dup
        1990: aload         61
        1992: aload         72
        1994: aload         80
        1996: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        99
        2001: new           #194                // class ocaml_fn_51
        2004: dup
        2005: aload         72
        2007: aload         80
        2009: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        100
        2014: new           #197                // class ocaml_fn_52
        2017: dup
        2018: aload         72
        2020: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2023: astore        101
        2025: new           #200                // class ocaml_fn_53
        2028: dup
        2029: aload         74
        2031: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2034: astore        102
        2036: new           #203                // class ocaml_fn_54
        2039: dup
        2040: aload         74
        2042: aload         80
        2044: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        103
        2049: new           #206                // class ocaml_fn_55
        2052: dup
        2053: aload         74
        2055: aload         79
        2057: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        104
        2062: new           #209                // class ocaml_fn_56
        2065: dup
        2066: aload         58
        2068: aload         74
        2070: aload         80
        2072: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        105
        2077: new           #212                // class ocaml_fn_57
        2080: dup
        2081: aload         61
        2083: aload         74
        2085: aload         80
        2087: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        106
        2092: new           #215                // class ocaml_fn_58
        2095: dup
        2096: aload         74
        2098: aload         80
        2100: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        107
        2105: new           #218                // class ocaml_fn_59
        2108: dup
        2109: aload         74
        2111: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2114: astore        108
        2116: new           #221                // class ocaml_fn_60
        2119: dup
        2120: aload         70
        2122: aload         72
        2124: aload         93
        2126: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        109
        2131: new           #224                // class ocaml_fn_61
        2134: dup
        2135: aload         109
        2137: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2140: astore        110
        2142: new           #227                // class ocaml_fn_62
        2145: dup
        2146: aload         59
        2148: aload         109
        2150: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        111
        2155: new           #230                // class ocaml_fn_63
        2158: dup
        2159: aload         109
        2161: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2164: astore        112
        2166: new           #233                // class ocaml_fn_64
        2169: dup
        2170: aload         62
        2172: aload         109
        2174: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2177: astore        113
        2179: new           #236                // class ocaml_fn_65
        2182: dup
        2183: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2186: astore        114
        2188: new           #239                // class ocaml_fn_66
        2191: dup
        2192: aload         53
        2194: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2197: astore        115
        2199: new           #14                 // class Block
        2202: dup
        2203: iconst_0
        2204: iconst_1
        2205: anewarray     #16                 // class java/lang/Object
        2208: dup
        2209: iconst_0
        2210: aload         78
        2212: aastore
        2213: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2216: astore        116
        2218: new           #242                // class ocaml_fn_67
        2221: dup
        2222: aload         116
        2224: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2227: astore        117
        2229: new           #245                // class ocaml_fn_68
        2232: dup
        2233: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2236: astore        118
        2238: new           #14                 // class Block
        2241: dup
        2242: iconst_0
        2243: iconst_1
        2244: anewarray     #16                 // class java/lang/Object
        2247: dup
        2248: iconst_0
        2249: aload         118
        2251: aastore
        2252: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2255: astore        119
        2257: new           #248                // class ocaml_fn_69
        2260: dup
        2261: aload         116
        2263: aload         119
        2265: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2268: astore        120
        2270: new           #251                // class ocaml_fn_70
        2273: dup
        2274: aload         120
        2276: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2279: astore        121
        2281: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2284: bipush        44
        2286: aaload
        2287: astore        122
        2289: iconst_0
        2290: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2293: astore        123
        2295: new           #254                // class ocaml_fn_71
        2298: dup
        2299: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2302: astore        124
        2304: new           #257                // class ocaml_fn_72
        2307: dup
        2308: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2311: astore        125
        2313: new           #260                // class ocaml_fn_73
        2316: dup
        2317: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2320: astore        126
        2322: new           #263                // class ocaml_fn_74
        2325: dup
        2326: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2329: astore        127
        2331: new           #266                // class ocaml_fn_75
        2334: dup
        2335: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2338: astore        128
        2340: new           #269                // class ocaml_fn_76
        2343: dup
        2344: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2347: astore        129
        2349: new           #14                 // class Block
        2352: dup
        2353: iconst_0
        2354: bipush        6
        2356: anewarray     #16                 // class java/lang/Object
        2359: dup
        2360: iconst_0
        2361: aload         129
        2363: aastore
        2364: dup
        2365: iconst_1
        2366: aload         128
        2368: aastore
        2369: dup
        2370: iconst_2
        2371: aload         127
        2373: aastore
        2374: dup
        2375: iconst_3
        2376: aload         126
        2378: aastore
        2379: dup
        2380: iconst_4
        2381: aload         125
        2383: aastore
        2384: dup
        2385: iconst_5
        2386: aload         124
        2388: aastore
        2389: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2392: astore        130
        2394: new           #272                // class ocaml_fn_77
        2397: dup
        2398: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2401: astore        131
        2403: new           #275                // class ocaml_fn_78
        2406: dup
        2407: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2410: astore        132
        2412: new           #278                // class ocaml_fn_79
        2415: dup
        2416: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2419: astore        133
        2421: new           #281                // class ocaml_fn_80
        2424: dup
        2425: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2428: astore        134
        2430: new           #284                // class ocaml_fn_81
        2433: dup
        2434: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2437: astore        135
        2439: new           #287                // class ocaml_fn_82
        2442: dup
        2443: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2446: astore        136
        2448: new           #290                // class ocaml_fn_83
        2451: dup
        2452: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2455: astore        137
        2457: new           #293                // class ocaml_fn_84
        2460: dup
        2461: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2464: astore        138
        2466: new           #296                // class ocaml_fn_85
        2469: dup
        2470: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2473: astore        139
        2475: new           #299                // class ocaml_fn_86
        2478: dup
        2479: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2482: astore        140
        2484: new           #302                // class ocaml_fn_87
        2487: dup
        2488: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2491: astore        141
        2493: new           #305                // class ocaml_fn_88
        2496: dup
        2497: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2500: astore        142
        2502: new           #308                // class ocaml_fn_89
        2505: dup
        2506: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2509: astore        143
        2511: new           #311                // class ocaml_fn_90
        2514: dup
        2515: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2518: astore        144
        2520: new           #314                // class ocaml_fn_91
        2523: dup
        2524: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2527: astore        145
        2529: new           #317                // class ocaml_fn_92
        2532: dup
        2533: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2536: astore        146
        2538: new           #320                // class ocaml_fn_93
        2541: dup
        2542: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2545: astore        147
        2547: new           #14                 // class Block
        2550: dup
        2551: iconst_0
        2552: bipush        104
        2554: anewarray     #16                 // class java/lang/Object
        2557: dup
        2558: iconst_0
        2559: aload         18
        2561: aastore
        2562: dup
        2563: iconst_1
        2564: aload         17
        2566: aastore
        2567: dup
        2568: iconst_2
        2569: aload         22
        2571: aastore
        2572: dup
        2573: iconst_3
        2574: aload         23
        2576: aastore
        2577: dup
        2578: iconst_4
        2579: aload         24
        2581: aastore
        2582: dup
        2583: iconst_5
        2584: aload         25
        2586: aastore
        2587: dup
        2588: bipush        6
        2590: aload         26
        2592: aastore
        2593: dup
        2594: bipush        7
        2596: aload         27
        2598: aastore
        2599: dup
        2600: bipush        8
        2602: aload         28
        2604: aastore
        2605: dup
        2606: bipush        9
        2608: aload         29
        2610: aastore
        2611: dup
        2612: bipush        10
        2614: aload         30
        2616: aastore
        2617: dup
        2618: bipush        11
        2620: aload         31
        2622: aastore
        2623: dup
        2624: bipush        12
        2626: aload         32
        2628: aastore
        2629: dup
        2630: bipush        13
        2632: aload         33
        2634: aastore
        2635: dup
        2636: bipush        14
        2638: aload         34
        2640: aastore
        2641: dup
        2642: bipush        15
        2644: aload         35
        2646: aastore
        2647: dup
        2648: bipush        16
        2650: aload         36
        2652: aastore
        2653: dup
        2654: bipush        17
        2656: aload         37
        2658: aastore
        2659: dup
        2660: bipush        18
        2662: iload         39
        2664: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2667: aastore
        2668: dup
        2669: bipush        19
        2671: iload         40
        2673: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2676: aastore
        2677: dup
        2678: bipush        20
        2680: aload         38
        2682: aastore
        2683: dup
        2684: bipush        21
        2686: aload         42
        2688: aastore
        2689: dup
        2690: bipush        22
        2692: aload         44
        2694: aastore
        2695: dup
        2696: bipush        23
        2698: aload         46
        2700: aastore
        2701: dup
        2702: bipush        24
        2704: aload         48
        2706: aastore
        2707: dup
        2708: bipush        25
        2710: aload         50
        2712: aastore
        2713: dup
        2714: bipush        26
        2716: aload         52
        2718: aastore
        2719: dup
        2720: bipush        27
        2722: aload         53
        2724: aastore
        2725: dup
        2726: bipush        28
        2728: aload         54
        2730: aastore
        2731: dup
        2732: bipush        29
        2734: aload         55
        2736: aastore
        2737: dup
        2738: bipush        30
        2740: aload         57
        2742: aastore
        2743: dup
        2744: bipush        31
        2746: aload         56
        2748: aastore
        2749: dup
        2750: bipush        32
        2752: aload         58
        2754: aastore
        2755: dup
        2756: bipush        33
        2758: aload         59
        2760: aastore
        2761: dup
        2762: bipush        34
        2764: aload         61
        2766: aastore
        2767: dup
        2768: bipush        35
        2770: aload         62
        2772: aastore
        2773: dup
        2774: bipush        36
        2776: aload         63
        2778: aastore
        2779: dup
        2780: bipush        37
        2782: aload         70
        2784: aastore
        2785: dup
        2786: bipush        38
        2788: aload         72
        2790: aastore
        2791: dup
        2792: bipush        39
        2794: aload         74
        2796: aastore
        2797: dup
        2798: bipush        40
        2800: aload         95
        2802: aastore
        2803: dup
        2804: bipush        41
        2806: aload         96
        2808: aastore
        2809: dup
        2810: bipush        42
        2812: aload         97
        2814: aastore
        2815: dup
        2816: bipush        43
        2818: aload         98
        2820: aastore
        2821: dup
        2822: bipush        44
        2824: aload         99
        2826: aastore
        2827: dup
        2828: bipush        45
        2830: aload         100
        2832: aastore
        2833: dup
        2834: bipush        46
        2836: aload         101
        2838: aastore
        2839: dup
        2840: bipush        47
        2842: aload         102
        2844: aastore
        2845: dup
        2846: bipush        48
        2848: aload         103
        2850: aastore
        2851: dup
        2852: bipush        49
        2854: aload         104
        2856: aastore
        2857: dup
        2858: bipush        50
        2860: aload         105
        2862: aastore
        2863: dup
        2864: bipush        51
        2866: aload         106
        2868: aastore
        2869: dup
        2870: bipush        52
        2872: aload         107
        2874: aastore
        2875: dup
        2876: bipush        53
        2878: aload         108
        2880: aastore
        2881: dup
        2882: bipush        54
        2884: aload         109
        2886: aastore
        2887: dup
        2888: bipush        55
        2890: aload         111
        2892: aastore
        2893: dup
        2894: bipush        56
        2896: aload         110
        2898: aastore
        2899: dup
        2900: bipush        57
        2902: aload         113
        2904: aastore
        2905: dup
        2906: bipush        58
        2908: aload         112
        2910: aastore
        2911: dup
        2912: bipush        59
        2914: aload         76
        2916: aastore
        2917: dup
        2918: bipush        60
        2920: aload         77
        2922: aastore
        2923: dup
        2924: bipush        61
        2926: aload         75
        2928: aastore
        2929: dup
        2930: bipush        62
        2932: aload         147
        2934: aastore
        2935: dup
        2936: bipush        63
        2938: aload         78
        2940: aastore
        2941: dup
        2942: bipush        64
        2944: aload         146
        2946: aastore
        2947: dup
        2948: bipush        65
        2950: aload         80
        2952: aastore
        2953: dup
        2954: bipush        66
        2956: aload         79
        2958: aastore
        2959: dup
        2960: bipush        67
        2962: aload         81
        2964: aastore
        2965: dup
        2966: bipush        68
        2968: aload         82
        2970: aastore
        2971: dup
        2972: bipush        69
        2974: aload         145
        2976: aastore
        2977: dup
        2978: bipush        70
        2980: aload         144
        2982: aastore
        2983: dup
        2984: bipush        71
        2986: aload         83
        2988: aastore
        2989: dup
        2990: bipush        72
        2992: aload         143
        2994: aastore
        2995: dup
        2996: bipush        73
        2998: aload         142
        3000: aastore
        3001: dup
        3002: bipush        74
        3004: aload         141
        3006: aastore
        3007: dup
        3008: bipush        75
        3010: aload         84
        3012: aastore
        3013: dup
        3014: bipush        76
        3016: aload         85
        3018: aastore
        3019: dup
        3020: bipush        77
        3022: aload         140
        3024: aastore
        3025: dup
        3026: bipush        78
        3028: aload         87
        3030: aastore
        3031: dup
        3032: bipush        79
        3034: aload         88
        3036: aastore
        3037: dup
        3038: bipush        80
        3040: aload         86
        3042: aastore
        3043: dup
        3044: bipush        81
        3046: aload         139
        3048: aastore
        3049: dup
        3050: bipush        82
        3052: aload         93
        3054: aastore
        3055: dup
        3056: bipush        83
        3058: aload         89
        3060: aastore
        3061: dup
        3062: bipush        84
        3064: aload         91
        3066: aastore
        3067: dup
        3068: bipush        85
        3070: aload         92
        3072: aastore
        3073: dup
        3074: bipush        86
        3076: aload         138
        3078: aastore
        3079: dup
        3080: bipush        87
        3082: aload         137
        3084: aastore
        3085: dup
        3086: bipush        88
        3088: aload         136
        3090: aastore
        3091: dup
        3092: bipush        89
        3094: aload         135
        3096: aastore
        3097: dup
        3098: bipush        90
        3100: aload         134
        3102: aastore
        3103: dup
        3104: bipush        91
        3106: aload         133
        3108: aastore
        3109: dup
        3110: bipush        92
        3112: aload         132
        3114: aastore
        3115: dup
        3116: bipush        93
        3118: aload         94
        3120: aastore
        3121: dup
        3122: bipush        94
        3124: aload         131
        3126: aastore
        3127: dup
        3128: bipush        95
        3130: aload         130
        3132: aastore
        3133: dup
        3134: bipush        96
        3136: aload         114
        3138: aastore
        3139: dup
        3140: bipush        97
        3142: aload         115
        3144: aastore
        3145: dup
        3146: bipush        98
        3148: aload         121
        3150: aastore
        3151: dup
        3152: bipush        99
        3154: aload         117
        3156: aastore
        3157: dup
        3158: bipush        100
        3160: aload         60
        3162: aastore
        3163: dup
        3164: bipush        101
        3166: aload         90
        3168: aastore
        3169: dup
        3170: bipush        102
        3172: aload         120
        3174: aastore
        3175: dup
        3176: bipush        103
        3178: aload         119
        3180: aastore
        3181: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3184: astore        148
        3186: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3189: bipush        45
        3191: aload         148
        3193: aastore
        3194: iconst_0
        3195: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3198: astore        149
        3200: iconst_0
        3201: istore        150
        3203: iload         150
        3205: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3208: astore        151
        3210: goto_w        3215
        3215: new           #323                // class ocaml_fn_95
        3218: dup
        3219: invokespecial #324                // Method ocaml_fn_95."<init>":()V
        3222: astore        152
        3224: bipush        10
        3226: istore        153
        3228: aload         152
        3230: iload         153
        3232: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3235: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3238: astore        154
        3240: bipush        32
        3242: istore        155
        3244: aload         154
        3246: checkcast     #98                 // class Closure
        3249: iload         155
        3251: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3254: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3257: astore        156
        3259: getstatic     #334                // Field java/lang/System.out:Ljava/io/PrintStream;
        3262: aload         156
        3264: checkcast     #27                 // class java/lang/Integer
        3267: invokevirtual #338                // Method java/lang/Integer.intValue:()I
        3270: invokevirtual #344                // Method java/io/PrintStream.println:(I)V
        3273: iconst_0
        3274: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3277: astore        157
        3279: new           #14                 // class Block
        3282: dup
        3283: iconst_0
        3284: iconst_1
        3285: anewarray     #16                 // class java/lang/Object
        3288: dup
        3289: iconst_0
        3290: aload         152
        3292: aastore
        3293: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3296: astore        158
        3298: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3301: bipush        46
        3303: aload         158
        3305: aastore
        3306: iconst_0
        3307: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3310: astore        159
        3312: iconst_0
        3313: istore        160
        3315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3318: bipush        45
        3320: aaload
        3321: checkcast     #14                 // class Block
        3324: getfield      #347                // Field Block.fields:[Ljava/lang/Object;
        3327: bipush        102
        3329: aaload
        3330: astore        161
        3332: aload         161
        3334: checkcast     #98                 // class Closure
        3337: iload         160
        3339: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3342: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3345: astore        162
        3347: new           #14                 // class Block
        3350: dup
        3351: iconst_0
        3352: iconst_0
        3353: anewarray     #16                 // class java/lang/Object
        3356: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3359: astore        163
        3361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3364: bipush        47
        3366: aload         163
        3368: aastore
        3369: iconst_0
        3370: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3373: astore        164
        3375: return
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
          25: ldc_w         #349                // String Out_of_memory
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
          57: ldc_w         #351                // String Sys_error
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
          90: ldc_w         #353                // String Failure
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
         123: ldc_w         #355                // String Invalid_argument
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
         156: ldc_w         #357                // String End_of_file
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
         189: ldc_w         #359                // String Division_by_zero
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
         223: ldc_w         #361                // String Not_found
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
         257: ldc_w         #363                // String Match_failure
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
         291: ldc_w         #365                // String Stack_overflow
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
         325: ldc_w         #367                // String Sys_blocked_io
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
         359: ldc_w         #369                // String Assert_failure
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
         393: ldc_w         #371                // String Undefined_recursive_module
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
         424: ldc_w         #373                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #375                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #377                // String input
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
         561: ldc_w         #379                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #381                // String output
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
         777: ldc_w         #383                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #385                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #387                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #389                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #391                // String true
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
         872: ldc_w         #389                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #391                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #393                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #391                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #389                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #395                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #397                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #399                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #401                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #402                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #402                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #403                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #404                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #405                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #406                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #408                // String Pervasives.do_at_exit
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
        1428: ldc           #50                 // int 2147483647
        1430: istore        39
        1432: ldc           #51                 // int -2147483648
        1434: istore        40
        1436: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        38
        1441: aaload
        1442: astore        41
        1444: ldc2_w        #52                 // double 0.0d
        1447: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        42
        1452: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        39
        1457: aaload
        1458: astore        43
        1460: ldc2_w        #52                 // double 0.0d
        1463: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        44
        1468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1471: bipush        40
        1473: aaload
        1474: astore        45
        1476: ldc2_w        #52                 // double 0.0d
        1479: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1482: astore        46
        1484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1487: bipush        41
        1489: aaload
        1490: astore        47
        1492: ldc2_w        #52                 // double 0.0d
        1495: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1498: astore        48
        1500: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1503: bipush        42
        1505: aaload
        1506: astore        49
        1508: ldc2_w        #52                 // double 0.0d
        1511: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1514: astore        50
        1516: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1519: bipush        43
        1521: aaload
        1522: astore        51
        1524: ldc2_w        #52                 // double 0.0d
        1527: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1530: astore        52
        1532: new           #60                 // class ocaml_fn_14
        1535: dup
        1536: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1539: astore        53
        1541: new           #63                 // class ocaml_fn_15
        1544: dup
        1545: aload         18
        1547: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1550: astore        54
        1552: new           #68                 // class ocaml_fn_16
        1555: dup
        1556: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1559: astore        55
        1561: new           #71                 // class ocaml_fn_17
        1564: dup
        1565: aload         18
        1567: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1570: astore        56
        1572: new           #74                 // class ocaml_fn_18
        1575: dup
        1576: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1579: astore        57
        1581: new           #77                 // class ocaml_fn_19
        1584: dup
        1585: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1588: astore        58
        1590: new           #80                 // class ocaml_fn_20
        1593: dup
        1594: aload         26
        1596: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1599: astore        59
        1601: new           #83                 // class ocaml_fn_21
        1604: dup
        1605: aload         53
        1607: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1610: astore        60
        1612: new           #86                 // class ocaml_fn_22
        1615: dup
        1616: aload         60
        1618: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1621: astore        61
        1623: new           #89                 // class ocaml_fn_23
        1626: dup
        1627: aload         26
        1629: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1632: astore        62
        1634: new           #92                 // class ocaml_fn_24
        1637: dup
        1638: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1641: astore        63
        1643: new           #95                 // class ocaml_fn_25
        1646: dup
        1647: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1650: astore        64
        1652: aload         63
        1654: checkcast     #92                 // class ocaml_fn_24
        1657: aload         63
        1659: checkcast     #98                 // class Closure
        1662: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1665: iconst_0
        1666: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1669: astore        65
        1671: aload         63
        1673: checkcast     #92                 // class ocaml_fn_24
        1676: aload         64
        1678: checkcast     #98                 // class Closure
        1681: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1684: iconst_0
        1685: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1688: astore        66
        1690: aload         64
        1692: checkcast     #95                 // class ocaml_fn_25
        1695: aload         63
        1697: checkcast     #98                 // class Closure
        1700: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1703: iconst_0
        1704: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1707: astore        67
        1709: aload         64
        1711: checkcast     #95                 // class ocaml_fn_25
        1714: aload         64
        1716: checkcast     #98                 // class Closure
        1719: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1722: iconst_0
        1723: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1726: astore        68
        1728: iconst_0
        1729: istore        69
        1731: aconst_null
        1732: astore        70
        1734: iconst_1
        1735: istore        71
        1737: iload         71
        1739: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1742: astore        72
        1744: iconst_2
        1745: istore        73
        1747: iload         73
        1749: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1752: astore        74
        1754: new           #115                // class ocaml_fn_26
        1757: dup
        1758: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1761: astore        75
        1763: new           #118                // class ocaml_fn_27
        1766: dup
        1767: aload         75
        1769: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1772: astore        76
        1774: new           #121                // class ocaml_fn_28
        1777: dup
        1778: aload         75
        1780: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1783: astore        77
        1785: new           #124                // class ocaml_fn_29
        1788: dup
        1789: aload         30
        1791: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1794: astore        78
        1796: new           #127                // class ocaml_fn_30
        1799: dup
        1800: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1803: astore        79
        1805: new           #130                // class ocaml_fn_31
        1808: dup
        1809: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1812: astore        80
        1814: new           #133                // class ocaml_fn_32
        1817: dup
        1818: aload         18
        1820: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1823: astore        81
        1825: new           #136                // class ocaml_fn_33
        1828: dup
        1829: aload         18
        1831: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1834: astore        82
        1836: new           #139                // class ocaml_fn_34
        1839: dup
        1840: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1843: astore        83
        1845: new           #142                // class ocaml_fn_35
        1848: dup
        1849: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1852: astore        84
        1854: new           #145                // class ocaml_fn_36
        1857: dup
        1858: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1861: astore        85
        1863: new           #148                // class ocaml_fn_37
        1866: dup
        1867: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1870: astore        86
        1872: new           #151                // class ocaml_fn_38
        1875: dup
        1876: aload         86
        1878: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1881: astore        87
        1883: new           #154                // class ocaml_fn_39
        1886: dup
        1887: aload         86
        1889: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1892: astore        88
        1894: new           #157                // class ocaml_fn_40
        1897: dup
        1898: aload         18
        1900: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1903: astore        89
        1905: new           #160                // class ocaml_fn_41
        1908: dup
        1909: aload         31
        1911: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1914: astore        90
        1916: new           #163                // class ocaml_fn_42
        1919: dup
        1920: aload         18
        1922: aload         90
        1924: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        91
        1929: new           #168                // class ocaml_fn_43
        1932: dup
        1933: aload         91
        1935: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1938: astore        92
        1940: new           #171                // class ocaml_fn_44
        1943: dup
        1944: aload         31
        1946: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1949: astore        93
        1951: new           #174                // class ocaml_fn_45
        1954: dup
        1955: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1958: astore        94
        1960: new           #177                // class ocaml_fn_46
        1963: dup
        1964: aload         72
        1966: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1969: astore        95
        1971: new           #180                // class ocaml_fn_47
        1974: dup
        1975: aload         72
        1977: aload         80
        1979: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1982: astore        96
        1984: new           #183                // class ocaml_fn_48
        1987: dup
        1988: aload         72
        1990: aload         79
        1992: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1995: astore        97
        1997: new           #186                // class ocaml_fn_49
        2000: dup
        2001: aload         58
        2003: aload         72
        2005: aload         80
        2007: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2010: astore        98
        2012: new           #191                // class ocaml_fn_50
        2015: dup
        2016: aload         61
        2018: aload         72
        2020: aload         80
        2022: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2025: astore        99
        2027: new           #194                // class ocaml_fn_51
        2030: dup
        2031: aload         72
        2033: aload         80
        2035: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        100
        2040: new           #197                // class ocaml_fn_52
        2043: dup
        2044: aload         72
        2046: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2049: astore        101
        2051: new           #200                // class ocaml_fn_53
        2054: dup
        2055: aload         74
        2057: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2060: astore        102
        2062: new           #203                // class ocaml_fn_54
        2065: dup
        2066: aload         74
        2068: aload         80
        2070: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        103
        2075: new           #206                // class ocaml_fn_55
        2078: dup
        2079: aload         74
        2081: aload         79
        2083: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        104
        2088: new           #209                // class ocaml_fn_56
        2091: dup
        2092: aload         58
        2094: aload         74
        2096: aload         80
        2098: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        105
        2103: new           #212                // class ocaml_fn_57
        2106: dup
        2107: aload         61
        2109: aload         74
        2111: aload         80
        2113: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2116: astore        106
        2118: new           #215                // class ocaml_fn_58
        2121: dup
        2122: aload         74
        2124: aload         80
        2126: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        107
        2131: new           #218                // class ocaml_fn_59
        2134: dup
        2135: aload         74
        2137: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2140: astore        108
        2142: new           #221                // class ocaml_fn_60
        2145: dup
        2146: aload         70
        2148: aload         72
        2150: aload         93
        2152: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        109
        2157: new           #224                // class ocaml_fn_61
        2160: dup
        2161: aload         109
        2163: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2166: astore        110
        2168: new           #227                // class ocaml_fn_62
        2171: dup
        2172: aload         59
        2174: aload         109
        2176: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2179: astore        111
        2181: new           #230                // class ocaml_fn_63
        2184: dup
        2185: aload         109
        2187: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2190: astore        112
        2192: new           #233                // class ocaml_fn_64
        2195: dup
        2196: aload         62
        2198: aload         109
        2200: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2203: astore        113
        2205: new           #236                // class ocaml_fn_65
        2208: dup
        2209: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2212: astore        114
        2214: new           #239                // class ocaml_fn_66
        2217: dup
        2218: aload         53
        2220: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2223: astore        115
        2225: new           #14                 // class Block
        2228: dup
        2229: iconst_0
        2230: iconst_1
        2231: anewarray     #16                 // class java/lang/Object
        2234: dup
        2235: iconst_0
        2236: aload         78
        2238: aastore
        2239: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2242: astore        116
        2244: new           #242                // class ocaml_fn_67
        2247: dup
        2248: aload         116
        2250: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2253: astore        117
        2255: new           #245                // class ocaml_fn_68
        2258: dup
        2259: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2262: astore        118
        2264: new           #14                 // class Block
        2267: dup
        2268: iconst_0
        2269: iconst_1
        2270: anewarray     #16                 // class java/lang/Object
        2273: dup
        2274: iconst_0
        2275: aload         118
        2277: aastore
        2278: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2281: astore        119
        2283: new           #248                // class ocaml_fn_69
        2286: dup
        2287: aload         116
        2289: aload         119
        2291: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2294: astore        120
        2296: new           #251                // class ocaml_fn_70
        2299: dup
        2300: aload         120
        2302: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2305: astore        121
        2307: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2310: bipush        44
        2312: aaload
        2313: astore        122
        2315: iconst_0
        2316: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2319: astore        123
        2321: new           #254                // class ocaml_fn_71
        2324: dup
        2325: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2328: astore        124
        2330: new           #257                // class ocaml_fn_72
        2333: dup
        2334: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2337: astore        125
        2339: new           #260                // class ocaml_fn_73
        2342: dup
        2343: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2346: astore        126
        2348: new           #263                // class ocaml_fn_74
        2351: dup
        2352: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2355: astore        127
        2357: new           #266                // class ocaml_fn_75
        2360: dup
        2361: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2364: astore        128
        2366: new           #269                // class ocaml_fn_76
        2369: dup
        2370: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2373: astore        129
        2375: new           #14                 // class Block
        2378: dup
        2379: iconst_0
        2380: bipush        6
        2382: anewarray     #16                 // class java/lang/Object
        2385: dup
        2386: iconst_0
        2387: aload         129
        2389: aastore
        2390: dup
        2391: iconst_1
        2392: aload         128
        2394: aastore
        2395: dup
        2396: iconst_2
        2397: aload         127
        2399: aastore
        2400: dup
        2401: iconst_3
        2402: aload         126
        2404: aastore
        2405: dup
        2406: iconst_4
        2407: aload         125
        2409: aastore
        2410: dup
        2411: iconst_5
        2412: aload         124
        2414: aastore
        2415: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2418: astore        130
        2420: new           #272                // class ocaml_fn_77
        2423: dup
        2424: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2427: astore        131
        2429: new           #275                // class ocaml_fn_78
        2432: dup
        2433: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2436: astore        132
        2438: new           #278                // class ocaml_fn_79
        2441: dup
        2442: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2445: astore        133
        2447: new           #281                // class ocaml_fn_80
        2450: dup
        2451: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2454: astore        134
        2456: new           #284                // class ocaml_fn_81
        2459: dup
        2460: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2463: astore        135
        2465: new           #287                // class ocaml_fn_82
        2468: dup
        2469: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2472: astore        136
        2474: new           #290                // class ocaml_fn_83
        2477: dup
        2478: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2481: astore        137
        2483: new           #293                // class ocaml_fn_84
        2486: dup
        2487: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2490: astore        138
        2492: new           #296                // class ocaml_fn_85
        2495: dup
        2496: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2499: astore        139
        2501: new           #299                // class ocaml_fn_86
        2504: dup
        2505: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2508: astore        140
        2510: new           #302                // class ocaml_fn_87
        2513: dup
        2514: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2517: astore        141
        2519: new           #305                // class ocaml_fn_88
        2522: dup
        2523: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2526: astore        142
        2528: new           #308                // class ocaml_fn_89
        2531: dup
        2532: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2535: astore        143
        2537: new           #311                // class ocaml_fn_90
        2540: dup
        2541: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2544: astore        144
        2546: new           #314                // class ocaml_fn_91
        2549: dup
        2550: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2553: astore        145
        2555: new           #317                // class ocaml_fn_92
        2558: dup
        2559: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2562: astore        146
        2564: new           #320                // class ocaml_fn_93
        2567: dup
        2568: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2571: astore        147
        2573: new           #14                 // class Block
        2576: dup
        2577: iconst_0
        2578: bipush        104
        2580: anewarray     #16                 // class java/lang/Object
        2583: dup
        2584: iconst_0
        2585: aload         18
        2587: aastore
        2588: dup
        2589: iconst_1
        2590: aload         17
        2592: aastore
        2593: dup
        2594: iconst_2
        2595: aload         22
        2597: aastore
        2598: dup
        2599: iconst_3
        2600: aload         23
        2602: aastore
        2603: dup
        2604: iconst_4
        2605: aload         24
        2607: aastore
        2608: dup
        2609: iconst_5
        2610: aload         25
        2612: aastore
        2613: dup
        2614: bipush        6
        2616: aload         26
        2618: aastore
        2619: dup
        2620: bipush        7
        2622: aload         27
        2624: aastore
        2625: dup
        2626: bipush        8
        2628: aload         28
        2630: aastore
        2631: dup
        2632: bipush        9
        2634: aload         29
        2636: aastore
        2637: dup
        2638: bipush        10
        2640: aload         30
        2642: aastore
        2643: dup
        2644: bipush        11
        2646: aload         31
        2648: aastore
        2649: dup
        2650: bipush        12
        2652: aload         32
        2654: aastore
        2655: dup
        2656: bipush        13
        2658: aload         33
        2660: aastore
        2661: dup
        2662: bipush        14
        2664: aload         34
        2666: aastore
        2667: dup
        2668: bipush        15
        2670: aload         35
        2672: aastore
        2673: dup
        2674: bipush        16
        2676: aload         36
        2678: aastore
        2679: dup
        2680: bipush        17
        2682: aload         37
        2684: aastore
        2685: dup
        2686: bipush        18
        2688: iload         39
        2690: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2693: aastore
        2694: dup
        2695: bipush        19
        2697: iload         40
        2699: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2702: aastore
        2703: dup
        2704: bipush        20
        2706: aload         38
        2708: aastore
        2709: dup
        2710: bipush        21
        2712: aload         42
        2714: aastore
        2715: dup
        2716: bipush        22
        2718: aload         44
        2720: aastore
        2721: dup
        2722: bipush        23
        2724: aload         46
        2726: aastore
        2727: dup
        2728: bipush        24
        2730: aload         48
        2732: aastore
        2733: dup
        2734: bipush        25
        2736: aload         50
        2738: aastore
        2739: dup
        2740: bipush        26
        2742: aload         52
        2744: aastore
        2745: dup
        2746: bipush        27
        2748: aload         53
        2750: aastore
        2751: dup
        2752: bipush        28
        2754: aload         54
        2756: aastore
        2757: dup
        2758: bipush        29
        2760: aload         55
        2762: aastore
        2763: dup
        2764: bipush        30
        2766: aload         57
        2768: aastore
        2769: dup
        2770: bipush        31
        2772: aload         56
        2774: aastore
        2775: dup
        2776: bipush        32
        2778: aload         58
        2780: aastore
        2781: dup
        2782: bipush        33
        2784: aload         59
        2786: aastore
        2787: dup
        2788: bipush        34
        2790: aload         61
        2792: aastore
        2793: dup
        2794: bipush        35
        2796: aload         62
        2798: aastore
        2799: dup
        2800: bipush        36
        2802: aload         63
        2804: aastore
        2805: dup
        2806: bipush        37
        2808: aload         70
        2810: aastore
        2811: dup
        2812: bipush        38
        2814: aload         72
        2816: aastore
        2817: dup
        2818: bipush        39
        2820: aload         74
        2822: aastore
        2823: dup
        2824: bipush        40
        2826: aload         95
        2828: aastore
        2829: dup
        2830: bipush        41
        2832: aload         96
        2834: aastore
        2835: dup
        2836: bipush        42
        2838: aload         97
        2840: aastore
        2841: dup
        2842: bipush        43
        2844: aload         98
        2846: aastore
        2847: dup
        2848: bipush        44
        2850: aload         99
        2852: aastore
        2853: dup
        2854: bipush        45
        2856: aload         100
        2858: aastore
        2859: dup
        2860: bipush        46
        2862: aload         101
        2864: aastore
        2865: dup
        2866: bipush        47
        2868: aload         102
        2870: aastore
        2871: dup
        2872: bipush        48
        2874: aload         103
        2876: aastore
        2877: dup
        2878: bipush        49
        2880: aload         104
        2882: aastore
        2883: dup
        2884: bipush        50
        2886: aload         105
        2888: aastore
        2889: dup
        2890: bipush        51
        2892: aload         106
        2894: aastore
        2895: dup
        2896: bipush        52
        2898: aload         107
        2900: aastore
        2901: dup
        2902: bipush        53
        2904: aload         108
        2906: aastore
        2907: dup
        2908: bipush        54
        2910: aload         109
        2912: aastore
        2913: dup
        2914: bipush        55
        2916: aload         111
        2918: aastore
        2919: dup
        2920: bipush        56
        2922: aload         110
        2924: aastore
        2925: dup
        2926: bipush        57
        2928: aload         113
        2930: aastore
        2931: dup
        2932: bipush        58
        2934: aload         112
        2936: aastore
        2937: dup
        2938: bipush        59
        2940: aload         76
        2942: aastore
        2943: dup
        2944: bipush        60
        2946: aload         77
        2948: aastore
        2949: dup
        2950: bipush        61
        2952: aload         75
        2954: aastore
        2955: dup
        2956: bipush        62
        2958: aload         147
        2960: aastore
        2961: dup
        2962: bipush        63
        2964: aload         78
        2966: aastore
        2967: dup
        2968: bipush        64
        2970: aload         146
        2972: aastore
        2973: dup
        2974: bipush        65
        2976: aload         80
        2978: aastore
        2979: dup
        2980: bipush        66
        2982: aload         79
        2984: aastore
        2985: dup
        2986: bipush        67
        2988: aload         81
        2990: aastore
        2991: dup
        2992: bipush        68
        2994: aload         82
        2996: aastore
        2997: dup
        2998: bipush        69
        3000: aload         145
        3002: aastore
        3003: dup
        3004: bipush        70
        3006: aload         144
        3008: aastore
        3009: dup
        3010: bipush        71
        3012: aload         83
        3014: aastore
        3015: dup
        3016: bipush        72
        3018: aload         143
        3020: aastore
        3021: dup
        3022: bipush        73
        3024: aload         142
        3026: aastore
        3027: dup
        3028: bipush        74
        3030: aload         141
        3032: aastore
        3033: dup
        3034: bipush        75
        3036: aload         84
        3038: aastore
        3039: dup
        3040: bipush        76
        3042: aload         85
        3044: aastore
        3045: dup
        3046: bipush        77
        3048: aload         140
        3050: aastore
        3051: dup
        3052: bipush        78
        3054: aload         87
        3056: aastore
        3057: dup
        3058: bipush        79
        3060: aload         88
        3062: aastore
        3063: dup
        3064: bipush        80
        3066: aload         86
        3068: aastore
        3069: dup
        3070: bipush        81
        3072: aload         139
        3074: aastore
        3075: dup
        3076: bipush        82
        3078: aload         93
        3080: aastore
        3081: dup
        3082: bipush        83
        3084: aload         89
        3086: aastore
        3087: dup
        3088: bipush        84
        3090: aload         91
        3092: aastore
        3093: dup
        3094: bipush        85
        3096: aload         92
        3098: aastore
        3099: dup
        3100: bipush        86
        3102: aload         138
        3104: aastore
        3105: dup
        3106: bipush        87
        3108: aload         137
        3110: aastore
        3111: dup
        3112: bipush        88
        3114: aload         136
        3116: aastore
        3117: dup
        3118: bipush        89
        3120: aload         135
        3122: aastore
        3123: dup
        3124: bipush        90
        3126: aload         134
        3128: aastore
        3129: dup
        3130: bipush        91
        3132: aload         133
        3134: aastore
        3135: dup
        3136: bipush        92
        3138: aload         132
        3140: aastore
        3141: dup
        3142: bipush        93
        3144: aload         94
        3146: aastore
        3147: dup
        3148: bipush        94
        3150: aload         131
        3152: aastore
        3153: dup
        3154: bipush        95
        3156: aload         130
        3158: aastore
        3159: dup
        3160: bipush        96
        3162: aload         114
        3164: aastore
        3165: dup
        3166: bipush        97
        3168: aload         115
        3170: aastore
        3171: dup
        3172: bipush        98
        3174: aload         121
        3176: aastore
        3177: dup
        3178: bipush        99
        3180: aload         117
        3182: aastore
        3183: dup
        3184: bipush        100
        3186: aload         60
        3188: aastore
        3189: dup
        3190: bipush        101
        3192: aload         90
        3194: aastore
        3195: dup
        3196: bipush        102
        3198: aload         120
        3200: aastore
        3201: dup
        3202: bipush        103
        3204: aload         119
        3206: aastore
        3207: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3210: astore        148
        3212: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3215: bipush        45
        3217: aload         148
        3219: aastore
        3220: iconst_0
        3221: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3224: astore        149
        3226: iconst_0
        3227: istore        150
        3229: iload         150
        3231: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3234: astore        151
        3236: goto_w        3241
        3241: new           #323                // class ocaml_fn_94
        3244: dup
        3245: invokespecial #324                // Method ocaml_fn_94."<init>":()V
        3248: astore        152
        3250: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3253: bipush        46
        3255: aaload
        3256: astore        153
        3258: aload         152
        3260: aload         153
        3262: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3265: astore        154
        3267: getstatic     #334                // Field java/lang/System.out:Ljava/io/PrintStream;
        3270: aload         154
        3272: checkcast     #27                 // class java/lang/Integer
        3275: invokevirtual #338                // Method java/lang/Integer.intValue:()I
        3278: invokevirtual #344                // Method java/io/PrintStream.println:(I)V
        3281: iconst_0
        3282: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3285: astore        155
        3287: new           #14                 // class Block
        3290: dup
        3291: iconst_0
        3292: iconst_1
        3293: anewarray     #16                 // class java/lang/Object
        3296: dup
        3297: iconst_0
        3298: aload         152
        3300: aastore
        3301: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3304: astore        156
        3306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3309: bipush        47
        3311: aload         156
        3313: aastore
        3314: iconst_0
        3315: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3318: astore        157
        3320: iconst_0
        3321: istore        158
        3323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3326: bipush        45
        3328: aaload
        3329: checkcast     #14                 // class Block
        3332: getfield      #347                // Field Block.fields:[Ljava/lang/Object;
        3335: bipush        102
        3337: aaload
        3338: astore        159
        3340: aload         159
        3342: checkcast     #98                 // class Closure
        3345: iload         158
        3347: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3350: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3353: astore        160
        3355: new           #14                 // class Block
        3358: dup
        3359: iconst_0
        3360: iconst_0
        3361: anewarray     #16                 // class java/lang/Object
        3364: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3367: astore        161
        3369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3372: bipush        48
        3374: aload         161
        3376: aastore
        3377: iconst_0
        3378: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3381: astore        162
        3383: return
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
          25: ldc_w         #349                // String Out_of_memory
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
          57: ldc_w         #351                // String Sys_error
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
          90: ldc_w         #353                // String Failure
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
         123: ldc_w         #355                // String Invalid_argument
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
         156: ldc_w         #357                // String End_of_file
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
         189: ldc_w         #359                // String Division_by_zero
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
         223: ldc_w         #361                // String Not_found
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
         257: ldc_w         #363                // String Match_failure
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
         291: ldc_w         #365                // String Stack_overflow
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
         325: ldc_w         #367                // String Sys_blocked_io
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
         359: ldc_w         #369                // String Assert_failure
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
         393: ldc_w         #371                // String Undefined_recursive_module
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
         424: ldc_w         #373                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #375                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #377                // String input
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
         561: ldc_w         #379                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #381                // String output
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
         777: ldc_w         #383                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #385                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #387                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #389                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #391                // String true
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
         872: ldc_w         #389                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #391                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #393                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #391                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #389                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #395                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #397                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #399                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #401                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #402                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #402                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #403                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #404                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #405                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #406                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #408                // String Pervasives.do_at_exit
        1028: aastore
        1029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1032: bipush        45
        1034: iconst_0
        1035: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1038: aastore
        1039: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1042: bipush        46
        1044: ldc_w         #410                // String Test.Oops
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
        1411: ldc           #50                 // int 2147483647
        1413: istore        39
        1415: ldc           #51                 // int -2147483648
        1417: istore        40
        1419: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1422: bipush        38
        1424: aaload
        1425: astore        41
        1427: ldc2_w        #52                 // double 0.0d
        1430: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1433: astore        42
        1435: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1438: bipush        39
        1440: aaload
        1441: astore        43
        1443: ldc2_w        #52                 // double 0.0d
        1446: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1449: astore        44
        1451: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1454: bipush        40
        1456: aaload
        1457: astore        45
        1459: ldc2_w        #52                 // double 0.0d
        1462: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1465: astore        46
        1467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1470: bipush        41
        1472: aaload
        1473: astore        47
        1475: ldc2_w        #52                 // double 0.0d
        1478: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1481: astore        48
        1483: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1486: bipush        42
        1488: aaload
        1489: astore        49
        1491: ldc2_w        #52                 // double 0.0d
        1494: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1497: astore        50
        1499: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1502: bipush        43
        1504: aaload
        1505: astore        51
        1507: ldc2_w        #52                 // double 0.0d
        1510: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1513: astore        52
        1515: new           #60                 // class ocaml_fn_14
        1518: dup
        1519: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1522: astore        53
        1524: new           #63                 // class ocaml_fn_15
        1527: dup
        1528: aload         18
        1530: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1533: astore        54
        1535: new           #68                 // class ocaml_fn_16
        1538: dup
        1539: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1542: astore        55
        1544: new           #71                 // class ocaml_fn_17
        1547: dup
        1548: aload         18
        1550: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1553: astore        56
        1555: new           #74                 // class ocaml_fn_18
        1558: dup
        1559: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1562: astore        57
        1564: new           #77                 // class ocaml_fn_19
        1567: dup
        1568: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1571: astore        58
        1573: new           #80                 // class ocaml_fn_20
        1576: dup
        1577: aload         26
        1579: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1582: astore        59
        1584: new           #83                 // class ocaml_fn_21
        1587: dup
        1588: aload         53
        1590: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1593: astore        60
        1595: new           #86                 // class ocaml_fn_22
        1598: dup
        1599: aload         60
        1601: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1604: astore        61
        1606: new           #89                 // class ocaml_fn_23
        1609: dup
        1610: aload         26
        1612: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1615: astore        62
        1617: new           #92                 // class ocaml_fn_24
        1620: dup
        1621: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1624: astore        63
        1626: new           #95                 // class ocaml_fn_25
        1629: dup
        1630: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1633: astore        64
        1635: aload         63
        1637: checkcast     #92                 // class ocaml_fn_24
        1640: aload         63
        1642: checkcast     #98                 // class Closure
        1645: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1648: iconst_0
        1649: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1652: astore        65
        1654: aload         63
        1656: checkcast     #92                 // class ocaml_fn_24
        1659: aload         64
        1661: checkcast     #98                 // class Closure
        1664: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1667: iconst_0
        1668: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1671: astore        66
        1673: aload         64
        1675: checkcast     #95                 // class ocaml_fn_25
        1678: aload         63
        1680: checkcast     #98                 // class Closure
        1683: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1686: iconst_0
        1687: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1690: astore        67
        1692: aload         64
        1694: checkcast     #95                 // class ocaml_fn_25
        1697: aload         64
        1699: checkcast     #98                 // class Closure
        1702: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1705: iconst_0
        1706: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1709: astore        68
        1711: iconst_0
        1712: istore        69
        1714: aconst_null
        1715: astore        70
        1717: iconst_1
        1718: istore        71
        1720: iload         71
        1722: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1725: astore        72
        1727: iconst_2
        1728: istore        73
        1730: iload         73
        1732: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1735: astore        74
        1737: new           #115                // class ocaml_fn_26
        1740: dup
        1741: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1744: astore        75
        1746: new           #118                // class ocaml_fn_27
        1749: dup
        1750: aload         75
        1752: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1755: astore        76
        1757: new           #121                // class ocaml_fn_28
        1760: dup
        1761: aload         75
        1763: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1766: astore        77
        1768: new           #124                // class ocaml_fn_29
        1771: dup
        1772: aload         30
        1774: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1777: astore        78
        1779: new           #127                // class ocaml_fn_30
        1782: dup
        1783: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1786: astore        79
        1788: new           #130                // class ocaml_fn_31
        1791: dup
        1792: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1795: astore        80
        1797: new           #133                // class ocaml_fn_32
        1800: dup
        1801: aload         18
        1803: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1806: astore        81
        1808: new           #136                // class ocaml_fn_33
        1811: dup
        1812: aload         18
        1814: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1817: astore        82
        1819: new           #139                // class ocaml_fn_34
        1822: dup
        1823: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1826: astore        83
        1828: new           #142                // class ocaml_fn_35
        1831: dup
        1832: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1835: astore        84
        1837: new           #145                // class ocaml_fn_36
        1840: dup
        1841: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1844: astore        85
        1846: new           #148                // class ocaml_fn_37
        1849: dup
        1850: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1853: astore        86
        1855: new           #151                // class ocaml_fn_38
        1858: dup
        1859: aload         86
        1861: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1864: astore        87
        1866: new           #154                // class ocaml_fn_39
        1869: dup
        1870: aload         86
        1872: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1875: astore        88
        1877: new           #157                // class ocaml_fn_40
        1880: dup
        1881: aload         18
        1883: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1886: astore        89
        1888: new           #160                // class ocaml_fn_41
        1891: dup
        1892: aload         31
        1894: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1897: astore        90
        1899: new           #163                // class ocaml_fn_42
        1902: dup
        1903: aload         18
        1905: aload         90
        1907: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        91
        1912: new           #168                // class ocaml_fn_43
        1915: dup
        1916: aload         91
        1918: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1921: astore        92
        1923: new           #171                // class ocaml_fn_44
        1926: dup
        1927: aload         31
        1929: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1932: astore        93
        1934: new           #174                // class ocaml_fn_45
        1937: dup
        1938: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1941: astore        94
        1943: new           #177                // class ocaml_fn_46
        1946: dup
        1947: aload         72
        1949: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1952: astore        95
        1954: new           #180                // class ocaml_fn_47
        1957: dup
        1958: aload         72
        1960: aload         80
        1962: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1965: astore        96
        1967: new           #183                // class ocaml_fn_48
        1970: dup
        1971: aload         72
        1973: aload         79
        1975: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1978: astore        97
        1980: new           #186                // class ocaml_fn_49
        1983: dup
        1984: aload         58
        1986: aload         72
        1988: aload         80
        1990: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1993: astore        98
        1995: new           #191                // class ocaml_fn_50
        1998: dup
        1999: aload         61
        2001: aload         72
        2003: aload         80
        2005: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2008: astore        99
        2010: new           #194                // class ocaml_fn_51
        2013: dup
        2014: aload         72
        2016: aload         80
        2018: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        100
        2023: new           #197                // class ocaml_fn_52
        2026: dup
        2027: aload         72
        2029: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2032: astore        101
        2034: new           #200                // class ocaml_fn_53
        2037: dup
        2038: aload         74
        2040: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2043: astore        102
        2045: new           #203                // class ocaml_fn_54
        2048: dup
        2049: aload         74
        2051: aload         80
        2053: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2056: astore        103
        2058: new           #206                // class ocaml_fn_55
        2061: dup
        2062: aload         74
        2064: aload         79
        2066: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        104
        2071: new           #209                // class ocaml_fn_56
        2074: dup
        2075: aload         58
        2077: aload         74
        2079: aload         80
        2081: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2084: astore        105
        2086: new           #212                // class ocaml_fn_57
        2089: dup
        2090: aload         61
        2092: aload         74
        2094: aload         80
        2096: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        106
        2101: new           #215                // class ocaml_fn_58
        2104: dup
        2105: aload         74
        2107: aload         80
        2109: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        107
        2114: new           #218                // class ocaml_fn_59
        2117: dup
        2118: aload         74
        2120: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2123: astore        108
        2125: new           #221                // class ocaml_fn_60
        2128: dup
        2129: aload         70
        2131: aload         72
        2133: aload         93
        2135: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2138: astore        109
        2140: new           #224                // class ocaml_fn_61
        2143: dup
        2144: aload         109
        2146: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2149: astore        110
        2151: new           #227                // class ocaml_fn_62
        2154: dup
        2155: aload         59
        2157: aload         109
        2159: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2162: astore        111
        2164: new           #230                // class ocaml_fn_63
        2167: dup
        2168: aload         109
        2170: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2173: astore        112
        2175: new           #233                // class ocaml_fn_64
        2178: dup
        2179: aload         62
        2181: aload         109
        2183: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        113
        2188: new           #236                // class ocaml_fn_65
        2191: dup
        2192: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2195: astore        114
        2197: new           #239                // class ocaml_fn_66
        2200: dup
        2201: aload         53
        2203: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2206: astore        115
        2208: new           #14                 // class Block
        2211: dup
        2212: iconst_0
        2213: iconst_1
        2214: anewarray     #16                 // class java/lang/Object
        2217: dup
        2218: iconst_0
        2219: aload         78
        2221: aastore
        2222: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2225: astore        116
        2227: new           #242                // class ocaml_fn_67
        2230: dup
        2231: aload         116
        2233: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2236: astore        117
        2238: new           #245                // class ocaml_fn_68
        2241: dup
        2242: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2245: astore        118
        2247: new           #14                 // class Block
        2250: dup
        2251: iconst_0
        2252: iconst_1
        2253: anewarray     #16                 // class java/lang/Object
        2256: dup
        2257: iconst_0
        2258: aload         118
        2260: aastore
        2261: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2264: astore        119
        2266: new           #248                // class ocaml_fn_69
        2269: dup
        2270: aload         116
        2272: aload         119
        2274: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2277: astore        120
        2279: new           #251                // class ocaml_fn_70
        2282: dup
        2283: aload         120
        2285: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2288: astore        121
        2290: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2293: bipush        44
        2295: aaload
        2296: astore        122
        2298: iconst_0
        2299: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2302: astore        123
        2304: new           #254                // class ocaml_fn_71
        2307: dup
        2308: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2311: astore        124
        2313: new           #257                // class ocaml_fn_72
        2316: dup
        2317: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2320: astore        125
        2322: new           #260                // class ocaml_fn_73
        2325: dup
        2326: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2329: astore        126
        2331: new           #263                // class ocaml_fn_74
        2334: dup
        2335: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2338: astore        127
        2340: new           #266                // class ocaml_fn_75
        2343: dup
        2344: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2347: astore        128
        2349: new           #269                // class ocaml_fn_76
        2352: dup
        2353: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2356: astore        129
        2358: new           #14                 // class Block
        2361: dup
        2362: iconst_0
        2363: bipush        6
        2365: anewarray     #16                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         129
        2372: aastore
        2373: dup
        2374: iconst_1
        2375: aload         128
        2377: aastore
        2378: dup
        2379: iconst_2
        2380: aload         127
        2382: aastore
        2383: dup
        2384: iconst_3
        2385: aload         126
        2387: aastore
        2388: dup
        2389: iconst_4
        2390: aload         125
        2392: aastore
        2393: dup
        2394: iconst_5
        2395: aload         124
        2397: aastore
        2398: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2401: astore        130
        2403: new           #272                // class ocaml_fn_77
        2406: dup
        2407: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2410: astore        131
        2412: new           #275                // class ocaml_fn_78
        2415: dup
        2416: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2419: astore        132
        2421: new           #278                // class ocaml_fn_79
        2424: dup
        2425: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2428: astore        133
        2430: new           #281                // class ocaml_fn_80
        2433: dup
        2434: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2437: astore        134
        2439: new           #284                // class ocaml_fn_81
        2442: dup
        2443: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2446: astore        135
        2448: new           #287                // class ocaml_fn_82
        2451: dup
        2452: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2455: astore        136
        2457: new           #290                // class ocaml_fn_83
        2460: dup
        2461: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2464: astore        137
        2466: new           #293                // class ocaml_fn_84
        2469: dup
        2470: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2473: astore        138
        2475: new           #296                // class ocaml_fn_85
        2478: dup
        2479: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2482: astore        139
        2484: new           #299                // class ocaml_fn_86
        2487: dup
        2488: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2491: astore        140
        2493: new           #302                // class ocaml_fn_87
        2496: dup
        2497: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2500: astore        141
        2502: new           #305                // class ocaml_fn_88
        2505: dup
        2506: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2509: astore        142
        2511: new           #308                // class ocaml_fn_89
        2514: dup
        2515: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2518: astore        143
        2520: new           #311                // class ocaml_fn_90
        2523: dup
        2524: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2527: astore        144
        2529: new           #314                // class ocaml_fn_91
        2532: dup
        2533: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2536: astore        145
        2538: new           #317                // class ocaml_fn_92
        2541: dup
        2542: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2545: astore        146
        2547: new           #320                // class ocaml_fn_93
        2550: dup
        2551: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2554: astore        147
        2556: new           #14                 // class Block
        2559: dup
        2560: iconst_0
        2561: bipush        104
        2563: anewarray     #16                 // class java/lang/Object
        2566: dup
        2567: iconst_0
        2568: aload         18
        2570: aastore
        2571: dup
        2572: iconst_1
        2573: aload         17
        2575: aastore
        2576: dup
        2577: iconst_2
        2578: aload         22
        2580: aastore
        2581: dup
        2582: iconst_3
        2583: aload         23
        2585: aastore
        2586: dup
        2587: iconst_4
        2588: aload         24
        2590: aastore
        2591: dup
        2592: iconst_5
        2593: aload         25
        2595: aastore
        2596: dup
        2597: bipush        6
        2599: aload         26
        2601: aastore
        2602: dup
        2603: bipush        7
        2605: aload         27
        2607: aastore
        2608: dup
        2609: bipush        8
        2611: aload         28
        2613: aastore
        2614: dup
        2615: bipush        9
        2617: aload         29
        2619: aastore
        2620: dup
        2621: bipush        10
        2623: aload         30
        2625: aastore
        2626: dup
        2627: bipush        11
        2629: aload         31
        2631: aastore
        2632: dup
        2633: bipush        12
        2635: aload         32
        2637: aastore
        2638: dup
        2639: bipush        13
        2641: aload         33
        2643: aastore
        2644: dup
        2645: bipush        14
        2647: aload         34
        2649: aastore
        2650: dup
        2651: bipush        15
        2653: aload         35
        2655: aastore
        2656: dup
        2657: bipush        16
        2659: aload         36
        2661: aastore
        2662: dup
        2663: bipush        17
        2665: aload         37
        2667: aastore
        2668: dup
        2669: bipush        18
        2671: iload         39
        2673: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2676: aastore
        2677: dup
        2678: bipush        19
        2680: iload         40
        2682: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2685: aastore
        2686: dup
        2687: bipush        20
        2689: aload         38
        2691: aastore
        2692: dup
        2693: bipush        21
        2695: aload         42
        2697: aastore
        2698: dup
        2699: bipush        22
        2701: aload         44
        2703: aastore
        2704: dup
        2705: bipush        23
        2707: aload         46
        2709: aastore
        2710: dup
        2711: bipush        24
        2713: aload         48
        2715: aastore
        2716: dup
        2717: bipush        25
        2719: aload         50
        2721: aastore
        2722: dup
        2723: bipush        26
        2725: aload         52
        2727: aastore
        2728: dup
        2729: bipush        27
        2731: aload         53
        2733: aastore
        2734: dup
        2735: bipush        28
        2737: aload         54
        2739: aastore
        2740: dup
        2741: bipush        29
        2743: aload         55
        2745: aastore
        2746: dup
        2747: bipush        30
        2749: aload         57
        2751: aastore
        2752: dup
        2753: bipush        31
        2755: aload         56
        2757: aastore
        2758: dup
        2759: bipush        32
        2761: aload         58
        2763: aastore
        2764: dup
        2765: bipush        33
        2767: aload         59
        2769: aastore
        2770: dup
        2771: bipush        34
        2773: aload         61
        2775: aastore
        2776: dup
        2777: bipush        35
        2779: aload         62
        2781: aastore
        2782: dup
        2783: bipush        36
        2785: aload         63
        2787: aastore
        2788: dup
        2789: bipush        37
        2791: aload         70
        2793: aastore
        2794: dup
        2795: bipush        38
        2797: aload         72
        2799: aastore
        2800: dup
        2801: bipush        39
        2803: aload         74
        2805: aastore
        2806: dup
        2807: bipush        40
        2809: aload         95
        2811: aastore
        2812: dup
        2813: bipush        41
        2815: aload         96
        2817: aastore
        2818: dup
        2819: bipush        42
        2821: aload         97
        2823: aastore
        2824: dup
        2825: bipush        43
        2827: aload         98
        2829: aastore
        2830: dup
        2831: bipush        44
        2833: aload         99
        2835: aastore
        2836: dup
        2837: bipush        45
        2839: aload         100
        2841: aastore
        2842: dup
        2843: bipush        46
        2845: aload         101
        2847: aastore
        2848: dup
        2849: bipush        47
        2851: aload         102
        2853: aastore
        2854: dup
        2855: bipush        48
        2857: aload         103
        2859: aastore
        2860: dup
        2861: bipush        49
        2863: aload         104
        2865: aastore
        2866: dup
        2867: bipush        50
        2869: aload         105
        2871: aastore
        2872: dup
        2873: bipush        51
        2875: aload         106
        2877: aastore
        2878: dup
        2879: bipush        52
        2881: aload         107
        2883: aastore
        2884: dup
        2885: bipush        53
        2887: aload         108
        2889: aastore
        2890: dup
        2891: bipush        54
        2893: aload         109
        2895: aastore
        2896: dup
        2897: bipush        55
        2899: aload         111
        2901: aastore
        2902: dup
        2903: bipush        56
        2905: aload         110
        2907: aastore
        2908: dup
        2909: bipush        57
        2911: aload         113
        2913: aastore
        2914: dup
        2915: bipush        58
        2917: aload         112
        2919: aastore
        2920: dup
        2921: bipush        59
        2923: aload         76
        2925: aastore
        2926: dup
        2927: bipush        60
        2929: aload         77
        2931: aastore
        2932: dup
        2933: bipush        61
        2935: aload         75
        2937: aastore
        2938: dup
        2939: bipush        62
        2941: aload         147
        2943: aastore
        2944: dup
        2945: bipush        63
        2947: aload         78
        2949: aastore
        2950: dup
        2951: bipush        64
        2953: aload         146
        2955: aastore
        2956: dup
        2957: bipush        65
        2959: aload         80
        2961: aastore
        2962: dup
        2963: bipush        66
        2965: aload         79
        2967: aastore
        2968: dup
        2969: bipush        67
        2971: aload         81
        2973: aastore
        2974: dup
        2975: bipush        68
        2977: aload         82
        2979: aastore
        2980: dup
        2981: bipush        69
        2983: aload         145
        2985: aastore
        2986: dup
        2987: bipush        70
        2989: aload         144
        2991: aastore
        2992: dup
        2993: bipush        71
        2995: aload         83
        2997: aastore
        2998: dup
        2999: bipush        72
        3001: aload         143
        3003: aastore
        3004: dup
        3005: bipush        73
        3007: aload         142
        3009: aastore
        3010: dup
        3011: bipush        74
        3013: aload         141
        3015: aastore
        3016: dup
        3017: bipush        75
        3019: aload         84
        3021: aastore
        3022: dup
        3023: bipush        76
        3025: aload         85
        3027: aastore
        3028: dup
        3029: bipush        77
        3031: aload         140
        3033: aastore
        3034: dup
        3035: bipush        78
        3037: aload         87
        3039: aastore
        3040: dup
        3041: bipush        79
        3043: aload         88
        3045: aastore
        3046: dup
        3047: bipush        80
        3049: aload         86
        3051: aastore
        3052: dup
        3053: bipush        81
        3055: aload         139
        3057: aastore
        3058: dup
        3059: bipush        82
        3061: aload         93
        3063: aastore
        3064: dup
        3065: bipush        83
        3067: aload         89
        3069: aastore
        3070: dup
        3071: bipush        84
        3073: aload         91
        3075: aastore
        3076: dup
        3077: bipush        85
        3079: aload         92
        3081: aastore
        3082: dup
        3083: bipush        86
        3085: aload         138
        3087: aastore
        3088: dup
        3089: bipush        87
        3091: aload         137
        3093: aastore
        3094: dup
        3095: bipush        88
        3097: aload         136
        3099: aastore
        3100: dup
        3101: bipush        89
        3103: aload         135
        3105: aastore
        3106: dup
        3107: bipush        90
        3109: aload         134
        3111: aastore
        3112: dup
        3113: bipush        91
        3115: aload         133
        3117: aastore
        3118: dup
        3119: bipush        92
        3121: aload         132
        3123: aastore
        3124: dup
        3125: bipush        93
        3127: aload         94
        3129: aastore
        3130: dup
        3131: bipush        94
        3133: aload         131
        3135: aastore
        3136: dup
        3137: bipush        95
        3139: aload         130
        3141: aastore
        3142: dup
        3143: bipush        96
        3145: aload         114
        3147: aastore
        3148: dup
        3149: bipush        97
        3151: aload         115
        3153: aastore
        3154: dup
        3155: bipush        98
        3157: aload         121
        3159: aastore
        3160: dup
        3161: bipush        99
        3163: aload         117
        3165: aastore
        3166: dup
        3167: bipush        100
        3169: aload         60
        3171: aastore
        3172: dup
        3173: bipush        101
        3175: aload         90
        3177: aastore
        3178: dup
        3179: bipush        102
        3181: aload         120
        3183: aastore
        3184: dup
        3185: bipush        103
        3187: aload         119
        3189: aastore
        3190: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3193: astore        148
        3195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3198: bipush        45
        3200: aload         148
        3202: aastore
        3203: iconst_0
        3204: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3207: astore        149
        3209: iconst_0
        3210: istore        150
        3212: iload         150
        3214: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3217: astore        151
        3219: goto_w        3224
        3224: iconst_0
        3225: istore        152
        3227: iconst_1
        3228: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3231: astore        153
        3233: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3236: bipush        46
        3238: aaload
        3239: astore        154
        3241: new           #14                 // class Block
        3244: dup
        3245: sipush        248
        3248: iconst_2
        3249: anewarray     #16                 // class java/lang/Object
        3252: dup
        3253: iconst_0
        3254: aload         154
        3256: aastore
        3257: dup
        3258: iconst_1
        3259: aload         153
        3261: aastore
        3262: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3265: astore        155
        3267: new           #323                // class ocaml_fn_94
        3270: dup
        3271: aload         155
        3273: invokespecial #324                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3276: astore        156
        3278: iconst_0
        3279: istore        157
        3281: aload         156
        3283: iload         157
        3285: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3288: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3291: astore        158
        3293: getstatic     #334                // Field java/lang/System.out:Ljava/io/PrintStream;
        3296: aload         158
        3298: checkcast     #27                 // class java/lang/Integer
        3301: invokevirtual #338                // Method java/lang/Integer.intValue:()I
        3304: invokevirtual #344                // Method java/io/PrintStream.println:(I)V
        3307: iconst_0
        3308: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3311: astore        159
        3313: new           #14                 // class Block
        3316: dup
        3317: iconst_0
        3318: iconst_2
        3319: anewarray     #16                 // class java/lang/Object
        3322: dup
        3323: iconst_0
        3324: aload         155
        3326: aastore
        3327: dup
        3328: iconst_1
        3329: aload         156
        3331: aastore
        3332: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3335: astore        160
        3337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3340: bipush        47
        3342: aload         160
        3344: aastore
        3345: iconst_0
        3346: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3349: astore        161
        3351: iconst_0
        3352: istore        162
        3354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3357: bipush        45
        3359: aaload
        3360: checkcast     #14                 // class Block
        3363: getfield      #347                // Field Block.fields:[Ljava/lang/Object;
        3366: bipush        102
        3368: aaload
        3369: astore        163
        3371: aload         163
        3373: checkcast     #98                 // class Closure
        3376: iload         162
        3378: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3381: invokevirtual #328                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3384: astore        164
        3386: new           #14                 // class Block
        3389: dup
        3390: iconst_0
        3391: iconst_0
        3392: anewarray     #16                 // class java/lang/Object
        3395: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3398: astore        165
        3400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3403: bipush        48
        3405: aload         165
        3407: aastore
        3408: iconst_0
        3409: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3412: astore        166
        3414: return
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
          25: ldc_w         #346                // String Out_of_memory
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
          57: ldc_w         #348                // String Sys_error
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
          90: ldc_w         #350                // String Failure
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
         123: ldc_w         #352                // String Invalid_argument
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
         156: ldc_w         #354                // String End_of_file
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
         189: ldc_w         #356                // String Division_by_zero
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
         223: ldc_w         #358                // String Not_found
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
         257: ldc_w         #360                // String Match_failure
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
         291: ldc_w         #362                // String Stack_overflow
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
         325: ldc_w         #364                // String Sys_blocked_io
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
         359: ldc_w         #366                // String Assert_failure
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
         393: ldc_w         #368                // String Undefined_recursive_module
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
         424: ldc_w         #370                // String %,
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        14
         433: ldc_w         #372                // String really_input
         436: aastore
         437: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc_w         #374                // String input
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
         561: ldc_w         #376                // String output_substring
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        19
         570: ldc_w         #378                // String output
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
         777: ldc_w         #380                // String %.12g
         780: aastore
         781: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         784: bipush        23
         786: ldc_w         #382                // String .
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        24
         795: ldc_w         #384                // String %d
         798: aastore
         799: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         802: bipush        25
         804: ldc_w         #386                // String false
         807: aastore
         808: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         811: bipush        26
         813: ldc_w         #388                // String true
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
         872: ldc_w         #386                // String false
         875: aastore
         876: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         879: bipush        30
         881: ldc_w         #388                // String true
         884: aastore
         885: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        31
         890: ldc_w         #390                // String bool_of_string
         893: aastore
         894: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         897: bipush        32
         899: ldc_w         #388                // String true
         902: aastore
         903: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        33
         908: ldc_w         #386                // String false
         911: aastore
         912: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        34
         917: ldc_w         #392                // String char_of_int
         920: aastore
         921: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         924: bipush        35
         926: ldc_w         #394                // String index out of bounds
         929: aastore
         930: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         933: bipush        36
         935: ldc_w         #396                // String Pervasives.array_bound_error
         938: aastore
         939: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        37
         944: ldc_w         #398                // String Stdlib.Exit
         947: aastore
         948: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         951: bipush        38
         953: ldc_w         #399                // int 0
         956: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         959: aastore
         960: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         963: bipush        39
         965: ldc_w         #399                // int 0
         968: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        40
         977: ldc_w         #400                // int 1
         980: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         983: aastore
         984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         987: bipush        41
         989: ldc_w         #401                // int -1
         992: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         995: aastore
         996: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         999: bipush        42
        1001: ldc_w         #402                // int 0
        1004: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1007: aastore
        1008: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1011: bipush        43
        1013: ldc_w         #403                // int 0
        1016: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: aastore
        1020: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1023: bipush        44
        1025: ldc_w         #405                // String Pervasives.do_at_exit
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
        1402: ldc           #50                 // int 2147483647
        1404: istore        39
        1406: ldc           #51                 // int -2147483648
        1408: istore        40
        1410: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1413: bipush        38
        1415: aaload
        1416: astore        41
        1418: ldc2_w        #52                 // double 0.0d
        1421: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1424: astore        42
        1426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1429: bipush        39
        1431: aaload
        1432: astore        43
        1434: ldc2_w        #52                 // double 0.0d
        1437: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1440: astore        44
        1442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1445: bipush        40
        1447: aaload
        1448: astore        45
        1450: ldc2_w        #52                 // double 0.0d
        1453: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1456: astore        46
        1458: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1461: bipush        41
        1463: aaload
        1464: astore        47
        1466: ldc2_w        #52                 // double 0.0d
        1469: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1472: astore        48
        1474: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1477: bipush        42
        1479: aaload
        1480: astore        49
        1482: ldc2_w        #52                 // double 0.0d
        1485: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1488: astore        50
        1490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1493: bipush        43
        1495: aaload
        1496: astore        51
        1498: ldc2_w        #52                 // double 0.0d
        1501: invokestatic  #58                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1504: astore        52
        1506: new           #60                 // class ocaml_fn_14
        1509: dup
        1510: invokespecial #61                 // Method ocaml_fn_14."<init>":()V
        1513: astore        53
        1515: new           #63                 // class ocaml_fn_15
        1518: dup
        1519: aload         18
        1521: invokespecial #66                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1524: astore        54
        1526: new           #68                 // class ocaml_fn_16
        1529: dup
        1530: invokespecial #69                 // Method ocaml_fn_16."<init>":()V
        1533: astore        55
        1535: new           #71                 // class ocaml_fn_17
        1538: dup
        1539: aload         18
        1541: invokespecial #72                 // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1544: astore        56
        1546: new           #74                 // class ocaml_fn_18
        1549: dup
        1550: invokespecial #75                 // Method ocaml_fn_18."<init>":()V
        1553: astore        57
        1555: new           #77                 // class ocaml_fn_19
        1558: dup
        1559: invokespecial #78                 // Method ocaml_fn_19."<init>":()V
        1562: astore        58
        1564: new           #80                 // class ocaml_fn_20
        1567: dup
        1568: aload         26
        1570: invokespecial #81                 // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1573: astore        59
        1575: new           #83                 // class ocaml_fn_21
        1578: dup
        1579: aload         53
        1581: invokespecial #84                 // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1584: astore        60
        1586: new           #86                 // class ocaml_fn_22
        1589: dup
        1590: aload         60
        1592: invokespecial #87                 // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1595: astore        61
        1597: new           #89                 // class ocaml_fn_23
        1600: dup
        1601: aload         26
        1603: invokespecial #90                 // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1606: astore        62
        1608: new           #92                 // class ocaml_fn_24
        1611: dup
        1612: invokespecial #93                 // Method ocaml_fn_24."<init>":()V
        1615: astore        63
        1617: new           #95                 // class ocaml_fn_25
        1620: dup
        1621: invokespecial #96                 // Method ocaml_fn_25."<init>":()V
        1624: astore        64
        1626: aload         63
        1628: checkcast     #92                 // class ocaml_fn_24
        1631: aload         63
        1633: checkcast     #98                 // class Closure
        1636: putfield      #102                // Field ocaml_fn_24.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        65
        1645: aload         63
        1647: checkcast     #92                 // class ocaml_fn_24
        1650: aload         64
        1652: checkcast     #98                 // class Closure
        1655: putfield      #105                // Field ocaml_fn_24.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        66
        1664: aload         64
        1666: checkcast     #95                 // class ocaml_fn_25
        1669: aload         63
        1671: checkcast     #98                 // class Closure
        1674: putfield      #106                // Field ocaml_fn_25.sibling_0:LClosure;
        1677: iconst_0
        1678: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1681: astore        67
        1683: aload         64
        1685: checkcast     #95                 // class ocaml_fn_25
        1688: aload         64
        1690: checkcast     #98                 // class Closure
        1693: putfield      #107                // Field ocaml_fn_25.sibling_1:LClosure;
        1696: iconst_0
        1697: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1700: astore        68
        1702: iconst_0
        1703: istore        69
        1705: aconst_null
        1706: astore        70
        1708: iconst_1
        1709: istore        71
        1711: iload         71
        1713: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1716: astore        72
        1718: iconst_2
        1719: istore        73
        1721: iload         73
        1723: invokestatic  #113                // Method Channel.forDescriptor:(I)LChannel;
        1726: astore        74
        1728: new           #115                // class ocaml_fn_26
        1731: dup
        1732: invokespecial #116                // Method ocaml_fn_26."<init>":()V
        1735: astore        75
        1737: new           #118                // class ocaml_fn_27
        1740: dup
        1741: aload         75
        1743: invokespecial #119                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1746: astore        76
        1748: new           #121                // class ocaml_fn_28
        1751: dup
        1752: aload         75
        1754: invokespecial #122                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1757: astore        77
        1759: new           #124                // class ocaml_fn_29
        1762: dup
        1763: aload         30
        1765: invokespecial #125                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1768: astore        78
        1770: new           #127                // class ocaml_fn_30
        1773: dup
        1774: invokespecial #128                // Method ocaml_fn_30."<init>":()V
        1777: astore        79
        1779: new           #130                // class ocaml_fn_31
        1782: dup
        1783: invokespecial #131                // Method ocaml_fn_31."<init>":()V
        1786: astore        80
        1788: new           #133                // class ocaml_fn_32
        1791: dup
        1792: aload         18
        1794: invokespecial #134                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1797: astore        81
        1799: new           #136                // class ocaml_fn_33
        1802: dup
        1803: aload         18
        1805: invokespecial #137                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1808: astore        82
        1810: new           #139                // class ocaml_fn_34
        1813: dup
        1814: invokespecial #140                // Method ocaml_fn_34."<init>":()V
        1817: astore        83
        1819: new           #142                // class ocaml_fn_35
        1822: dup
        1823: invokespecial #143                // Method ocaml_fn_35."<init>":()V
        1826: astore        84
        1828: new           #145                // class ocaml_fn_36
        1831: dup
        1832: invokespecial #146                // Method ocaml_fn_36."<init>":()V
        1835: astore        85
        1837: new           #148                // class ocaml_fn_37
        1840: dup
        1841: invokespecial #149                // Method ocaml_fn_37."<init>":()V
        1844: astore        86
        1846: new           #151                // class ocaml_fn_38
        1849: dup
        1850: aload         86
        1852: invokespecial #152                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1855: astore        87
        1857: new           #154                // class ocaml_fn_39
        1860: dup
        1861: aload         86
        1863: invokespecial #155                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1866: astore        88
        1868: new           #157                // class ocaml_fn_40
        1871: dup
        1872: aload         18
        1874: invokespecial #158                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1877: astore        89
        1879: new           #160                // class ocaml_fn_41
        1882: dup
        1883: aload         31
        1885: invokespecial #161                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1888: astore        90
        1890: new           #163                // class ocaml_fn_42
        1893: dup
        1894: aload         18
        1896: aload         90
        1898: invokespecial #166                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1901: astore        91
        1903: new           #168                // class ocaml_fn_43
        1906: dup
        1907: aload         91
        1909: invokespecial #169                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1912: astore        92
        1914: new           #171                // class ocaml_fn_44
        1917: dup
        1918: aload         31
        1920: invokespecial #172                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1923: astore        93
        1925: new           #174                // class ocaml_fn_45
        1928: dup
        1929: invokespecial #175                // Method ocaml_fn_45."<init>":()V
        1932: astore        94
        1934: new           #177                // class ocaml_fn_46
        1937: dup
        1938: aload         72
        1940: invokespecial #178                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1943: astore        95
        1945: new           #180                // class ocaml_fn_47
        1948: dup
        1949: aload         72
        1951: aload         80
        1953: invokespecial #181                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1956: astore        96
        1958: new           #183                // class ocaml_fn_48
        1961: dup
        1962: aload         72
        1964: aload         79
        1966: invokespecial #184                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1969: astore        97
        1971: new           #186                // class ocaml_fn_49
        1974: dup
        1975: aload         58
        1977: aload         72
        1979: aload         80
        1981: invokespecial #189                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1984: astore        98
        1986: new           #191                // class ocaml_fn_50
        1989: dup
        1990: aload         61
        1992: aload         72
        1994: aload         80
        1996: invokespecial #192                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1999: astore        99
        2001: new           #194                // class ocaml_fn_51
        2004: dup
        2005: aload         72
        2007: aload         80
        2009: invokespecial #195                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        100
        2014: new           #197                // class ocaml_fn_52
        2017: dup
        2018: aload         72
        2020: invokespecial #198                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2023: astore        101
        2025: new           #200                // class ocaml_fn_53
        2028: dup
        2029: aload         74
        2031: invokespecial #201                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2034: astore        102
        2036: new           #203                // class ocaml_fn_54
        2039: dup
        2040: aload         74
        2042: aload         80
        2044: invokespecial #204                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        103
        2049: new           #206                // class ocaml_fn_55
        2052: dup
        2053: aload         74
        2055: aload         79
        2057: invokespecial #207                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        104
        2062: new           #209                // class ocaml_fn_56
        2065: dup
        2066: aload         58
        2068: aload         74
        2070: aload         80
        2072: invokespecial #210                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        105
        2077: new           #212                // class ocaml_fn_57
        2080: dup
        2081: aload         61
        2083: aload         74
        2085: aload         80
        2087: invokespecial #213                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2090: astore        106
        2092: new           #215                // class ocaml_fn_58
        2095: dup
        2096: aload         74
        2098: aload         80
        2100: invokespecial #216                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        107
        2105: new           #218                // class ocaml_fn_59
        2108: dup
        2109: aload         74
        2111: invokespecial #219                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2114: astore        108
        2116: new           #221                // class ocaml_fn_60
        2119: dup
        2120: aload         70
        2122: aload         72
        2124: aload         93
        2126: invokespecial #222                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        109
        2131: new           #224                // class ocaml_fn_61
        2134: dup
        2135: aload         109
        2137: invokespecial #225                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2140: astore        110
        2142: new           #227                // class ocaml_fn_62
        2145: dup
        2146: aload         59
        2148: aload         109
        2150: invokespecial #228                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2153: astore        111
        2155: new           #230                // class ocaml_fn_63
        2158: dup
        2159: aload         109
        2161: invokespecial #231                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2164: astore        112
        2166: new           #233                // class ocaml_fn_64
        2169: dup
        2170: aload         62
        2172: aload         109
        2174: invokespecial #234                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2177: astore        113
        2179: new           #236                // class ocaml_fn_65
        2182: dup
        2183: invokespecial #237                // Method ocaml_fn_65."<init>":()V
        2186: astore        114
        2188: new           #239                // class ocaml_fn_66
        2191: dup
        2192: aload         53
        2194: invokespecial #240                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2197: astore        115
        2199: new           #14                 // class Block
        2202: dup
        2203: iconst_0
        2204: iconst_1
        2205: anewarray     #16                 // class java/lang/Object
        2208: dup
        2209: iconst_0
        2210: aload         78
        2212: aastore
        2213: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2216: astore        116
        2218: new           #242                // class ocaml_fn_67
        2221: dup
        2222: aload         116
        2224: invokespecial #243                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2227: astore        117
        2229: new           #245                // class ocaml_fn_68
        2232: dup
        2233: invokespecial #246                // Method ocaml_fn_68."<init>":()V
        2236: astore        118
        2238: new           #14                 // class Block
        2241: dup
        2242: iconst_0
        2243: iconst_1
        2244: anewarray     #16                 // class java/lang/Object
        2247: dup
        2248: iconst_0
        2249: aload         118
        2251: aastore
        2252: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2255: astore        119
        2257: new           #248                // class ocaml_fn_69
        2260: dup
        2261: aload         116
        2263: aload         119
        2265: invokespecial #249                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2268: astore        120
        2270: new           #251                // class ocaml_fn_70
        2273: dup
        2274: aload         120
        2276: invokespecial #252                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2279: astore        121
        2281: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2284: bipush        44
        2286: aaload
        2287: astore        122
        2289: iconst_0
        2290: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2293: astore        123
        2295: new           #254                // class ocaml_fn_71
        2298: dup
        2299: invokespecial #255                // Method ocaml_fn_71."<init>":()V
        2302: astore        124
        2304: new           #257                // class ocaml_fn_72
        2307: dup
        2308: invokespecial #258                // Method ocaml_fn_72."<init>":()V
        2311: astore        125
        2313: new           #260                // class ocaml_fn_73
        2316: dup
        2317: invokespecial #261                // Method ocaml_fn_73."<init>":()V
        2320: astore        126
        2322: new           #263                // class ocaml_fn_74
        2325: dup
        2326: invokespecial #264                // Method ocaml_fn_74."<init>":()V
        2329: astore        127
        2331: new           #266                // class ocaml_fn_75
        2334: dup
        2335: invokespecial #267                // Method ocaml_fn_75."<init>":()V
        2338: astore        128
        2340: new           #269                // class ocaml_fn_76
        2343: dup
        2344: invokespecial #270                // Method ocaml_fn_76."<init>":()V
        2347: astore        129
        2349: new           #14                 // class Block
        2352: dup
        2353: iconst_0
        2354: bipush        6
        2356: anewarray     #16                 // class java/lang/Object
        2359: dup
        2360: iconst_0
        2361: aload         129
        2363: aastore
        2364: dup
        2365: iconst_1
        2366: aload         128
        2368: aastore
        2369: dup
        2370: iconst_2
        2371: aload         127
        2373: aastore
        2374: dup
        2375: iconst_3
        2376: aload         126
        2378: aastore
        2379: dup
        2380: iconst_4
        2381: aload         125
        2383: aastore
        2384: dup
        2385: iconst_5
        2386: aload         124
        2388: aastore
        2389: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2392: astore        130
        2394: new           #272                // class ocaml_fn_77
        2397: dup
        2398: invokespecial #273                // Method ocaml_fn_77."<init>":()V
        2401: astore        131
        2403: new           #275                // class ocaml_fn_78
        2406: dup
        2407: invokespecial #276                // Method ocaml_fn_78."<init>":()V
        2410: astore        132
        2412: new           #278                // class ocaml_fn_79
        2415: dup
        2416: invokespecial #279                // Method ocaml_fn_79."<init>":()V
        2419: astore        133
        2421: new           #281                // class ocaml_fn_80
        2424: dup
        2425: invokespecial #282                // Method ocaml_fn_80."<init>":()V
        2428: astore        134
        2430: new           #284                // class ocaml_fn_81
        2433: dup
        2434: invokespecial #285                // Method ocaml_fn_81."<init>":()V
        2437: astore        135
        2439: new           #287                // class ocaml_fn_82
        2442: dup
        2443: invokespecial #288                // Method ocaml_fn_82."<init>":()V
        2446: astore        136
        2448: new           #290                // class ocaml_fn_83
        2451: dup
        2452: invokespecial #291                // Method ocaml_fn_83."<init>":()V
        2455: astore        137
        2457: new           #293                // class ocaml_fn_84
        2460: dup
        2461: invokespecial #294                // Method ocaml_fn_84."<init>":()V
        2464: astore        138
        2466: new           #296                // class ocaml_fn_85
        2469: dup
        2470: invokespecial #297                // Method ocaml_fn_85."<init>":()V
        2473: astore        139
        2475: new           #299                // class ocaml_fn_86
        2478: dup
        2479: invokespecial #300                // Method ocaml_fn_86."<init>":()V
        2482: astore        140
        2484: new           #302                // class ocaml_fn_87
        2487: dup
        2488: invokespecial #303                // Method ocaml_fn_87."<init>":()V
        2491: astore        141
        2493: new           #305                // class ocaml_fn_88
        2496: dup
        2497: invokespecial #306                // Method ocaml_fn_88."<init>":()V
        2500: astore        142
        2502: new           #308                // class ocaml_fn_89
        2505: dup
        2506: invokespecial #309                // Method ocaml_fn_89."<init>":()V
        2509: astore        143
        2511: new           #311                // class ocaml_fn_90
        2514: dup
        2515: invokespecial #312                // Method ocaml_fn_90."<init>":()V
        2518: astore        144
        2520: new           #314                // class ocaml_fn_91
        2523: dup
        2524: invokespecial #315                // Method ocaml_fn_91."<init>":()V
        2527: astore        145
        2529: new           #317                // class ocaml_fn_92
        2532: dup
        2533: invokespecial #318                // Method ocaml_fn_92."<init>":()V
        2536: astore        146
        2538: new           #320                // class ocaml_fn_93
        2541: dup
        2542: invokespecial #321                // Method ocaml_fn_93."<init>":()V
        2545: astore        147
        2547: new           #14                 // class Block
        2550: dup
        2551: iconst_0
        2552: bipush        104
        2554: anewarray     #16                 // class java/lang/Object
        2557: dup
        2558: iconst_0
        2559: aload         18
        2561: aastore
        2562: dup
        2563: iconst_1
        2564: aload         17
        2566: aastore
        2567: dup
        2568: iconst_2
        2569: aload         22
        2571: aastore
        2572: dup
        2573: iconst_3
        2574: aload         23
        2576: aastore
        2577: dup
        2578: iconst_4
        2579: aload         24
        2581: aastore
        2582: dup
        2583: iconst_5
        2584: aload         25
        2586: aastore
        2587: dup
        2588: bipush        6
        2590: aload         26
        2592: aastore
        2593: dup
        2594: bipush        7
        2596: aload         27
        2598: aastore
        2599: dup
        2600: bipush        8
        2602: aload         28
        2604: aastore
        2605: dup
        2606: bipush        9
        2608: aload         29
        2610: aastore
        2611: dup
        2612: bipush        10
        2614: aload         30
        2616: aastore
        2617: dup
        2618: bipush        11
        2620: aload         31
        2622: aastore
        2623: dup
        2624: bipush        12
        2626: aload         32
        2628: aastore
        2629: dup
        2630: bipush        13
        2632: aload         33
        2634: aastore
        2635: dup
        2636: bipush        14
        2638: aload         34
        2640: aastore
        2641: dup
        2642: bipush        15
        2644: aload         35
        2646: aastore
        2647: dup
        2648: bipush        16
        2650: aload         36
        2652: aastore
        2653: dup
        2654: bipush        17
        2656: aload         37
        2658: aastore
        2659: dup
        2660: bipush        18
        2662: iload         39
        2664: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2667: aastore
        2668: dup
        2669: bipush        19
        2671: iload         40
        2673: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2676: aastore
        2677: dup
        2678: bipush        20
        2680: aload         38
        2682: aastore
        2683: dup
        2684: bipush        21
        2686: aload         42
        2688: aastore
        2689: dup
        2690: bipush        22
        2692: aload         44
        2694: aastore
        2695: dup
        2696: bipush        23
        2698: aload         46
        2700: aastore
        2701: dup
        2702: bipush        24
        2704: aload         48
        2706: aastore
        2707: dup
        2708: bipush        25
        2710: aload         50
        2712: aastore
        2713: dup
        2714: bipush        26
        2716: aload         52
        2718: aastore
        2719: dup
        2720: bipush        27
        2722: aload         53
        2724: aastore
        2725: dup
        2726: bipush        28
        2728: aload         54
        2730: aastore
        2731: dup
        2732: bipush        29
        2734: aload         55
        2736: aastore
        2737: dup
        2738: bipush        30
        2740: aload         57
        2742: aastore
        2743: dup
        2744: bipush        31
        2746: aload         56
        2748: aastore
        2749: dup
        2750: bipush        32
        2752: aload         58
        2754: aastore
        2755: dup
        2756: bipush        33
        2758: aload         59
        2760: aastore
        2761: dup
        2762: bipush        34
        2764: aload         61
        2766: aastore
        2767: dup
        2768: bipush        35
        2770: aload         62
        2772: aastore
        2773: dup
        2774: bipush        36
        2776: aload         63
        2778: aastore
        2779: dup
        2780: bipush        37
        2782: aload         70
        2784: aastore
        2785: dup
        2786: bipush        38
        2788: aload         72
        2790: aastore
        2791: dup
        2792: bipush        39
        2794: aload         74
        2796: aastore
        2797: dup
        2798: bipush        40
        2800: aload         95
        2802: aastore
        2803: dup
        2804: bipush        41
        2806: aload         96
        2808: aastore
        2809: dup
        2810: bipush        42
        2812: aload         97
        2814: aastore
        2815: dup
        2816: bipush        43
        2818: aload         98
        2820: aastore
        2821: dup
        2822: bipush        44
        2824: aload         99
        2826: aastore
        2827: dup
        2828: bipush        45
        2830: aload         100
        2832: aastore
        2833: dup
        2834: bipush        46
        2836: aload         101
        2838: aastore
        2839: dup
        2840: bipush        47
        2842: aload         102
        2844: aastore
        2845: dup
        2846: bipush        48
        2848: aload         103
        2850: aastore
        2851: dup
        2852: bipush        49
        2854: aload         104
        2856: aastore
        2857: dup
        2858: bipush        50
        2860: aload         105
        2862: aastore
        2863: dup
        2864: bipush        51
        2866: aload         106
        2868: aastore
        2869: dup
        2870: bipush        52
        2872: aload         107
        2874: aastore
        2875: dup
        2876: bipush        53
        2878: aload         108
        2880: aastore
        2881: dup
        2882: bipush        54
        2884: aload         109
        2886: aastore
        2887: dup
        2888: bipush        55
        2890: aload         111
        2892: aastore
        2893: dup
        2894: bipush        56
        2896: aload         110
        2898: aastore
        2899: dup
        2900: bipush        57
        2902: aload         113
        2904: aastore
        2905: dup
        2906: bipush        58
        2908: aload         112
        2910: aastore
        2911: dup
        2912: bipush        59
        2914: aload         76
        2916: aastore
        2917: dup
        2918: bipush        60
        2920: aload         77
        2922: aastore
        2923: dup
        2924: bipush        61
        2926: aload         75
        2928: aastore
        2929: dup
        2930: bipush        62
        2932: aload         147
        2934: aastore
        2935: dup
        2936: bipush        63
        2938: aload         78
        2940: aastore
        2941: dup
        2942: bipush        64
        2944: aload         146
        2946: aastore
        2947: dup
        2948: bipush        65
        2950: aload         80
        2952: aastore
        2953: dup
        2954: bipush        66
        2956: aload         79
        2958: aastore
        2959: dup
        2960: bipush        67
        2962: aload         81
        2964: aastore
        2965: dup
        2966: bipush        68
        2968: aload         82
        2970: aastore
        2971: dup
        2972: bipush        69
        2974: aload         145
        2976: aastore
        2977: dup
        2978: bipush        70
        2980: aload         144
        2982: aastore
        2983: dup
        2984: bipush        71
        2986: aload         83
        2988: aastore
        2989: dup
        2990: bipush        72
        2992: aload         143
        2994: aastore
        2995: dup
        2996: bipush        73
        2998: aload         142
        3000: aastore
        3001: dup
        3002: bipush        74
        3004: aload         141
        3006: aastore
        3007: dup
        3008: bipush        75
        3010: aload         84
        3012: aastore
        3013: dup
        3014: bipush        76
        3016: aload         85
        3018: aastore
        3019: dup
        3020: bipush        77
        3022: aload         140
        3024: aastore
        3025: dup
        3026: bipush        78
        3028: aload         87
        3030: aastore
        3031: dup
        3032: bipush        79
        3034: aload         88
        3036: aastore
        3037: dup
        3038: bipush        80
        3040: aload         86
        3042: aastore
        3043: dup
        3044: bipush        81
        3046: aload         139
        3048: aastore
        3049: dup
        3050: bipush        82
        3052: aload         93
        3054: aastore
        3055: dup
        3056: bipush        83
        3058: aload         89
        3060: aastore
        3061: dup
        3062: bipush        84
        3064: aload         91
        3066: aastore
        3067: dup
        3068: bipush        85
        3070: aload         92
        3072: aastore
        3073: dup
        3074: bipush        86
        3076: aload         138
        3078: aastore
        3079: dup
        3080: bipush        87
        3082: aload         137
        3084: aastore
        3085: dup
        3086: bipush        88
        3088: aload         136
        3090: aastore
        3091: dup
        3092: bipush        89
        3094: aload         135
        3096: aastore
        3097: dup
        3098: bipush        90
        3100: aload         134
        3102: aastore
        3103: dup
        3104: bipush        91
        3106: aload         133
        3108: aastore
        3109: dup
        3110: bipush        92
        3112: aload         132
        3114: aastore
        3115: dup
        3116: bipush        93
        3118: aload         94
        3120: aastore
        3121: dup
        3122: bipush        94
        3124: aload         131
        3126: aastore
        3127: dup
        3128: bipush        95
        3130: aload         130
        3132: aastore
        3133: dup
        3134: bipush        96
        3136: aload         114
        3138: aastore
        3139: dup
        3140: bipush        97
        3142: aload         115
        3144: aastore
        3145: dup
        3146: bipush        98
        3148: aload         121
        3150: aastore
        3151: dup
        3152: bipush        99
        3154: aload         117
        3156: aastore
        3157: dup
        3158: bipush        100
        3160: aload         60
        3162: aastore
        3163: dup
        3164: bipush        101
        3166: aload         90
        3168: aastore
        3169: dup
        3170: bipush        102
        3172: aload         120
        3174: aastore
        3175: dup
        3176: bipush        103
        3178: aload         119
        3180: aastore
        3181: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3184: astore        148
        3186: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3189: bipush        45
        3191: aload         148
        3193: aastore
        3194: iconst_0
        3195: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3198: astore        149
        3200: iconst_1
        3201: istore        150
        3203: iconst_0
        3204: istore        151
        3206: iload         151
        3208: ifeq          3223
        3211: iload         150
        3213: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3216: astore        152
        3218: goto_w        3251
        3223: iload         150
        3225: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3228: astore        153
        3230: goto_w        3235
        3235: bipush        10
        3237: istore        154
        3239: iload         154
        3241: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3244: astore        155
        3246: goto_w        3267
        3251: bipush        20
        3253: istore        156
        3255: iload         156
        3257: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3260: astore        155
        3262: goto_w        3267
        3267: getstatic     #327                // Field java/lang/System.out:Ljava/io/PrintStream;
        3270: aload         155
        3272: checkcast     #27                 // class java/lang/Integer
        3275: invokevirtual #331                // Method java/lang/Integer.intValue:()I
        3278: invokevirtual #337                // Method java/io/PrintStream.println:(I)V
        3281: iconst_0
        3282: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3285: astore        157
        3287: new           #14                 // class Block
        3290: dup
        3291: iconst_0
        3292: iconst_0
        3293: anewarray     #16                 // class java/lang/Object
        3296: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3299: astore        158
        3301: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3304: bipush        46
        3306: aload         158
        3308: aastore
        3309: iconst_0
        3310: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3313: astore        159
        3315: iconst_0
        3316: istore        160
        3318: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3321: bipush        45
        3323: aaload
        3324: checkcast     #14                 // class Block
        3327: getfield      #340                // Field Block.fields:[Ljava/lang/Object;
        3330: bipush        102
        3332: aaload
        3333: astore        161
        3335: aload         161
        3337: checkcast     #98                 // class Closure
        3340: iload         160
        3342: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3345: invokevirtual #344                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3348: astore        162
        3350: new           #14                 // class Block
        3353: dup
        3354: iconst_0
        3355: iconst_0
        3356: anewarray     #16                 // class java/lang/Object
        3359: invokespecial #19                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3362: astore        163
        3364: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3367: bipush        47
        3369: aload         163
        3371: aastore
        3372: iconst_0
        3373: invokestatic  #31                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3376: astore        164
        3378: return
    }
    |}]
