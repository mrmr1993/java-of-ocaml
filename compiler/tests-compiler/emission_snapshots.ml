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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3059: bipush        46
        3061: aaload
        3062: astore        157
        3064: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3067: aload         157
        3069: checkcast     #380                // class java/lang/String
        3072: invokevirtual #386                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3075: iconst_0
        3076: i2l
        3077: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3080: astore        158
        3082: new           #8                  // class Block
        3085: dup
        3086: iconst_0
        3087: iconst_0
        3088: anewarray     #10                 // class java/lang/Object
        3091: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3094: astore        159
        3096: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3099: bipush        47
        3101: aload         159
        3103: aastore
        3104: iconst_0
        3105: i2l
        3106: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3109: astore        160
        3111: iconst_0
        3112: i2l
        3113: lstore        161
        3115: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3118: bipush        45
        3120: aaload
        3121: checkcast     #8                  // class Block
        3124: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3127: bipush        102
        3129: aaload
        3130: astore        163
        3132: aload         163
        3134: checkcast     #153                // class Closure
        3137: lload         161
        3139: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3142: invokevirtual #390                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3145: astore        164
        3147: new           #8                  // class Block
        3150: dup
        3151: iconst_0
        3152: iconst_0
        3153: anewarray     #10                 // class java/lang/Object
        3156: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3159: astore        165
        3161: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3164: bipush        48
        3166: aload         165
        3168: aastore
        3169: iconst_0
        3170: i2l
        3171: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3174: astore        166
        3176: return
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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: bipush        8
        3058: i2l
        3059: lstore        157
        3061: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3064: lload         157
        3066: l2i
        3067: invokevirtual #384                // Method java/io/PrintStream.println:(I)V
        3070: iconst_0
        3071: i2l
        3072: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3075: astore        159
        3077: new           #8                  // class Block
        3080: dup
        3081: iconst_0
        3082: iconst_0
        3083: anewarray     #10                 // class java/lang/Object
        3086: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3089: astore        160
        3091: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3094: bipush        46
        3096: aload         160
        3098: aastore
        3099: iconst_0
        3100: i2l
        3101: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3104: astore        161
        3106: iconst_0
        3107: i2l
        3108: lstore        162
        3110: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3113: bipush        45
        3115: aaload
        3116: checkcast     #8                  // class Block
        3119: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3122: bipush        102
        3124: aaload
        3125: astore        164
        3127: aload         164
        3129: checkcast     #153                // class Closure
        3132: lload         162
        3134: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3137: invokevirtual #388                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3140: astore        165
        3142: new           #8                  // class Block
        3145: dup
        3146: iconst_0
        3147: iconst_0
        3148: anewarray     #10                 // class java/lang/Object
        3151: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3154: astore        166
        3156: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        47
        3161: aload         166
        3163: aastore
        3164: iconst_0
        3165: i2l
        3166: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3169: astore        167
        3171: return
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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: iconst_0
        3057: i2l
        3058: lstore        157
        3060: lload         157
        3062: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3065: astore        159
        3067: goto_w        3072
        3072: new           #376                // class ocaml_fn_Test_mkadder_95
        3075: dup
        3076: invokespecial #377                // Method ocaml_fn_Test_mkadder_95."<init>":()V
        3079: astore        160
        3081: bipush        10
        3083: i2l
        3084: lstore        161
        3086: aload         160
        3088: lload         161
        3090: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3093: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3096: astore        163
        3098: bipush        32
        3100: i2l
        3101: lstore        164
        3103: aload         163
        3105: checkcast     #153                // class Closure
        3108: lload         164
        3110: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3113: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3116: astore        166
        3118: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3121: aload         166
        3123: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3126: l2i
        3127: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3130: iconst_0
        3131: i2l
        3132: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3135: astore        167
        3137: new           #8                  // class Block
        3140: dup
        3141: iconst_0
        3142: iconst_1
        3143: anewarray     #10                 // class java/lang/Object
        3146: dup
        3147: iconst_0
        3148: aload         160
        3150: aastore
        3151: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3154: astore        168
        3156: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        46
        3161: aload         168
        3163: aastore
        3164: iconst_0
        3165: i2l
        3166: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3169: astore        169
        3171: iconst_0
        3172: i2l
        3173: lstore        170
        3175: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3178: bipush        45
        3180: aaload
        3181: checkcast     #8                  // class Block
        3184: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3187: bipush        102
        3189: aaload
        3190: astore        172
        3192: aload         172
        3194: checkcast     #153                // class Closure
        3197: lload         170
        3199: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3202: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3205: astore        173
        3207: new           #8                  // class Block
        3210: dup
        3211: iconst_0
        3212: iconst_0
        3213: anewarray     #10                 // class java/lang/Object
        3216: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3219: astore        174
        3221: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3224: bipush        47
        3226: aload         174
        3228: aastore
        3229: iconst_0
        3230: i2l
        3231: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3234: astore        175
        3236: return
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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: iconst_0
        3057: i2l
        3058: lstore        157
        3060: lload         157
        3062: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3065: astore        159
        3067: goto_w        3072
        3072: new           #376                // class ocaml_fn_Test_get_94
        3075: dup
        3076: invokespecial #377                // Method ocaml_fn_Test_get_94."<init>":()V
        3079: astore        160
        3081: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3084: bipush        46
        3086: aaload
        3087: astore        161
        3089: aload         160
        3091: aload         161
        3093: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3096: astore        162
        3098: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3101: aload         162
        3103: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3106: l2i
        3107: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3110: iconst_0
        3111: i2l
        3112: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3115: astore        163
        3117: new           #8                  // class Block
        3120: dup
        3121: iconst_0
        3122: iconst_1
        3123: anewarray     #10                 // class java/lang/Object
        3126: dup
        3127: iconst_0
        3128: aload         160
        3130: aastore
        3131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3134: astore        164
        3136: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3139: bipush        47
        3141: aload         164
        3143: aastore
        3144: iconst_0
        3145: i2l
        3146: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3149: astore        165
        3151: iconst_0
        3152: i2l
        3153: lstore        166
        3155: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3158: bipush        45
        3160: aaload
        3161: checkcast     #8                  // class Block
        3164: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3167: bipush        102
        3169: aaload
        3170: astore        168
        3172: aload         168
        3174: checkcast     #153                // class Closure
        3177: lload         166
        3179: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3182: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3185: astore        169
        3187: new           #8                  // class Block
        3190: dup
        3191: iconst_0
        3192: iconst_0
        3193: anewarray     #10                 // class java/lang/Object
        3196: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3199: astore        170
        3201: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3204: bipush        48
        3206: aload         170
        3208: aastore
        3209: iconst_0
        3210: i2l
        3211: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3214: astore        171
        3216: return
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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        49
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: iconst_0
        3057: i2l
        3058: lstore        157
        3060: lload         157
        3062: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3065: astore        159
        3067: goto_w        3072
        3072: iconst_0
        3073: i2l
        3074: lstore        160
        3076: invokestatic  #84                 // Method Ocaml.freshOoId:()J
        3079: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3082: astore        162
        3084: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3087: bipush        46
        3089: aaload
        3090: astore        163
        3092: new           #8                  // class Block
        3095: dup
        3096: sipush        248
        3099: iconst_2
        3100: anewarray     #10                 // class java/lang/Object
        3103: dup
        3104: iconst_0
        3105: aload         163
        3107: aastore
        3108: dup
        3109: iconst_1
        3110: aload         162
        3112: aastore
        3113: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3116: astore        164
        3118: new           #376                // class ocaml_fn_Test_safe_94
        3121: dup
        3122: aload         164
        3124: invokespecial #377                // Method ocaml_fn_Test_safe_94."<init>":(Ljava/lang/Object;)V
        3127: astore        165
        3129: iconst_0
        3130: i2l
        3131: lstore        166
        3133: aload         165
        3135: lload         166
        3137: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3140: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3143: astore        168
        3145: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3148: aload         168
        3150: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3153: l2i
        3154: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3157: iconst_0
        3158: i2l
        3159: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3162: astore        169
        3164: new           #8                  // class Block
        3167: dup
        3168: iconst_0
        3169: iconst_2
        3170: anewarray     #10                 // class java/lang/Object
        3173: dup
        3174: iconst_0
        3175: aload         164
        3177: aastore
        3178: dup
        3179: iconst_1
        3180: aload         165
        3182: aastore
        3183: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3186: astore        170
        3188: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3191: bipush        47
        3193: aload         170
        3195: aastore
        3196: iconst_0
        3197: i2l
        3198: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3201: astore        171
        3203: iconst_0
        3204: i2l
        3205: lstore        172
        3207: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3210: bipush        45
        3212: aaload
        3213: checkcast     #8                  // class Block
        3216: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3219: bipush        102
        3221: aaload
        3222: astore        174
        3224: aload         174
        3226: checkcast     #153                // class Closure
        3229: lload         172
        3231: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3234: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3237: astore        175
        3239: new           #8                  // class Block
        3242: dup
        3243: iconst_0
        3244: iconst_0
        3245: anewarray     #10                 // class java/lang/Object
        3248: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3251: astore        176
        3253: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3256: bipush        48
        3258: aload         176
        3260: aastore
        3261: iconst_0
        3262: i2l
        3263: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3266: astore        177
        3268: return
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
           0: invokestatic  #6                  // Method Ocaml.runtimeLock:()V
           3: new           #8                  // class Block
           6: dup
           7: iconst_0
           8: aload_0
           9: arraylength
          10: iconst_1
          11: iadd
          12: anewarray     #10                 // class java/lang/Object
          15: astore_1
          16: aload_1
          17: iconst_0
          18: ldc           #12                 // String Main
          20: aastore
          21: aload_0
          22: iconst_0
          23: aload_1
          24: iconst_1
          25: aload_0
          26: arraylength
          27: invokestatic  #18                 // Method java/lang/System.arraycopy:(Ljava/lang/Object;ILjava/lang/Object;II)V
          30: aload_1
          31: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          34: putstatic     #27                 // Field ARGV:LBlock;
          37: bipush        48
          39: anewarray     #10                 // class java/lang/Object
          42: putstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          45: invokestatic  #36                 // Method Main$globals_0.init:()V
          48: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          51: iconst_4
          52: aaload
          53: putstatic     #42                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          56: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          59: iconst_2
          60: aaload
          61: putstatic     #45                 // Field Ocaml.failureExn:Ljava/lang/Object;
          64: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          67: bipush        6
          69: aaload
          70: putstatic     #48                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          73: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
          76: iconst_1
          77: aaload
          78: putstatic     #51                 // Field Ocaml.sysErrorExn:Ljava/lang/Object;
          81: aconst_null
          82: astore_0
          83: aload_0
          84: astore_1
          85: goto_w        90
          90: new           #53                 // class ocaml_fn_CamlinternalFormatBasics_erase_rel_0
          93: dup
          94: invokespecial #55                 // Method ocaml_fn_CamlinternalFormatBasics_erase_rel_0."<init>":()V
          97: astore_2
          98: new           #57                 // class ocaml_fn_1
         101: dup
         102: invokespecial #58                 // Method ocaml_fn_1."<init>":()V
         105: astore_3
         106: new           #60                 // class ocaml_fn_2
         109: dup
         110: invokespecial #61                 // Method ocaml_fn_2."<init>":()V
         113: astore        4
         115: new           #8                  // class Block
         118: dup
         119: iconst_0
         120: iconst_3
         121: anewarray     #10                 // class java/lang/Object
         124: dup
         125: iconst_0
         126: aload_3
         127: aastore
         128: dup
         129: iconst_1
         130: aload_2
         131: aastore
         132: dup
         133: iconst_2
         134: aload         4
         136: aastore
         137: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         140: astore        5
         142: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         145: bipush        12
         147: aload         5
         149: aastore
         150: iconst_0
         151: i2l
         152: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        6
         157: iconst_0
         158: i2l
         159: lstore        7
         161: lload         7
         163: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         166: astore        9
         168: goto_w        173
         173: sipush        199
         176: i2l
         177: lstore        10
         179: iconst_0
         180: i2l
         181: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         184: astore        12
         186: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         189: bipush        35
         191: aaload
         192: astore        13
         194: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         197: iconst_3
         198: aaload
         199: astore        14
         201: new           #8                  // class Block
         204: dup
         205: iconst_0
         206: iconst_2
         207: anewarray     #10                 // class java/lang/Object
         210: dup
         211: iconst_0
         212: aload         14
         214: aastore
         215: dup
         216: iconst_1
         217: aload         13
         219: aastore
         220: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         223: astore        15
         225: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         228: bipush        36
         230: aaload
         231: astore        16
         233: aload         16
         235: aload         15
         237: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         240: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         243: astore        17
         245: new           #8                  // class Block
         248: dup
         249: iconst_0
         250: bipush        104
         252: anewarray     #10                 // class java/lang/Object
         255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         258: astore        18
         260: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         263: dup
         264: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         267: astore        19
         269: aload         18
         271: checkcast     #8                  // class Block
         274: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         277: iconst_1
         278: aload         19
         280: aastore
         281: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         284: dup
         285: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         288: astore        20
         290: aload         18
         292: checkcast     #8                  // class Block
         295: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         298: iconst_0
         299: aload         20
         301: aastore
         302: iconst_0
         303: i2l
         304: lstore        21
         306: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         309: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         312: astore        23
         314: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         317: bipush        37
         319: aaload
         320: astore        24
         322: new           #8                  // class Block
         325: dup
         326: sipush        248
         329: iconst_2
         330: anewarray     #10                 // class java/lang/Object
         333: dup
         334: iconst_0
         335: aload         24
         337: aastore
         338: dup
         339: iconst_1
         340: aload         23
         342: aastore
         343: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         346: astore        25
         348: aload         18
         350: checkcast     #8                  // class Block
         353: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         356: iconst_2
         357: aload         25
         359: aastore
         360: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         363: bipush        7
         365: aaload
         366: astore        26
         368: aload         18
         370: checkcast     #8                  // class Block
         373: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_3
         377: aload         26
         379: aastore
         380: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         383: bipush        10
         385: aaload
         386: astore        27
         388: aload         18
         390: checkcast     #8                  // class Block
         393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         396: iconst_4
         397: aload         27
         399: aastore
         400: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         403: iconst_3
         404: aaload
         405: astore        28
         407: aload         18
         409: checkcast     #8                  // class Block
         412: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         415: iconst_5
         416: aload         28
         418: aastore
         419: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         422: iconst_2
         423: aaload
         424: astore        29
         426: aload         18
         428: checkcast     #8                  // class Block
         431: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         434: bipush        6
         436: aload         29
         438: aastore
         439: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         442: bipush        6
         444: aaload
         445: astore        30
         447: aload         18
         449: checkcast     #8                  // class Block
         452: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         455: bipush        7
         457: aload         30
         459: aastore
         460: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         463: iconst_0
         464: aaload
         465: astore        31
         467: aload         18
         469: checkcast     #8                  // class Block
         472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         475: bipush        8
         477: aload         31
         479: aastore
         480: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         483: bipush        8
         485: aaload
         486: astore        32
         488: aload         18
         490: checkcast     #8                  // class Block
         493: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         496: bipush        9
         498: aload         32
         500: aastore
         501: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         504: iconst_1
         505: aaload
         506: astore        33
         508: aload         18
         510: checkcast     #8                  // class Block
         513: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         516: bipush        10
         518: aload         33
         520: aastore
         521: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         524: iconst_4
         525: aaload
         526: astore        34
         528: aload         18
         530: checkcast     #8                  // class Block
         533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         536: bipush        11
         538: aload         34
         540: aastore
         541: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         544: iconst_5
         545: aaload
         546: astore        35
         548: aload         18
         550: checkcast     #8                  // class Block
         553: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         556: bipush        12
         558: aload         35
         560: aastore
         561: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         564: bipush        9
         566: aaload
         567: astore        36
         569: aload         18
         571: checkcast     #8                  // class Block
         574: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         577: bipush        13
         579: aload         36
         581: aastore
         582: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         585: bipush        11
         587: aaload
         588: astore        37
         590: aload         18
         592: checkcast     #8                  // class Block
         595: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         598: bipush        14
         600: aload         37
         602: aastore
         603: new           #86                 // class ocaml_fn_10
         606: dup
         607: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         610: astore        38
         612: aload         18
         614: checkcast     #8                  // class Block
         617: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         620: bipush        15
         622: aload         38
         624: aastore
         625: new           #89                 // class ocaml_fn_11
         628: dup
         629: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         632: astore        39
         634: aload         18
         636: checkcast     #8                  // class Block
         639: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         642: bipush        16
         644: aload         39
         646: aastore
         647: new           #92                 // class ocaml_fn_Stdlib_abs_12
         650: dup
         651: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         654: astore        40
         656: aload         18
         658: checkcast     #8                  // class Block
         661: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        17
         666: aload         40
         668: aastore
         669: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         672: dup
         673: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         676: astore        41
         678: aload         18
         680: checkcast     #8                  // class Block
         683: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         686: bipush        20
         688: aload         41
         690: aastore
         691: ldc2_w        #97                 // long 4611686018427387903l
         694: lstore        42
         696: aload         18
         698: checkcast     #8                  // class Block
         701: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         704: bipush        18
         706: lload         42
         708: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         711: aastore
         712: ldc2_w        #99                 // long -4611686018427387904l
         715: lstore        44
         717: aload         18
         719: checkcast     #8                  // class Block
         722: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         725: bipush        19
         727: lload         44
         729: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         732: aastore
         733: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        38
         738: aaload
         739: astore        46
         741: aload         46
         743: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        47
         754: aload         18
         756: checkcast     #8                  // class Block
         759: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        21
         764: aload         47
         766: aastore
         767: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        39
         772: aaload
         773: astore        48
         775: aload         48
         777: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        49
         788: aload         18
         790: checkcast     #8                  // class Block
         793: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        22
         798: aload         49
         800: aastore
         801: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        40
         806: aaload
         807: astore        50
         809: aload         50
         811: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        51
         822: aload         18
         824: checkcast     #8                  // class Block
         827: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        23
         832: aload         51
         834: aastore
         835: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        41
         840: aaload
         841: astore        52
         843: aload         52
         845: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        53
         856: aload         18
         858: checkcast     #8                  // class Block
         861: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        24
         866: aload         53
         868: aastore
         869: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        42
         874: aaload
         875: astore        54
         877: aload         54
         879: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        55
         890: aload         18
         892: checkcast     #8                  // class Block
         895: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        25
         900: aload         55
         902: aastore
         903: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        43
         908: aaload
         909: astore        56
         911: aload         56
         913: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         916: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         919: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         922: astore        57
         924: aload         18
         926: checkcast     #8                  // class Block
         929: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         932: bipush        26
         934: aload         57
         936: aastore
         937: new           #115                // class ocaml_fn_14
         940: dup
         941: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         944: astore        58
         946: aload         18
         948: checkcast     #8                  // class Block
         951: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         954: bipush        27
         956: aload         58
         958: aastore
         959: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         962: dup
         963: aload         20
         965: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         968: astore        59
         970: aload         18
         972: checkcast     #8                  // class Block
         975: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         978: bipush        28
         980: aload         59
         982: aastore
         983: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         986: dup
         987: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         990: astore        60
         992: aload         18
         994: checkcast     #8                  // class Block
         997: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1000: bipush        29
        1002: aload         60
        1004: aastore
        1005: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1008: dup
        1009: aload         20
        1011: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1014: astore        61
        1016: aload         18
        1018: checkcast     #8                  // class Block
        1021: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1024: bipush        31
        1026: aload         61
        1028: aastore
        1029: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1032: dup
        1033: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1036: astore        62
        1038: aload         18
        1040: checkcast     #8                  // class Block
        1043: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1046: bipush        30
        1048: aload         62
        1050: aastore
        1051: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1054: dup
        1055: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1058: astore        63
        1060: aload         18
        1062: checkcast     #8                  // class Block
        1065: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1068: bipush        32
        1070: aload         63
        1072: aastore
        1073: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1076: dup
        1077: aload         29
        1079: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1082: astore        64
        1084: aload         18
        1086: checkcast     #8                  // class Block
        1089: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1092: bipush        33
        1094: aload         64
        1096: aastore
        1097: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1100: dup
        1101: aload         58
        1103: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1106: astore        65
        1108: aload         18
        1110: checkcast     #8                  // class Block
        1113: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1116: bipush        100
        1118: aload         65
        1120: aastore
        1121: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1124: dup
        1125: aload         65
        1127: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1130: astore        66
        1132: aload         18
        1134: checkcast     #8                  // class Block
        1137: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1140: bipush        34
        1142: aload         66
        1144: aastore
        1145: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1148: dup
        1149: aload         29
        1151: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1154: astore        67
        1156: aload         18
        1158: checkcast     #8                  // class Block
        1161: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1164: bipush        35
        1166: aload         67
        1168: aastore
        1169: new           #147                // class ocaml_fn_24
        1172: dup
        1173: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1176: astore        68
        1178: aload         18
        1180: checkcast     #8                  // class Block
        1183: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1186: bipush        36
        1188: aload         68
        1190: aastore
        1191: new           #150                // class ocaml_fn_25
        1194: dup
        1195: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1198: astore        69
        1200: aload         68
        1202: checkcast     #147                // class ocaml_fn_24
        1205: aload         68
        1207: checkcast     #153                // class Closure
        1210: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1213: iconst_0
        1214: i2l
        1215: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1218: astore        70
        1220: aload         68
        1222: checkcast     #147                // class ocaml_fn_24
        1225: aload         69
        1227: checkcast     #153                // class Closure
        1230: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1233: iconst_0
        1234: i2l
        1235: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1238: astore        71
        1240: aload         69
        1242: checkcast     #150                // class ocaml_fn_25
        1245: aload         68
        1247: checkcast     #153                // class Closure
        1250: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1253: iconst_0
        1254: i2l
        1255: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1258: astore        72
        1260: aload         69
        1262: checkcast     #150                // class ocaml_fn_25
        1265: aload         69
        1267: checkcast     #153                // class Closure
        1270: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1273: iconst_0
        1274: i2l
        1275: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1278: astore        73
        1280: iconst_0
        1281: i2l
        1282: lstore        74
        1284: lload         74
        1286: l2i
        1287: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1290: astore        76
        1292: aload         18
        1294: checkcast     #8                  // class Block
        1297: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1300: bipush        37
        1302: aload         76
        1304: aastore
        1305: iconst_1
        1306: i2l
        1307: lstore        77
        1309: lload         77
        1311: l2i
        1312: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1315: astore        79
        1317: aload         18
        1319: checkcast     #8                  // class Block
        1322: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1325: bipush        38
        1327: aload         79
        1329: aastore
        1330: iconst_2
        1331: i2l
        1332: lstore        80
        1334: lload         80
        1336: l2i
        1337: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1340: astore        82
        1342: aload         18
        1344: checkcast     #8                  // class Block
        1347: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1350: bipush        39
        1352: aload         82
        1354: aastore
        1355: new           #168                // class ocaml_fn_26
        1358: dup
        1359: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1362: astore        83
        1364: aload         18
        1366: checkcast     #8                  // class Block
        1369: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1372: bipush        61
        1374: aload         83
        1376: aastore
        1377: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1380: dup
        1381: aload         83
        1383: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1386: astore        84
        1388: aload         18
        1390: checkcast     #8                  // class Block
        1393: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1396: bipush        59
        1398: aload         84
        1400: aastore
        1401: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1404: dup
        1405: aload         83
        1407: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1410: astore        85
        1412: aload         18
        1414: checkcast     #8                  // class Block
        1417: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1420: bipush        60
        1422: aload         85
        1424: aastore
        1425: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1428: dup
        1429: aload         33
        1431: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1434: astore        86
        1436: aload         18
        1438: checkcast     #8                  // class Block
        1441: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1444: bipush        63
        1446: aload         86
        1448: aastore
        1449: new           #180                // class ocaml_fn_30
        1452: dup
        1453: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1456: astore        87
        1458: aload         18
        1460: checkcast     #8                  // class Block
        1463: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1466: bipush        66
        1468: aload         87
        1470: aastore
        1471: new           #183                // class ocaml_fn_31
        1474: dup
        1475: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1478: astore        88
        1480: aload         18
        1482: checkcast     #8                  // class Block
        1485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1488: bipush        65
        1490: aload         88
        1492: aastore
        1493: new           #186                // class ocaml_fn_32
        1496: dup
        1497: aload         20
        1499: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1502: astore        89
        1504: aload         18
        1506: checkcast     #8                  // class Block
        1509: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1512: bipush        67
        1514: aload         89
        1516: aastore
        1517: new           #189                // class ocaml_fn_33
        1520: dup
        1521: aload         20
        1523: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1526: astore        90
        1528: aload         18
        1530: checkcast     #8                  // class Block
        1533: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1536: bipush        68
        1538: aload         90
        1540: aastore
        1541: new           #192                // class ocaml_fn_34
        1544: dup
        1545: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1548: astore        91
        1550: aload         18
        1552: checkcast     #8                  // class Block
        1555: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1558: bipush        71
        1560: aload         91
        1562: aastore
        1563: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1566: dup
        1567: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1570: astore        92
        1572: aload         18
        1574: checkcast     #8                  // class Block
        1577: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1580: bipush        75
        1582: aload         92
        1584: aastore
        1585: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1588: dup
        1589: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1592: astore        93
        1594: aload         18
        1596: checkcast     #8                  // class Block
        1599: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1602: bipush        76
        1604: aload         93
        1606: aastore
        1607: new           #201                // class ocaml_fn_37
        1610: dup
        1611: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1614: astore        94
        1616: aload         18
        1618: checkcast     #8                  // class Block
        1621: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1624: bipush        80
        1626: aload         94
        1628: aastore
        1629: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1632: dup
        1633: aload         94
        1635: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1638: astore        95
        1640: aload         18
        1642: checkcast     #8                  // class Block
        1645: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1648: bipush        78
        1650: aload         95
        1652: aastore
        1653: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1656: dup
        1657: aload         94
        1659: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1662: astore        96
        1664: aload         18
        1666: checkcast     #8                  // class Block
        1669: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1672: bipush        79
        1674: aload         96
        1676: aastore
        1677: new           #210                // class ocaml_fn_40
        1680: dup
        1681: aload         20
        1683: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1686: astore        97
        1688: aload         18
        1690: checkcast     #8                  // class Block
        1693: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1696: bipush        83
        1698: aload         97
        1700: aastore
        1701: new           #213                // class ocaml_fn_41
        1704: dup
        1705: aload         34
        1707: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1710: astore        98
        1712: aload         18
        1714: checkcast     #8                  // class Block
        1717: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        101
        1722: aload         98
        1724: aastore
        1725: new           #216                // class ocaml_fn_42
        1728: dup
        1729: aload         20
        1731: aload         98
        1733: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1736: astore        99
        1738: aload         18
        1740: checkcast     #8                  // class Block
        1743: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1746: bipush        84
        1748: aload         99
        1750: aastore
        1751: new           #221                // class ocaml_fn_43
        1754: dup
        1755: aload         99
        1757: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1760: astore        100
        1762: aload         18
        1764: checkcast     #8                  // class Block
        1767: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1770: bipush        85
        1772: aload         100
        1774: aastore
        1775: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1778: dup
        1779: aload         34
        1781: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1784: astore        101
        1786: aload         18
        1788: checkcast     #8                  // class Block
        1791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1794: bipush        82
        1796: aload         101
        1798: aastore
        1799: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1802: dup
        1803: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1806: astore        102
        1808: aload         18
        1810: checkcast     #8                  // class Block
        1813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1816: bipush        93
        1818: aload         102
        1820: aastore
        1821: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1824: dup
        1825: aload         79
        1827: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1830: astore        103
        1832: aload         18
        1834: checkcast     #8                  // class Block
        1837: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        40
        1842: aload         103
        1844: aastore
        1845: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1848: dup
        1849: aload         79
        1851: aload         88
        1853: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        104
        1858: aload         18
        1860: checkcast     #8                  // class Block
        1863: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        41
        1868: aload         104
        1870: aastore
        1871: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1874: dup
        1875: aload         79
        1877: aload         87
        1879: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1882: astore        105
        1884: aload         18
        1886: checkcast     #8                  // class Block
        1889: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1892: bipush        42
        1894: aload         105
        1896: aastore
        1897: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1900: dup
        1901: aload         63
        1903: aload         79
        1905: aload         88
        1907: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1910: astore        106
        1912: aload         18
        1914: checkcast     #8                  // class Block
        1917: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1920: bipush        43
        1922: aload         106
        1924: aastore
        1925: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1928: dup
        1929: aload         66
        1931: aload         79
        1933: aload         88
        1935: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        107
        1940: aload         18
        1942: checkcast     #8                  // class Block
        1945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        44
        1950: aload         107
        1952: aastore
        1953: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1956: dup
        1957: aload         79
        1959: aload         88
        1961: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1964: astore        108
        1966: aload         18
        1968: checkcast     #8                  // class Block
        1971: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1974: bipush        45
        1976: aload         108
        1978: aastore
        1979: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1982: dup
        1983: aload         79
        1985: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1988: astore        109
        1990: aload         18
        1992: checkcast     #8                  // class Block
        1995: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1998: bipush        46
        2000: aload         109
        2002: aastore
        2003: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2006: dup
        2007: aload         82
        2009: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2012: astore        110
        2014: aload         18
        2016: checkcast     #8                  // class Block
        2019: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        47
        2024: aload         110
        2026: aastore
        2027: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2030: dup
        2031: aload         82
        2033: aload         88
        2035: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        111
        2040: aload         18
        2042: checkcast     #8                  // class Block
        2045: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        48
        2050: aload         111
        2052: aastore
        2053: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2056: dup
        2057: aload         82
        2059: aload         87
        2061: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2064: astore        112
        2066: aload         18
        2068: checkcast     #8                  // class Block
        2071: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2074: bipush        49
        2076: aload         112
        2078: aastore
        2079: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2082: dup
        2083: aload         63
        2085: aload         82
        2087: aload         88
        2089: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2092: astore        113
        2094: aload         18
        2096: checkcast     #8                  // class Block
        2099: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2102: bipush        50
        2104: aload         113
        2106: aastore
        2107: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2110: dup
        2111: aload         66
        2113: aload         82
        2115: aload         88
        2117: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        114
        2122: aload         18
        2124: checkcast     #8                  // class Block
        2127: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        51
        2132: aload         114
        2134: aastore
        2135: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2138: dup
        2139: aload         82
        2141: aload         88
        2143: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2146: astore        115
        2148: aload         18
        2150: checkcast     #8                  // class Block
        2153: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2156: bipush        52
        2158: aload         115
        2160: aastore
        2161: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2164: dup
        2165: aload         82
        2167: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2170: astore        116
        2172: aload         18
        2174: checkcast     #8                  // class Block
        2177: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2180: bipush        53
        2182: aload         116
        2184: aastore
        2185: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2188: dup
        2189: aload         76
        2191: aload         79
        2193: aload         101
        2195: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2198: astore        117
        2200: aload         18
        2202: checkcast     #8                  // class Block
        2205: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2208: bipush        54
        2210: aload         117
        2212: aastore
        2213: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2216: dup
        2217: aload         117
        2219: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2222: astore        118
        2224: aload         18
        2226: checkcast     #8                  // class Block
        2229: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        56
        2234: aload         118
        2236: aastore
        2237: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2240: dup
        2241: aload         64
        2243: aload         117
        2245: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2248: astore        119
        2250: aload         18
        2252: checkcast     #8                  // class Block
        2255: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2258: bipush        55
        2260: aload         119
        2262: aastore
        2263: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2266: dup
        2267: aload         117
        2269: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2272: astore        120
        2274: aload         18
        2276: checkcast     #8                  // class Block
        2279: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        58
        2284: aload         120
        2286: aastore
        2287: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2290: dup
        2291: aload         67
        2293: aload         117
        2295: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2298: astore        121
        2300: aload         18
        2302: checkcast     #8                  // class Block
        2305: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2308: bipush        57
        2310: aload         121
        2312: aastore
        2313: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2316: dup
        2317: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2320: astore        122
        2322: aload         18
        2324: checkcast     #8                  // class Block
        2327: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2330: bipush        96
        2332: aload         122
        2334: aastore
        2335: new           #292                // class ocaml_fn_66
        2338: dup
        2339: aload         58
        2341: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2344: astore        123
        2346: aload         18
        2348: checkcast     #8                  // class Block
        2351: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2354: bipush        97
        2356: aload         123
        2358: aastore
        2359: new           #8                  // class Block
        2362: dup
        2363: iconst_0
        2364: iconst_1
        2365: anewarray     #10                 // class java/lang/Object
        2368: dup
        2369: iconst_0
        2370: aload         86
        2372: aastore
        2373: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2376: astore        124
        2378: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2381: dup
        2382: aload         124
        2384: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2387: astore        125
        2389: aload         18
        2391: checkcast     #8                  // class Block
        2394: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2397: bipush        99
        2399: aload         125
        2401: aastore
        2402: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2405: dup
        2406: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2409: astore        126
        2411: new           #8                  // class Block
        2414: dup
        2415: iconst_0
        2416: iconst_1
        2417: anewarray     #10                 // class java/lang/Object
        2420: dup
        2421: iconst_0
        2422: aload         126
        2424: aastore
        2425: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2428: astore        127
        2430: aload         18
        2432: checkcast     #8                  // class Block
        2435: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        103
        2440: aload         127
        2442: aastore
        2443: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2446: dup
        2447: aload         124
        2449: aload         127
        2451: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2454: astore        128
        2456: aload         18
        2458: checkcast     #8                  // class Block
        2461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2464: bipush        102
        2466: aload         128
        2468: aastore
        2469: new           #304                // class ocaml_fn_Stdlib_exit_70
        2472: dup
        2473: aload         128
        2475: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2478: astore        129
        2480: aload         18
        2482: checkcast     #8                  // class Block
        2485: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2488: bipush        98
        2490: aload         129
        2492: aastore
        2493: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2496: bipush        44
        2498: aaload
        2499: astore        130
        2501: aload         130
        2503: aload         128
        2505: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2508: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2511: astore        131
        2513: new           #8                  // class Block
        2516: dup
        2517: iconst_0
        2518: bipush        6
        2520: anewarray     #10                 // class java/lang/Object
        2523: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2526: astore        132
        2528: new           #307                // class ocaml_fn_71
        2531: dup
        2532: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2535: astore        133
        2537: aload         132
        2539: checkcast     #8                  // class Block
        2542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2545: iconst_5
        2546: aload         133
        2548: aastore
        2549: new           #310                // class ocaml_fn_72
        2552: dup
        2553: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2556: astore        134
        2558: aload         132
        2560: checkcast     #8                  // class Block
        2563: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2566: iconst_4
        2567: aload         134
        2569: aastore
        2570: new           #313                // class ocaml_fn_73
        2573: dup
        2574: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2577: astore        135
        2579: aload         132
        2581: checkcast     #8                  // class Block
        2584: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2587: iconst_3
        2588: aload         135
        2590: aastore
        2591: new           #316                // class ocaml_fn_74
        2594: dup
        2595: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2598: astore        136
        2600: aload         132
        2602: checkcast     #8                  // class Block
        2605: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2608: iconst_2
        2609: aload         136
        2611: aastore
        2612: new           #319                // class ocaml_fn_75
        2615: dup
        2616: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2619: astore        137
        2621: aload         132
        2623: checkcast     #8                  // class Block
        2626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2629: iconst_1
        2630: aload         137
        2632: aastore
        2633: new           #322                // class ocaml_fn_76
        2636: dup
        2637: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2640: astore        138
        2642: aload         132
        2644: checkcast     #8                  // class Block
        2647: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2650: iconst_0
        2651: aload         138
        2653: aastore
        2654: aload         18
        2656: checkcast     #8                  // class Block
        2659: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        95
        2664: aload         132
        2666: aastore
        2667: new           #325                // class ocaml_fn_77
        2670: dup
        2671: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2674: astore        139
        2676: aload         18
        2678: checkcast     #8                  // class Block
        2681: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        94
        2686: aload         139
        2688: aastore
        2689: new           #328                // class ocaml_fn_78
        2692: dup
        2693: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2696: astore        140
        2698: aload         18
        2700: checkcast     #8                  // class Block
        2703: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        92
        2708: aload         140
        2710: aastore
        2711: new           #331                // class ocaml_fn_79
        2714: dup
        2715: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2718: astore        141
        2720: aload         18
        2722: checkcast     #8                  // class Block
        2725: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        91
        2730: aload         141
        2732: aastore
        2733: new           #334                // class ocaml_fn_80
        2736: dup
        2737: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2740: astore        142
        2742: aload         18
        2744: checkcast     #8                  // class Block
        2747: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        90
        2752: aload         142
        2754: aastore
        2755: new           #337                // class ocaml_fn_81
        2758: dup
        2759: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2762: astore        143
        2764: aload         18
        2766: checkcast     #8                  // class Block
        2769: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        89
        2774: aload         143
        2776: aastore
        2777: new           #340                // class ocaml_fn_82
        2780: dup
        2781: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2784: astore        144
        2786: aload         18
        2788: checkcast     #8                  // class Block
        2791: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        88
        2796: aload         144
        2798: aastore
        2799: new           #343                // class ocaml_fn_83
        2802: dup
        2803: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2806: astore        145
        2808: aload         18
        2810: checkcast     #8                  // class Block
        2813: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        87
        2818: aload         145
        2820: aastore
        2821: new           #346                // class ocaml_fn_84
        2824: dup
        2825: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2828: astore        146
        2830: aload         18
        2832: checkcast     #8                  // class Block
        2835: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        86
        2840: aload         146
        2842: aastore
        2843: new           #349                // class ocaml_fn_85
        2846: dup
        2847: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2850: astore        147
        2852: aload         18
        2854: checkcast     #8                  // class Block
        2857: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        81
        2862: aload         147
        2864: aastore
        2865: new           #352                // class ocaml_fn_86
        2868: dup
        2869: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2872: astore        148
        2874: aload         18
        2876: checkcast     #8                  // class Block
        2879: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        77
        2884: aload         148
        2886: aastore
        2887: new           #355                // class ocaml_fn_87
        2890: dup
        2891: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2894: astore        149
        2896: aload         18
        2898: checkcast     #8                  // class Block
        2901: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        74
        2906: aload         149
        2908: aastore
        2909: new           #358                // class ocaml_fn_88
        2912: dup
        2913: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2916: astore        150
        2918: aload         18
        2920: checkcast     #8                  // class Block
        2923: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        73
        2928: aload         150
        2930: aastore
        2931: new           #361                // class ocaml_fn_89
        2934: dup
        2935: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2938: astore        151
        2940: aload         18
        2942: checkcast     #8                  // class Block
        2945: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        72
        2950: aload         151
        2952: aastore
        2953: new           #364                // class ocaml_fn_90
        2956: dup
        2957: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2960: astore        152
        2962: aload         18
        2964: checkcast     #8                  // class Block
        2967: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        70
        2972: aload         152
        2974: aastore
        2975: new           #367                // class ocaml_fn_91
        2978: dup
        2979: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2982: astore        153
        2984: aload         18
        2986: checkcast     #8                  // class Block
        2989: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        69
        2994: aload         153
        2996: aastore
        2997: new           #370                // class ocaml_fn_92
        3000: dup
        3001: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3004: astore        154
        3006: aload         18
        3008: checkcast     #8                  // class Block
        3011: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        64
        3016: aload         154
        3018: aastore
        3019: new           #373                // class ocaml_fn_93
        3022: dup
        3023: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3026: astore        155
        3028: aload         18
        3030: checkcast     #8                  // class Block
        3033: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3036: bipush        62
        3038: aload         155
        3040: aastore
        3041: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3044: bipush        45
        3046: aload         18
        3048: aastore
        3049: iconst_0
        3050: i2l
        3051: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        156
        3056: iconst_1
        3057: i2l
        3058: lstore        157
        3060: iconst_0
        3061: i2l
        3062: lstore        159
        3064: lload         159
        3066: iconst_0
        3067: i2l
        3068: lcmp
        3069: ifeq          3084
        3072: lload         157
        3074: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3077: astore        161
        3079: goto_w        3113
        3084: lload         157
        3086: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3089: astore        162
        3091: goto_w        3096
        3096: bipush        10
        3098: i2l
        3099: lstore        163
        3101: lload         163
        3103: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3106: astore        165
        3108: goto_w        3130
        3113: bipush        20
        3115: i2l
        3116: lstore        166
        3118: lload         166
        3120: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3123: astore        165
        3125: goto_w        3130
        3130: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3133: aload         165
        3135: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3138: l2i
        3139: invokevirtual #384                // Method java/io/PrintStream.println:(I)V
        3142: iconst_0
        3143: i2l
        3144: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3147: astore        168
        3149: new           #8                  // class Block
        3152: dup
        3153: iconst_0
        3154: iconst_0
        3155: anewarray     #10                 // class java/lang/Object
        3158: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3161: astore        169
        3163: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3166: bipush        46
        3168: aload         169
        3170: aastore
        3171: iconst_0
        3172: i2l
        3173: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3176: astore        170
        3178: iconst_0
        3179: i2l
        3180: lstore        171
        3182: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3185: bipush        45
        3187: aaload
        3188: checkcast     #8                  // class Block
        3191: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3194: bipush        102
        3196: aaload
        3197: astore        173
        3199: aload         173
        3201: checkcast     #153                // class Closure
        3204: lload         171
        3206: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3209: invokevirtual #388                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3212: astore        174
        3214: new           #8                  // class Block
        3217: dup
        3218: iconst_0
        3219: iconst_0
        3220: anewarray     #10                 // class java/lang/Object
        3223: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3226: astore        175
        3228: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3231: bipush        47
        3233: aload         175
        3235: aastore
        3236: iconst_0
        3237: i2l
        3238: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3241: astore        176
        3243: return
    }
    |}]
