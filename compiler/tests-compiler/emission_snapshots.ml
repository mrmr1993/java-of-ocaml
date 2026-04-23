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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3048: bipush        46
        3050: aaload
        3051: astore        157
        3053: getstatic     #372                // Field java/lang/System.out:Ljava/io/PrintStream;
        3056: aload         157
        3058: checkcast     #374                // class java/lang/String
        3061: invokevirtual #380                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3064: iconst_0
        3065: i2l
        3066: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3069: astore        158
        3071: new           #2                  // class Block
        3074: dup
        3075: iconst_0
        3076: iconst_0
        3077: anewarray     #4                  // class java/lang/Object
        3080: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3083: astore        159
        3085: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3088: bipush        47
        3090: aload         159
        3092: aastore
        3093: iconst_0
        3094: i2l
        3095: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3098: astore        160
        3100: iconst_0
        3101: i2l
        3102: lstore        161
        3104: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3107: bipush        45
        3109: aaload
        3110: checkcast     #2                  // class Block
        3113: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3116: bipush        102
        3118: aaload
        3119: astore        163
        3121: aload         163
        3123: checkcast     #147                // class Closure
        3126: lload         161
        3128: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3131: invokevirtual #384                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3134: astore        164
        3136: new           #2                  // class Block
        3139: dup
        3140: iconst_0
        3141: iconst_0
        3142: anewarray     #4                  // class java/lang/Object
        3145: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3148: astore        165
        3150: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3153: bipush        48
        3155: aload         165
        3157: aastore
        3158: iconst_0
        3159: i2l
        3160: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3163: astore        166
        3165: return
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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: bipush        8
        3047: i2l
        3048: lstore        157
        3050: getstatic     #372                // Field java/lang/System.out:Ljava/io/PrintStream;
        3053: lload         157
        3055: l2i
        3056: invokevirtual #378                // Method java/io/PrintStream.println:(I)V
        3059: iconst_0
        3060: i2l
        3061: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3064: astore        159
        3066: new           #2                  // class Block
        3069: dup
        3070: iconst_0
        3071: iconst_0
        3072: anewarray     #4                  // class java/lang/Object
        3075: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3078: astore        160
        3080: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3083: bipush        46
        3085: aload         160
        3087: aastore
        3088: iconst_0
        3089: i2l
        3090: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3093: astore        161
        3095: iconst_0
        3096: i2l
        3097: lstore        162
        3099: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3102: bipush        45
        3104: aaload
        3105: checkcast     #2                  // class Block
        3108: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3111: bipush        102
        3113: aaload
        3114: astore        164
        3116: aload         164
        3118: checkcast     #147                // class Closure
        3121: lload         162
        3123: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3126: invokevirtual #382                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3129: astore        165
        3131: new           #2                  // class Block
        3134: dup
        3135: iconst_0
        3136: iconst_0
        3137: anewarray     #4                  // class java/lang/Object
        3140: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3143: astore        166
        3145: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3148: bipush        47
        3150: aload         166
        3152: aastore
        3153: iconst_0
        3154: i2l
        3155: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3158: astore        167
        3160: return
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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: iconst_0
        3046: i2l
        3047: lstore        157
        3049: lload         157
        3051: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        159
        3056: goto_w        3061
        3061: new           #370                // class ocaml_fn_95
        3064: dup
        3065: invokespecial #371                // Method ocaml_fn_95."<init>":()V
        3068: astore        160
        3070: bipush        10
        3072: i2l
        3073: lstore        161
        3075: aload         160
        3077: lload         161
        3079: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3082: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3085: astore        163
        3087: bipush        32
        3089: i2l
        3090: lstore        164
        3092: aload         163
        3094: checkcast     #147                // class Closure
        3097: lload         164
        3099: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3102: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3105: astore        166
        3107: getstatic     #379                // Field java/lang/System.out:Ljava/io/PrintStream;
        3110: aload         166
        3112: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
        3115: l2i
        3116: invokevirtual #385                // Method java/io/PrintStream.println:(I)V
        3119: iconst_0
        3120: i2l
        3121: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3124: astore        167
        3126: new           #2                  // class Block
        3129: dup
        3130: iconst_0
        3131: iconst_1
        3132: anewarray     #4                  // class java/lang/Object
        3135: dup
        3136: iconst_0
        3137: aload         160
        3139: aastore
        3140: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3143: astore        168
        3145: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3148: bipush        46
        3150: aload         168
        3152: aastore
        3153: iconst_0
        3154: i2l
        3155: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3158: astore        169
        3160: iconst_0
        3161: i2l
        3162: lstore        170
        3164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3167: bipush        45
        3169: aaload
        3170: checkcast     #2                  // class Block
        3173: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3176: bipush        102
        3178: aaload
        3179: astore        172
        3181: aload         172
        3183: checkcast     #147                // class Closure
        3186: lload         170
        3188: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3191: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3194: astore        173
        3196: new           #2                  // class Block
        3199: dup
        3200: iconst_0
        3201: iconst_0
        3202: anewarray     #4                  // class java/lang/Object
        3205: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3208: astore        174
        3210: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3213: bipush        47
        3215: aload         174
        3217: aastore
        3218: iconst_0
        3219: i2l
        3220: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3223: astore        175
        3225: return
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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: iconst_0
        3046: i2l
        3047: lstore        157
        3049: lload         157
        3051: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        159
        3056: goto_w        3061
        3061: new           #370                // class ocaml_fn_94
        3064: dup
        3065: invokespecial #371                // Method ocaml_fn_94."<init>":()V
        3068: astore        160
        3070: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3073: bipush        46
        3075: aaload
        3076: astore        161
        3078: aload         160
        3080: aload         161
        3082: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3085: astore        162
        3087: getstatic     #379                // Field java/lang/System.out:Ljava/io/PrintStream;
        3090: aload         162
        3092: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
        3095: l2i
        3096: invokevirtual #385                // Method java/io/PrintStream.println:(I)V
        3099: iconst_0
        3100: i2l
        3101: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3104: astore        163
        3106: new           #2                  // class Block
        3109: dup
        3110: iconst_0
        3111: iconst_1
        3112: anewarray     #4                  // class java/lang/Object
        3115: dup
        3116: iconst_0
        3117: aload         160
        3119: aastore
        3120: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3123: astore        164
        3125: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3128: bipush        47
        3130: aload         164
        3132: aastore
        3133: iconst_0
        3134: i2l
        3135: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3138: astore        165
        3140: iconst_0
        3141: i2l
        3142: lstore        166
        3144: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3147: bipush        45
        3149: aaload
        3150: checkcast     #2                  // class Block
        3153: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3156: bipush        102
        3158: aaload
        3159: astore        168
        3161: aload         168
        3163: checkcast     #147                // class Closure
        3166: lload         166
        3168: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3171: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3174: astore        169
        3176: new           #2                  // class Block
        3179: dup
        3180: iconst_0
        3181: iconst_0
        3182: anewarray     #4                  // class java/lang/Object
        3185: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3188: astore        170
        3190: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3193: bipush        48
        3195: aload         170
        3197: aastore
        3198: iconst_0
        3199: i2l
        3200: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3203: astore        171
        3205: return
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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: iconst_0
        3046: i2l
        3047: lstore        157
        3049: lload         157
        3051: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: astore        159
        3056: goto_w        3061
        3061: iconst_0
        3062: i2l
        3063: lstore        160
        3065: invokestatic  #78                 // Method Ocaml.freshOoId:()J
        3068: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3071: astore        162
        3073: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3076: bipush        46
        3078: aaload
        3079: astore        163
        3081: new           #2                  // class Block
        3084: dup
        3085: sipush        248
        3088: iconst_2
        3089: anewarray     #4                  // class java/lang/Object
        3092: dup
        3093: iconst_0
        3094: aload         163
        3096: aastore
        3097: dup
        3098: iconst_1
        3099: aload         162
        3101: aastore
        3102: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3105: astore        164
        3107: new           #370                // class ocaml_fn_94
        3110: dup
        3111: aload         164
        3113: invokespecial #371                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3116: astore        165
        3118: iconst_0
        3119: i2l
        3120: lstore        166
        3122: aload         165
        3124: lload         166
        3126: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3129: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3132: astore        168
        3134: getstatic     #379                // Field java/lang/System.out:Ljava/io/PrintStream;
        3137: aload         168
        3139: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
        3142: l2i
        3143: invokevirtual #385                // Method java/io/PrintStream.println:(I)V
        3146: iconst_0
        3147: i2l
        3148: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3151: astore        169
        3153: new           #2                  // class Block
        3156: dup
        3157: iconst_0
        3158: iconst_2
        3159: anewarray     #4                  // class java/lang/Object
        3162: dup
        3163: iconst_0
        3164: aload         164
        3166: aastore
        3167: dup
        3168: iconst_1
        3169: aload         165
        3171: aastore
        3172: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3175: astore        170
        3177: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3180: bipush        47
        3182: aload         170
        3184: aastore
        3185: iconst_0
        3186: i2l
        3187: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3190: astore        171
        3192: iconst_0
        3193: i2l
        3194: lstore        172
        3196: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3199: bipush        45
        3201: aaload
        3202: checkcast     #2                  // class Block
        3205: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3208: bipush        102
        3210: aaload
        3211: astore        174
        3213: aload         174
        3215: checkcast     #147                // class Closure
        3218: lload         172
        3220: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3223: invokevirtual #375                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3226: astore        175
        3228: new           #2                  // class Block
        3231: dup
        3232: iconst_0
        3233: iconst_0
        3234: anewarray     #4                  // class java/lang/Object
        3237: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3240: astore        176
        3242: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3245: bipush        48
        3247: aload         176
        3249: aastore
        3250: iconst_0
        3251: i2l
        3252: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3255: astore        177
        3257: return
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
         222: aload         16
         224: aload         15
         226: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
         229: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         232: astore        17
         234: new           #2                  // class Block
         237: dup
         238: iconst_0
         239: bipush        104
         241: anewarray     #4                  // class java/lang/Object
         244: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         247: astore        18
         249: new           #67                 // class ocaml_fn_8
         252: dup
         253: invokespecial #68                 // Method ocaml_fn_8."<init>":()V
         256: astore        19
         258: aload         18
         260: checkcast     #2                  // class Block
         263: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         266: iconst_1
         267: aload         19
         269: aastore
         270: new           #73                 // class ocaml_fn_9
         273: dup
         274: invokespecial #74                 // Method ocaml_fn_9."<init>":()V
         277: astore        20
         279: aload         18
         281: checkcast     #2                  // class Block
         284: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         287: iconst_0
         288: aload         20
         290: aastore
         291: iconst_0
         292: i2l
         293: lstore        21
         295: invokestatic  #78                 // Method Ocaml.freshOoId:()J
         298: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         301: astore        23
         303: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         306: bipush        37
         308: aaload
         309: astore        24
         311: new           #2                  // class Block
         314: dup
         315: sipush        248
         318: iconst_2
         319: anewarray     #4                  // class java/lang/Object
         322: dup
         323: iconst_0
         324: aload         24
         326: aastore
         327: dup
         328: iconst_1
         329: aload         23
         331: aastore
         332: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         335: astore        25
         337: aload         18
         339: checkcast     #2                  // class Block
         342: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         345: iconst_2
         346: aload         25
         348: aastore
         349: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         352: bipush        7
         354: aaload
         355: astore        26
         357: aload         18
         359: checkcast     #2                  // class Block
         362: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         365: iconst_3
         366: aload         26
         368: aastore
         369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         372: bipush        10
         374: aaload
         375: astore        27
         377: aload         18
         379: checkcast     #2                  // class Block
         382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         385: iconst_4
         386: aload         27
         388: aastore
         389: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         392: iconst_3
         393: aaload
         394: astore        28
         396: aload         18
         398: checkcast     #2                  // class Block
         401: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         404: iconst_5
         405: aload         28
         407: aastore
         408: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         411: iconst_2
         412: aaload
         413: astore        29
         415: aload         18
         417: checkcast     #2                  // class Block
         420: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         423: bipush        6
         425: aload         29
         427: aastore
         428: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         431: bipush        6
         433: aaload
         434: astore        30
         436: aload         18
         438: checkcast     #2                  // class Block
         441: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         444: bipush        7
         446: aload         30
         448: aastore
         449: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         452: iconst_0
         453: aaload
         454: astore        31
         456: aload         18
         458: checkcast     #2                  // class Block
         461: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         464: bipush        8
         466: aload         31
         468: aastore
         469: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         472: bipush        8
         474: aaload
         475: astore        32
         477: aload         18
         479: checkcast     #2                  // class Block
         482: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         485: bipush        9
         487: aload         32
         489: aastore
         490: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         493: iconst_1
         494: aaload
         495: astore        33
         497: aload         18
         499: checkcast     #2                  // class Block
         502: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         505: bipush        10
         507: aload         33
         509: aastore
         510: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         513: iconst_4
         514: aaload
         515: astore        34
         517: aload         18
         519: checkcast     #2                  // class Block
         522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         525: bipush        11
         527: aload         34
         529: aastore
         530: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         533: iconst_5
         534: aaload
         535: astore        35
         537: aload         18
         539: checkcast     #2                  // class Block
         542: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         545: bipush        12
         547: aload         35
         549: aastore
         550: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         553: bipush        9
         555: aaload
         556: astore        36
         558: aload         18
         560: checkcast     #2                  // class Block
         563: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         566: bipush        13
         568: aload         36
         570: aastore
         571: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        11
         576: aaload
         577: astore        37
         579: aload         18
         581: checkcast     #2                  // class Block
         584: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         587: bipush        14
         589: aload         37
         591: aastore
         592: new           #80                 // class ocaml_fn_10
         595: dup
         596: invokespecial #81                 // Method ocaml_fn_10."<init>":()V
         599: astore        38
         601: aload         18
         603: checkcast     #2                  // class Block
         606: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         609: bipush        15
         611: aload         38
         613: aastore
         614: new           #83                 // class ocaml_fn_11
         617: dup
         618: invokespecial #84                 // Method ocaml_fn_11."<init>":()V
         621: astore        39
         623: aload         18
         625: checkcast     #2                  // class Block
         628: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         631: bipush        16
         633: aload         39
         635: aastore
         636: new           #86                 // class ocaml_fn_12
         639: dup
         640: invokespecial #87                 // Method ocaml_fn_12."<init>":()V
         643: astore        40
         645: aload         18
         647: checkcast     #2                  // class Block
         650: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         653: bipush        17
         655: aload         40
         657: aastore
         658: new           #89                 // class ocaml_fn_13
         661: dup
         662: invokespecial #90                 // Method ocaml_fn_13."<init>":()V
         665: astore        41
         667: aload         18
         669: checkcast     #2                  // class Block
         672: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         675: bipush        20
         677: aload         41
         679: aastore
         680: ldc2_w        #91                 // long 4611686018427387903l
         683: lstore        42
         685: aload         18
         687: checkcast     #2                  // class Block
         690: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         693: bipush        18
         695: lload         42
         697: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         700: aastore
         701: ldc2_w        #93                 // long -4611686018427387904l
         704: lstore        44
         706: aload         18
         708: checkcast     #2                  // class Block
         711: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         714: bipush        19
         716: lload         44
         718: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         721: aastore
         722: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         725: bipush        38
         727: aaload
         728: astore        46
         730: aload         46
         732: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         735: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         738: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         741: astore        47
         743: aload         18
         745: checkcast     #2                  // class Block
         748: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         751: bipush        21
         753: aload         47
         755: aastore
         756: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         759: bipush        39
         761: aaload
         762: astore        48
         764: aload         48
         766: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         769: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         772: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         775: astore        49
         777: aload         18
         779: checkcast     #2                  // class Block
         782: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         785: bipush        22
         787: aload         49
         789: aastore
         790: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         793: bipush        40
         795: aaload
         796: astore        50
         798: aload         50
         800: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         803: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         806: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         809: astore        51
         811: aload         18
         813: checkcast     #2                  // class Block
         816: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         819: bipush        23
         821: aload         51
         823: aastore
         824: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         827: bipush        41
         829: aaload
         830: astore        52
         832: aload         52
         834: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         837: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         840: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         843: astore        53
         845: aload         18
         847: checkcast     #2                  // class Block
         850: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         853: bipush        24
         855: aload         53
         857: aastore
         858: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         861: bipush        42
         863: aaload
         864: astore        54
         866: aload         54
         868: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         871: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         874: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         877: astore        55
         879: aload         18
         881: checkcast     #2                  // class Block
         884: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         887: bipush        25
         889: aload         55
         891: aastore
         892: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         895: bipush        43
         897: aaload
         898: astore        56
         900: aload         56
         902: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
         905: invokestatic  #104                // Method java/lang/Double.longBitsToDouble:(J)D
         908: invokestatic  #107                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         911: astore        57
         913: aload         18
         915: checkcast     #2                  // class Block
         918: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         921: bipush        26
         923: aload         57
         925: aastore
         926: new           #109                // class ocaml_fn_14
         929: dup
         930: invokespecial #110                // Method ocaml_fn_14."<init>":()V
         933: astore        58
         935: aload         18
         937: checkcast     #2                  // class Block
         940: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         943: bipush        27
         945: aload         58
         947: aastore
         948: new           #112                // class ocaml_fn_15
         951: dup
         952: aload         20
         954: invokespecial #115                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         957: astore        59
         959: aload         18
         961: checkcast     #2                  // class Block
         964: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         967: bipush        28
         969: aload         59
         971: aastore
         972: new           #117                // class ocaml_fn_16
         975: dup
         976: invokespecial #118                // Method ocaml_fn_16."<init>":()V
         979: astore        60
         981: aload         18
         983: checkcast     #2                  // class Block
         986: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         989: bipush        29
         991: aload         60
         993: aastore
         994: new           #120                // class ocaml_fn_17
         997: dup
         998: aload         20
        1000: invokespecial #121                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1003: astore        61
        1005: aload         18
        1007: checkcast     #2                  // class Block
        1010: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1013: bipush        31
        1015: aload         61
        1017: aastore
        1018: new           #123                // class ocaml_fn_18
        1021: dup
        1022: invokespecial #124                // Method ocaml_fn_18."<init>":()V
        1025: astore        62
        1027: aload         18
        1029: checkcast     #2                  // class Block
        1032: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1035: bipush        30
        1037: aload         62
        1039: aastore
        1040: new           #126                // class ocaml_fn_19
        1043: dup
        1044: invokespecial #127                // Method ocaml_fn_19."<init>":()V
        1047: astore        63
        1049: aload         18
        1051: checkcast     #2                  // class Block
        1054: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1057: bipush        32
        1059: aload         63
        1061: aastore
        1062: new           #129                // class ocaml_fn_20
        1065: dup
        1066: aload         29
        1068: invokespecial #130                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1071: astore        64
        1073: aload         18
        1075: checkcast     #2                  // class Block
        1078: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1081: bipush        33
        1083: aload         64
        1085: aastore
        1086: new           #132                // class ocaml_fn_21
        1089: dup
        1090: aload         58
        1092: invokespecial #133                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1095: astore        65
        1097: aload         18
        1099: checkcast     #2                  // class Block
        1102: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1105: bipush        100
        1107: aload         65
        1109: aastore
        1110: new           #135                // class ocaml_fn_22
        1113: dup
        1114: aload         65
        1116: invokespecial #136                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1119: astore        66
        1121: aload         18
        1123: checkcast     #2                  // class Block
        1126: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1129: bipush        34
        1131: aload         66
        1133: aastore
        1134: new           #138                // class ocaml_fn_23
        1137: dup
        1138: aload         29
        1140: invokespecial #139                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1143: astore        67
        1145: aload         18
        1147: checkcast     #2                  // class Block
        1150: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1153: bipush        35
        1155: aload         67
        1157: aastore
        1158: new           #141                // class ocaml_fn_24
        1161: dup
        1162: invokespecial #142                // Method ocaml_fn_24."<init>":()V
        1165: astore        68
        1167: aload         18
        1169: checkcast     #2                  // class Block
        1172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1175: bipush        36
        1177: aload         68
        1179: aastore
        1180: new           #144                // class ocaml_fn_25
        1183: dup
        1184: invokespecial #145                // Method ocaml_fn_25."<init>":()V
        1187: astore        69
        1189: aload         68
        1191: checkcast     #141                // class ocaml_fn_24
        1194: aload         68
        1196: checkcast     #147                // class Closure
        1199: putfield      #151                // Field ocaml_fn_24.sibling_0:LClosure;
        1202: iconst_0
        1203: i2l
        1204: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1207: astore        70
        1209: aload         68
        1211: checkcast     #141                // class ocaml_fn_24
        1214: aload         69
        1216: checkcast     #147                // class Closure
        1219: putfield      #154                // Field ocaml_fn_24.sibling_1:LClosure;
        1222: iconst_0
        1223: i2l
        1224: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1227: astore        71
        1229: aload         69
        1231: checkcast     #144                // class ocaml_fn_25
        1234: aload         68
        1236: checkcast     #147                // class Closure
        1239: putfield      #155                // Field ocaml_fn_25.sibling_0:LClosure;
        1242: iconst_0
        1243: i2l
        1244: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1247: astore        72
        1249: aload         69
        1251: checkcast     #144                // class ocaml_fn_25
        1254: aload         69
        1256: checkcast     #147                // class Closure
        1259: putfield      #156                // Field ocaml_fn_25.sibling_1:LClosure;
        1262: iconst_0
        1263: i2l
        1264: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1267: astore        73
        1269: iconst_0
        1270: i2l
        1271: lstore        74
        1273: lload         74
        1275: l2i
        1276: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1279: astore        76
        1281: aload         18
        1283: checkcast     #2                  // class Block
        1286: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1289: bipush        37
        1291: aload         76
        1293: aastore
        1294: iconst_1
        1295: i2l
        1296: lstore        77
        1298: lload         77
        1300: l2i
        1301: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1304: astore        79
        1306: aload         18
        1308: checkcast     #2                  // class Block
        1311: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1314: bipush        38
        1316: aload         79
        1318: aastore
        1319: iconst_2
        1320: i2l
        1321: lstore        80
        1323: lload         80
        1325: l2i
        1326: invokestatic  #160                // Method Channel.forDescriptor:(I)LChannel;
        1329: astore        82
        1331: aload         18
        1333: checkcast     #2                  // class Block
        1336: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1339: bipush        39
        1341: aload         82
        1343: aastore
        1344: new           #162                // class ocaml_fn_26
        1347: dup
        1348: invokespecial #163                // Method ocaml_fn_26."<init>":()V
        1351: astore        83
        1353: aload         18
        1355: checkcast     #2                  // class Block
        1358: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1361: bipush        61
        1363: aload         83
        1365: aastore
        1366: new           #165                // class ocaml_fn_27
        1369: dup
        1370: aload         83
        1372: invokespecial #166                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1375: astore        84
        1377: aload         18
        1379: checkcast     #2                  // class Block
        1382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1385: bipush        59
        1387: aload         84
        1389: aastore
        1390: new           #168                // class ocaml_fn_28
        1393: dup
        1394: aload         83
        1396: invokespecial #169                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1399: astore        85
        1401: aload         18
        1403: checkcast     #2                  // class Block
        1406: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1409: bipush        60
        1411: aload         85
        1413: aastore
        1414: new           #171                // class ocaml_fn_29
        1417: dup
        1418: aload         33
        1420: invokespecial #172                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1423: astore        86
        1425: aload         18
        1427: checkcast     #2                  // class Block
        1430: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1433: bipush        63
        1435: aload         86
        1437: aastore
        1438: new           #174                // class ocaml_fn_30
        1441: dup
        1442: invokespecial #175                // Method ocaml_fn_30."<init>":()V
        1445: astore        87
        1447: aload         18
        1449: checkcast     #2                  // class Block
        1452: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1455: bipush        66
        1457: aload         87
        1459: aastore
        1460: new           #177                // class ocaml_fn_31
        1463: dup
        1464: invokespecial #178                // Method ocaml_fn_31."<init>":()V
        1467: astore        88
        1469: aload         18
        1471: checkcast     #2                  // class Block
        1474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1477: bipush        65
        1479: aload         88
        1481: aastore
        1482: new           #180                // class ocaml_fn_32
        1485: dup
        1486: aload         20
        1488: invokespecial #181                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1491: astore        89
        1493: aload         18
        1495: checkcast     #2                  // class Block
        1498: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1501: bipush        67
        1503: aload         89
        1505: aastore
        1506: new           #183                // class ocaml_fn_33
        1509: dup
        1510: aload         20
        1512: invokespecial #184                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1515: astore        90
        1517: aload         18
        1519: checkcast     #2                  // class Block
        1522: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1525: bipush        68
        1527: aload         90
        1529: aastore
        1530: new           #186                // class ocaml_fn_34
        1533: dup
        1534: invokespecial #187                // Method ocaml_fn_34."<init>":()V
        1537: astore        91
        1539: aload         18
        1541: checkcast     #2                  // class Block
        1544: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1547: bipush        71
        1549: aload         91
        1551: aastore
        1552: new           #189                // class ocaml_fn_35
        1555: dup
        1556: invokespecial #190                // Method ocaml_fn_35."<init>":()V
        1559: astore        92
        1561: aload         18
        1563: checkcast     #2                  // class Block
        1566: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1569: bipush        75
        1571: aload         92
        1573: aastore
        1574: new           #192                // class ocaml_fn_36
        1577: dup
        1578: invokespecial #193                // Method ocaml_fn_36."<init>":()V
        1581: astore        93
        1583: aload         18
        1585: checkcast     #2                  // class Block
        1588: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1591: bipush        76
        1593: aload         93
        1595: aastore
        1596: new           #195                // class ocaml_fn_37
        1599: dup
        1600: invokespecial #196                // Method ocaml_fn_37."<init>":()V
        1603: astore        94
        1605: aload         18
        1607: checkcast     #2                  // class Block
        1610: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1613: bipush        80
        1615: aload         94
        1617: aastore
        1618: new           #198                // class ocaml_fn_38
        1621: dup
        1622: aload         94
        1624: invokespecial #199                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1627: astore        95
        1629: aload         18
        1631: checkcast     #2                  // class Block
        1634: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1637: bipush        78
        1639: aload         95
        1641: aastore
        1642: new           #201                // class ocaml_fn_39
        1645: dup
        1646: aload         94
        1648: invokespecial #202                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1651: astore        96
        1653: aload         18
        1655: checkcast     #2                  // class Block
        1658: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1661: bipush        79
        1663: aload         96
        1665: aastore
        1666: new           #204                // class ocaml_fn_40
        1669: dup
        1670: aload         20
        1672: invokespecial #205                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1675: astore        97
        1677: aload         18
        1679: checkcast     #2                  // class Block
        1682: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1685: bipush        83
        1687: aload         97
        1689: aastore
        1690: new           #207                // class ocaml_fn_41
        1693: dup
        1694: aload         34
        1696: invokespecial #208                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1699: astore        98
        1701: aload         18
        1703: checkcast     #2                  // class Block
        1706: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1709: bipush        101
        1711: aload         98
        1713: aastore
        1714: new           #210                // class ocaml_fn_42
        1717: dup
        1718: aload         20
        1720: aload         98
        1722: invokespecial #213                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1725: astore        99
        1727: aload         18
        1729: checkcast     #2                  // class Block
        1732: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1735: bipush        84
        1737: aload         99
        1739: aastore
        1740: new           #215                // class ocaml_fn_43
        1743: dup
        1744: aload         99
        1746: invokespecial #216                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1749: astore        100
        1751: aload         18
        1753: checkcast     #2                  // class Block
        1756: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1759: bipush        85
        1761: aload         100
        1763: aastore
        1764: new           #218                // class ocaml_fn_44
        1767: dup
        1768: aload         34
        1770: invokespecial #219                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1773: astore        101
        1775: aload         18
        1777: checkcast     #2                  // class Block
        1780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1783: bipush        82
        1785: aload         101
        1787: aastore
        1788: new           #221                // class ocaml_fn_45
        1791: dup
        1792: invokespecial #222                // Method ocaml_fn_45."<init>":()V
        1795: astore        102
        1797: aload         18
        1799: checkcast     #2                  // class Block
        1802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1805: bipush        93
        1807: aload         102
        1809: aastore
        1810: new           #224                // class ocaml_fn_46
        1813: dup
        1814: aload         79
        1816: invokespecial #225                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1819: astore        103
        1821: aload         18
        1823: checkcast     #2                  // class Block
        1826: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1829: bipush        40
        1831: aload         103
        1833: aastore
        1834: new           #227                // class ocaml_fn_47
        1837: dup
        1838: aload         79
        1840: aload         88
        1842: invokespecial #228                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1845: astore        104
        1847: aload         18
        1849: checkcast     #2                  // class Block
        1852: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1855: bipush        41
        1857: aload         104
        1859: aastore
        1860: new           #230                // class ocaml_fn_48
        1863: dup
        1864: aload         79
        1866: aload         87
        1868: invokespecial #231                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        105
        1873: aload         18
        1875: checkcast     #2                  // class Block
        1878: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1881: bipush        42
        1883: aload         105
        1885: aastore
        1886: new           #233                // class ocaml_fn_49
        1889: dup
        1890: aload         63
        1892: aload         79
        1894: aload         88
        1896: invokespecial #236                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1899: astore        106
        1901: aload         18
        1903: checkcast     #2                  // class Block
        1906: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1909: bipush        43
        1911: aload         106
        1913: aastore
        1914: new           #238                // class ocaml_fn_50
        1917: dup
        1918: aload         66
        1920: aload         79
        1922: aload         88
        1924: invokespecial #239                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1927: astore        107
        1929: aload         18
        1931: checkcast     #2                  // class Block
        1934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1937: bipush        44
        1939: aload         107
        1941: aastore
        1942: new           #241                // class ocaml_fn_51
        1945: dup
        1946: aload         79
        1948: aload         88
        1950: invokespecial #242                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1953: astore        108
        1955: aload         18
        1957: checkcast     #2                  // class Block
        1960: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1963: bipush        45
        1965: aload         108
        1967: aastore
        1968: new           #244                // class ocaml_fn_52
        1971: dup
        1972: aload         79
        1974: invokespecial #245                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1977: astore        109
        1979: aload         18
        1981: checkcast     #2                  // class Block
        1984: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1987: bipush        46
        1989: aload         109
        1991: aastore
        1992: new           #247                // class ocaml_fn_53
        1995: dup
        1996: aload         82
        1998: invokespecial #248                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2001: astore        110
        2003: aload         18
        2005: checkcast     #2                  // class Block
        2008: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2011: bipush        47
        2013: aload         110
        2015: aastore
        2016: new           #250                // class ocaml_fn_54
        2019: dup
        2020: aload         82
        2022: aload         88
        2024: invokespecial #251                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2027: astore        111
        2029: aload         18
        2031: checkcast     #2                  // class Block
        2034: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2037: bipush        48
        2039: aload         111
        2041: aastore
        2042: new           #253                // class ocaml_fn_55
        2045: dup
        2046: aload         82
        2048: aload         87
        2050: invokespecial #254                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2053: astore        112
        2055: aload         18
        2057: checkcast     #2                  // class Block
        2060: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2063: bipush        49
        2065: aload         112
        2067: aastore
        2068: new           #256                // class ocaml_fn_56
        2071: dup
        2072: aload         63
        2074: aload         82
        2076: aload         88
        2078: invokespecial #257                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2081: astore        113
        2083: aload         18
        2085: checkcast     #2                  // class Block
        2088: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2091: bipush        50
        2093: aload         113
        2095: aastore
        2096: new           #259                // class ocaml_fn_57
        2099: dup
        2100: aload         66
        2102: aload         82
        2104: aload         88
        2106: invokespecial #260                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2109: astore        114
        2111: aload         18
        2113: checkcast     #2                  // class Block
        2116: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2119: bipush        51
        2121: aload         114
        2123: aastore
        2124: new           #262                // class ocaml_fn_58
        2127: dup
        2128: aload         82
        2130: aload         88
        2132: invokespecial #263                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2135: astore        115
        2137: aload         18
        2139: checkcast     #2                  // class Block
        2142: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2145: bipush        52
        2147: aload         115
        2149: aastore
        2150: new           #265                // class ocaml_fn_59
        2153: dup
        2154: aload         82
        2156: invokespecial #266                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2159: astore        116
        2161: aload         18
        2163: checkcast     #2                  // class Block
        2166: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2169: bipush        53
        2171: aload         116
        2173: aastore
        2174: new           #268                // class ocaml_fn_60
        2177: dup
        2178: aload         76
        2180: aload         79
        2182: aload         101
        2184: invokespecial #269                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2187: astore        117
        2189: aload         18
        2191: checkcast     #2                  // class Block
        2194: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2197: bipush        54
        2199: aload         117
        2201: aastore
        2202: new           #271                // class ocaml_fn_61
        2205: dup
        2206: aload         117
        2208: invokespecial #272                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2211: astore        118
        2213: aload         18
        2215: checkcast     #2                  // class Block
        2218: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2221: bipush        56
        2223: aload         118
        2225: aastore
        2226: new           #274                // class ocaml_fn_62
        2229: dup
        2230: aload         64
        2232: aload         117
        2234: invokespecial #275                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2237: astore        119
        2239: aload         18
        2241: checkcast     #2                  // class Block
        2244: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2247: bipush        55
        2249: aload         119
        2251: aastore
        2252: new           #277                // class ocaml_fn_63
        2255: dup
        2256: aload         117
        2258: invokespecial #278                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2261: astore        120
        2263: aload         18
        2265: checkcast     #2                  // class Block
        2268: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2271: bipush        58
        2273: aload         120
        2275: aastore
        2276: new           #280                // class ocaml_fn_64
        2279: dup
        2280: aload         67
        2282: aload         117
        2284: invokespecial #281                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2287: astore        121
        2289: aload         18
        2291: checkcast     #2                  // class Block
        2294: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2297: bipush        57
        2299: aload         121
        2301: aastore
        2302: new           #283                // class ocaml_fn_65
        2305: dup
        2306: invokespecial #284                // Method ocaml_fn_65."<init>":()V
        2309: astore        122
        2311: aload         18
        2313: checkcast     #2                  // class Block
        2316: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2319: bipush        96
        2321: aload         122
        2323: aastore
        2324: new           #286                // class ocaml_fn_66
        2327: dup
        2328: aload         58
        2330: invokespecial #287                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2333: astore        123
        2335: aload         18
        2337: checkcast     #2                  // class Block
        2340: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2343: bipush        97
        2345: aload         123
        2347: aastore
        2348: new           #2                  // class Block
        2351: dup
        2352: iconst_0
        2353: iconst_1
        2354: anewarray     #4                  // class java/lang/Object
        2357: dup
        2358: iconst_0
        2359: aload         86
        2361: aastore
        2362: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2365: astore        124
        2367: new           #289                // class ocaml_fn_67
        2370: dup
        2371: aload         124
        2373: invokespecial #290                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2376: astore        125
        2378: aload         18
        2380: checkcast     #2                  // class Block
        2383: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2386: bipush        99
        2388: aload         125
        2390: aastore
        2391: new           #292                // class ocaml_fn_68
        2394: dup
        2395: invokespecial #293                // Method ocaml_fn_68."<init>":()V
        2398: astore        126
        2400: new           #2                  // class Block
        2403: dup
        2404: iconst_0
        2405: iconst_1
        2406: anewarray     #4                  // class java/lang/Object
        2409: dup
        2410: iconst_0
        2411: aload         126
        2413: aastore
        2414: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2417: astore        127
        2419: aload         18
        2421: checkcast     #2                  // class Block
        2424: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2427: bipush        103
        2429: aload         127
        2431: aastore
        2432: new           #295                // class ocaml_fn_69
        2435: dup
        2436: aload         124
        2438: aload         127
        2440: invokespecial #296                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2443: astore        128
        2445: aload         18
        2447: checkcast     #2                  // class Block
        2450: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2453: bipush        102
        2455: aload         128
        2457: aastore
        2458: new           #298                // class ocaml_fn_70
        2461: dup
        2462: aload         128
        2464: invokespecial #299                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2467: astore        129
        2469: aload         18
        2471: checkcast     #2                  // class Block
        2474: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2477: bipush        98
        2479: aload         129
        2481: aastore
        2482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2485: bipush        44
        2487: aaload
        2488: astore        130
        2490: aload         130
        2492: aload         128
        2494: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2497: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2500: astore        131
        2502: new           #2                  // class Block
        2505: dup
        2506: iconst_0
        2507: bipush        6
        2509: anewarray     #4                  // class java/lang/Object
        2512: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2515: astore        132
        2517: new           #301                // class ocaml_fn_71
        2520: dup
        2521: invokespecial #302                // Method ocaml_fn_71."<init>":()V
        2524: astore        133
        2526: aload         132
        2528: checkcast     #2                  // class Block
        2531: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2534: iconst_5
        2535: aload         133
        2537: aastore
        2538: new           #304                // class ocaml_fn_72
        2541: dup
        2542: invokespecial #305                // Method ocaml_fn_72."<init>":()V
        2545: astore        134
        2547: aload         132
        2549: checkcast     #2                  // class Block
        2552: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2555: iconst_4
        2556: aload         134
        2558: aastore
        2559: new           #307                // class ocaml_fn_73
        2562: dup
        2563: invokespecial #308                // Method ocaml_fn_73."<init>":()V
        2566: astore        135
        2568: aload         132
        2570: checkcast     #2                  // class Block
        2573: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2576: iconst_3
        2577: aload         135
        2579: aastore
        2580: new           #310                // class ocaml_fn_74
        2583: dup
        2584: invokespecial #311                // Method ocaml_fn_74."<init>":()V
        2587: astore        136
        2589: aload         132
        2591: checkcast     #2                  // class Block
        2594: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2597: iconst_2
        2598: aload         136
        2600: aastore
        2601: new           #313                // class ocaml_fn_75
        2604: dup
        2605: invokespecial #314                // Method ocaml_fn_75."<init>":()V
        2608: astore        137
        2610: aload         132
        2612: checkcast     #2                  // class Block
        2615: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2618: iconst_1
        2619: aload         137
        2621: aastore
        2622: new           #316                // class ocaml_fn_76
        2625: dup
        2626: invokespecial #317                // Method ocaml_fn_76."<init>":()V
        2629: astore        138
        2631: aload         132
        2633: checkcast     #2                  // class Block
        2636: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2639: iconst_0
        2640: aload         138
        2642: aastore
        2643: aload         18
        2645: checkcast     #2                  // class Block
        2648: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2651: bipush        95
        2653: aload         132
        2655: aastore
        2656: new           #319                // class ocaml_fn_77
        2659: dup
        2660: invokespecial #320                // Method ocaml_fn_77."<init>":()V
        2663: astore        139
        2665: aload         18
        2667: checkcast     #2                  // class Block
        2670: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2673: bipush        94
        2675: aload         139
        2677: aastore
        2678: new           #322                // class ocaml_fn_78
        2681: dup
        2682: invokespecial #323                // Method ocaml_fn_78."<init>":()V
        2685: astore        140
        2687: aload         18
        2689: checkcast     #2                  // class Block
        2692: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2695: bipush        92
        2697: aload         140
        2699: aastore
        2700: new           #325                // class ocaml_fn_79
        2703: dup
        2704: invokespecial #326                // Method ocaml_fn_79."<init>":()V
        2707: astore        141
        2709: aload         18
        2711: checkcast     #2                  // class Block
        2714: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2717: bipush        91
        2719: aload         141
        2721: aastore
        2722: new           #328                // class ocaml_fn_80
        2725: dup
        2726: invokespecial #329                // Method ocaml_fn_80."<init>":()V
        2729: astore        142
        2731: aload         18
        2733: checkcast     #2                  // class Block
        2736: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2739: bipush        90
        2741: aload         142
        2743: aastore
        2744: new           #331                // class ocaml_fn_81
        2747: dup
        2748: invokespecial #332                // Method ocaml_fn_81."<init>":()V
        2751: astore        143
        2753: aload         18
        2755: checkcast     #2                  // class Block
        2758: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2761: bipush        89
        2763: aload         143
        2765: aastore
        2766: new           #334                // class ocaml_fn_82
        2769: dup
        2770: invokespecial #335                // Method ocaml_fn_82."<init>":()V
        2773: astore        144
        2775: aload         18
        2777: checkcast     #2                  // class Block
        2780: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2783: bipush        88
        2785: aload         144
        2787: aastore
        2788: new           #337                // class ocaml_fn_83
        2791: dup
        2792: invokespecial #338                // Method ocaml_fn_83."<init>":()V
        2795: astore        145
        2797: aload         18
        2799: checkcast     #2                  // class Block
        2802: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2805: bipush        87
        2807: aload         145
        2809: aastore
        2810: new           #340                // class ocaml_fn_84
        2813: dup
        2814: invokespecial #341                // Method ocaml_fn_84."<init>":()V
        2817: astore        146
        2819: aload         18
        2821: checkcast     #2                  // class Block
        2824: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2827: bipush        86
        2829: aload         146
        2831: aastore
        2832: new           #343                // class ocaml_fn_85
        2835: dup
        2836: invokespecial #344                // Method ocaml_fn_85."<init>":()V
        2839: astore        147
        2841: aload         18
        2843: checkcast     #2                  // class Block
        2846: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2849: bipush        81
        2851: aload         147
        2853: aastore
        2854: new           #346                // class ocaml_fn_86
        2857: dup
        2858: invokespecial #347                // Method ocaml_fn_86."<init>":()V
        2861: astore        148
        2863: aload         18
        2865: checkcast     #2                  // class Block
        2868: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2871: bipush        77
        2873: aload         148
        2875: aastore
        2876: new           #349                // class ocaml_fn_87
        2879: dup
        2880: invokespecial #350                // Method ocaml_fn_87."<init>":()V
        2883: astore        149
        2885: aload         18
        2887: checkcast     #2                  // class Block
        2890: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2893: bipush        74
        2895: aload         149
        2897: aastore
        2898: new           #352                // class ocaml_fn_88
        2901: dup
        2902: invokespecial #353                // Method ocaml_fn_88."<init>":()V
        2905: astore        150
        2907: aload         18
        2909: checkcast     #2                  // class Block
        2912: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2915: bipush        73
        2917: aload         150
        2919: aastore
        2920: new           #355                // class ocaml_fn_89
        2923: dup
        2924: invokespecial #356                // Method ocaml_fn_89."<init>":()V
        2927: astore        151
        2929: aload         18
        2931: checkcast     #2                  // class Block
        2934: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2937: bipush        72
        2939: aload         151
        2941: aastore
        2942: new           #358                // class ocaml_fn_90
        2945: dup
        2946: invokespecial #359                // Method ocaml_fn_90."<init>":()V
        2949: astore        152
        2951: aload         18
        2953: checkcast     #2                  // class Block
        2956: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2959: bipush        70
        2961: aload         152
        2963: aastore
        2964: new           #361                // class ocaml_fn_91
        2967: dup
        2968: invokespecial #362                // Method ocaml_fn_91."<init>":()V
        2971: astore        153
        2973: aload         18
        2975: checkcast     #2                  // class Block
        2978: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2981: bipush        69
        2983: aload         153
        2985: aastore
        2986: new           #364                // class ocaml_fn_92
        2989: dup
        2990: invokespecial #365                // Method ocaml_fn_92."<init>":()V
        2993: astore        154
        2995: aload         18
        2997: checkcast     #2                  // class Block
        3000: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3003: bipush        64
        3005: aload         154
        3007: aastore
        3008: new           #367                // class ocaml_fn_93
        3011: dup
        3012: invokespecial #368                // Method ocaml_fn_93."<init>":()V
        3015: astore        155
        3017: aload         18
        3019: checkcast     #2                  // class Block
        3022: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3025: bipush        62
        3027: aload         155
        3029: aastore
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        45
        3035: aload         18
        3037: aastore
        3038: iconst_0
        3039: i2l
        3040: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3043: astore        156
        3045: iconst_1
        3046: i2l
        3047: lstore        157
        3049: iconst_0
        3050: i2l
        3051: lstore        159
        3053: lload         159
        3055: iconst_0
        3056: i2l
        3057: lcmp
        3058: ifeq          3073
        3061: lload         157
        3063: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3066: astore        161
        3068: goto_w        3102
        3073: lload         157
        3075: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3078: astore        162
        3080: goto_w        3085
        3085: bipush        10
        3087: i2l
        3088: lstore        163
        3090: lload         163
        3092: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3095: astore        165
        3097: goto_w        3119
        3102: bipush        20
        3104: i2l
        3105: lstore        166
        3107: lload         166
        3109: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3112: astore        165
        3114: goto_w        3119
        3119: getstatic     #372                // Field java/lang/System.out:Ljava/io/PrintStream;
        3122: aload         165
        3124: invokestatic  #98                 // Method Block.asLong:(Ljava/lang/Object;)J
        3127: l2i
        3128: invokevirtual #378                // Method java/io/PrintStream.println:(I)V
        3131: iconst_0
        3132: i2l
        3133: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3136: astore        168
        3138: new           #2                  // class Block
        3141: dup
        3142: iconst_0
        3143: iconst_0
        3144: anewarray     #4                  // class java/lang/Object
        3147: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3150: astore        169
        3152: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3155: bipush        46
        3157: aload         169
        3159: aastore
        3160: iconst_0
        3161: i2l
        3162: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3165: astore        170
        3167: iconst_0
        3168: i2l
        3169: lstore        171
        3171: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3174: bipush        45
        3176: aaload
        3177: checkcast     #2                  // class Block
        3180: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3183: bipush        102
        3185: aaload
        3186: astore        173
        3188: aload         173
        3190: checkcast     #147                // class Closure
        3193: lload         171
        3195: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3198: invokevirtual #382                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3201: astore        174
        3203: new           #2                  // class Block
        3206: dup
        3207: iconst_0
        3208: iconst_0
        3209: anewarray     #4                  // class java/lang/Object
        3212: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3215: astore        175
        3217: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3220: bipush        47
        3222: aload         175
        3224: aastore
        3225: iconst_0
        3226: i2l
        3227: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3230: astore        176
        3232: return
    }
    |}]
