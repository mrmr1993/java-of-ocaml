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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3084: bipush        46
        3086: aaload
        3087: astore        161
        3089: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3092: aload         161
        3094: checkcast     #380                // class java/lang/String
        3097: invokevirtual #386                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3100: iconst_0
        3101: i2l
        3102: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3105: astore        162
        3107: new           #8                  // class Block
        3110: dup
        3111: iconst_0
        3112: iconst_0
        3113: anewarray     #10                 // class java/lang/Object
        3116: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3119: astore        163
        3121: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3124: bipush        47
        3126: aload         163
        3128: aastore
        3129: iconst_0
        3130: i2l
        3131: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3134: astore        164
        3136: iconst_0
        3137: i2l
        3138: lstore        165
        3140: lload         165
        3142: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3145: astore        167
        3147: goto_w        3152
        3152: iconst_0
        3153: i2l
        3154: lstore        168
        3156: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        45
        3161: aaload
        3162: checkcast     #8                  // class Block
        3165: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3168: bipush        102
        3170: aaload
        3171: astore        170
        3173: aload         170
        3175: checkcast     #153                // class Closure
        3178: lload         168
        3180: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3183: invokevirtual #390                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3186: astore        171
        3188: new           #8                  // class Block
        3191: dup
        3192: iconst_0
        3193: iconst_0
        3194: anewarray     #10                 // class java/lang/Object
        3197: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3200: astore        172
        3202: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3205: bipush        48
        3207: aload         172
        3209: aastore
        3210: iconst_0
        3211: i2l
        3212: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3215: astore        173
        3217: return
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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: bipush        8
        3083: i2l
        3084: lstore        161
        3086: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3089: lload         161
        3091: l2i
        3092: invokevirtual #384                // Method java/io/PrintStream.println:(I)V
        3095: iconst_0
        3096: i2l
        3097: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3100: astore        163
        3102: new           #8                  // class Block
        3105: dup
        3106: iconst_0
        3107: iconst_0
        3108: anewarray     #10                 // class java/lang/Object
        3111: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3114: astore        164
        3116: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3119: bipush        46
        3121: aload         164
        3123: aastore
        3124: iconst_0
        3125: i2l
        3126: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3129: astore        165
        3131: iconst_0
        3132: i2l
        3133: lstore        166
        3135: lload         166
        3137: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3140: astore        168
        3142: goto_w        3147
        3147: iconst_0
        3148: i2l
        3149: lstore        169
        3151: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3154: bipush        45
        3156: aaload
        3157: checkcast     #8                  // class Block
        3160: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3163: bipush        102
        3165: aaload
        3166: astore        171
        3168: aload         171
        3170: checkcast     #153                // class Closure
        3173: lload         169
        3175: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3178: invokevirtual #388                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3181: astore        172
        3183: new           #8                  // class Block
        3186: dup
        3187: iconst_0
        3188: iconst_0
        3189: anewarray     #10                 // class java/lang/Object
        3192: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3195: astore        173
        3197: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3200: bipush        47
        3202: aload         173
        3204: aastore
        3205: iconst_0
        3206: i2l
        3207: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3210: astore        174
        3212: return
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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: aload         160
        3083: astore        161
        3085: goto_w        3090
        3090: new           #376                // class ocaml_fn_Test_mkadder_95
        3093: dup
        3094: invokespecial #377                // Method ocaml_fn_Test_mkadder_95."<init>":()V
        3097: astore        162
        3099: bipush        10
        3101: i2l
        3102: lstore        163
        3104: aload         162
        3106: lload         163
        3108: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3111: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3114: astore        165
        3116: bipush        32
        3118: i2l
        3119: lstore        166
        3121: aload         165
        3123: checkcast     #153                // class Closure
        3126: lload         166
        3128: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3131: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3134: astore        168
        3136: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3139: aload         168
        3141: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3144: l2i
        3145: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3148: iconst_0
        3149: i2l
        3150: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3153: astore        169
        3155: new           #8                  // class Block
        3158: dup
        3159: iconst_0
        3160: iconst_1
        3161: anewarray     #10                 // class java/lang/Object
        3164: dup
        3165: iconst_0
        3166: aload         162
        3168: aastore
        3169: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3172: astore        170
        3174: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3177: bipush        46
        3179: aload         170
        3181: aastore
        3182: iconst_0
        3183: i2l
        3184: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3187: astore        171
        3189: iconst_0
        3190: i2l
        3191: lstore        172
        3193: lload         172
        3195: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3198: astore        174
        3200: goto_w        3205
        3205: iconst_0
        3206: i2l
        3207: lstore        175
        3209: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3212: bipush        45
        3214: aaload
        3215: checkcast     #8                  // class Block
        3218: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3221: bipush        102
        3223: aaload
        3224: astore        177
        3226: aload         177
        3228: checkcast     #153                // class Closure
        3231: lload         175
        3233: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3236: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3239: astore        178
        3241: new           #8                  // class Block
        3244: dup
        3245: iconst_0
        3246: iconst_0
        3247: anewarray     #10                 // class java/lang/Object
        3250: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3253: astore        179
        3255: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3258: bipush        47
        3260: aload         179
        3262: aastore
        3263: iconst_0
        3264: i2l
        3265: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3268: astore        180
        3270: return
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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: aload         160
        3083: astore        161
        3085: goto_w        3090
        3090: new           #376                // class ocaml_fn_Test_get_94
        3093: dup
        3094: invokespecial #377                // Method ocaml_fn_Test_get_94."<init>":()V
        3097: astore        162
        3099: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3102: bipush        46
        3104: aaload
        3105: astore        163
        3107: aload         162
        3109: aload         163
        3111: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3114: astore        164
        3116: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3119: aload         164
        3121: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3124: l2i
        3125: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3128: iconst_0
        3129: i2l
        3130: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3133: astore        165
        3135: new           #8                  // class Block
        3138: dup
        3139: iconst_0
        3140: iconst_1
        3141: anewarray     #10                 // class java/lang/Object
        3144: dup
        3145: iconst_0
        3146: aload         162
        3148: aastore
        3149: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3152: astore        166
        3154: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3157: bipush        47
        3159: aload         166
        3161: aastore
        3162: iconst_0
        3163: i2l
        3164: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3167: astore        167
        3169: iconst_0
        3170: i2l
        3171: lstore        168
        3173: lload         168
        3175: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3178: astore        170
        3180: goto_w        3185
        3185: iconst_0
        3186: i2l
        3187: lstore        171
        3189: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3192: bipush        45
        3194: aaload
        3195: checkcast     #8                  // class Block
        3198: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3201: bipush        102
        3203: aaload
        3204: astore        173
        3206: aload         173
        3208: checkcast     #153                // class Closure
        3211: lload         171
        3213: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3216: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3219: astore        174
        3221: new           #8                  // class Block
        3224: dup
        3225: iconst_0
        3226: iconst_0
        3227: anewarray     #10                 // class java/lang/Object
        3230: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3233: astore        175
        3235: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3238: bipush        48
        3240: aload         175
        3242: aastore
        3243: iconst_0
        3244: i2l
        3245: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3248: astore        176
        3250: return
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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: aload         160
        3083: astore        161
        3085: goto_w        3090
        3090: iconst_0
        3091: i2l
        3092: lstore        162
        3094: invokestatic  #84                 // Method Ocaml.freshOoId:()J
        3097: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3100: astore        164
        3102: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3105: bipush        46
        3107: aaload
        3108: astore        165
        3110: new           #8                  // class Block
        3113: dup
        3114: sipush        248
        3117: iconst_2
        3118: anewarray     #10                 // class java/lang/Object
        3121: dup
        3122: iconst_0
        3123: aload         165
        3125: aastore
        3126: dup
        3127: iconst_1
        3128: aload         164
        3130: aastore
        3131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3134: astore        166
        3136: new           #376                // class ocaml_fn_Test_safe_94
        3139: dup
        3140: aload         166
        3142: invokespecial #377                // Method ocaml_fn_Test_safe_94."<init>":(Ljava/lang/Object;)V
        3145: astore        167
        3147: iconst_0
        3148: i2l
        3149: lstore        168
        3151: aload         167
        3153: lload         168
        3155: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3158: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3161: astore        170
        3163: getstatic     #385                // Field java/lang/System.out:Ljava/io/PrintStream;
        3166: aload         170
        3168: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3171: l2i
        3172: invokevirtual #391                // Method java/io/PrintStream.println:(I)V
        3175: iconst_0
        3176: i2l
        3177: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3180: astore        171
        3182: new           #8                  // class Block
        3185: dup
        3186: iconst_0
        3187: iconst_2
        3188: anewarray     #10                 // class java/lang/Object
        3191: dup
        3192: iconst_0
        3193: aload         166
        3195: aastore
        3196: dup
        3197: iconst_1
        3198: aload         167
        3200: aastore
        3201: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3204: astore        172
        3206: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3209: bipush        47
        3211: aload         172
        3213: aastore
        3214: iconst_0
        3215: i2l
        3216: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3219: astore        173
        3221: iconst_0
        3222: i2l
        3223: lstore        174
        3225: lload         174
        3227: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3230: astore        176
        3232: goto_w        3237
        3237: iconst_0
        3238: i2l
        3239: lstore        177
        3241: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3244: bipush        45
        3246: aaload
        3247: checkcast     #8                  // class Block
        3250: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3253: bipush        102
        3255: aaload
        3256: astore        179
        3258: aload         179
        3260: checkcast     #153                // class Closure
        3263: lload         177
        3265: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3268: invokevirtual #381                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3271: astore        180
        3273: new           #8                  // class Block
        3276: dup
        3277: iconst_0
        3278: iconst_0
        3279: anewarray     #10                 // class java/lang/Object
        3282: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3285: astore        181
        3287: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3290: bipush        48
        3292: aload         181
        3294: aastore
        3295: iconst_0
        3296: i2l
        3297: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3300: astore        182
        3302: return
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
         173: aload         9
         175: astore        10
         177: goto_w        182
         182: sipush        199
         185: i2l
         186: lstore        11
         188: iconst_0
         189: i2l
         190: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         193: astore        13
         195: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        35
         200: aaload
         201: astore        14
         203: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         206: iconst_3
         207: aaload
         208: astore        15
         210: new           #8                  // class Block
         213: dup
         214: iconst_0
         215: iconst_2
         216: anewarray     #10                 // class java/lang/Object
         219: dup
         220: iconst_0
         221: aload         15
         223: aastore
         224: dup
         225: iconst_1
         226: aload         14
         228: aastore
         229: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         232: astore        16
         234: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         237: bipush        36
         239: aaload
         240: astore        17
         242: aload         17
         244: aload         16
         246: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         249: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         252: astore        18
         254: new           #8                  // class Block
         257: dup
         258: iconst_0
         259: bipush        104
         261: anewarray     #10                 // class java/lang/Object
         264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         267: astore        19
         269: new           #73                 // class ocaml_fn_Stdlib_failwith_8
         272: dup
         273: invokespecial #74                 // Method ocaml_fn_Stdlib_failwith_8."<init>":()V
         276: astore        20
         278: aload         19
         280: checkcast     #8                  // class Block
         283: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         286: iconst_1
         287: aload         20
         289: aastore
         290: new           #79                 // class ocaml_fn_Stdlib_invalid_arg_9
         293: dup
         294: invokespecial #80                 // Method ocaml_fn_Stdlib_invalid_arg_9."<init>":()V
         297: astore        21
         299: aload         19
         301: checkcast     #8                  // class Block
         304: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         307: iconst_0
         308: aload         21
         310: aastore
         311: iconst_0
         312: i2l
         313: lstore        22
         315: invokestatic  #84                 // Method Ocaml.freshOoId:()J
         318: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         321: astore        24
         323: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         326: bipush        37
         328: aaload
         329: astore        25
         331: new           #8                  // class Block
         334: dup
         335: sipush        248
         338: iconst_2
         339: anewarray     #10                 // class java/lang/Object
         342: dup
         343: iconst_0
         344: aload         25
         346: aastore
         347: dup
         348: iconst_1
         349: aload         24
         351: aastore
         352: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         355: astore        26
         357: aload         19
         359: checkcast     #8                  // class Block
         362: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_2
         366: aload         26
         368: aastore
         369: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        7
         374: aaload
         375: astore        27
         377: aload         19
         379: checkcast     #8                  // class Block
         382: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_3
         386: aload         27
         388: aastore
         389: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         392: bipush        10
         394: aaload
         395: astore        28
         397: aload         19
         399: checkcast     #8                  // class Block
         402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         405: iconst_4
         406: aload         28
         408: aastore
         409: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         412: iconst_3
         413: aaload
         414: astore        29
         416: aload         19
         418: checkcast     #8                  // class Block
         421: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         424: iconst_5
         425: aload         29
         427: aastore
         428: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         431: iconst_2
         432: aaload
         433: astore        30
         435: aload         19
         437: checkcast     #8                  // class Block
         440: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        6
         445: aload         30
         447: aastore
         448: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         451: bipush        6
         453: aaload
         454: astore        31
         456: aload         19
         458: checkcast     #8                  // class Block
         461: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        7
         466: aload         31
         468: aastore
         469: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         472: iconst_0
         473: aaload
         474: astore        32
         476: aload         19
         478: checkcast     #8                  // class Block
         481: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        8
         486: aload         32
         488: aastore
         489: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         492: bipush        8
         494: aaload
         495: astore        33
         497: aload         19
         499: checkcast     #8                  // class Block
         502: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        9
         507: aload         33
         509: aastore
         510: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_1
         514: aaload
         515: astore        34
         517: aload         19
         519: checkcast     #8                  // class Block
         522: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        10
         527: aload         34
         529: aastore
         530: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_4
         534: aaload
         535: astore        35
         537: aload         19
         539: checkcast     #8                  // class Block
         542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        11
         547: aload         35
         549: aastore
         550: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         553: iconst_5
         554: aaload
         555: astore        36
         557: aload         19
         559: checkcast     #8                  // class Block
         562: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        12
         567: aload         36
         569: aastore
         570: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        9
         575: aaload
         576: astore        37
         578: aload         19
         580: checkcast     #8                  // class Block
         583: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        13
         588: aload         37
         590: aastore
         591: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         594: bipush        11
         596: aaload
         597: astore        38
         599: aload         19
         601: checkcast     #8                  // class Block
         604: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         607: bipush        14
         609: aload         38
         611: aastore
         612: new           #86                 // class ocaml_fn_10
         615: dup
         616: invokespecial #87                 // Method ocaml_fn_10."<init>":()V
         619: astore        39
         621: aload         19
         623: checkcast     #8                  // class Block
         626: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         629: bipush        15
         631: aload         39
         633: aastore
         634: new           #89                 // class ocaml_fn_11
         637: dup
         638: invokespecial #90                 // Method ocaml_fn_11."<init>":()V
         641: astore        40
         643: aload         19
         645: checkcast     #8                  // class Block
         648: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         651: bipush        16
         653: aload         40
         655: aastore
         656: new           #92                 // class ocaml_fn_Stdlib_abs_12
         659: dup
         660: invokespecial #93                 // Method ocaml_fn_Stdlib_abs_12."<init>":()V
         663: astore        41
         665: aload         19
         667: checkcast     #8                  // class Block
         670: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         673: bipush        17
         675: aload         41
         677: aastore
         678: new           #95                 // class ocaml_fn_Stdlib_lnot_13
         681: dup
         682: invokespecial #96                 // Method ocaml_fn_Stdlib_lnot_13."<init>":()V
         685: astore        42
         687: aload         19
         689: checkcast     #8                  // class Block
         692: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         695: bipush        20
         697: aload         42
         699: aastore
         700: ldc2_w        #97                 // long 4611686018427387903l
         703: lstore        43
         705: aload         19
         707: checkcast     #8                  // class Block
         710: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        18
         715: lload         43
         717: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: ldc2_w        #99                 // long -4611686018427387904l
         724: lstore        45
         726: aload         19
         728: checkcast     #8                  // class Block
         731: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         734: bipush        19
         736: lload         45
         738: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         741: aastore
         742: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         745: bipush        38
         747: aaload
         748: astore        47
         750: aload         47
         752: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         755: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         758: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         761: astore        48
         763: aload         19
         765: checkcast     #8                  // class Block
         768: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         771: bipush        21
         773: aload         48
         775: aastore
         776: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         779: bipush        39
         781: aaload
         782: astore        49
         784: aload         49
         786: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         789: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         792: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         795: astore        50
         797: aload         19
         799: checkcast     #8                  // class Block
         802: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         805: bipush        22
         807: aload         50
         809: aastore
         810: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         813: bipush        40
         815: aaload
         816: astore        51
         818: aload         51
         820: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         823: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         826: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         829: astore        52
         831: aload         19
         833: checkcast     #8                  // class Block
         836: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         839: bipush        23
         841: aload         52
         843: aastore
         844: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         847: bipush        41
         849: aaload
         850: astore        53
         852: aload         53
         854: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         857: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         860: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         863: astore        54
         865: aload         19
         867: checkcast     #8                  // class Block
         870: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         873: bipush        24
         875: aload         54
         877: aastore
         878: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         881: bipush        42
         883: aaload
         884: astore        55
         886: aload         55
         888: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         891: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         894: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         897: astore        56
         899: aload         19
         901: checkcast     #8                  // class Block
         904: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         907: bipush        25
         909: aload         56
         911: aastore
         912: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
         915: bipush        43
         917: aaload
         918: astore        57
         920: aload         57
         922: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
         925: invokestatic  #110                // Method java/lang/Double.longBitsToDouble:(J)D
         928: invokestatic  #113                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         931: astore        58
         933: aload         19
         935: checkcast     #8                  // class Block
         938: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         941: bipush        26
         943: aload         58
         945: aastore
         946: new           #115                // class ocaml_fn_14
         949: dup
         950: invokespecial #116                // Method ocaml_fn_14."<init>":()V
         953: astore        59
         955: aload         19
         957: checkcast     #8                  // class Block
         960: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         963: bipush        27
         965: aload         59
         967: aastore
         968: new           #118                // class ocaml_fn_Stdlib_char_of_int_15
         971: dup
         972: aload         21
         974: invokespecial #121                // Method ocaml_fn_Stdlib_char_of_int_15."<init>":(Ljava/lang/Object;)V
         977: astore        60
         979: aload         19
         981: checkcast     #8                  // class Block
         984: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
         987: bipush        28
         989: aload         60
         991: aastore
         992: new           #123                // class ocaml_fn_Stdlib_string_of_bool_16
         995: dup
         996: invokespecial #124                // Method ocaml_fn_Stdlib_string_of_bool_16."<init>":()V
         999: astore        61
        1001: aload         19
        1003: checkcast     #8                  // class Block
        1006: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1009: bipush        29
        1011: aload         61
        1013: aastore
        1014: new           #126                // class ocaml_fn_Stdlib_bool_of_string_17
        1017: dup
        1018: aload         21
        1020: invokespecial #127                // Method ocaml_fn_Stdlib_bool_of_string_17."<init>":(Ljava/lang/Object;)V
        1023: astore        62
        1025: aload         19
        1027: checkcast     #8                  // class Block
        1030: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1033: bipush        31
        1035: aload         62
        1037: aastore
        1038: new           #129                // class ocaml_fn_Stdlib_bool_of_string_opt_18
        1041: dup
        1042: invokespecial #130                // Method ocaml_fn_Stdlib_bool_of_string_opt_18."<init>":()V
        1045: astore        63
        1047: aload         19
        1049: checkcast     #8                  // class Block
        1052: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1055: bipush        30
        1057: aload         63
        1059: aastore
        1060: new           #132                // class ocaml_fn_Stdlib_string_of_int_19
        1063: dup
        1064: invokespecial #133                // Method ocaml_fn_Stdlib_string_of_int_19."<init>":()V
        1067: astore        64
        1069: aload         19
        1071: checkcast     #8                  // class Block
        1074: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1077: bipush        32
        1079: aload         64
        1081: aastore
        1082: new           #135                // class ocaml_fn_Stdlib_int_of_string_opt_20
        1085: dup
        1086: aload         30
        1088: invokespecial #136                // Method ocaml_fn_Stdlib_int_of_string_opt_20."<init>":(Ljava/lang/Object;)V
        1091: astore        65
        1093: aload         19
        1095: checkcast     #8                  // class Block
        1098: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1101: bipush        33
        1103: aload         65
        1105: aastore
        1106: new           #138                // class ocaml_fn_Stdlib_valid_float_lexem_21
        1109: dup
        1110: aload         59
        1112: invokespecial #139                // Method ocaml_fn_Stdlib_valid_float_lexem_21."<init>":(Ljava/lang/Object;)V
        1115: astore        66
        1117: aload         19
        1119: checkcast     #8                  // class Block
        1122: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1125: bipush        100
        1127: aload         66
        1129: aastore
        1130: new           #141                // class ocaml_fn_Stdlib_string_of_float_22
        1133: dup
        1134: aload         66
        1136: invokespecial #142                // Method ocaml_fn_Stdlib_string_of_float_22."<init>":(Ljava/lang/Object;)V
        1139: astore        67
        1141: aload         19
        1143: checkcast     #8                  // class Block
        1146: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1149: bipush        34
        1151: aload         67
        1153: aastore
        1154: new           #144                // class ocaml_fn_Stdlib_float_of_string_opt_23
        1157: dup
        1158: aload         30
        1160: invokespecial #145                // Method ocaml_fn_Stdlib_float_of_string_opt_23."<init>":(Ljava/lang/Object;)V
        1163: astore        68
        1165: aload         19
        1167: checkcast     #8                  // class Block
        1170: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1173: bipush        35
        1175: aload         68
        1177: aastore
        1178: new           #147                // class ocaml_fn_24
        1181: dup
        1182: invokespecial #148                // Method ocaml_fn_24."<init>":()V
        1185: astore        69
        1187: aload         19
        1189: checkcast     #8                  // class Block
        1192: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1195: bipush        36
        1197: aload         69
        1199: aastore
        1200: new           #150                // class ocaml_fn_25
        1203: dup
        1204: invokespecial #151                // Method ocaml_fn_25."<init>":()V
        1207: astore        70
        1209: aload         69
        1211: checkcast     #147                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #153                // class Closure
        1219: putfield      #157                // Field ocaml_fn_24.sibling_0:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #147                // class ocaml_fn_24
        1234: aload         70
        1236: checkcast     #153                // class Closure
        1239: putfield      #160                // Field ocaml_fn_24.sibling_1:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         70
        1251: checkcast     #150                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #153                // class Closure
        1259: putfield      #161                // Field ocaml_fn_25.sibling_0:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: aload         70
        1271: checkcast     #150                // class ocaml_fn_25
        1274: aload         70
        1276: checkcast     #153                // class Closure
        1279: putfield      #162                // Field ocaml_fn_25.sibling_1:LClosure;
        1282: iconst_0
        1283: i2l
        1284: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1287: astore        74
        1289: iconst_0
        1290: i2l
        1291: lstore        75
        1293: lload         75
        1295: l2i
        1296: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1299: astore        77
        1301: aload         19
        1303: checkcast     #8                  // class Block
        1306: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1309: bipush        37
        1311: aload         77
        1313: aastore
        1314: iconst_1
        1315: i2l
        1316: lstore        78
        1318: lload         78
        1320: l2i
        1321: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1324: astore        80
        1326: aload         19
        1328: checkcast     #8                  // class Block
        1331: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1334: bipush        38
        1336: aload         80
        1338: aastore
        1339: iconst_2
        1340: i2l
        1341: lstore        81
        1343: lload         81
        1345: l2i
        1346: invokestatic  #166                // Method Channel.forDescriptor:(I)LChannel;
        1349: astore        83
        1351: aload         19
        1353: checkcast     #8                  // class Block
        1356: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1359: bipush        39
        1361: aload         83
        1363: aastore
        1364: new           #168                // class ocaml_fn_26
        1367: dup
        1368: invokespecial #169                // Method ocaml_fn_26."<init>":()V
        1371: astore        84
        1373: aload         19
        1375: checkcast     #8                  // class Block
        1378: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1381: bipush        61
        1383: aload         84
        1385: aastore
        1386: new           #171                // class ocaml_fn_Stdlib_open_out_27
        1389: dup
        1390: aload         84
        1392: invokespecial #172                // Method ocaml_fn_Stdlib_open_out_27."<init>":(Ljava/lang/Object;)V
        1395: astore        85
        1397: aload         19
        1399: checkcast     #8                  // class Block
        1402: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1405: bipush        59
        1407: aload         85
        1409: aastore
        1410: new           #174                // class ocaml_fn_Stdlib_open_out_bin_28
        1413: dup
        1414: aload         84
        1416: invokespecial #175                // Method ocaml_fn_Stdlib_open_out_bin_28."<init>":(Ljava/lang/Object;)V
        1419: astore        86
        1421: aload         19
        1423: checkcast     #8                  // class Block
        1426: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1429: bipush        60
        1431: aload         86
        1433: aastore
        1434: new           #177                // class ocaml_fn_Stdlib_flush_all_29
        1437: dup
        1438: aload         34
        1440: invokespecial #178                // Method ocaml_fn_Stdlib_flush_all_29."<init>":(Ljava/lang/Object;)V
        1443: astore        87
        1445: aload         19
        1447: checkcast     #8                  // class Block
        1450: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1453: bipush        63
        1455: aload         87
        1457: aastore
        1458: new           #180                // class ocaml_fn_30
        1461: dup
        1462: invokespecial #181                // Method ocaml_fn_30."<init>":()V
        1465: astore        88
        1467: aload         19
        1469: checkcast     #8                  // class Block
        1472: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1475: bipush        66
        1477: aload         88
        1479: aastore
        1480: new           #183                // class ocaml_fn_31
        1483: dup
        1484: invokespecial #184                // Method ocaml_fn_31."<init>":()V
        1487: astore        89
        1489: aload         19
        1491: checkcast     #8                  // class Block
        1494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1497: bipush        65
        1499: aload         89
        1501: aastore
        1502: new           #186                // class ocaml_fn_32
        1505: dup
        1506: aload         21
        1508: invokespecial #187                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1511: astore        90
        1513: aload         19
        1515: checkcast     #8                  // class Block
        1518: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1521: bipush        67
        1523: aload         90
        1525: aastore
        1526: new           #189                // class ocaml_fn_33
        1529: dup
        1530: aload         21
        1532: invokespecial #190                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1535: astore        91
        1537: aload         19
        1539: checkcast     #8                  // class Block
        1542: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1545: bipush        68
        1547: aload         91
        1549: aastore
        1550: new           #192                // class ocaml_fn_34
        1553: dup
        1554: invokespecial #193                // Method ocaml_fn_34."<init>":()V
        1557: astore        92
        1559: aload         19
        1561: checkcast     #8                  // class Block
        1564: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1567: bipush        71
        1569: aload         92
        1571: aastore
        1572: new           #195                // class ocaml_fn_Stdlib_close_out_35
        1575: dup
        1576: invokespecial #196                // Method ocaml_fn_Stdlib_close_out_35."<init>":()V
        1579: astore        93
        1581: aload         19
        1583: checkcast     #8                  // class Block
        1586: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1589: bipush        75
        1591: aload         93
        1593: aastore
        1594: new           #198                // class ocaml_fn_Stdlib_close_out_noerr_36
        1597: dup
        1598: invokespecial #199                // Method ocaml_fn_Stdlib_close_out_noerr_36."<init>":()V
        1601: astore        94
        1603: aload         19
        1605: checkcast     #8                  // class Block
        1608: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1611: bipush        76
        1613: aload         94
        1615: aastore
        1616: new           #201                // class ocaml_fn_37
        1619: dup
        1620: invokespecial #202                // Method ocaml_fn_37."<init>":()V
        1623: astore        95
        1625: aload         19
        1627: checkcast     #8                  // class Block
        1630: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1633: bipush        80
        1635: aload         95
        1637: aastore
        1638: new           #204                // class ocaml_fn_Stdlib_open_in_38
        1641: dup
        1642: aload         95
        1644: invokespecial #205                // Method ocaml_fn_Stdlib_open_in_38."<init>":(Ljava/lang/Object;)V
        1647: astore        96
        1649: aload         19
        1651: checkcast     #8                  // class Block
        1654: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1657: bipush        78
        1659: aload         96
        1661: aastore
        1662: new           #207                // class ocaml_fn_Stdlib_open_in_bin_39
        1665: dup
        1666: aload         95
        1668: invokespecial #208                // Method ocaml_fn_Stdlib_open_in_bin_39."<init>":(Ljava/lang/Object;)V
        1671: astore        97
        1673: aload         19
        1675: checkcast     #8                  // class Block
        1678: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1681: bipush        79
        1683: aload         97
        1685: aastore
        1686: new           #210                // class ocaml_fn_40
        1689: dup
        1690: aload         21
        1692: invokespecial #211                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1695: astore        98
        1697: aload         19
        1699: checkcast     #8                  // class Block
        1702: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1705: bipush        83
        1707: aload         98
        1709: aastore
        1710: new           #213                // class ocaml_fn_41
        1713: dup
        1714: aload         35
        1716: invokespecial #214                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         19
        1723: checkcast     #8                  // class Block
        1726: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        101
        1731: aload         99
        1733: aastore
        1734: new           #216                // class ocaml_fn_42
        1737: dup
        1738: aload         21
        1740: aload         99
        1742: invokespecial #219                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1745: astore        100
        1747: aload         19
        1749: checkcast     #8                  // class Block
        1752: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1755: bipush        84
        1757: aload         100
        1759: aastore
        1760: new           #221                // class ocaml_fn_43
        1763: dup
        1764: aload         100
        1766: invokespecial #222                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1769: astore        101
        1771: aload         19
        1773: checkcast     #8                  // class Block
        1776: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1779: bipush        85
        1781: aload         101
        1783: aastore
        1784: new           #224                // class ocaml_fn_Stdlib_input_line_44
        1787: dup
        1788: aload         35
        1790: invokespecial #225                // Method ocaml_fn_Stdlib_input_line_44."<init>":(Ljava/lang/Object;)V
        1793: astore        102
        1795: aload         19
        1797: checkcast     #8                  // class Block
        1800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1803: bipush        82
        1805: aload         102
        1807: aastore
        1808: new           #227                // class ocaml_fn_Stdlib_close_in_noerr_45
        1811: dup
        1812: invokespecial #228                // Method ocaml_fn_Stdlib_close_in_noerr_45."<init>":()V
        1815: astore        103
        1817: aload         19
        1819: checkcast     #8                  // class Block
        1822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1825: bipush        93
        1827: aload         103
        1829: aastore
        1830: new           #230                // class ocaml_fn_Stdlib_print_char_46
        1833: dup
        1834: aload         80
        1836: invokespecial #231                // Method ocaml_fn_Stdlib_print_char_46."<init>":(Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         19
        1843: checkcast     #8                  // class Block
        1846: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        40
        1851: aload         104
        1853: aastore
        1854: new           #233                // class ocaml_fn_Stdlib_print_string_47
        1857: dup
        1858: aload         80
        1860: aload         89
        1862: invokespecial #234                // Method ocaml_fn_Stdlib_print_string_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         19
        1869: checkcast     #8                  // class Block
        1872: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        41
        1877: aload         105
        1879: aastore
        1880: new           #236                // class ocaml_fn_Stdlib_print_bytes_48
        1883: dup
        1884: aload         80
        1886: aload         88
        1888: invokespecial #237                // Method ocaml_fn_Stdlib_print_bytes_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1891: astore        106
        1893: aload         19
        1895: checkcast     #8                  // class Block
        1898: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1901: bipush        42
        1903: aload         106
        1905: aastore
        1906: new           #239                // class ocaml_fn_Stdlib_print_int_49
        1909: dup
        1910: aload         64
        1912: aload         80
        1914: aload         89
        1916: invokespecial #242                // Method ocaml_fn_Stdlib_print_int_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1919: astore        107
        1921: aload         19
        1923: checkcast     #8                  // class Block
        1926: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1929: bipush        43
        1931: aload         107
        1933: aastore
        1934: new           #244                // class ocaml_fn_Stdlib_print_float_50
        1937: dup
        1938: aload         67
        1940: aload         80
        1942: aload         89
        1944: invokespecial #245                // Method ocaml_fn_Stdlib_print_float_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         19
        1951: checkcast     #8                  // class Block
        1954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        44
        1959: aload         108
        1961: aastore
        1962: new           #247                // class ocaml_fn_Stdlib_print_endline_51
        1965: dup
        1966: aload         80
        1968: aload         89
        1970: invokespecial #248                // Method ocaml_fn_Stdlib_print_endline_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1973: astore        109
        1975: aload         19
        1977: checkcast     #8                  // class Block
        1980: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        1983: bipush        45
        1985: aload         109
        1987: aastore
        1988: new           #250                // class ocaml_fn_Stdlib_print_newline_52
        1991: dup
        1992: aload         80
        1994: invokespecial #251                // Method ocaml_fn_Stdlib_print_newline_52."<init>":(Ljava/lang/Object;)V
        1997: astore        110
        1999: aload         19
        2001: checkcast     #8                  // class Block
        2004: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2007: bipush        46
        2009: aload         110
        2011: aastore
        2012: new           #253                // class ocaml_fn_Stdlib_prerr_char_53
        2015: dup
        2016: aload         83
        2018: invokespecial #254                // Method ocaml_fn_Stdlib_prerr_char_53."<init>":(Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         19
        2025: checkcast     #8                  // class Block
        2028: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        47
        2033: aload         111
        2035: aastore
        2036: new           #256                // class ocaml_fn_Stdlib_prerr_string_54
        2039: dup
        2040: aload         83
        2042: aload         89
        2044: invokespecial #257                // Method ocaml_fn_Stdlib_prerr_string_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         19
        2051: checkcast     #8                  // class Block
        2054: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        48
        2059: aload         112
        2061: aastore
        2062: new           #259                // class ocaml_fn_Stdlib_prerr_bytes_55
        2065: dup
        2066: aload         83
        2068: aload         88
        2070: invokespecial #260                // Method ocaml_fn_Stdlib_prerr_bytes_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        113
        2075: aload         19
        2077: checkcast     #8                  // class Block
        2080: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2083: bipush        49
        2085: aload         113
        2087: aastore
        2088: new           #262                // class ocaml_fn_Stdlib_prerr_int_56
        2091: dup
        2092: aload         64
        2094: aload         83
        2096: aload         89
        2098: invokespecial #263                // Method ocaml_fn_Stdlib_prerr_int_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2101: astore        114
        2103: aload         19
        2105: checkcast     #8                  // class Block
        2108: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2111: bipush        50
        2113: aload         114
        2115: aastore
        2116: new           #265                // class ocaml_fn_Stdlib_prerr_float_57
        2119: dup
        2120: aload         67
        2122: aload         83
        2124: aload         89
        2126: invokespecial #266                // Method ocaml_fn_Stdlib_prerr_float_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         19
        2133: checkcast     #8                  // class Block
        2136: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        51
        2141: aload         115
        2143: aastore
        2144: new           #268                // class ocaml_fn_Stdlib_prerr_endline_58
        2147: dup
        2148: aload         83
        2150: aload         89
        2152: invokespecial #269                // Method ocaml_fn_Stdlib_prerr_endline_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2155: astore        116
        2157: aload         19
        2159: checkcast     #8                  // class Block
        2162: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2165: bipush        52
        2167: aload         116
        2169: aastore
        2170: new           #271                // class ocaml_fn_Stdlib_prerr_newline_59
        2173: dup
        2174: aload         83
        2176: invokespecial #272                // Method ocaml_fn_Stdlib_prerr_newline_59."<init>":(Ljava/lang/Object;)V
        2179: astore        117
        2181: aload         19
        2183: checkcast     #8                  // class Block
        2186: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2189: bipush        53
        2191: aload         117
        2193: aastore
        2194: new           #274                // class ocaml_fn_Stdlib_read_line_60
        2197: dup
        2198: aload         77
        2200: aload         80
        2202: aload         102
        2204: invokespecial #275                // Method ocaml_fn_Stdlib_read_line_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2207: astore        118
        2209: aload         19
        2211: checkcast     #8                  // class Block
        2214: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2217: bipush        54
        2219: aload         118
        2221: aastore
        2222: new           #277                // class ocaml_fn_Stdlib_read_int_61
        2225: dup
        2226: aload         118
        2228: invokespecial #278                // Method ocaml_fn_Stdlib_read_int_61."<init>":(Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         19
        2235: checkcast     #8                  // class Block
        2238: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        56
        2243: aload         119
        2245: aastore
        2246: new           #280                // class ocaml_fn_Stdlib_read_int_opt_62
        2249: dup
        2250: aload         65
        2252: aload         118
        2254: invokespecial #281                // Method ocaml_fn_Stdlib_read_int_opt_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2257: astore        120
        2259: aload         19
        2261: checkcast     #8                  // class Block
        2264: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2267: bipush        55
        2269: aload         120
        2271: aastore
        2272: new           #283                // class ocaml_fn_Stdlib_read_float_63
        2275: dup
        2276: aload         118
        2278: invokespecial #284                // Method ocaml_fn_Stdlib_read_float_63."<init>":(Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         19
        2285: checkcast     #8                  // class Block
        2288: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        58
        2293: aload         121
        2295: aastore
        2296: new           #286                // class ocaml_fn_Stdlib_read_float_opt_64
        2299: dup
        2300: aload         68
        2302: aload         118
        2304: invokespecial #287                // Method ocaml_fn_Stdlib_read_float_opt_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2307: astore        122
        2309: aload         19
        2311: checkcast     #8                  // class Block
        2314: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2317: bipush        57
        2319: aload         122
        2321: aastore
        2322: new           #289                // class ocaml_fn_Stdlib_string_of_format_65
        2325: dup
        2326: invokespecial #290                // Method ocaml_fn_Stdlib_string_of_format_65."<init>":()V
        2329: astore        123
        2331: aload         19
        2333: checkcast     #8                  // class Block
        2336: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2339: bipush        96
        2341: aload         123
        2343: aastore
        2344: new           #292                // class ocaml_fn_66
        2347: dup
        2348: aload         59
        2350: invokespecial #293                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2353: astore        124
        2355: aload         19
        2357: checkcast     #8                  // class Block
        2360: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        97
        2365: aload         124
        2367: aastore
        2368: new           #8                  // class Block
        2371: dup
        2372: iconst_0
        2373: iconst_1
        2374: anewarray     #10                 // class java/lang/Object
        2377: dup
        2378: iconst_0
        2379: aload         87
        2381: aastore
        2382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        125
        2387: new           #295                // class ocaml_fn_Stdlib_at_exit_67
        2390: dup
        2391: aload         125
        2393: invokespecial #296                // Method ocaml_fn_Stdlib_at_exit_67."<init>":(Ljava/lang/Object;)V
        2396: astore        126
        2398: aload         19
        2400: checkcast     #8                  // class Block
        2403: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2406: bipush        99
        2408: aload         126
        2410: aastore
        2411: new           #298                // class ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68
        2414: dup
        2415: invokespecial #299                // Method ocaml_fn_Stdlib_do_domain_local_at_exit__fun__68."<init>":()V
        2418: astore        127
        2420: new           #8                  // class Block
        2423: dup
        2424: iconst_0
        2425: iconst_1
        2426: anewarray     #10                 // class java/lang/Object
        2429: dup
        2430: iconst_0
        2431: aload         127
        2433: aastore
        2434: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         19
        2441: checkcast     #8                  // class Block
        2444: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        103
        2449: aload         128
        2451: aastore
        2452: new           #301                // class ocaml_fn_Stdlib_do_at_exit_69
        2455: dup
        2456: aload         125
        2458: aload         128
        2460: invokespecial #302                // Method ocaml_fn_Stdlib_do_at_exit_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2463: astore        129
        2465: aload         19
        2467: checkcast     #8                  // class Block
        2470: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2473: bipush        102
        2475: aload         129
        2477: aastore
        2478: new           #304                // class ocaml_fn_Stdlib_exit_70
        2481: dup
        2482: aload         129
        2484: invokespecial #305                // Method ocaml_fn_Stdlib_exit_70."<init>":(Ljava/lang/Object;)V
        2487: astore        130
        2489: aload         19
        2491: checkcast     #8                  // class Block
        2494: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2497: bipush        98
        2499: aload         130
        2501: aastore
        2502: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        2505: bipush        44
        2507: aaload
        2508: astore        131
        2510: aload         131
        2512: aload         129
        2514: invokestatic  #71                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2517: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2520: astore        132
        2522: new           #8                  // class Block
        2525: dup
        2526: iconst_0
        2527: bipush        6
        2529: anewarray     #10                 // class java/lang/Object
        2532: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2535: astore        133
        2537: new           #307                // class ocaml_fn_71
        2540: dup
        2541: invokespecial #308                // Method ocaml_fn_71."<init>":()V
        2544: astore        134
        2546: aload         133
        2548: checkcast     #8                  // class Block
        2551: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_5
        2555: aload         134
        2557: aastore
        2558: new           #310                // class ocaml_fn_72
        2561: dup
        2562: invokespecial #311                // Method ocaml_fn_72."<init>":()V
        2565: astore        135
        2567: aload         133
        2569: checkcast     #8                  // class Block
        2572: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_4
        2576: aload         135
        2578: aastore
        2579: new           #313                // class ocaml_fn_73
        2582: dup
        2583: invokespecial #314                // Method ocaml_fn_73."<init>":()V
        2586: astore        136
        2588: aload         133
        2590: checkcast     #8                  // class Block
        2593: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_3
        2597: aload         136
        2599: aastore
        2600: new           #316                // class ocaml_fn_74
        2603: dup
        2604: invokespecial #317                // Method ocaml_fn_74."<init>":()V
        2607: astore        137
        2609: aload         133
        2611: checkcast     #8                  // class Block
        2614: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_2
        2618: aload         137
        2620: aastore
        2621: new           #319                // class ocaml_fn_75
        2624: dup
        2625: invokespecial #320                // Method ocaml_fn_75."<init>":()V
        2628: astore        138
        2630: aload         133
        2632: checkcast     #8                  // class Block
        2635: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_1
        2639: aload         138
        2641: aastore
        2642: new           #322                // class ocaml_fn_76
        2645: dup
        2646: invokespecial #323                // Method ocaml_fn_76."<init>":()V
        2649: astore        139
        2651: aload         133
        2653: checkcast     #8                  // class Block
        2656: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2659: iconst_0
        2660: aload         139
        2662: aastore
        2663: aload         19
        2665: checkcast     #8                  // class Block
        2668: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        95
        2673: aload         133
        2675: aastore
        2676: new           #325                // class ocaml_fn_77
        2679: dup
        2680: invokespecial #326                // Method ocaml_fn_77."<init>":()V
        2683: astore        140
        2685: aload         19
        2687: checkcast     #8                  // class Block
        2690: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        94
        2695: aload         140
        2697: aastore
        2698: new           #328                // class ocaml_fn_78
        2701: dup
        2702: invokespecial #329                // Method ocaml_fn_78."<init>":()V
        2705: astore        141
        2707: aload         19
        2709: checkcast     #8                  // class Block
        2712: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        92
        2717: aload         141
        2719: aastore
        2720: new           #331                // class ocaml_fn_79
        2723: dup
        2724: invokespecial #332                // Method ocaml_fn_79."<init>":()V
        2727: astore        142
        2729: aload         19
        2731: checkcast     #8                  // class Block
        2734: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        91
        2739: aload         142
        2741: aastore
        2742: new           #334                // class ocaml_fn_80
        2745: dup
        2746: invokespecial #335                // Method ocaml_fn_80."<init>":()V
        2749: astore        143
        2751: aload         19
        2753: checkcast     #8                  // class Block
        2756: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        90
        2761: aload         143
        2763: aastore
        2764: new           #337                // class ocaml_fn_81
        2767: dup
        2768: invokespecial #338                // Method ocaml_fn_81."<init>":()V
        2771: astore        144
        2773: aload         19
        2775: checkcast     #8                  // class Block
        2778: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        89
        2783: aload         144
        2785: aastore
        2786: new           #340                // class ocaml_fn_82
        2789: dup
        2790: invokespecial #341                // Method ocaml_fn_82."<init>":()V
        2793: astore        145
        2795: aload         19
        2797: checkcast     #8                  // class Block
        2800: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        88
        2805: aload         145
        2807: aastore
        2808: new           #343                // class ocaml_fn_83
        2811: dup
        2812: invokespecial #344                // Method ocaml_fn_83."<init>":()V
        2815: astore        146
        2817: aload         19
        2819: checkcast     #8                  // class Block
        2822: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        87
        2827: aload         146
        2829: aastore
        2830: new           #346                // class ocaml_fn_84
        2833: dup
        2834: invokespecial #347                // Method ocaml_fn_84."<init>":()V
        2837: astore        147
        2839: aload         19
        2841: checkcast     #8                  // class Block
        2844: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        86
        2849: aload         147
        2851: aastore
        2852: new           #349                // class ocaml_fn_85
        2855: dup
        2856: invokespecial #350                // Method ocaml_fn_85."<init>":()V
        2859: astore        148
        2861: aload         19
        2863: checkcast     #8                  // class Block
        2866: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        81
        2871: aload         148
        2873: aastore
        2874: new           #352                // class ocaml_fn_86
        2877: dup
        2878: invokespecial #353                // Method ocaml_fn_86."<init>":()V
        2881: astore        149
        2883: aload         19
        2885: checkcast     #8                  // class Block
        2888: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        77
        2893: aload         149
        2895: aastore
        2896: new           #355                // class ocaml_fn_87
        2899: dup
        2900: invokespecial #356                // Method ocaml_fn_87."<init>":()V
        2903: astore        150
        2905: aload         19
        2907: checkcast     #8                  // class Block
        2910: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        74
        2915: aload         150
        2917: aastore
        2918: new           #358                // class ocaml_fn_88
        2921: dup
        2922: invokespecial #359                // Method ocaml_fn_88."<init>":()V
        2925: astore        151
        2927: aload         19
        2929: checkcast     #8                  // class Block
        2932: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        73
        2937: aload         151
        2939: aastore
        2940: new           #361                // class ocaml_fn_89
        2943: dup
        2944: invokespecial #362                // Method ocaml_fn_89."<init>":()V
        2947: astore        152
        2949: aload         19
        2951: checkcast     #8                  // class Block
        2954: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        72
        2959: aload         152
        2961: aastore
        2962: new           #364                // class ocaml_fn_90
        2965: dup
        2966: invokespecial #365                // Method ocaml_fn_90."<init>":()V
        2969: astore        153
        2971: aload         19
        2973: checkcast     #8                  // class Block
        2976: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        70
        2981: aload         153
        2983: aastore
        2984: new           #367                // class ocaml_fn_91
        2987: dup
        2988: invokespecial #368                // Method ocaml_fn_91."<init>":()V
        2991: astore        154
        2993: aload         19
        2995: checkcast     #8                  // class Block
        2998: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3001: bipush        69
        3003: aload         154
        3005: aastore
        3006: new           #370                // class ocaml_fn_92
        3009: dup
        3010: invokespecial #371                // Method ocaml_fn_92."<init>":()V
        3013: astore        155
        3015: aload         19
        3017: checkcast     #8                  // class Block
        3020: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3023: bipush        64
        3025: aload         155
        3027: aastore
        3028: new           #373                // class ocaml_fn_93
        3031: dup
        3032: invokespecial #374                // Method ocaml_fn_93."<init>":()V
        3035: astore        156
        3037: aload         19
        3039: checkcast     #8                  // class Block
        3042: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3045: bipush        62
        3047: aload         156
        3049: aastore
        3050: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        45
        3055: aload         19
        3057: aastore
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        157
        3065: iconst_0
        3066: i2l
        3067: lstore        158
        3069: lload         158
        3071: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: astore        160
        3076: goto_w        3081
        3081: iconst_1
        3082: i2l
        3083: lstore        161
        3085: iconst_0
        3086: i2l
        3087: lstore        163
        3089: lload         163
        3091: iconst_0
        3092: i2l
        3093: lcmp
        3094: ifeq          3109
        3097: lload         161
        3099: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3102: astore        165
        3104: goto_w        3138
        3109: lload         161
        3111: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3114: astore        166
        3116: goto_w        3121
        3121: bipush        10
        3123: i2l
        3124: lstore        167
        3126: lload         167
        3128: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3131: astore        169
        3133: goto_w        3155
        3138: bipush        20
        3140: i2l
        3141: lstore        170
        3143: lload         170
        3145: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3148: astore        169
        3150: goto_w        3155
        3155: getstatic     #378                // Field java/lang/System.out:Ljava/io/PrintStream;
        3158: aload         169
        3160: invokestatic  #104                // Method Block.asLong:(Ljava/lang/Object;)J
        3163: l2i
        3164: invokevirtual #384                // Method java/io/PrintStream.println:(I)V
        3167: iconst_0
        3168: i2l
        3169: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3172: astore        172
        3174: new           #8                  // class Block
        3177: dup
        3178: iconst_0
        3179: iconst_0
        3180: anewarray     #10                 // class java/lang/Object
        3183: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3186: astore        173
        3188: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3191: bipush        46
        3193: aload         173
        3195: aastore
        3196: iconst_0
        3197: i2l
        3198: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3201: astore        174
        3203: iconst_0
        3204: i2l
        3205: lstore        175
        3207: lload         175
        3209: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3212: astore        177
        3214: goto_w        3219
        3219: iconst_0
        3220: i2l
        3221: lstore        178
        3223: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3226: bipush        45
        3228: aaload
        3229: checkcast     #8                  // class Block
        3232: getfield      #77                 // Field Block.fields:[Ljava/lang/Object;
        3235: bipush        102
        3237: aaload
        3238: astore        180
        3240: aload         180
        3242: checkcast     #153                // class Closure
        3245: lload         178
        3247: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3250: invokevirtual #388                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3253: astore        181
        3255: new           #8                  // class Block
        3258: dup
        3259: iconst_0
        3260: iconst_0
        3261: anewarray     #10                 // class java/lang/Object
        3264: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3267: astore        182
        3269: getstatic     #31                 // Field GLOBALS:[Ljava/lang/Object;
        3272: bipush        47
        3274: aload         182
        3276: aastore
        3277: iconst_0
        3278: i2l
        3279: invokestatic  #67                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3282: astore        183
        3284: return
    }
    |}]
