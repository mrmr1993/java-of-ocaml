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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3028: bipush        46
        3030: aaload
        3031: astore        157
        3033: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3036: aload         157
        3038: checkcast     #363                // class java/lang/String
        3041: invokevirtual #369                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3044: iconst_0
        3045: i2l
        3046: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3049: astore        158
        3051: new           #2                  // class Block
        3054: dup
        3055: iconst_0
        3056: iconst_0
        3057: anewarray     #4                  // class java/lang/Object
        3060: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3063: astore        159
        3065: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3068: bipush        47
        3070: aload         159
        3072: aastore
        3073: iconst_0
        3074: i2l
        3075: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3078: astore        160
        3080: iconst_0
        3081: i2l
        3082: lstore        161
        3084: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3087: bipush        45
        3089: aaload
        3090: checkcast     #2                  // class Block
        3093: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3096: bipush        102
        3098: aaload
        3099: astore        163
        3101: aload         163
        3103: checkcast     #136                // class Closure
        3106: lload         161
        3108: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3111: invokevirtual #373                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3114: astore        164
        3116: new           #2                  // class Block
        3119: dup
        3120: iconst_0
        3121: iconst_0
        3122: anewarray     #4                  // class java/lang/Object
        3125: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3128: astore        165
        3130: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3133: bipush        48
        3135: aload         165
        3137: aastore
        3138: iconst_0
        3139: i2l
        3140: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3143: astore        166
        3145: return
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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: bipush        8
        3027: i2l
        3028: lstore        157
        3030: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3033: lload         157
        3035: l2i
        3036: invokevirtual #367                // Method java/io/PrintStream.println:(I)V
        3039: iconst_0
        3040: i2l
        3041: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3044: astore        159
        3046: new           #2                  // class Block
        3049: dup
        3050: iconst_0
        3051: iconst_0
        3052: anewarray     #4                  // class java/lang/Object
        3055: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3058: astore        160
        3060: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3063: bipush        46
        3065: aload         160
        3067: aastore
        3068: iconst_0
        3069: i2l
        3070: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3073: astore        161
        3075: iconst_0
        3076: i2l
        3077: lstore        162
        3079: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3082: bipush        45
        3084: aaload
        3085: checkcast     #2                  // class Block
        3088: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3091: bipush        102
        3093: aaload
        3094: astore        164
        3096: aload         164
        3098: checkcast     #136                // class Closure
        3101: lload         162
        3103: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3106: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3109: astore        165
        3111: new           #2                  // class Block
        3114: dup
        3115: iconst_0
        3116: iconst_0
        3117: anewarray     #4                  // class java/lang/Object
        3120: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3123: astore        166
        3125: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3128: bipush        47
        3130: aload         166
        3132: aastore
        3133: iconst_0
        3134: i2l
        3135: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3138: astore        167
        3140: return
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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: iconst_0
        3026: i2l
        3027: lstore        157
        3029: lload         157
        3031: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3034: astore        159
        3036: goto_w        3041
        3041: new           #359                // class ocaml_fn_95
        3044: dup
        3045: invokespecial #360                // Method ocaml_fn_95."<init>":()V
        3048: astore        160
        3050: bipush        10
        3052: i2l
        3053: lstore        161
        3055: aload         160
        3057: lload         161
        3059: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3062: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3065: astore        163
        3067: bipush        32
        3069: i2l
        3070: lstore        164
        3072: aload         163
        3074: checkcast     #136                // class Closure
        3077: lload         164
        3079: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3082: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3085: astore        166
        3087: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3090: aload         166
        3092: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
        3095: l2i
        3096: invokevirtual #374                // Method java/io/PrintStream.println:(I)V
        3099: iconst_0
        3100: i2l
        3101: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3104: astore        167
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
        3123: astore        168
        3125: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3128: bipush        46
        3130: aload         168
        3132: aastore
        3133: iconst_0
        3134: i2l
        3135: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3138: astore        169
        3140: iconst_0
        3141: i2l
        3142: lstore        170
        3144: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3147: bipush        45
        3149: aaload
        3150: checkcast     #2                  // class Block
        3153: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3156: bipush        102
        3158: aaload
        3159: astore        172
        3161: aload         172
        3163: checkcast     #136                // class Closure
        3166: lload         170
        3168: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3171: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3174: astore        173
        3176: new           #2                  // class Block
        3179: dup
        3180: iconst_0
        3181: iconst_0
        3182: anewarray     #4                  // class java/lang/Object
        3185: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3188: astore        174
        3190: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3193: bipush        47
        3195: aload         174
        3197: aastore
        3198: iconst_0
        3199: i2l
        3200: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3203: astore        175
        3205: return
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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: iconst_0
        3026: i2l
        3027: lstore        157
        3029: lload         157
        3031: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3034: astore        159
        3036: goto_w        3041
        3041: new           #359                // class ocaml_fn_94
        3044: dup
        3045: invokespecial #360                // Method ocaml_fn_94."<init>":()V
        3048: astore        160
        3050: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3053: bipush        46
        3055: aaload
        3056: astore        161
        3058: aload         160
        3060: aload         161
        3062: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3065: astore        162
        3067: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3070: aload         162
        3072: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
        3075: l2i
        3076: invokevirtual #374                // Method java/io/PrintStream.println:(I)V
        3079: iconst_0
        3080: i2l
        3081: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3084: astore        163
        3086: new           #2                  // class Block
        3089: dup
        3090: iconst_0
        3091: iconst_1
        3092: anewarray     #4                  // class java/lang/Object
        3095: dup
        3096: iconst_0
        3097: aload         160
        3099: aastore
        3100: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3103: astore        164
        3105: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3108: bipush        47
        3110: aload         164
        3112: aastore
        3113: iconst_0
        3114: i2l
        3115: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3118: astore        165
        3120: iconst_0
        3121: i2l
        3122: lstore        166
        3124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3127: bipush        45
        3129: aaload
        3130: checkcast     #2                  // class Block
        3133: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3136: bipush        102
        3138: aaload
        3139: astore        168
        3141: aload         168
        3143: checkcast     #136                // class Closure
        3146: lload         166
        3148: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3151: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3154: astore        169
        3156: new           #2                  // class Block
        3159: dup
        3160: iconst_0
        3161: iconst_0
        3162: anewarray     #4                  // class java/lang/Object
        3165: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3168: astore        170
        3170: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3173: bipush        48
        3175: aload         170
        3177: aastore
        3178: iconst_0
        3179: i2l
        3180: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3183: astore        171
        3185: return
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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: iconst_0
        3026: i2l
        3027: lstore        157
        3029: lload         157
        3031: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3034: astore        159
        3036: goto_w        3041
        3041: iconst_0
        3042: i2l
        3043: lstore        160
        3045: iconst_1
        3046: i2l
        3047: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3050: astore        162
        3052: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3055: bipush        46
        3057: aaload
        3058: astore        163
        3060: new           #2                  // class Block
        3063: dup
        3064: sipush        248
        3067: iconst_2
        3068: anewarray     #4                  // class java/lang/Object
        3071: dup
        3072: iconst_0
        3073: aload         163
        3075: aastore
        3076: dup
        3077: iconst_1
        3078: aload         162
        3080: aastore
        3081: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3084: astore        164
        3086: new           #359                // class ocaml_fn_94
        3089: dup
        3090: aload         164
        3092: invokespecial #360                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3095: astore        165
        3097: iconst_0
        3098: i2l
        3099: lstore        166
        3101: aload         165
        3103: lload         166
        3105: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3108: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3111: astore        168
        3113: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3116: aload         168
        3118: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
        3121: l2i
        3122: invokevirtual #374                // Method java/io/PrintStream.println:(I)V
        3125: iconst_0
        3126: i2l
        3127: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3130: astore        169
        3132: new           #2                  // class Block
        3135: dup
        3136: iconst_0
        3137: iconst_2
        3138: anewarray     #4                  // class java/lang/Object
        3141: dup
        3142: iconst_0
        3143: aload         164
        3145: aastore
        3146: dup
        3147: iconst_1
        3148: aload         165
        3150: aastore
        3151: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3154: astore        170
        3156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        47
        3161: aload         170
        3163: aastore
        3164: iconst_0
        3165: i2l
        3166: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3169: astore        171
        3171: iconst_0
        3172: i2l
        3173: lstore        172
        3175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3178: bipush        45
        3180: aaload
        3181: checkcast     #2                  // class Block
        3184: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3187: bipush        102
        3189: aaload
        3190: astore        174
        3192: aload         174
        3194: checkcast     #136                // class Closure
        3197: lload         172
        3199: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3202: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3205: astore        175
        3207: new           #2                  // class Block
        3210: dup
        3211: iconst_0
        3212: iconst_0
        3213: anewarray     #4                  // class java/lang/Object
        3216: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3219: astore        176
        3221: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3224: bipush        48
        3226: aload         176
        3228: aastore
        3229: iconst_0
        3230: i2l
        3231: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3234: astore        177
        3236: return
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
          61: aconst_null
          62: astore_0
          63: aload_0
          64: astore_1
          65: goto_w        70
          70: new           #44                 // class ocaml_fn_0
          73: dup
          74: invokespecial #46                 // Method ocaml_fn_0."<init>":()V
          77: astore_2
          78: new           #48                 // class ocaml_fn_1
          81: dup
          82: invokespecial #49                 // Method ocaml_fn_1."<init>":()V
          85: astore_3
          86: new           #51                 // class ocaml_fn_2
          89: dup
          90: invokespecial #52                 // Method ocaml_fn_2."<init>":()V
          93: astore        4
          95: new           #2                  // class Block
          98: dup
          99: iconst_0
         100: iconst_3
         101: anewarray     #4                  // class java/lang/Object
         104: dup
         105: iconst_0
         106: aload_3
         107: aastore
         108: dup
         109: iconst_1
         110: aload_2
         111: aastore
         112: dup
         113: iconst_2
         114: aload         4
         116: aastore
         117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         120: astore        5
         122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         125: bipush        12
         127: aload         5
         129: aastore
         130: iconst_0
         131: i2l
         132: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         135: astore        6
         137: iconst_0
         138: i2l
         139: lstore        7
         141: lload         7
         143: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         146: astore        9
         148: goto_w        153
         153: sipush        199
         156: i2l
         157: lstore        10
         159: iconst_0
         160: i2l
         161: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         164: astore        12
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: bipush        35
         171: aaload
         172: astore        13
         174: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         177: iconst_3
         178: aaload
         179: astore        14
         181: new           #2                  // class Block
         184: dup
         185: iconst_0
         186: iconst_2
         187: anewarray     #4                  // class java/lang/Object
         190: dup
         191: iconst_0
         192: aload         14
         194: aastore
         195: dup
         196: iconst_1
         197: aload         13
         199: aastore
         200: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         203: astore        15
         205: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         208: bipush        36
         210: aaload
         211: astore        16
         213: iconst_0
         214: i2l
         215: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         218: astore        17
         220: new           #2                  // class Block
         223: dup
         224: iconst_0
         225: bipush        104
         227: anewarray     #4                  // class java/lang/Object
         230: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         233: astore        18
         235: new           #60                 // class ocaml_fn_8
         238: dup
         239: invokespecial #61                 // Method ocaml_fn_8."<init>":()V
         242: astore        19
         244: aload         18
         246: checkcast     #2                  // class Block
         249: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         252: iconst_1
         253: aload         19
         255: aastore
         256: new           #66                 // class ocaml_fn_9
         259: dup
         260: invokespecial #67                 // Method ocaml_fn_9."<init>":()V
         263: astore        20
         265: aload         18
         267: checkcast     #2                  // class Block
         270: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         273: iconst_0
         274: aload         20
         276: aastore
         277: iconst_0
         278: i2l
         279: lstore        21
         281: iconst_0
         282: i2l
         283: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         286: astore        23
         288: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         291: bipush        37
         293: aaload
         294: astore        24
         296: new           #2                  // class Block
         299: dup
         300: sipush        248
         303: iconst_2
         304: anewarray     #4                  // class java/lang/Object
         307: dup
         308: iconst_0
         309: aload         24
         311: aastore
         312: dup
         313: iconst_1
         314: aload         23
         316: aastore
         317: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         320: astore        25
         322: aload         18
         324: checkcast     #2                  // class Block
         327: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         330: iconst_2
         331: aload         25
         333: aastore
         334: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         337: bipush        7
         339: aaload
         340: astore        26
         342: aload         18
         344: checkcast     #2                  // class Block
         347: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         350: iconst_3
         351: aload         26
         353: aastore
         354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         357: bipush        10
         359: aaload
         360: astore        27
         362: aload         18
         364: checkcast     #2                  // class Block
         367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         370: iconst_4
         371: aload         27
         373: aastore
         374: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         377: iconst_3
         378: aaload
         379: astore        28
         381: aload         18
         383: checkcast     #2                  // class Block
         386: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         389: iconst_5
         390: aload         28
         392: aastore
         393: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         396: iconst_2
         397: aaload
         398: astore        29
         400: aload         18
         402: checkcast     #2                  // class Block
         405: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         408: bipush        6
         410: aload         29
         412: aastore
         413: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         416: bipush        6
         418: aaload
         419: astore        30
         421: aload         18
         423: checkcast     #2                  // class Block
         426: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         429: bipush        7
         431: aload         30
         433: aastore
         434: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         437: iconst_0
         438: aaload
         439: astore        31
         441: aload         18
         443: checkcast     #2                  // class Block
         446: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         449: bipush        8
         451: aload         31
         453: aastore
         454: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         457: bipush        8
         459: aaload
         460: astore        32
         462: aload         18
         464: checkcast     #2                  // class Block
         467: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         470: bipush        9
         472: aload         32
         474: aastore
         475: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         478: iconst_1
         479: aaload
         480: astore        33
         482: aload         18
         484: checkcast     #2                  // class Block
         487: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         490: bipush        10
         492: aload         33
         494: aastore
         495: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         498: iconst_4
         499: aaload
         500: astore        34
         502: aload         18
         504: checkcast     #2                  // class Block
         507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         510: bipush        11
         512: aload         34
         514: aastore
         515: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         518: iconst_5
         519: aaload
         520: astore        35
         522: aload         18
         524: checkcast     #2                  // class Block
         527: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         530: bipush        12
         532: aload         35
         534: aastore
         535: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         538: bipush        9
         540: aaload
         541: astore        36
         543: aload         18
         545: checkcast     #2                  // class Block
         548: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         551: bipush        13
         553: aload         36
         555: aastore
         556: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         559: bipush        11
         561: aaload
         562: astore        37
         564: aload         18
         566: checkcast     #2                  // class Block
         569: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         572: bipush        14
         574: aload         37
         576: aastore
         577: new           #69                 // class ocaml_fn_10
         580: dup
         581: invokespecial #70                 // Method ocaml_fn_10."<init>":()V
         584: astore        38
         586: aload         18
         588: checkcast     #2                  // class Block
         591: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         594: bipush        15
         596: aload         38
         598: aastore
         599: new           #72                 // class ocaml_fn_11
         602: dup
         603: invokespecial #73                 // Method ocaml_fn_11."<init>":()V
         606: astore        39
         608: aload         18
         610: checkcast     #2                  // class Block
         613: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         616: bipush        16
         618: aload         39
         620: aastore
         621: new           #75                 // class ocaml_fn_12
         624: dup
         625: invokespecial #76                 // Method ocaml_fn_12."<init>":()V
         628: astore        40
         630: aload         18
         632: checkcast     #2                  // class Block
         635: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         638: bipush        17
         640: aload         40
         642: aastore
         643: new           #78                 // class ocaml_fn_13
         646: dup
         647: invokespecial #79                 // Method ocaml_fn_13."<init>":()V
         650: astore        41
         652: aload         18
         654: checkcast     #2                  // class Block
         657: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         660: bipush        20
         662: aload         41
         664: aastore
         665: ldc2_w        #80                 // long 4611686018427387903l
         668: lstore        42
         670: aload         18
         672: checkcast     #2                  // class Block
         675: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         678: bipush        18
         680: lload         42
         682: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         685: aastore
         686: ldc2_w        #82                 // long -4611686018427387904l
         689: lstore        44
         691: aload         18
         693: checkcast     #2                  // class Block
         696: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         699: bipush        19
         701: lload         44
         703: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         706: aastore
         707: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         710: bipush        38
         712: aaload
         713: astore        46
         715: aload         46
         717: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         720: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         723: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         726: astore        47
         728: aload         18
         730: checkcast     #2                  // class Block
         733: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         736: bipush        21
         738: aload         47
         740: aastore
         741: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         744: bipush        39
         746: aaload
         747: astore        48
         749: aload         48
         751: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         754: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         757: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         760: astore        49
         762: aload         18
         764: checkcast     #2                  // class Block
         767: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         770: bipush        22
         772: aload         49
         774: aastore
         775: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         778: bipush        40
         780: aaload
         781: astore        50
         783: aload         50
         785: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         788: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         791: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         794: astore        51
         796: aload         18
         798: checkcast     #2                  // class Block
         801: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         804: bipush        23
         806: aload         51
         808: aastore
         809: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        41
         814: aaload
         815: astore        52
         817: aload         52
         819: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         822: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         825: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         828: astore        53
         830: aload         18
         832: checkcast     #2                  // class Block
         835: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         838: bipush        24
         840: aload         53
         842: aastore
         843: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         846: bipush        42
         848: aaload
         849: astore        54
         851: aload         54
         853: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         856: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         859: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         862: astore        55
         864: aload         18
         866: checkcast     #2                  // class Block
         869: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         872: bipush        25
         874: aload         55
         876: aastore
         877: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        43
         882: aaload
         883: astore        56
         885: aload         56
         887: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
         890: invokestatic  #93                 // Method java/lang/Double.longBitsToDouble:(J)D
         893: invokestatic  #96                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         896: astore        57
         898: aload         18
         900: checkcast     #2                  // class Block
         903: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         906: bipush        26
         908: aload         57
         910: aastore
         911: new           #98                 // class ocaml_fn_14
         914: dup
         915: invokespecial #99                 // Method ocaml_fn_14."<init>":()V
         918: astore        58
         920: aload         18
         922: checkcast     #2                  // class Block
         925: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         928: bipush        27
         930: aload         58
         932: aastore
         933: new           #101                // class ocaml_fn_15
         936: dup
         937: aload         20
         939: invokespecial #104                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         942: astore        59
         944: aload         18
         946: checkcast     #2                  // class Block
         949: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         952: bipush        28
         954: aload         59
         956: aastore
         957: new           #106                // class ocaml_fn_16
         960: dup
         961: invokespecial #107                // Method ocaml_fn_16."<init>":()V
         964: astore        60
         966: aload         18
         968: checkcast     #2                  // class Block
         971: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         974: bipush        29
         976: aload         60
         978: aastore
         979: new           #109                // class ocaml_fn_17
         982: dup
         983: aload         20
         985: invokespecial #110                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         988: astore        61
         990: aload         18
         992: checkcast     #2                  // class Block
         995: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
         998: bipush        31
        1000: aload         61
        1002: aastore
        1003: new           #112                // class ocaml_fn_18
        1006: dup
        1007: invokespecial #113                // Method ocaml_fn_18."<init>":()V
        1010: astore        62
        1012: aload         18
        1014: checkcast     #2                  // class Block
        1017: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1020: bipush        30
        1022: aload         62
        1024: aastore
        1025: new           #115                // class ocaml_fn_19
        1028: dup
        1029: invokespecial #116                // Method ocaml_fn_19."<init>":()V
        1032: astore        63
        1034: aload         18
        1036: checkcast     #2                  // class Block
        1039: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1042: bipush        32
        1044: aload         63
        1046: aastore
        1047: new           #118                // class ocaml_fn_20
        1050: dup
        1051: aload         29
        1053: invokespecial #119                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1056: astore        64
        1058: aload         18
        1060: checkcast     #2                  // class Block
        1063: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1066: bipush        33
        1068: aload         64
        1070: aastore
        1071: new           #121                // class ocaml_fn_21
        1074: dup
        1075: aload         58
        1077: invokespecial #122                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1080: astore        65
        1082: aload         18
        1084: checkcast     #2                  // class Block
        1087: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1090: bipush        100
        1092: aload         65
        1094: aastore
        1095: new           #124                // class ocaml_fn_22
        1098: dup
        1099: aload         65
        1101: invokespecial #125                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1104: astore        66
        1106: aload         18
        1108: checkcast     #2                  // class Block
        1111: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1114: bipush        34
        1116: aload         66
        1118: aastore
        1119: new           #127                // class ocaml_fn_23
        1122: dup
        1123: aload         29
        1125: invokespecial #128                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1128: astore        67
        1130: aload         18
        1132: checkcast     #2                  // class Block
        1135: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1138: bipush        35
        1140: aload         67
        1142: aastore
        1143: new           #130                // class ocaml_fn_24
        1146: dup
        1147: invokespecial #131                // Method ocaml_fn_24."<init>":()V
        1150: astore        68
        1152: aload         18
        1154: checkcast     #2                  // class Block
        1157: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1160: bipush        36
        1162: aload         68
        1164: aastore
        1165: new           #133                // class ocaml_fn_25
        1168: dup
        1169: invokespecial #134                // Method ocaml_fn_25."<init>":()V
        1172: astore        69
        1174: aload         68
        1176: checkcast     #130                // class ocaml_fn_24
        1179: aload         68
        1181: checkcast     #136                // class Closure
        1184: putfield      #140                // Field ocaml_fn_24.sibling_0:LClosure;
        1187: iconst_0
        1188: i2l
        1189: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1192: astore        70
        1194: aload         68
        1196: checkcast     #130                // class ocaml_fn_24
        1199: aload         69
        1201: checkcast     #136                // class Closure
        1204: putfield      #143                // Field ocaml_fn_24.sibling_1:LClosure;
        1207: iconst_0
        1208: i2l
        1209: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1212: astore        71
        1214: aload         69
        1216: checkcast     #133                // class ocaml_fn_25
        1219: aload         68
        1221: checkcast     #136                // class Closure
        1224: putfield      #144                // Field ocaml_fn_25.sibling_0:LClosure;
        1227: iconst_0
        1228: i2l
        1229: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1232: astore        72
        1234: aload         69
        1236: checkcast     #133                // class ocaml_fn_25
        1239: aload         69
        1241: checkcast     #136                // class Closure
        1244: putfield      #145                // Field ocaml_fn_25.sibling_1:LClosure;
        1247: iconst_0
        1248: i2l
        1249: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1252: astore        73
        1254: iconst_0
        1255: i2l
        1256: lstore        74
        1258: lload         74
        1260: l2i
        1261: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1264: astore        76
        1266: aload         18
        1268: checkcast     #2                  // class Block
        1271: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1274: bipush        37
        1276: aload         76
        1278: aastore
        1279: iconst_1
        1280: i2l
        1281: lstore        77
        1283: lload         77
        1285: l2i
        1286: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        79
        1291: aload         18
        1293: checkcast     #2                  // class Block
        1296: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        38
        1301: aload         79
        1303: aastore
        1304: iconst_2
        1305: i2l
        1306: lstore        80
        1308: lload         80
        1310: l2i
        1311: invokestatic  #149                // Method Channel.forDescriptor:(I)LChannel;
        1314: astore        82
        1316: aload         18
        1318: checkcast     #2                  // class Block
        1321: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1324: bipush        39
        1326: aload         82
        1328: aastore
        1329: new           #151                // class ocaml_fn_26
        1332: dup
        1333: invokespecial #152                // Method ocaml_fn_26."<init>":()V
        1336: astore        83
        1338: aload         18
        1340: checkcast     #2                  // class Block
        1343: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1346: bipush        61
        1348: aload         83
        1350: aastore
        1351: new           #154                // class ocaml_fn_27
        1354: dup
        1355: aload         83
        1357: invokespecial #155                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1360: astore        84
        1362: aload         18
        1364: checkcast     #2                  // class Block
        1367: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1370: bipush        59
        1372: aload         84
        1374: aastore
        1375: new           #157                // class ocaml_fn_28
        1378: dup
        1379: aload         83
        1381: invokespecial #158                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1384: astore        85
        1386: aload         18
        1388: checkcast     #2                  // class Block
        1391: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1394: bipush        60
        1396: aload         85
        1398: aastore
        1399: new           #160                // class ocaml_fn_29
        1402: dup
        1403: aload         33
        1405: invokespecial #161                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1408: astore        86
        1410: aload         18
        1412: checkcast     #2                  // class Block
        1415: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1418: bipush        63
        1420: aload         86
        1422: aastore
        1423: new           #163                // class ocaml_fn_30
        1426: dup
        1427: invokespecial #164                // Method ocaml_fn_30."<init>":()V
        1430: astore        87
        1432: aload         18
        1434: checkcast     #2                  // class Block
        1437: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1440: bipush        66
        1442: aload         87
        1444: aastore
        1445: new           #166                // class ocaml_fn_31
        1448: dup
        1449: invokespecial #167                // Method ocaml_fn_31."<init>":()V
        1452: astore        88
        1454: aload         18
        1456: checkcast     #2                  // class Block
        1459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1462: bipush        65
        1464: aload         88
        1466: aastore
        1467: new           #169                // class ocaml_fn_32
        1470: dup
        1471: aload         20
        1473: invokespecial #170                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1476: astore        89
        1478: aload         18
        1480: checkcast     #2                  // class Block
        1483: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1486: bipush        67
        1488: aload         89
        1490: aastore
        1491: new           #172                // class ocaml_fn_33
        1494: dup
        1495: aload         20
        1497: invokespecial #173                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1500: astore        90
        1502: aload         18
        1504: checkcast     #2                  // class Block
        1507: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1510: bipush        68
        1512: aload         90
        1514: aastore
        1515: new           #175                // class ocaml_fn_34
        1518: dup
        1519: invokespecial #176                // Method ocaml_fn_34."<init>":()V
        1522: astore        91
        1524: aload         18
        1526: checkcast     #2                  // class Block
        1529: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1532: bipush        71
        1534: aload         91
        1536: aastore
        1537: new           #178                // class ocaml_fn_35
        1540: dup
        1541: invokespecial #179                // Method ocaml_fn_35."<init>":()V
        1544: astore        92
        1546: aload         18
        1548: checkcast     #2                  // class Block
        1551: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1554: bipush        75
        1556: aload         92
        1558: aastore
        1559: new           #181                // class ocaml_fn_36
        1562: dup
        1563: invokespecial #182                // Method ocaml_fn_36."<init>":()V
        1566: astore        93
        1568: aload         18
        1570: checkcast     #2                  // class Block
        1573: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1576: bipush        76
        1578: aload         93
        1580: aastore
        1581: new           #184                // class ocaml_fn_37
        1584: dup
        1585: invokespecial #185                // Method ocaml_fn_37."<init>":()V
        1588: astore        94
        1590: aload         18
        1592: checkcast     #2                  // class Block
        1595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1598: bipush        80
        1600: aload         94
        1602: aastore
        1603: new           #187                // class ocaml_fn_38
        1606: dup
        1607: aload         94
        1609: invokespecial #188                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1612: astore        95
        1614: aload         18
        1616: checkcast     #2                  // class Block
        1619: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1622: bipush        78
        1624: aload         95
        1626: aastore
        1627: new           #190                // class ocaml_fn_39
        1630: dup
        1631: aload         94
        1633: invokespecial #191                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1636: astore        96
        1638: aload         18
        1640: checkcast     #2                  // class Block
        1643: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1646: bipush        79
        1648: aload         96
        1650: aastore
        1651: new           #193                // class ocaml_fn_40
        1654: dup
        1655: aload         20
        1657: invokespecial #194                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1660: astore        97
        1662: aload         18
        1664: checkcast     #2                  // class Block
        1667: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1670: bipush        83
        1672: aload         97
        1674: aastore
        1675: new           #196                // class ocaml_fn_41
        1678: dup
        1679: aload         34
        1681: invokespecial #197                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1684: astore        98
        1686: aload         18
        1688: checkcast     #2                  // class Block
        1691: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1694: bipush        101
        1696: aload         98
        1698: aastore
        1699: new           #199                // class ocaml_fn_42
        1702: dup
        1703: aload         20
        1705: aload         98
        1707: invokespecial #202                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1710: astore        99
        1712: aload         18
        1714: checkcast     #2                  // class Block
        1717: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1720: bipush        84
        1722: aload         99
        1724: aastore
        1725: new           #204                // class ocaml_fn_43
        1728: dup
        1729: aload         99
        1731: invokespecial #205                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1734: astore        100
        1736: aload         18
        1738: checkcast     #2                  // class Block
        1741: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1744: bipush        85
        1746: aload         100
        1748: aastore
        1749: new           #207                // class ocaml_fn_44
        1752: dup
        1753: aload         34
        1755: invokespecial #208                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1758: astore        101
        1760: aload         18
        1762: checkcast     #2                  // class Block
        1765: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1768: bipush        82
        1770: aload         101
        1772: aastore
        1773: new           #210                // class ocaml_fn_45
        1776: dup
        1777: invokespecial #211                // Method ocaml_fn_45."<init>":()V
        1780: astore        102
        1782: aload         18
        1784: checkcast     #2                  // class Block
        1787: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1790: bipush        93
        1792: aload         102
        1794: aastore
        1795: new           #213                // class ocaml_fn_46
        1798: dup
        1799: aload         79
        1801: invokespecial #214                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1804: astore        103
        1806: aload         18
        1808: checkcast     #2                  // class Block
        1811: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1814: bipush        40
        1816: aload         103
        1818: aastore
        1819: new           #216                // class ocaml_fn_47
        1822: dup
        1823: aload         79
        1825: aload         88
        1827: invokespecial #217                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1830: astore        104
        1832: aload         18
        1834: checkcast     #2                  // class Block
        1837: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1840: bipush        41
        1842: aload         104
        1844: aastore
        1845: new           #219                // class ocaml_fn_48
        1848: dup
        1849: aload         79
        1851: aload         87
        1853: invokespecial #220                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1856: astore        105
        1858: aload         18
        1860: checkcast     #2                  // class Block
        1863: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1866: bipush        42
        1868: aload         105
        1870: aastore
        1871: new           #222                // class ocaml_fn_49
        1874: dup
        1875: aload         63
        1877: aload         79
        1879: aload         88
        1881: invokespecial #225                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1884: astore        106
        1886: aload         18
        1888: checkcast     #2                  // class Block
        1891: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1894: bipush        43
        1896: aload         106
        1898: aastore
        1899: new           #227                // class ocaml_fn_50
        1902: dup
        1903: aload         66
        1905: aload         79
        1907: aload         88
        1909: invokespecial #228                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1912: astore        107
        1914: aload         18
        1916: checkcast     #2                  // class Block
        1919: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1922: bipush        44
        1924: aload         107
        1926: aastore
        1927: new           #230                // class ocaml_fn_51
        1930: dup
        1931: aload         79
        1933: aload         88
        1935: invokespecial #231                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1938: astore        108
        1940: aload         18
        1942: checkcast     #2                  // class Block
        1945: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1948: bipush        45
        1950: aload         108
        1952: aastore
        1953: new           #233                // class ocaml_fn_52
        1956: dup
        1957: aload         79
        1959: invokespecial #234                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1962: astore        109
        1964: aload         18
        1966: checkcast     #2                  // class Block
        1969: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1972: bipush        46
        1974: aload         109
        1976: aastore
        1977: new           #236                // class ocaml_fn_53
        1980: dup
        1981: aload         82
        1983: invokespecial #237                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1986: astore        110
        1988: aload         18
        1990: checkcast     #2                  // class Block
        1993: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        1996: bipush        47
        1998: aload         110
        2000: aastore
        2001: new           #239                // class ocaml_fn_54
        2004: dup
        2005: aload         82
        2007: aload         88
        2009: invokespecial #240                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2012: astore        111
        2014: aload         18
        2016: checkcast     #2                  // class Block
        2019: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2022: bipush        48
        2024: aload         111
        2026: aastore
        2027: new           #242                // class ocaml_fn_55
        2030: dup
        2031: aload         82
        2033: aload         87
        2035: invokespecial #243                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2038: astore        112
        2040: aload         18
        2042: checkcast     #2                  // class Block
        2045: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2048: bipush        49
        2050: aload         112
        2052: aastore
        2053: new           #245                // class ocaml_fn_56
        2056: dup
        2057: aload         63
        2059: aload         82
        2061: aload         88
        2063: invokespecial #246                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2066: astore        113
        2068: aload         18
        2070: checkcast     #2                  // class Block
        2073: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2076: bipush        50
        2078: aload         113
        2080: aastore
        2081: new           #248                // class ocaml_fn_57
        2084: dup
        2085: aload         66
        2087: aload         82
        2089: aload         88
        2091: invokespecial #249                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2094: astore        114
        2096: aload         18
        2098: checkcast     #2                  // class Block
        2101: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2104: bipush        51
        2106: aload         114
        2108: aastore
        2109: new           #251                // class ocaml_fn_58
        2112: dup
        2113: aload         82
        2115: aload         88
        2117: invokespecial #252                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2120: astore        115
        2122: aload         18
        2124: checkcast     #2                  // class Block
        2127: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2130: bipush        52
        2132: aload         115
        2134: aastore
        2135: new           #254                // class ocaml_fn_59
        2138: dup
        2139: aload         82
        2141: invokespecial #255                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2144: astore        116
        2146: aload         18
        2148: checkcast     #2                  // class Block
        2151: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2154: bipush        53
        2156: aload         116
        2158: aastore
        2159: new           #257                // class ocaml_fn_60
        2162: dup
        2163: aload         76
        2165: aload         79
        2167: aload         101
        2169: invokespecial #258                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2172: astore        117
        2174: aload         18
        2176: checkcast     #2                  // class Block
        2179: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2182: bipush        54
        2184: aload         117
        2186: aastore
        2187: new           #260                // class ocaml_fn_61
        2190: dup
        2191: aload         117
        2193: invokespecial #261                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2196: astore        118
        2198: aload         18
        2200: checkcast     #2                  // class Block
        2203: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2206: bipush        56
        2208: aload         118
        2210: aastore
        2211: new           #263                // class ocaml_fn_62
        2214: dup
        2215: aload         64
        2217: aload         117
        2219: invokespecial #264                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2222: astore        119
        2224: aload         18
        2226: checkcast     #2                  // class Block
        2229: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2232: bipush        55
        2234: aload         119
        2236: aastore
        2237: new           #266                // class ocaml_fn_63
        2240: dup
        2241: aload         117
        2243: invokespecial #267                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2246: astore        120
        2248: aload         18
        2250: checkcast     #2                  // class Block
        2253: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2256: bipush        58
        2258: aload         120
        2260: aastore
        2261: new           #269                // class ocaml_fn_64
        2264: dup
        2265: aload         67
        2267: aload         117
        2269: invokespecial #270                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2272: astore        121
        2274: aload         18
        2276: checkcast     #2                  // class Block
        2279: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2282: bipush        57
        2284: aload         121
        2286: aastore
        2287: new           #272                // class ocaml_fn_65
        2290: dup
        2291: invokespecial #273                // Method ocaml_fn_65."<init>":()V
        2294: astore        122
        2296: aload         18
        2298: checkcast     #2                  // class Block
        2301: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2304: bipush        96
        2306: aload         122
        2308: aastore
        2309: new           #275                // class ocaml_fn_66
        2312: dup
        2313: aload         58
        2315: invokespecial #276                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2318: astore        123
        2320: aload         18
        2322: checkcast     #2                  // class Block
        2325: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2328: bipush        97
        2330: aload         123
        2332: aastore
        2333: new           #2                  // class Block
        2336: dup
        2337: iconst_0
        2338: iconst_1
        2339: anewarray     #4                  // class java/lang/Object
        2342: dup
        2343: iconst_0
        2344: aload         86
        2346: aastore
        2347: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2350: astore        124
        2352: new           #278                // class ocaml_fn_67
        2355: dup
        2356: aload         124
        2358: invokespecial #279                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2361: astore        125
        2363: aload         18
        2365: checkcast     #2                  // class Block
        2368: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2371: bipush        99
        2373: aload         125
        2375: aastore
        2376: new           #281                // class ocaml_fn_68
        2379: dup
        2380: invokespecial #282                // Method ocaml_fn_68."<init>":()V
        2383: astore        126
        2385: new           #2                  // class Block
        2388: dup
        2389: iconst_0
        2390: iconst_1
        2391: anewarray     #4                  // class java/lang/Object
        2394: dup
        2395: iconst_0
        2396: aload         126
        2398: aastore
        2399: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2402: astore        127
        2404: aload         18
        2406: checkcast     #2                  // class Block
        2409: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2412: bipush        103
        2414: aload         127
        2416: aastore
        2417: new           #284                // class ocaml_fn_69
        2420: dup
        2421: aload         124
        2423: aload         127
        2425: invokespecial #285                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2428: astore        128
        2430: aload         18
        2432: checkcast     #2                  // class Block
        2435: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2438: bipush        102
        2440: aload         128
        2442: aastore
        2443: new           #287                // class ocaml_fn_70
        2446: dup
        2447: aload         128
        2449: invokespecial #288                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2452: astore        129
        2454: aload         18
        2456: checkcast     #2                  // class Block
        2459: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2462: bipush        98
        2464: aload         129
        2466: aastore
        2467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2470: bipush        44
        2472: aaload
        2473: astore        130
        2475: iconst_0
        2476: i2l
        2477: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2480: astore        131
        2482: new           #2                  // class Block
        2485: dup
        2486: iconst_0
        2487: bipush        6
        2489: anewarray     #4                  // class java/lang/Object
        2492: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2495: astore        132
        2497: new           #290                // class ocaml_fn_71
        2500: dup
        2501: invokespecial #291                // Method ocaml_fn_71."<init>":()V
        2504: astore        133
        2506: aload         132
        2508: checkcast     #2                  // class Block
        2511: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2514: iconst_5
        2515: aload         133
        2517: aastore
        2518: new           #293                // class ocaml_fn_72
        2521: dup
        2522: invokespecial #294                // Method ocaml_fn_72."<init>":()V
        2525: astore        134
        2527: aload         132
        2529: checkcast     #2                  // class Block
        2532: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2535: iconst_4
        2536: aload         134
        2538: aastore
        2539: new           #296                // class ocaml_fn_73
        2542: dup
        2543: invokespecial #297                // Method ocaml_fn_73."<init>":()V
        2546: astore        135
        2548: aload         132
        2550: checkcast     #2                  // class Block
        2553: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2556: iconst_3
        2557: aload         135
        2559: aastore
        2560: new           #299                // class ocaml_fn_74
        2563: dup
        2564: invokespecial #300                // Method ocaml_fn_74."<init>":()V
        2567: astore        136
        2569: aload         132
        2571: checkcast     #2                  // class Block
        2574: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2577: iconst_2
        2578: aload         136
        2580: aastore
        2581: new           #302                // class ocaml_fn_75
        2584: dup
        2585: invokespecial #303                // Method ocaml_fn_75."<init>":()V
        2588: astore        137
        2590: aload         132
        2592: checkcast     #2                  // class Block
        2595: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2598: iconst_1
        2599: aload         137
        2601: aastore
        2602: new           #305                // class ocaml_fn_76
        2605: dup
        2606: invokespecial #306                // Method ocaml_fn_76."<init>":()V
        2609: astore        138
        2611: aload         132
        2613: checkcast     #2                  // class Block
        2616: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2619: iconst_0
        2620: aload         138
        2622: aastore
        2623: aload         18
        2625: checkcast     #2                  // class Block
        2628: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2631: bipush        95
        2633: aload         132
        2635: aastore
        2636: new           #308                // class ocaml_fn_77
        2639: dup
        2640: invokespecial #309                // Method ocaml_fn_77."<init>":()V
        2643: astore        139
        2645: aload         18
        2647: checkcast     #2                  // class Block
        2650: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2653: bipush        94
        2655: aload         139
        2657: aastore
        2658: new           #311                // class ocaml_fn_78
        2661: dup
        2662: invokespecial #312                // Method ocaml_fn_78."<init>":()V
        2665: astore        140
        2667: aload         18
        2669: checkcast     #2                  // class Block
        2672: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2675: bipush        92
        2677: aload         140
        2679: aastore
        2680: new           #314                // class ocaml_fn_79
        2683: dup
        2684: invokespecial #315                // Method ocaml_fn_79."<init>":()V
        2687: astore        141
        2689: aload         18
        2691: checkcast     #2                  // class Block
        2694: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2697: bipush        91
        2699: aload         141
        2701: aastore
        2702: new           #317                // class ocaml_fn_80
        2705: dup
        2706: invokespecial #318                // Method ocaml_fn_80."<init>":()V
        2709: astore        142
        2711: aload         18
        2713: checkcast     #2                  // class Block
        2716: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2719: bipush        90
        2721: aload         142
        2723: aastore
        2724: new           #320                // class ocaml_fn_81
        2727: dup
        2728: invokespecial #321                // Method ocaml_fn_81."<init>":()V
        2731: astore        143
        2733: aload         18
        2735: checkcast     #2                  // class Block
        2738: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2741: bipush        89
        2743: aload         143
        2745: aastore
        2746: new           #323                // class ocaml_fn_82
        2749: dup
        2750: invokespecial #324                // Method ocaml_fn_82."<init>":()V
        2753: astore        144
        2755: aload         18
        2757: checkcast     #2                  // class Block
        2760: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2763: bipush        88
        2765: aload         144
        2767: aastore
        2768: new           #326                // class ocaml_fn_83
        2771: dup
        2772: invokespecial #327                // Method ocaml_fn_83."<init>":()V
        2775: astore        145
        2777: aload         18
        2779: checkcast     #2                  // class Block
        2782: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2785: bipush        87
        2787: aload         145
        2789: aastore
        2790: new           #329                // class ocaml_fn_84
        2793: dup
        2794: invokespecial #330                // Method ocaml_fn_84."<init>":()V
        2797: astore        146
        2799: aload         18
        2801: checkcast     #2                  // class Block
        2804: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2807: bipush        86
        2809: aload         146
        2811: aastore
        2812: new           #332                // class ocaml_fn_85
        2815: dup
        2816: invokespecial #333                // Method ocaml_fn_85."<init>":()V
        2819: astore        147
        2821: aload         18
        2823: checkcast     #2                  // class Block
        2826: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2829: bipush        81
        2831: aload         147
        2833: aastore
        2834: new           #335                // class ocaml_fn_86
        2837: dup
        2838: invokespecial #336                // Method ocaml_fn_86."<init>":()V
        2841: astore        148
        2843: aload         18
        2845: checkcast     #2                  // class Block
        2848: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2851: bipush        77
        2853: aload         148
        2855: aastore
        2856: new           #338                // class ocaml_fn_87
        2859: dup
        2860: invokespecial #339                // Method ocaml_fn_87."<init>":()V
        2863: astore        149
        2865: aload         18
        2867: checkcast     #2                  // class Block
        2870: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2873: bipush        74
        2875: aload         149
        2877: aastore
        2878: new           #341                // class ocaml_fn_88
        2881: dup
        2882: invokespecial #342                // Method ocaml_fn_88."<init>":()V
        2885: astore        150
        2887: aload         18
        2889: checkcast     #2                  // class Block
        2892: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2895: bipush        73
        2897: aload         150
        2899: aastore
        2900: new           #344                // class ocaml_fn_89
        2903: dup
        2904: invokespecial #345                // Method ocaml_fn_89."<init>":()V
        2907: astore        151
        2909: aload         18
        2911: checkcast     #2                  // class Block
        2914: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2917: bipush        72
        2919: aload         151
        2921: aastore
        2922: new           #347                // class ocaml_fn_90
        2925: dup
        2926: invokespecial #348                // Method ocaml_fn_90."<init>":()V
        2929: astore        152
        2931: aload         18
        2933: checkcast     #2                  // class Block
        2936: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2939: bipush        70
        2941: aload         152
        2943: aastore
        2944: new           #350                // class ocaml_fn_91
        2947: dup
        2948: invokespecial #351                // Method ocaml_fn_91."<init>":()V
        2951: astore        153
        2953: aload         18
        2955: checkcast     #2                  // class Block
        2958: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2961: bipush        69
        2963: aload         153
        2965: aastore
        2966: new           #353                // class ocaml_fn_92
        2969: dup
        2970: invokespecial #354                // Method ocaml_fn_92."<init>":()V
        2973: astore        154
        2975: aload         18
        2977: checkcast     #2                  // class Block
        2980: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        2983: bipush        64
        2985: aload         154
        2987: aastore
        2988: new           #356                // class ocaml_fn_93
        2991: dup
        2992: invokespecial #357                // Method ocaml_fn_93."<init>":()V
        2995: astore        155
        2997: aload         18
        2999: checkcast     #2                  // class Block
        3002: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3005: bipush        62
        3007: aload         155
        3009: aastore
        3010: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3013: bipush        45
        3015: aload         18
        3017: aastore
        3018: iconst_0
        3019: i2l
        3020: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3023: astore        156
        3025: iconst_1
        3026: i2l
        3027: lstore        157
        3029: iconst_0
        3030: i2l
        3031: lstore        159
        3033: lload         159
        3035: iconst_0
        3036: i2l
        3037: lcmp
        3038: ifeq          3053
        3041: lload         157
        3043: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3046: astore        161
        3048: goto_w        3082
        3053: lload         157
        3055: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3058: astore        162
        3060: goto_w        3065
        3065: bipush        10
        3067: i2l
        3068: lstore        163
        3070: lload         163
        3072: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3075: astore        165
        3077: goto_w        3099
        3082: bipush        20
        3084: i2l
        3085: lstore        166
        3087: lload         166
        3089: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3092: astore        165
        3094: goto_w        3099
        3099: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3102: aload         165
        3104: invokestatic  #87                 // Method Block.asLong:(Ljava/lang/Object;)J
        3107: l2i
        3108: invokevirtual #367                // Method java/io/PrintStream.println:(I)V
        3111: iconst_0
        3112: i2l
        3113: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3116: astore        168
        3118: new           #2                  // class Block
        3121: dup
        3122: iconst_0
        3123: iconst_0
        3124: anewarray     #4                  // class java/lang/Object
        3127: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3130: astore        169
        3132: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3135: bipush        46
        3137: aload         169
        3139: aastore
        3140: iconst_0
        3141: i2l
        3142: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3145: astore        170
        3147: iconst_0
        3148: i2l
        3149: lstore        171
        3151: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3154: bipush        45
        3156: aaload
        3157: checkcast     #2                  // class Block
        3160: getfield      #64                 // Field Block.fields:[Ljava/lang/Object;
        3163: bipush        102
        3165: aaload
        3166: astore        173
        3168: aload         173
        3170: checkcast     #136                // class Closure
        3173: lload         171
        3175: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3178: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3181: astore        174
        3183: new           #2                  // class Block
        3186: dup
        3187: iconst_0
        3188: iconst_0
        3189: anewarray     #4                  // class java/lang/Object
        3192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3195: astore        175
        3197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3200: bipush        47
        3202: aload         175
        3204: aastore
        3205: iconst_0
        3206: i2l
        3207: invokestatic  #58                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3210: astore        176
        3212: return
    }
    |}]
