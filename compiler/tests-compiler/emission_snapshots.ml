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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3037: bipush        46
        3039: aaload
        3040: astore        157
        3042: getstatic     #364                // Field java/lang/System.out:Ljava/io/PrintStream;
        3045: aload         157
        3047: checkcast     #366                // class java/lang/String
        3050: invokevirtual #372                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3053: iconst_0
        3054: i2l
        3055: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3058: astore        158
        3060: new           #2                  // class Block
        3063: dup
        3064: iconst_0
        3065: iconst_0
        3066: anewarray     #4                  // class java/lang/Object
        3069: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3072: astore        159
        3074: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3077: bipush        47
        3079: aload         159
        3081: aastore
        3082: iconst_0
        3083: i2l
        3084: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3087: astore        160
        3089: iconst_0
        3090: i2l
        3091: lstore        161
        3093: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3096: bipush        45
        3098: aaload
        3099: checkcast     #2                  // class Block
        3102: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3105: bipush        102
        3107: aaload
        3108: astore        163
        3110: aload         163
        3112: checkcast     #139                // class Closure
        3115: lload         161
        3117: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3120: invokevirtual #376                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3123: astore        164
        3125: new           #2                  // class Block
        3128: dup
        3129: iconst_0
        3130: iconst_0
        3131: anewarray     #4                  // class java/lang/Object
        3134: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3137: astore        165
        3139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3142: bipush        48
        3144: aload         165
        3146: aastore
        3147: iconst_0
        3148: i2l
        3149: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3152: astore        166
        3154: return
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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: bipush        8
        3036: i2l
        3037: lstore        157
        3039: getstatic     #364                // Field java/lang/System.out:Ljava/io/PrintStream;
        3042: lload         157
        3044: l2i
        3045: invokevirtual #370                // Method java/io/PrintStream.println:(I)V
        3048: iconst_0
        3049: i2l
        3050: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3053: astore        159
        3055: new           #2                  // class Block
        3058: dup
        3059: iconst_0
        3060: iconst_0
        3061: anewarray     #4                  // class java/lang/Object
        3064: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3067: astore        160
        3069: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3072: bipush        46
        3074: aload         160
        3076: aastore
        3077: iconst_0
        3078: i2l
        3079: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3082: astore        161
        3084: iconst_0
        3085: i2l
        3086: lstore        162
        3088: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3091: bipush        45
        3093: aaload
        3094: checkcast     #2                  // class Block
        3097: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3100: bipush        102
        3102: aaload
        3103: astore        164
        3105: aload         164
        3107: checkcast     #139                // class Closure
        3110: lload         162
        3112: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3115: invokevirtual #374                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3118: astore        165
        3120: new           #2                  // class Block
        3123: dup
        3124: iconst_0
        3125: iconst_0
        3126: anewarray     #4                  // class java/lang/Object
        3129: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3132: astore        166
        3134: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3137: bipush        47
        3139: aload         166
        3141: aastore
        3142: iconst_0
        3143: i2l
        3144: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3147: astore        167
        3149: return
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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: iconst_0
        3035: i2l
        3036: lstore        157
        3038: lload         157
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        159
        3045: goto_w        3050
        3050: new           #362                // class ocaml_fn_95
        3053: dup
        3054: invokespecial #363                // Method ocaml_fn_95."<init>":()V
        3057: astore        160
        3059: bipush        10
        3061: i2l
        3062: lstore        161
        3064: aload         160
        3066: lload         161
        3068: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3071: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3074: astore        163
        3076: bipush        32
        3078: i2l
        3079: lstore        164
        3081: aload         163
        3083: checkcast     #139                // class Closure
        3086: lload         164
        3088: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3091: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3094: astore        166
        3096: getstatic     #371                // Field java/lang/System.out:Ljava/io/PrintStream;
        3099: aload         166
        3101: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
        3104: l2i
        3105: invokevirtual #377                // Method java/io/PrintStream.println:(I)V
        3108: iconst_0
        3109: i2l
        3110: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3113: astore        167
        3115: new           #2                  // class Block
        3118: dup
        3119: iconst_0
        3120: iconst_1
        3121: anewarray     #4                  // class java/lang/Object
        3124: dup
        3125: iconst_0
        3126: aload         160
        3128: aastore
        3129: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3132: astore        168
        3134: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3137: bipush        46
        3139: aload         168
        3141: aastore
        3142: iconst_0
        3143: i2l
        3144: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3147: astore        169
        3149: iconst_0
        3150: i2l
        3151: lstore        170
        3153: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3156: bipush        45
        3158: aaload
        3159: checkcast     #2                  // class Block
        3162: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3165: bipush        102
        3167: aaload
        3168: astore        172
        3170: aload         172
        3172: checkcast     #139                // class Closure
        3175: lload         170
        3177: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3180: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3183: astore        173
        3185: new           #2                  // class Block
        3188: dup
        3189: iconst_0
        3190: iconst_0
        3191: anewarray     #4                  // class java/lang/Object
        3194: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3197: astore        174
        3199: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3202: bipush        47
        3204: aload         174
        3206: aastore
        3207: iconst_0
        3208: i2l
        3209: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3212: astore        175
        3214: return
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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: iconst_0
        3035: i2l
        3036: lstore        157
        3038: lload         157
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        159
        3045: goto_w        3050
        3050: new           #362                // class ocaml_fn_94
        3053: dup
        3054: invokespecial #363                // Method ocaml_fn_94."<init>":()V
        3057: astore        160
        3059: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3062: bipush        46
        3064: aaload
        3065: astore        161
        3067: aload         160
        3069: aload         161
        3071: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3074: astore        162
        3076: getstatic     #371                // Field java/lang/System.out:Ljava/io/PrintStream;
        3079: aload         162
        3081: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
        3084: l2i
        3085: invokevirtual #377                // Method java/io/PrintStream.println:(I)V
        3088: iconst_0
        3089: i2l
        3090: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3093: astore        163
        3095: new           #2                  // class Block
        3098: dup
        3099: iconst_0
        3100: iconst_1
        3101: anewarray     #4                  // class java/lang/Object
        3104: dup
        3105: iconst_0
        3106: aload         160
        3108: aastore
        3109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3112: astore        164
        3114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3117: bipush        47
        3119: aload         164
        3121: aastore
        3122: iconst_0
        3123: i2l
        3124: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3127: astore        165
        3129: iconst_0
        3130: i2l
        3131: lstore        166
        3133: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3136: bipush        45
        3138: aaload
        3139: checkcast     #2                  // class Block
        3142: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3145: bipush        102
        3147: aaload
        3148: astore        168
        3150: aload         168
        3152: checkcast     #139                // class Closure
        3155: lload         166
        3157: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3160: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3163: astore        169
        3165: new           #2                  // class Block
        3168: dup
        3169: iconst_0
        3170: iconst_0
        3171: anewarray     #4                  // class java/lang/Object
        3174: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3177: astore        170
        3179: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3182: bipush        48
        3184: aload         170
        3186: aastore
        3187: iconst_0
        3188: i2l
        3189: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3192: astore        171
        3194: return
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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: iconst_0
        3035: i2l
        3036: lstore        157
        3038: lload         157
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        159
        3045: goto_w        3050
        3050: iconst_0
        3051: i2l
        3052: lstore        160
        3054: iconst_1
        3055: i2l
        3056: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3059: astore        162
        3061: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3064: bipush        46
        3066: aaload
        3067: astore        163
        3069: new           #2                  // class Block
        3072: dup
        3073: sipush        248
        3076: iconst_2
        3077: anewarray     #4                  // class java/lang/Object
        3080: dup
        3081: iconst_0
        3082: aload         163
        3084: aastore
        3085: dup
        3086: iconst_1
        3087: aload         162
        3089: aastore
        3090: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3093: astore        164
        3095: new           #362                // class ocaml_fn_94
        3098: dup
        3099: aload         164
        3101: invokespecial #363                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3104: astore        165
        3106: iconst_0
        3107: i2l
        3108: lstore        166
        3110: aload         165
        3112: lload         166
        3114: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3117: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3120: astore        168
        3122: getstatic     #371                // Field java/lang/System.out:Ljava/io/PrintStream;
        3125: aload         168
        3127: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
        3130: l2i
        3131: invokevirtual #377                // Method java/io/PrintStream.println:(I)V
        3134: iconst_0
        3135: i2l
        3136: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3139: astore        169
        3141: new           #2                  // class Block
        3144: dup
        3145: iconst_0
        3146: iconst_2
        3147: anewarray     #4                  // class java/lang/Object
        3150: dup
        3151: iconst_0
        3152: aload         164
        3154: aastore
        3155: dup
        3156: iconst_1
        3157: aload         165
        3159: aastore
        3160: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3163: astore        170
        3165: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3168: bipush        47
        3170: aload         170
        3172: aastore
        3173: iconst_0
        3174: i2l
        3175: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3178: astore        171
        3180: iconst_0
        3181: i2l
        3182: lstore        172
        3184: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3187: bipush        45
        3189: aaload
        3190: checkcast     #2                  // class Block
        3193: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3196: bipush        102
        3198: aaload
        3199: astore        174
        3201: aload         174
        3203: checkcast     #139                // class Closure
        3206: lload         172
        3208: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3211: invokevirtual #367                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3214: astore        175
        3216: new           #2                  // class Block
        3219: dup
        3220: iconst_0
        3221: iconst_0
        3222: anewarray     #4                  // class java/lang/Object
        3225: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3228: astore        176
        3230: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3233: bipush        48
        3235: aload         176
        3237: aastore
        3238: iconst_0
        3239: i2l
        3240: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3243: astore        177
        3245: return
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
          42: invokestatic  #31                 // Method Main$globals_0.init:()V
          45: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          48: iconst_4
          49: aaload
          50: putstatic     #37                 // Field Channel.endOfFileExn:Ljava/lang/Object;
          53: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          56: iconst_2
          57: aaload
          58: putstatic     #42                 // Field Ocaml.failureExn:Ljava/lang/Object;
          61: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
          64: bipush        6
          66: aaload
          67: putstatic     #45                 // Field Ocaml.notFoundExn:Ljava/lang/Object;
          70: aconst_null
          71: astore_0
          72: aload_0
          73: astore_1
          74: goto_w        79
          79: new           #47                 // class ocaml_fn_0
          82: dup
          83: invokespecial #49                 // Method ocaml_fn_0."<init>":()V
          86: astore_2
          87: new           #51                 // class ocaml_fn_1
          90: dup
          91: invokespecial #52                 // Method ocaml_fn_1."<init>":()V
          94: astore_3
          95: new           #54                 // class ocaml_fn_2
          98: dup
          99: invokespecial #55                 // Method ocaml_fn_2."<init>":()V
         102: astore        4
         104: new           #2                  // class Block
         107: dup
         108: iconst_0
         109: iconst_3
         110: anewarray     #4                  // class java/lang/Object
         113: dup
         114: iconst_0
         115: aload_3
         116: aastore
         117: dup
         118: iconst_1
         119: aload_2
         120: aastore
         121: dup
         122: iconst_2
         123: aload         4
         125: aastore
         126: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         129: astore        5
         131: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         134: bipush        12
         136: aload         5
         138: aastore
         139: iconst_0
         140: i2l
         141: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         144: astore        6
         146: iconst_0
         147: i2l
         148: lstore        7
         150: lload         7
         152: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         155: astore        9
         157: goto_w        162
         162: sipush        199
         165: i2l
         166: lstore        10
         168: iconst_0
         169: i2l
         170: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         173: astore        12
         175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         178: bipush        35
         180: aaload
         181: astore        13
         183: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         186: iconst_3
         187: aaload
         188: astore        14
         190: new           #2                  // class Block
         193: dup
         194: iconst_0
         195: iconst_2
         196: anewarray     #4                  // class java/lang/Object
         199: dup
         200: iconst_0
         201: aload         14
         203: aastore
         204: dup
         205: iconst_1
         206: aload         13
         208: aastore
         209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         212: astore        15
         214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         217: bipush        36
         219: aaload
         220: astore        16
         222: iconst_0
         223: i2l
         224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         227: astore        17
         229: new           #2                  // class Block
         232: dup
         233: iconst_0
         234: bipush        104
         236: anewarray     #4                  // class java/lang/Object
         239: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         242: astore        18
         244: new           #63                 // class ocaml_fn_8
         247: dup
         248: invokespecial #64                 // Method ocaml_fn_8."<init>":()V
         251: astore        19
         253: aload         18
         255: checkcast     #2                  // class Block
         258: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         261: iconst_1
         262: aload         19
         264: aastore
         265: new           #69                 // class ocaml_fn_9
         268: dup
         269: invokespecial #70                 // Method ocaml_fn_9."<init>":()V
         272: astore        20
         274: aload         18
         276: checkcast     #2                  // class Block
         279: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         282: iconst_0
         283: aload         20
         285: aastore
         286: iconst_0
         287: i2l
         288: lstore        21
         290: iconst_0
         291: i2l
         292: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         295: astore        23
         297: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         300: bipush        37
         302: aaload
         303: astore        24
         305: new           #2                  // class Block
         308: dup
         309: sipush        248
         312: iconst_2
         313: anewarray     #4                  // class java/lang/Object
         316: dup
         317: iconst_0
         318: aload         24
         320: aastore
         321: dup
         322: iconst_1
         323: aload         23
         325: aastore
         326: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         329: astore        25
         331: aload         18
         333: checkcast     #2                  // class Block
         336: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         339: iconst_2
         340: aload         25
         342: aastore
         343: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         346: bipush        7
         348: aaload
         349: astore        26
         351: aload         18
         353: checkcast     #2                  // class Block
         356: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         359: iconst_3
         360: aload         26
         362: aastore
         363: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         366: bipush        10
         368: aaload
         369: astore        27
         371: aload         18
         373: checkcast     #2                  // class Block
         376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         379: iconst_4
         380: aload         27
         382: aastore
         383: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         386: iconst_3
         387: aaload
         388: astore        28
         390: aload         18
         392: checkcast     #2                  // class Block
         395: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         398: iconst_5
         399: aload         28
         401: aastore
         402: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         405: iconst_2
         406: aaload
         407: astore        29
         409: aload         18
         411: checkcast     #2                  // class Block
         414: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         417: bipush        6
         419: aload         29
         421: aastore
         422: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         425: bipush        6
         427: aaload
         428: astore        30
         430: aload         18
         432: checkcast     #2                  // class Block
         435: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         438: bipush        7
         440: aload         30
         442: aastore
         443: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         446: iconst_0
         447: aaload
         448: astore        31
         450: aload         18
         452: checkcast     #2                  // class Block
         455: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         458: bipush        8
         460: aload         31
         462: aastore
         463: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         466: bipush        8
         468: aaload
         469: astore        32
         471: aload         18
         473: checkcast     #2                  // class Block
         476: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         479: bipush        9
         481: aload         32
         483: aastore
         484: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         487: iconst_1
         488: aaload
         489: astore        33
         491: aload         18
         493: checkcast     #2                  // class Block
         496: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         499: bipush        10
         501: aload         33
         503: aastore
         504: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         507: iconst_4
         508: aaload
         509: astore        34
         511: aload         18
         513: checkcast     #2                  // class Block
         516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         519: bipush        11
         521: aload         34
         523: aastore
         524: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         527: iconst_5
         528: aaload
         529: astore        35
         531: aload         18
         533: checkcast     #2                  // class Block
         536: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         539: bipush        12
         541: aload         35
         543: aastore
         544: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         547: bipush        9
         549: aaload
         550: astore        36
         552: aload         18
         554: checkcast     #2                  // class Block
         557: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         560: bipush        13
         562: aload         36
         564: aastore
         565: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         568: bipush        11
         570: aaload
         571: astore        37
         573: aload         18
         575: checkcast     #2                  // class Block
         578: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        14
         583: aload         37
         585: aastore
         586: new           #72                 // class ocaml_fn_10
         589: dup
         590: invokespecial #73                 // Method ocaml_fn_10."<init>":()V
         593: astore        38
         595: aload         18
         597: checkcast     #2                  // class Block
         600: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        15
         605: aload         38
         607: aastore
         608: new           #75                 // class ocaml_fn_11
         611: dup
         612: invokespecial #76                 // Method ocaml_fn_11."<init>":()V
         615: astore        39
         617: aload         18
         619: checkcast     #2                  // class Block
         622: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        16
         627: aload         39
         629: aastore
         630: new           #78                 // class ocaml_fn_12
         633: dup
         634: invokespecial #79                 // Method ocaml_fn_12."<init>":()V
         637: astore        40
         639: aload         18
         641: checkcast     #2                  // class Block
         644: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        17
         649: aload         40
         651: aastore
         652: new           #81                 // class ocaml_fn_13
         655: dup
         656: invokespecial #82                 // Method ocaml_fn_13."<init>":()V
         659: astore        41
         661: aload         18
         663: checkcast     #2                  // class Block
         666: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         669: bipush        20
         671: aload         41
         673: aastore
         674: ldc2_w        #83                 // long 4611686018427387903l
         677: lstore        42
         679: aload         18
         681: checkcast     #2                  // class Block
         684: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         687: bipush        18
         689: lload         42
         691: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         694: aastore
         695: ldc2_w        #85                 // long -4611686018427387904l
         698: lstore        44
         700: aload         18
         702: checkcast     #2                  // class Block
         705: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         708: bipush        19
         710: lload         44
         712: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         715: aastore
         716: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         719: bipush        38
         721: aaload
         722: astore        46
         724: aload         46
         726: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         729: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         732: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         735: astore        47
         737: aload         18
         739: checkcast     #2                  // class Block
         742: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         745: bipush        21
         747: aload         47
         749: aastore
         750: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         753: bipush        39
         755: aaload
         756: astore        48
         758: aload         48
         760: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         763: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         766: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         769: astore        49
         771: aload         18
         773: checkcast     #2                  // class Block
         776: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         779: bipush        22
         781: aload         49
         783: aastore
         784: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         787: bipush        40
         789: aaload
         790: astore        50
         792: aload         50
         794: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         797: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         800: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         803: astore        51
         805: aload         18
         807: checkcast     #2                  // class Block
         810: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         813: bipush        23
         815: aload         51
         817: aastore
         818: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         821: bipush        41
         823: aaload
         824: astore        52
         826: aload         52
         828: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         831: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         834: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         837: astore        53
         839: aload         18
         841: checkcast     #2                  // class Block
         844: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         847: bipush        24
         849: aload         53
         851: aastore
         852: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         855: bipush        42
         857: aaload
         858: astore        54
         860: aload         54
         862: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         865: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         868: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         871: astore        55
         873: aload         18
         875: checkcast     #2                  // class Block
         878: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         881: bipush        25
         883: aload         55
         885: aastore
         886: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         889: bipush        43
         891: aaload
         892: astore        56
         894: aload         56
         896: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
         899: invokestatic  #96                 // Method java/lang/Double.longBitsToDouble:(J)D
         902: invokestatic  #99                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         905: astore        57
         907: aload         18
         909: checkcast     #2                  // class Block
         912: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         915: bipush        26
         917: aload         57
         919: aastore
         920: new           #101                // class ocaml_fn_14
         923: dup
         924: invokespecial #102                // Method ocaml_fn_14."<init>":()V
         927: astore        58
         929: aload         18
         931: checkcast     #2                  // class Block
         934: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        27
         939: aload         58
         941: aastore
         942: new           #104                // class ocaml_fn_15
         945: dup
         946: aload         20
         948: invokespecial #107                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         951: astore        59
         953: aload         18
         955: checkcast     #2                  // class Block
         958: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         961: bipush        28
         963: aload         59
         965: aastore
         966: new           #109                // class ocaml_fn_16
         969: dup
         970: invokespecial #110                // Method ocaml_fn_16."<init>":()V
         973: astore        60
         975: aload         18
         977: checkcast     #2                  // class Block
         980: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        29
         985: aload         60
         987: aastore
         988: new           #112                // class ocaml_fn_17
         991: dup
         992: aload         20
         994: invokespecial #113                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         997: astore        61
         999: aload         18
        1001: checkcast     #2                  // class Block
        1004: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1007: bipush        31
        1009: aload         61
        1011: aastore
        1012: new           #115                // class ocaml_fn_18
        1015: dup
        1016: invokespecial #116                // Method ocaml_fn_18."<init>":()V
        1019: astore        62
        1021: aload         18
        1023: checkcast     #2                  // class Block
        1026: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1029: bipush        30
        1031: aload         62
        1033: aastore
        1034: new           #118                // class ocaml_fn_19
        1037: dup
        1038: invokespecial #119                // Method ocaml_fn_19."<init>":()V
        1041: astore        63
        1043: aload         18
        1045: checkcast     #2                  // class Block
        1048: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        32
        1053: aload         63
        1055: aastore
        1056: new           #121                // class ocaml_fn_20
        1059: dup
        1060: aload         29
        1062: invokespecial #122                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1065: astore        64
        1067: aload         18
        1069: checkcast     #2                  // class Block
        1072: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        33
        1077: aload         64
        1079: aastore
        1080: new           #124                // class ocaml_fn_21
        1083: dup
        1084: aload         58
        1086: invokespecial #125                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1089: astore        65
        1091: aload         18
        1093: checkcast     #2                  // class Block
        1096: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        100
        1101: aload         65
        1103: aastore
        1104: new           #127                // class ocaml_fn_22
        1107: dup
        1108: aload         65
        1110: invokespecial #128                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1113: astore        66
        1115: aload         18
        1117: checkcast     #2                  // class Block
        1120: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        34
        1125: aload         66
        1127: aastore
        1128: new           #130                // class ocaml_fn_23
        1131: dup
        1132: aload         29
        1134: invokespecial #131                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1137: astore        67
        1139: aload         18
        1141: checkcast     #2                  // class Block
        1144: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1147: bipush        35
        1149: aload         67
        1151: aastore
        1152: new           #133                // class ocaml_fn_24
        1155: dup
        1156: invokespecial #134                // Method ocaml_fn_24."<init>":()V
        1159: astore        68
        1161: aload         18
        1163: checkcast     #2                  // class Block
        1166: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1169: bipush        36
        1171: aload         68
        1173: aastore
        1174: new           #136                // class ocaml_fn_25
        1177: dup
        1178: invokespecial #137                // Method ocaml_fn_25."<init>":()V
        1181: astore        69
        1183: aload         68
        1185: checkcast     #133                // class ocaml_fn_24
        1188: aload         68
        1190: checkcast     #139                // class Closure
        1193: putfield      #143                // Field ocaml_fn_24.sibling_0:LClosure;
        1196: iconst_0
        1197: i2l
        1198: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1201: astore        70
        1203: aload         68
        1205: checkcast     #133                // class ocaml_fn_24
        1208: aload         69
        1210: checkcast     #139                // class Closure
        1213: putfield      #146                // Field ocaml_fn_24.sibling_1:LClosure;
        1216: iconst_0
        1217: i2l
        1218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1221: astore        71
        1223: aload         69
        1225: checkcast     #136                // class ocaml_fn_25
        1228: aload         68
        1230: checkcast     #139                // class Closure
        1233: putfield      #147                // Field ocaml_fn_25.sibling_0:LClosure;
        1236: iconst_0
        1237: i2l
        1238: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1241: astore        72
        1243: aload         69
        1245: checkcast     #136                // class ocaml_fn_25
        1248: aload         69
        1250: checkcast     #139                // class Closure
        1253: putfield      #148                // Field ocaml_fn_25.sibling_1:LClosure;
        1256: iconst_0
        1257: i2l
        1258: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1261: astore        73
        1263: iconst_0
        1264: i2l
        1265: lstore        74
        1267: lload         74
        1269: l2i
        1270: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1273: astore        76
        1275: aload         18
        1277: checkcast     #2                  // class Block
        1280: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1283: bipush        37
        1285: aload         76
        1287: aastore
        1288: iconst_1
        1289: i2l
        1290: lstore        77
        1292: lload         77
        1294: l2i
        1295: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1298: astore        79
        1300: aload         18
        1302: checkcast     #2                  // class Block
        1305: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1308: bipush        38
        1310: aload         79
        1312: aastore
        1313: iconst_2
        1314: i2l
        1315: lstore        80
        1317: lload         80
        1319: l2i
        1320: invokestatic  #152                // Method Channel.forDescriptor:(I)LChannel;
        1323: astore        82
        1325: aload         18
        1327: checkcast     #2                  // class Block
        1330: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1333: bipush        39
        1335: aload         82
        1337: aastore
        1338: new           #154                // class ocaml_fn_26
        1341: dup
        1342: invokespecial #155                // Method ocaml_fn_26."<init>":()V
        1345: astore        83
        1347: aload         18
        1349: checkcast     #2                  // class Block
        1352: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1355: bipush        61
        1357: aload         83
        1359: aastore
        1360: new           #157                // class ocaml_fn_27
        1363: dup
        1364: aload         83
        1366: invokespecial #158                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1369: astore        84
        1371: aload         18
        1373: checkcast     #2                  // class Block
        1376: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1379: bipush        59
        1381: aload         84
        1383: aastore
        1384: new           #160                // class ocaml_fn_28
        1387: dup
        1388: aload         83
        1390: invokespecial #161                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1393: astore        85
        1395: aload         18
        1397: checkcast     #2                  // class Block
        1400: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1403: bipush        60
        1405: aload         85
        1407: aastore
        1408: new           #163                // class ocaml_fn_29
        1411: dup
        1412: aload         33
        1414: invokespecial #164                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1417: astore        86
        1419: aload         18
        1421: checkcast     #2                  // class Block
        1424: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1427: bipush        63
        1429: aload         86
        1431: aastore
        1432: new           #166                // class ocaml_fn_30
        1435: dup
        1436: invokespecial #167                // Method ocaml_fn_30."<init>":()V
        1439: astore        87
        1441: aload         18
        1443: checkcast     #2                  // class Block
        1446: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1449: bipush        66
        1451: aload         87
        1453: aastore
        1454: new           #169                // class ocaml_fn_31
        1457: dup
        1458: invokespecial #170                // Method ocaml_fn_31."<init>":()V
        1461: astore        88
        1463: aload         18
        1465: checkcast     #2                  // class Block
        1468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1471: bipush        65
        1473: aload         88
        1475: aastore
        1476: new           #172                // class ocaml_fn_32
        1479: dup
        1480: aload         20
        1482: invokespecial #173                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1485: astore        89
        1487: aload         18
        1489: checkcast     #2                  // class Block
        1492: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1495: bipush        67
        1497: aload         89
        1499: aastore
        1500: new           #175                // class ocaml_fn_33
        1503: dup
        1504: aload         20
        1506: invokespecial #176                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1509: astore        90
        1511: aload         18
        1513: checkcast     #2                  // class Block
        1516: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1519: bipush        68
        1521: aload         90
        1523: aastore
        1524: new           #178                // class ocaml_fn_34
        1527: dup
        1528: invokespecial #179                // Method ocaml_fn_34."<init>":()V
        1531: astore        91
        1533: aload         18
        1535: checkcast     #2                  // class Block
        1538: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1541: bipush        71
        1543: aload         91
        1545: aastore
        1546: new           #181                // class ocaml_fn_35
        1549: dup
        1550: invokespecial #182                // Method ocaml_fn_35."<init>":()V
        1553: astore        92
        1555: aload         18
        1557: checkcast     #2                  // class Block
        1560: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1563: bipush        75
        1565: aload         92
        1567: aastore
        1568: new           #184                // class ocaml_fn_36
        1571: dup
        1572: invokespecial #185                // Method ocaml_fn_36."<init>":()V
        1575: astore        93
        1577: aload         18
        1579: checkcast     #2                  // class Block
        1582: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1585: bipush        76
        1587: aload         93
        1589: aastore
        1590: new           #187                // class ocaml_fn_37
        1593: dup
        1594: invokespecial #188                // Method ocaml_fn_37."<init>":()V
        1597: astore        94
        1599: aload         18
        1601: checkcast     #2                  // class Block
        1604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1607: bipush        80
        1609: aload         94
        1611: aastore
        1612: new           #190                // class ocaml_fn_38
        1615: dup
        1616: aload         94
        1618: invokespecial #191                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1621: astore        95
        1623: aload         18
        1625: checkcast     #2                  // class Block
        1628: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1631: bipush        78
        1633: aload         95
        1635: aastore
        1636: new           #193                // class ocaml_fn_39
        1639: dup
        1640: aload         94
        1642: invokespecial #194                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1645: astore        96
        1647: aload         18
        1649: checkcast     #2                  // class Block
        1652: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1655: bipush        79
        1657: aload         96
        1659: aastore
        1660: new           #196                // class ocaml_fn_40
        1663: dup
        1664: aload         20
        1666: invokespecial #197                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1669: astore        97
        1671: aload         18
        1673: checkcast     #2                  // class Block
        1676: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1679: bipush        83
        1681: aload         97
        1683: aastore
        1684: new           #199                // class ocaml_fn_41
        1687: dup
        1688: aload         34
        1690: invokespecial #200                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1693: astore        98
        1695: aload         18
        1697: checkcast     #2                  // class Block
        1700: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1703: bipush        101
        1705: aload         98
        1707: aastore
        1708: new           #202                // class ocaml_fn_42
        1711: dup
        1712: aload         20
        1714: aload         98
        1716: invokespecial #205                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1719: astore        99
        1721: aload         18
        1723: checkcast     #2                  // class Block
        1726: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1729: bipush        84
        1731: aload         99
        1733: aastore
        1734: new           #207                // class ocaml_fn_43
        1737: dup
        1738: aload         99
        1740: invokespecial #208                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1743: astore        100
        1745: aload         18
        1747: checkcast     #2                  // class Block
        1750: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1753: bipush        85
        1755: aload         100
        1757: aastore
        1758: new           #210                // class ocaml_fn_44
        1761: dup
        1762: aload         34
        1764: invokespecial #211                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1767: astore        101
        1769: aload         18
        1771: checkcast     #2                  // class Block
        1774: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1777: bipush        82
        1779: aload         101
        1781: aastore
        1782: new           #213                // class ocaml_fn_45
        1785: dup
        1786: invokespecial #214                // Method ocaml_fn_45."<init>":()V
        1789: astore        102
        1791: aload         18
        1793: checkcast     #2                  // class Block
        1796: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1799: bipush        93
        1801: aload         102
        1803: aastore
        1804: new           #216                // class ocaml_fn_46
        1807: dup
        1808: aload         79
        1810: invokespecial #217                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1813: astore        103
        1815: aload         18
        1817: checkcast     #2                  // class Block
        1820: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1823: bipush        40
        1825: aload         103
        1827: aastore
        1828: new           #219                // class ocaml_fn_47
        1831: dup
        1832: aload         79
        1834: aload         88
        1836: invokespecial #220                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1839: astore        104
        1841: aload         18
        1843: checkcast     #2                  // class Block
        1846: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1849: bipush        41
        1851: aload         104
        1853: aastore
        1854: new           #222                // class ocaml_fn_48
        1857: dup
        1858: aload         79
        1860: aload         87
        1862: invokespecial #223                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1865: astore        105
        1867: aload         18
        1869: checkcast     #2                  // class Block
        1872: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1875: bipush        42
        1877: aload         105
        1879: aastore
        1880: new           #225                // class ocaml_fn_49
        1883: dup
        1884: aload         63
        1886: aload         79
        1888: aload         88
        1890: invokespecial #228                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1893: astore        106
        1895: aload         18
        1897: checkcast     #2                  // class Block
        1900: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1903: bipush        43
        1905: aload         106
        1907: aastore
        1908: new           #230                // class ocaml_fn_50
        1911: dup
        1912: aload         66
        1914: aload         79
        1916: aload         88
        1918: invokespecial #231                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1921: astore        107
        1923: aload         18
        1925: checkcast     #2                  // class Block
        1928: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1931: bipush        44
        1933: aload         107
        1935: aastore
        1936: new           #233                // class ocaml_fn_51
        1939: dup
        1940: aload         79
        1942: aload         88
        1944: invokespecial #234                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1947: astore        108
        1949: aload         18
        1951: checkcast     #2                  // class Block
        1954: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1957: bipush        45
        1959: aload         108
        1961: aastore
        1962: new           #236                // class ocaml_fn_52
        1965: dup
        1966: aload         79
        1968: invokespecial #237                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1971: astore        109
        1973: aload         18
        1975: checkcast     #2                  // class Block
        1978: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        1981: bipush        46
        1983: aload         109
        1985: aastore
        1986: new           #239                // class ocaml_fn_53
        1989: dup
        1990: aload         82
        1992: invokespecial #240                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1995: astore        110
        1997: aload         18
        1999: checkcast     #2                  // class Block
        2002: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2005: bipush        47
        2007: aload         110
        2009: aastore
        2010: new           #242                // class ocaml_fn_54
        2013: dup
        2014: aload         82
        2016: aload         88
        2018: invokespecial #243                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2021: astore        111
        2023: aload         18
        2025: checkcast     #2                  // class Block
        2028: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2031: bipush        48
        2033: aload         111
        2035: aastore
        2036: new           #245                // class ocaml_fn_55
        2039: dup
        2040: aload         82
        2042: aload         87
        2044: invokespecial #246                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2047: astore        112
        2049: aload         18
        2051: checkcast     #2                  // class Block
        2054: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2057: bipush        49
        2059: aload         112
        2061: aastore
        2062: new           #248                // class ocaml_fn_56
        2065: dup
        2066: aload         63
        2068: aload         82
        2070: aload         88
        2072: invokespecial #249                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2075: astore        113
        2077: aload         18
        2079: checkcast     #2                  // class Block
        2082: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2085: bipush        50
        2087: aload         113
        2089: aastore
        2090: new           #251                // class ocaml_fn_57
        2093: dup
        2094: aload         66
        2096: aload         82
        2098: aload         88
        2100: invokespecial #252                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2103: astore        114
        2105: aload         18
        2107: checkcast     #2                  // class Block
        2110: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2113: bipush        51
        2115: aload         114
        2117: aastore
        2118: new           #254                // class ocaml_fn_58
        2121: dup
        2122: aload         82
        2124: aload         88
        2126: invokespecial #255                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2129: astore        115
        2131: aload         18
        2133: checkcast     #2                  // class Block
        2136: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2139: bipush        52
        2141: aload         115
        2143: aastore
        2144: new           #257                // class ocaml_fn_59
        2147: dup
        2148: aload         82
        2150: invokespecial #258                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2153: astore        116
        2155: aload         18
        2157: checkcast     #2                  // class Block
        2160: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2163: bipush        53
        2165: aload         116
        2167: aastore
        2168: new           #260                // class ocaml_fn_60
        2171: dup
        2172: aload         76
        2174: aload         79
        2176: aload         101
        2178: invokespecial #261                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2181: astore        117
        2183: aload         18
        2185: checkcast     #2                  // class Block
        2188: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2191: bipush        54
        2193: aload         117
        2195: aastore
        2196: new           #263                // class ocaml_fn_61
        2199: dup
        2200: aload         117
        2202: invokespecial #264                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2205: astore        118
        2207: aload         18
        2209: checkcast     #2                  // class Block
        2212: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2215: bipush        56
        2217: aload         118
        2219: aastore
        2220: new           #266                // class ocaml_fn_62
        2223: dup
        2224: aload         64
        2226: aload         117
        2228: invokespecial #267                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2231: astore        119
        2233: aload         18
        2235: checkcast     #2                  // class Block
        2238: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2241: bipush        55
        2243: aload         119
        2245: aastore
        2246: new           #269                // class ocaml_fn_63
        2249: dup
        2250: aload         117
        2252: invokespecial #270                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2255: astore        120
        2257: aload         18
        2259: checkcast     #2                  // class Block
        2262: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2265: bipush        58
        2267: aload         120
        2269: aastore
        2270: new           #272                // class ocaml_fn_64
        2273: dup
        2274: aload         67
        2276: aload         117
        2278: invokespecial #273                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2281: astore        121
        2283: aload         18
        2285: checkcast     #2                  // class Block
        2288: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2291: bipush        57
        2293: aload         121
        2295: aastore
        2296: new           #275                // class ocaml_fn_65
        2299: dup
        2300: invokespecial #276                // Method ocaml_fn_65."<init>":()V
        2303: astore        122
        2305: aload         18
        2307: checkcast     #2                  // class Block
        2310: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2313: bipush        96
        2315: aload         122
        2317: aastore
        2318: new           #278                // class ocaml_fn_66
        2321: dup
        2322: aload         58
        2324: invokespecial #279                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2327: astore        123
        2329: aload         18
        2331: checkcast     #2                  // class Block
        2334: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2337: bipush        97
        2339: aload         123
        2341: aastore
        2342: new           #2                  // class Block
        2345: dup
        2346: iconst_0
        2347: iconst_1
        2348: anewarray     #4                  // class java/lang/Object
        2351: dup
        2352: iconst_0
        2353: aload         86
        2355: aastore
        2356: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2359: astore        124
        2361: new           #281                // class ocaml_fn_67
        2364: dup
        2365: aload         124
        2367: invokespecial #282                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2370: astore        125
        2372: aload         18
        2374: checkcast     #2                  // class Block
        2377: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2380: bipush        99
        2382: aload         125
        2384: aastore
        2385: new           #284                // class ocaml_fn_68
        2388: dup
        2389: invokespecial #285                // Method ocaml_fn_68."<init>":()V
        2392: astore        126
        2394: new           #2                  // class Block
        2397: dup
        2398: iconst_0
        2399: iconst_1
        2400: anewarray     #4                  // class java/lang/Object
        2403: dup
        2404: iconst_0
        2405: aload         126
        2407: aastore
        2408: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2411: astore        127
        2413: aload         18
        2415: checkcast     #2                  // class Block
        2418: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2421: bipush        103
        2423: aload         127
        2425: aastore
        2426: new           #287                // class ocaml_fn_69
        2429: dup
        2430: aload         124
        2432: aload         127
        2434: invokespecial #288                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2437: astore        128
        2439: aload         18
        2441: checkcast     #2                  // class Block
        2444: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2447: bipush        102
        2449: aload         128
        2451: aastore
        2452: new           #290                // class ocaml_fn_70
        2455: dup
        2456: aload         128
        2458: invokespecial #291                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2461: astore        129
        2463: aload         18
        2465: checkcast     #2                  // class Block
        2468: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2471: bipush        98
        2473: aload         129
        2475: aastore
        2476: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2479: bipush        44
        2481: aaload
        2482: astore        130
        2484: iconst_0
        2485: i2l
        2486: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2489: astore        131
        2491: new           #2                  // class Block
        2494: dup
        2495: iconst_0
        2496: bipush        6
        2498: anewarray     #4                  // class java/lang/Object
        2501: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2504: astore        132
        2506: new           #293                // class ocaml_fn_71
        2509: dup
        2510: invokespecial #294                // Method ocaml_fn_71."<init>":()V
        2513: astore        133
        2515: aload         132
        2517: checkcast     #2                  // class Block
        2520: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2523: iconst_5
        2524: aload         133
        2526: aastore
        2527: new           #296                // class ocaml_fn_72
        2530: dup
        2531: invokespecial #297                // Method ocaml_fn_72."<init>":()V
        2534: astore        134
        2536: aload         132
        2538: checkcast     #2                  // class Block
        2541: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2544: iconst_4
        2545: aload         134
        2547: aastore
        2548: new           #299                // class ocaml_fn_73
        2551: dup
        2552: invokespecial #300                // Method ocaml_fn_73."<init>":()V
        2555: astore        135
        2557: aload         132
        2559: checkcast     #2                  // class Block
        2562: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2565: iconst_3
        2566: aload         135
        2568: aastore
        2569: new           #302                // class ocaml_fn_74
        2572: dup
        2573: invokespecial #303                // Method ocaml_fn_74."<init>":()V
        2576: astore        136
        2578: aload         132
        2580: checkcast     #2                  // class Block
        2583: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2586: iconst_2
        2587: aload         136
        2589: aastore
        2590: new           #305                // class ocaml_fn_75
        2593: dup
        2594: invokespecial #306                // Method ocaml_fn_75."<init>":()V
        2597: astore        137
        2599: aload         132
        2601: checkcast     #2                  // class Block
        2604: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2607: iconst_1
        2608: aload         137
        2610: aastore
        2611: new           #308                // class ocaml_fn_76
        2614: dup
        2615: invokespecial #309                // Method ocaml_fn_76."<init>":()V
        2618: astore        138
        2620: aload         132
        2622: checkcast     #2                  // class Block
        2625: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2628: iconst_0
        2629: aload         138
        2631: aastore
        2632: aload         18
        2634: checkcast     #2                  // class Block
        2637: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2640: bipush        95
        2642: aload         132
        2644: aastore
        2645: new           #311                // class ocaml_fn_77
        2648: dup
        2649: invokespecial #312                // Method ocaml_fn_77."<init>":()V
        2652: astore        139
        2654: aload         18
        2656: checkcast     #2                  // class Block
        2659: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2662: bipush        94
        2664: aload         139
        2666: aastore
        2667: new           #314                // class ocaml_fn_78
        2670: dup
        2671: invokespecial #315                // Method ocaml_fn_78."<init>":()V
        2674: astore        140
        2676: aload         18
        2678: checkcast     #2                  // class Block
        2681: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2684: bipush        92
        2686: aload         140
        2688: aastore
        2689: new           #317                // class ocaml_fn_79
        2692: dup
        2693: invokespecial #318                // Method ocaml_fn_79."<init>":()V
        2696: astore        141
        2698: aload         18
        2700: checkcast     #2                  // class Block
        2703: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2706: bipush        91
        2708: aload         141
        2710: aastore
        2711: new           #320                // class ocaml_fn_80
        2714: dup
        2715: invokespecial #321                // Method ocaml_fn_80."<init>":()V
        2718: astore        142
        2720: aload         18
        2722: checkcast     #2                  // class Block
        2725: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2728: bipush        90
        2730: aload         142
        2732: aastore
        2733: new           #323                // class ocaml_fn_81
        2736: dup
        2737: invokespecial #324                // Method ocaml_fn_81."<init>":()V
        2740: astore        143
        2742: aload         18
        2744: checkcast     #2                  // class Block
        2747: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2750: bipush        89
        2752: aload         143
        2754: aastore
        2755: new           #326                // class ocaml_fn_82
        2758: dup
        2759: invokespecial #327                // Method ocaml_fn_82."<init>":()V
        2762: astore        144
        2764: aload         18
        2766: checkcast     #2                  // class Block
        2769: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2772: bipush        88
        2774: aload         144
        2776: aastore
        2777: new           #329                // class ocaml_fn_83
        2780: dup
        2781: invokespecial #330                // Method ocaml_fn_83."<init>":()V
        2784: astore        145
        2786: aload         18
        2788: checkcast     #2                  // class Block
        2791: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2794: bipush        87
        2796: aload         145
        2798: aastore
        2799: new           #332                // class ocaml_fn_84
        2802: dup
        2803: invokespecial #333                // Method ocaml_fn_84."<init>":()V
        2806: astore        146
        2808: aload         18
        2810: checkcast     #2                  // class Block
        2813: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2816: bipush        86
        2818: aload         146
        2820: aastore
        2821: new           #335                // class ocaml_fn_85
        2824: dup
        2825: invokespecial #336                // Method ocaml_fn_85."<init>":()V
        2828: astore        147
        2830: aload         18
        2832: checkcast     #2                  // class Block
        2835: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2838: bipush        81
        2840: aload         147
        2842: aastore
        2843: new           #338                // class ocaml_fn_86
        2846: dup
        2847: invokespecial #339                // Method ocaml_fn_86."<init>":()V
        2850: astore        148
        2852: aload         18
        2854: checkcast     #2                  // class Block
        2857: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2860: bipush        77
        2862: aload         148
        2864: aastore
        2865: new           #341                // class ocaml_fn_87
        2868: dup
        2869: invokespecial #342                // Method ocaml_fn_87."<init>":()V
        2872: astore        149
        2874: aload         18
        2876: checkcast     #2                  // class Block
        2879: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2882: bipush        74
        2884: aload         149
        2886: aastore
        2887: new           #344                // class ocaml_fn_88
        2890: dup
        2891: invokespecial #345                // Method ocaml_fn_88."<init>":()V
        2894: astore        150
        2896: aload         18
        2898: checkcast     #2                  // class Block
        2901: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2904: bipush        73
        2906: aload         150
        2908: aastore
        2909: new           #347                // class ocaml_fn_89
        2912: dup
        2913: invokespecial #348                // Method ocaml_fn_89."<init>":()V
        2916: astore        151
        2918: aload         18
        2920: checkcast     #2                  // class Block
        2923: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2926: bipush        72
        2928: aload         151
        2930: aastore
        2931: new           #350                // class ocaml_fn_90
        2934: dup
        2935: invokespecial #351                // Method ocaml_fn_90."<init>":()V
        2938: astore        152
        2940: aload         18
        2942: checkcast     #2                  // class Block
        2945: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2948: bipush        70
        2950: aload         152
        2952: aastore
        2953: new           #353                // class ocaml_fn_91
        2956: dup
        2957: invokespecial #354                // Method ocaml_fn_91."<init>":()V
        2960: astore        153
        2962: aload         18
        2964: checkcast     #2                  // class Block
        2967: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2970: bipush        69
        2972: aload         153
        2974: aastore
        2975: new           #356                // class ocaml_fn_92
        2978: dup
        2979: invokespecial #357                // Method ocaml_fn_92."<init>":()V
        2982: astore        154
        2984: aload         18
        2986: checkcast     #2                  // class Block
        2989: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        2992: bipush        64
        2994: aload         154
        2996: aastore
        2997: new           #359                // class ocaml_fn_93
        3000: dup
        3001: invokespecial #360                // Method ocaml_fn_93."<init>":()V
        3004: astore        155
        3006: aload         18
        3008: checkcast     #2                  // class Block
        3011: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3014: bipush        62
        3016: aload         155
        3018: aastore
        3019: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3022: bipush        45
        3024: aload         18
        3026: aastore
        3027: iconst_0
        3028: i2l
        3029: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3032: astore        156
        3034: iconst_1
        3035: i2l
        3036: lstore        157
        3038: iconst_0
        3039: i2l
        3040: lstore        159
        3042: lload         159
        3044: iconst_0
        3045: i2l
        3046: lcmp
        3047: ifeq          3062
        3050: lload         157
        3052: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3055: astore        161
        3057: goto_w        3091
        3062: lload         157
        3064: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3067: astore        162
        3069: goto_w        3074
        3074: bipush        10
        3076: i2l
        3077: lstore        163
        3079: lload         163
        3081: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3084: astore        165
        3086: goto_w        3108
        3091: bipush        20
        3093: i2l
        3094: lstore        166
        3096: lload         166
        3098: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3101: astore        165
        3103: goto_w        3108
        3108: getstatic     #364                // Field java/lang/System.out:Ljava/io/PrintStream;
        3111: aload         165
        3113: invokestatic  #90                 // Method Block.asLong:(Ljava/lang/Object;)J
        3116: l2i
        3117: invokevirtual #370                // Method java/io/PrintStream.println:(I)V
        3120: iconst_0
        3121: i2l
        3122: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3125: astore        168
        3127: new           #2                  // class Block
        3130: dup
        3131: iconst_0
        3132: iconst_0
        3133: anewarray     #4                  // class java/lang/Object
        3136: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3139: astore        169
        3141: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3144: bipush        46
        3146: aload         169
        3148: aastore
        3149: iconst_0
        3150: i2l
        3151: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3154: astore        170
        3156: iconst_0
        3157: i2l
        3158: lstore        171
        3160: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3163: bipush        45
        3165: aaload
        3166: checkcast     #2                  // class Block
        3169: getfield      #67                 // Field Block.fields:[Ljava/lang/Object;
        3172: bipush        102
        3174: aaload
        3175: astore        173
        3177: aload         173
        3179: checkcast     #139                // class Closure
        3182: lload         171
        3184: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3187: invokevirtual #374                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3190: astore        174
        3192: new           #2                  // class Block
        3195: dup
        3196: iconst_0
        3197: iconst_0
        3198: anewarray     #4                  // class java/lang/Object
        3201: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3204: astore        175
        3206: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3209: bipush        47
        3211: aload         175
        3213: aastore
        3214: iconst_0
        3215: i2l
        3216: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3219: astore        176
        3221: return
    }
    |}]
