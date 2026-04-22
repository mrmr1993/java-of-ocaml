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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3020: bipush        46
        3022: aaload
        3023: astore        157
        3025: getstatic     #356                // Field java/lang/System.out:Ljava/io/PrintStream;
        3028: aload         157
        3030: checkcast     #358                // class java/lang/String
        3033: invokevirtual #364                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3036: iconst_0
        3037: i2l
        3038: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3041: astore        158
        3043: new           #2                  // class Block
        3046: dup
        3047: iconst_0
        3048: iconst_0
        3049: anewarray     #4                  // class java/lang/Object
        3052: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3055: astore        159
        3057: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3060: bipush        47
        3062: aload         159
        3064: aastore
        3065: iconst_0
        3066: i2l
        3067: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3070: astore        160
        3072: iconst_0
        3073: i2l
        3074: lstore        161
        3076: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3079: bipush        45
        3081: aaload
        3082: checkcast     #2                  // class Block
        3085: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3088: bipush        102
        3090: aaload
        3091: astore        163
        3093: aload         163
        3095: checkcast     #131                // class Closure
        3098: lload         161
        3100: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3103: invokevirtual #368                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3106: astore        164
        3108: new           #2                  // class Block
        3111: dup
        3112: iconst_0
        3113: iconst_0
        3114: anewarray     #4                  // class java/lang/Object
        3117: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3120: astore        165
        3122: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3125: bipush        48
        3127: aload         165
        3129: aastore
        3130: iconst_0
        3131: i2l
        3132: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3135: astore        166
        3137: return
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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: bipush        8
        3019: i2l
        3020: lstore        157
        3022: getstatic     #356                // Field java/lang/System.out:Ljava/io/PrintStream;
        3025: lload         157
        3027: l2i
        3028: invokevirtual #362                // Method java/io/PrintStream.println:(I)V
        3031: iconst_0
        3032: i2l
        3033: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3036: astore        159
        3038: new           #2                  // class Block
        3041: dup
        3042: iconst_0
        3043: iconst_0
        3044: anewarray     #4                  // class java/lang/Object
        3047: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3050: astore        160
        3052: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3055: bipush        46
        3057: aload         160
        3059: aastore
        3060: iconst_0
        3061: i2l
        3062: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3065: astore        161
        3067: iconst_0
        3068: i2l
        3069: lstore        162
        3071: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3074: bipush        45
        3076: aaload
        3077: checkcast     #2                  // class Block
        3080: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3083: bipush        102
        3085: aaload
        3086: astore        164
        3088: aload         164
        3090: checkcast     #131                // class Closure
        3093: lload         162
        3095: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3098: invokevirtual #366                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3101: astore        165
        3103: new           #2                  // class Block
        3106: dup
        3107: iconst_0
        3108: iconst_0
        3109: anewarray     #4                  // class java/lang/Object
        3112: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3115: astore        166
        3117: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3120: bipush        47
        3122: aload         166
        3124: aastore
        3125: iconst_0
        3126: i2l
        3127: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3130: astore        167
        3132: return
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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: iconst_0
        3018: i2l
        3019: lstore        157
        3021: lload         157
        3023: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3026: astore        159
        3028: goto_w        3033
        3033: new           #354                // class ocaml_fn_95
        3036: dup
        3037: invokespecial #355                // Method ocaml_fn_95."<init>":()V
        3040: astore        160
        3042: bipush        10
        3044: i2l
        3045: lstore        161
        3047: aload         160
        3049: lload         161
        3051: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3054: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3057: astore        163
        3059: bipush        32
        3061: i2l
        3062: lstore        164
        3064: aload         163
        3066: checkcast     #131                // class Closure
        3069: lload         164
        3071: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3074: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3077: astore        166
        3079: getstatic     #363                // Field java/lang/System.out:Ljava/io/PrintStream;
        3082: aload         166
        3084: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
        3087: l2i
        3088: invokevirtual #369                // Method java/io/PrintStream.println:(I)V
        3091: iconst_0
        3092: i2l
        3093: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3096: astore        167
        3098: new           #2                  // class Block
        3101: dup
        3102: iconst_0
        3103: iconst_1
        3104: anewarray     #4                  // class java/lang/Object
        3107: dup
        3108: iconst_0
        3109: aload         160
        3111: aastore
        3112: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3115: astore        168
        3117: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3120: bipush        46
        3122: aload         168
        3124: aastore
        3125: iconst_0
        3126: i2l
        3127: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3130: astore        169
        3132: iconst_0
        3133: i2l
        3134: lstore        170
        3136: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3139: bipush        45
        3141: aaload
        3142: checkcast     #2                  // class Block
        3145: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3148: bipush        102
        3150: aaload
        3151: astore        172
        3153: aload         172
        3155: checkcast     #131                // class Closure
        3158: lload         170
        3160: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3163: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3166: astore        173
        3168: new           #2                  // class Block
        3171: dup
        3172: iconst_0
        3173: iconst_0
        3174: anewarray     #4                  // class java/lang/Object
        3177: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3180: astore        174
        3182: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3185: bipush        47
        3187: aload         174
        3189: aastore
        3190: iconst_0
        3191: i2l
        3192: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3195: astore        175
        3197: return
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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: iconst_0
        3018: i2l
        3019: lstore        157
        3021: lload         157
        3023: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3026: astore        159
        3028: goto_w        3033
        3033: new           #354                // class ocaml_fn_94
        3036: dup
        3037: invokespecial #355                // Method ocaml_fn_94."<init>":()V
        3040: astore        160
        3042: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3045: bipush        46
        3047: aaload
        3048: astore        161
        3050: aload         160
        3052: aload         161
        3054: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3057: astore        162
        3059: getstatic     #363                // Field java/lang/System.out:Ljava/io/PrintStream;
        3062: aload         162
        3064: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
        3067: l2i
        3068: invokevirtual #369                // Method java/io/PrintStream.println:(I)V
        3071: iconst_0
        3072: i2l
        3073: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3076: astore        163
        3078: new           #2                  // class Block
        3081: dup
        3082: iconst_0
        3083: iconst_1
        3084: anewarray     #4                  // class java/lang/Object
        3087: dup
        3088: iconst_0
        3089: aload         160
        3091: aastore
        3092: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3095: astore        164
        3097: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3100: bipush        47
        3102: aload         164
        3104: aastore
        3105: iconst_0
        3106: i2l
        3107: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3110: astore        165
        3112: iconst_0
        3113: i2l
        3114: lstore        166
        3116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3119: bipush        45
        3121: aaload
        3122: checkcast     #2                  // class Block
        3125: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3128: bipush        102
        3130: aaload
        3131: astore        168
        3133: aload         168
        3135: checkcast     #131                // class Closure
        3138: lload         166
        3140: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3143: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3146: astore        169
        3148: new           #2                  // class Block
        3151: dup
        3152: iconst_0
        3153: iconst_0
        3154: anewarray     #4                  // class java/lang/Object
        3157: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3160: astore        170
        3162: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3165: bipush        48
        3167: aload         170
        3169: aastore
        3170: iconst_0
        3171: i2l
        3172: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3175: astore        171
        3177: return
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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: iconst_0
        3018: i2l
        3019: lstore        157
        3021: lload         157
        3023: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3026: astore        159
        3028: goto_w        3033
        3033: iconst_0
        3034: i2l
        3035: lstore        160
        3037: iconst_1
        3038: i2l
        3039: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        162
        3044: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3047: bipush        46
        3049: aaload
        3050: astore        163
        3052: new           #2                  // class Block
        3055: dup
        3056: sipush        248
        3059: iconst_2
        3060: anewarray     #4                  // class java/lang/Object
        3063: dup
        3064: iconst_0
        3065: aload         163
        3067: aastore
        3068: dup
        3069: iconst_1
        3070: aload         162
        3072: aastore
        3073: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3076: astore        164
        3078: new           #354                // class ocaml_fn_94
        3081: dup
        3082: aload         164
        3084: invokespecial #355                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3087: astore        165
        3089: iconst_0
        3090: i2l
        3091: lstore        166
        3093: aload         165
        3095: lload         166
        3097: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3100: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3103: astore        168
        3105: getstatic     #363                // Field java/lang/System.out:Ljava/io/PrintStream;
        3108: aload         168
        3110: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
        3113: l2i
        3114: invokevirtual #369                // Method java/io/PrintStream.println:(I)V
        3117: iconst_0
        3118: i2l
        3119: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3122: astore        169
        3124: new           #2                  // class Block
        3127: dup
        3128: iconst_0
        3129: iconst_2
        3130: anewarray     #4                  // class java/lang/Object
        3133: dup
        3134: iconst_0
        3135: aload         164
        3137: aastore
        3138: dup
        3139: iconst_1
        3140: aload         165
        3142: aastore
        3143: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3146: astore        170
        3148: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3151: bipush        47
        3153: aload         170
        3155: aastore
        3156: iconst_0
        3157: i2l
        3158: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3161: astore        171
        3163: iconst_0
        3164: i2l
        3165: lstore        172
        3167: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3170: bipush        45
        3172: aaload
        3173: checkcast     #2                  // class Block
        3176: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3179: bipush        102
        3181: aaload
        3182: astore        174
        3184: aload         174
        3186: checkcast     #131                // class Closure
        3189: lload         172
        3191: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3194: invokevirtual #359                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3197: astore        175
        3199: new           #2                  // class Block
        3202: dup
        3203: iconst_0
        3204: iconst_0
        3205: anewarray     #4                  // class java/lang/Object
        3208: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3211: astore        176
        3213: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3216: bipush        48
        3218: aload         176
        3220: aastore
        3221: iconst_0
        3222: i2l
        3223: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3226: astore        177
        3228: return
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
          53: aconst_null
          54: astore_0
          55: aload_0
          56: astore_1
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_2
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore_3
          78: new           #46                 // class ocaml_fn_2
          81: dup
          82: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          85: astore        4
          87: new           #2                  // class Block
          90: dup
          91: iconst_0
          92: iconst_3
          93: anewarray     #4                  // class java/lang/Object
          96: dup
          97: iconst_0
          98: aload_3
          99: aastore
         100: dup
         101: iconst_1
         102: aload_2
         103: aastore
         104: dup
         105: iconst_2
         106: aload         4
         108: aastore
         109: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         112: astore        5
         114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         117: bipush        12
         119: aload         5
         121: aastore
         122: iconst_0
         123: i2l
         124: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         127: astore        6
         129: iconst_0
         130: i2l
         131: lstore        7
         133: lload         7
         135: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: i2l
         149: lstore        10
         151: iconst_0
         152: i2l
         153: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         156: astore        12
         158: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         161: bipush        35
         163: aaload
         164: astore        13
         166: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         169: iconst_3
         170: aaload
         171: astore        14
         173: new           #2                  // class Block
         176: dup
         177: iconst_0
         178: iconst_2
         179: anewarray     #4                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: aload         14
         186: aastore
         187: dup
         188: iconst_1
         189: aload         13
         191: aastore
         192: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         195: astore        15
         197: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         200: bipush        36
         202: aaload
         203: astore        16
         205: iconst_0
         206: i2l
         207: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         210: astore        17
         212: new           #2                  // class Block
         215: dup
         216: iconst_0
         217: bipush        104
         219: anewarray     #4                  // class java/lang/Object
         222: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         225: astore        18
         227: new           #55                 // class ocaml_fn_8
         230: dup
         231: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         234: astore        19
         236: aload         18
         238: checkcast     #2                  // class Block
         241: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         244: iconst_1
         245: aload         19
         247: aastore
         248: new           #61                 // class ocaml_fn_9
         251: dup
         252: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         255: astore        20
         257: aload         18
         259: checkcast     #2                  // class Block
         262: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         265: iconst_0
         266: aload         20
         268: aastore
         269: iconst_0
         270: i2l
         271: lstore        21
         273: iconst_0
         274: i2l
         275: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         278: astore        23
         280: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         283: bipush        37
         285: aaload
         286: astore        24
         288: new           #2                  // class Block
         291: dup
         292: sipush        248
         295: iconst_2
         296: anewarray     #4                  // class java/lang/Object
         299: dup
         300: iconst_0
         301: aload         24
         303: aastore
         304: dup
         305: iconst_1
         306: aload         23
         308: aastore
         309: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         312: astore        25
         314: aload         18
         316: checkcast     #2                  // class Block
         319: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         322: iconst_2
         323: aload         25
         325: aastore
         326: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         329: bipush        7
         331: aaload
         332: astore        26
         334: aload         18
         336: checkcast     #2                  // class Block
         339: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         342: iconst_3
         343: aload         26
         345: aastore
         346: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         349: bipush        10
         351: aaload
         352: astore        27
         354: aload         18
         356: checkcast     #2                  // class Block
         359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         362: iconst_4
         363: aload         27
         365: aastore
         366: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         369: iconst_3
         370: aaload
         371: astore        28
         373: aload         18
         375: checkcast     #2                  // class Block
         378: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         381: iconst_5
         382: aload         28
         384: aastore
         385: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         388: iconst_2
         389: aaload
         390: astore        29
         392: aload         18
         394: checkcast     #2                  // class Block
         397: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         400: bipush        6
         402: aload         29
         404: aastore
         405: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         408: bipush        6
         410: aaload
         411: astore        30
         413: aload         18
         415: checkcast     #2                  // class Block
         418: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         421: bipush        7
         423: aload         30
         425: aastore
         426: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         429: iconst_0
         430: aaload
         431: astore        31
         433: aload         18
         435: checkcast     #2                  // class Block
         438: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         441: bipush        8
         443: aload         31
         445: aastore
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        8
         451: aaload
         452: astore        32
         454: aload         18
         456: checkcast     #2                  // class Block
         459: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         462: bipush        9
         464: aload         32
         466: aastore
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: iconst_1
         471: aaload
         472: astore        33
         474: aload         18
         476: checkcast     #2                  // class Block
         479: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         482: bipush        10
         484: aload         33
         486: aastore
         487: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         490: iconst_4
         491: aaload
         492: astore        34
         494: aload         18
         496: checkcast     #2                  // class Block
         499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         502: bipush        11
         504: aload         34
         506: aastore
         507: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         510: iconst_5
         511: aaload
         512: astore        35
         514: aload         18
         516: checkcast     #2                  // class Block
         519: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         522: bipush        12
         524: aload         35
         526: aastore
         527: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         530: bipush        9
         532: aaload
         533: astore        36
         535: aload         18
         537: checkcast     #2                  // class Block
         540: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         543: bipush        13
         545: aload         36
         547: aastore
         548: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         551: bipush        11
         553: aaload
         554: astore        37
         556: aload         18
         558: checkcast     #2                  // class Block
         561: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         564: bipush        14
         566: aload         37
         568: aastore
         569: new           #64                 // class ocaml_fn_10
         572: dup
         573: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         576: astore        38
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        15
         588: aload         38
         590: aastore
         591: new           #67                 // class ocaml_fn_11
         594: dup
         595: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         598: astore        39
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        16
         610: aload         39
         612: aastore
         613: new           #70                 // class ocaml_fn_12
         616: dup
         617: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         620: astore        40
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        17
         632: aload         40
         634: aastore
         635: new           #73                 // class ocaml_fn_13
         638: dup
         639: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         642: astore        41
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        20
         654: aload         41
         656: aastore
         657: ldc2_w        #75                 // long 4611686018427387903l
         660: lstore        42
         662: aload         18
         664: checkcast     #2                  // class Block
         667: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         670: bipush        18
         672: lload         42
         674: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         677: aastore
         678: ldc2_w        #77                 // long -4611686018427387904l
         681: lstore        44
         683: aload         18
         685: checkcast     #2                  // class Block
         688: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         691: bipush        19
         693: lload         44
         695: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         698: aastore
         699: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         702: bipush        38
         704: aaload
         705: astore        46
         707: aload         46
         709: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         712: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         715: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         718: astore        47
         720: aload         18
         722: checkcast     #2                  // class Block
         725: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         728: bipush        21
         730: aload         47
         732: aastore
         733: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         736: bipush        39
         738: aaload
         739: astore        48
         741: aload         48
         743: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         746: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         749: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         752: astore        49
         754: aload         18
         756: checkcast     #2                  // class Block
         759: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         762: bipush        22
         764: aload         49
         766: aastore
         767: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         770: bipush        40
         772: aaload
         773: astore        50
         775: aload         50
         777: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         780: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         783: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         786: astore        51
         788: aload         18
         790: checkcast     #2                  // class Block
         793: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         796: bipush        23
         798: aload         51
         800: aastore
         801: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        41
         806: aaload
         807: astore        52
         809: aload         52
         811: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         814: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         817: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         820: astore        53
         822: aload         18
         824: checkcast     #2                  // class Block
         827: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         830: bipush        24
         832: aload         53
         834: aastore
         835: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         838: bipush        42
         840: aaload
         841: astore        54
         843: aload         54
         845: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         848: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         851: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         854: astore        55
         856: aload         18
         858: checkcast     #2                  // class Block
         861: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         864: bipush        25
         866: aload         55
         868: aastore
         869: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        43
         874: aaload
         875: astore        56
         877: aload         56
         879: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
         882: invokestatic  #88                 // Method java/lang/Double.longBitsToDouble:(J)D
         885: invokestatic  #91                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         888: astore        57
         890: aload         18
         892: checkcast     #2                  // class Block
         895: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         898: bipush        26
         900: aload         57
         902: aastore
         903: new           #93                 // class ocaml_fn_14
         906: dup
         907: invokespecial #94                 // Method ocaml_fn_14."<init>":()V
         910: astore        58
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        27
         922: aload         58
         924: aastore
         925: new           #96                 // class ocaml_fn_15
         928: dup
         929: aload         20
         931: invokespecial #99                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         934: astore        59
         936: aload         18
         938: checkcast     #2                  // class Block
         941: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         944: bipush        28
         946: aload         59
         948: aastore
         949: new           #101                // class ocaml_fn_16
         952: dup
         953: invokespecial #102                // Method ocaml_fn_16."<init>":()V
         956: astore        60
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        29
         968: aload         60
         970: aastore
         971: new           #104                // class ocaml_fn_17
         974: dup
         975: aload         20
         977: invokespecial #105                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         980: astore        61
         982: aload         18
         984: checkcast     #2                  // class Block
         987: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         990: bipush        31
         992: aload         61
         994: aastore
         995: new           #107                // class ocaml_fn_18
         998: dup
         999: invokespecial #108                // Method ocaml_fn_18."<init>":()V
        1002: astore        62
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        30
        1014: aload         62
        1016: aastore
        1017: new           #110                // class ocaml_fn_19
        1020: dup
        1021: invokespecial #111                // Method ocaml_fn_19."<init>":()V
        1024: astore        63
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        32
        1036: aload         63
        1038: aastore
        1039: new           #113                // class ocaml_fn_20
        1042: dup
        1043: aload         29
        1045: invokespecial #114                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1048: astore        64
        1050: aload         18
        1052: checkcast     #2                  // class Block
        1055: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1058: bipush        33
        1060: aload         64
        1062: aastore
        1063: new           #116                // class ocaml_fn_21
        1066: dup
        1067: aload         58
        1069: invokespecial #117                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1072: astore        65
        1074: aload         18
        1076: checkcast     #2                  // class Block
        1079: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1082: bipush        100
        1084: aload         65
        1086: aastore
        1087: new           #119                // class ocaml_fn_22
        1090: dup
        1091: aload         65
        1093: invokespecial #120                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1096: astore        66
        1098: aload         18
        1100: checkcast     #2                  // class Block
        1103: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1106: bipush        34
        1108: aload         66
        1110: aastore
        1111: new           #122                // class ocaml_fn_23
        1114: dup
        1115: aload         29
        1117: invokespecial #123                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1120: astore        67
        1122: aload         18
        1124: checkcast     #2                  // class Block
        1127: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1130: bipush        35
        1132: aload         67
        1134: aastore
        1135: new           #125                // class ocaml_fn_24
        1138: dup
        1139: invokespecial #126                // Method ocaml_fn_24."<init>":()V
        1142: astore        68
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        36
        1154: aload         68
        1156: aastore
        1157: new           #128                // class ocaml_fn_25
        1160: dup
        1161: invokespecial #129                // Method ocaml_fn_25."<init>":()V
        1164: astore        69
        1166: aload         68
        1168: checkcast     #125                // class ocaml_fn_24
        1171: aload         68
        1173: checkcast     #131                // class Closure
        1176: putfield      #135                // Field ocaml_fn_24.sibling_0:LClosure;
        1179: iconst_0
        1180: i2l
        1181: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1184: astore        70
        1186: aload         68
        1188: checkcast     #125                // class ocaml_fn_24
        1191: aload         69
        1193: checkcast     #131                // class Closure
        1196: putfield      #138                // Field ocaml_fn_24.sibling_1:LClosure;
        1199: iconst_0
        1200: i2l
        1201: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1204: astore        71
        1206: aload         69
        1208: checkcast     #128                // class ocaml_fn_25
        1211: aload         68
        1213: checkcast     #131                // class Closure
        1216: putfield      #139                // Field ocaml_fn_25.sibling_0:LClosure;
        1219: iconst_0
        1220: i2l
        1221: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1224: astore        72
        1226: aload         69
        1228: checkcast     #128                // class ocaml_fn_25
        1231: aload         69
        1233: checkcast     #131                // class Closure
        1236: putfield      #140                // Field ocaml_fn_25.sibling_1:LClosure;
        1239: iconst_0
        1240: i2l
        1241: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1244: astore        73
        1246: iconst_0
        1247: i2l
        1248: lstore        74
        1250: lload         74
        1252: l2i
        1253: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1256: astore        76
        1258: aload         18
        1260: checkcast     #2                  // class Block
        1263: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1266: bipush        37
        1268: aload         76
        1270: aastore
        1271: iconst_1
        1272: i2l
        1273: lstore        77
        1275: lload         77
        1277: l2i
        1278: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1281: astore        79
        1283: aload         18
        1285: checkcast     #2                  // class Block
        1288: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1291: bipush        38
        1293: aload         79
        1295: aastore
        1296: iconst_2
        1297: i2l
        1298: lstore        80
        1300: lload         80
        1302: l2i
        1303: invokestatic  #144                // Method Channel.forDescriptor:(I)LChannel;
        1306: astore        82
        1308: aload         18
        1310: checkcast     #2                  // class Block
        1313: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1316: bipush        39
        1318: aload         82
        1320: aastore
        1321: new           #146                // class ocaml_fn_26
        1324: dup
        1325: invokespecial #147                // Method ocaml_fn_26."<init>":()V
        1328: astore        83
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        61
        1340: aload         83
        1342: aastore
        1343: new           #149                // class ocaml_fn_27
        1346: dup
        1347: aload         83
        1349: invokespecial #150                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1352: astore        84
        1354: aload         18
        1356: checkcast     #2                  // class Block
        1359: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1362: bipush        59
        1364: aload         84
        1366: aastore
        1367: new           #152                // class ocaml_fn_28
        1370: dup
        1371: aload         83
        1373: invokespecial #153                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1376: astore        85
        1378: aload         18
        1380: checkcast     #2                  // class Block
        1383: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1386: bipush        60
        1388: aload         85
        1390: aastore
        1391: new           #155                // class ocaml_fn_29
        1394: dup
        1395: aload         33
        1397: invokespecial #156                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1400: astore        86
        1402: aload         18
        1404: checkcast     #2                  // class Block
        1407: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1410: bipush        63
        1412: aload         86
        1414: aastore
        1415: new           #158                // class ocaml_fn_30
        1418: dup
        1419: invokespecial #159                // Method ocaml_fn_30."<init>":()V
        1422: astore        87
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        66
        1434: aload         87
        1436: aastore
        1437: new           #161                // class ocaml_fn_31
        1440: dup
        1441: invokespecial #162                // Method ocaml_fn_31."<init>":()V
        1444: astore        88
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        65
        1456: aload         88
        1458: aastore
        1459: new           #164                // class ocaml_fn_32
        1462: dup
        1463: aload         20
        1465: invokespecial #165                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1468: astore        89
        1470: aload         18
        1472: checkcast     #2                  // class Block
        1475: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1478: bipush        67
        1480: aload         89
        1482: aastore
        1483: new           #167                // class ocaml_fn_33
        1486: dup
        1487: aload         20
        1489: invokespecial #168                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1492: astore        90
        1494: aload         18
        1496: checkcast     #2                  // class Block
        1499: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1502: bipush        68
        1504: aload         90
        1506: aastore
        1507: new           #170                // class ocaml_fn_34
        1510: dup
        1511: invokespecial #171                // Method ocaml_fn_34."<init>":()V
        1514: astore        91
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        71
        1526: aload         91
        1528: aastore
        1529: new           #173                // class ocaml_fn_35
        1532: dup
        1533: invokespecial #174                // Method ocaml_fn_35."<init>":()V
        1536: astore        92
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        75
        1548: aload         92
        1550: aastore
        1551: new           #176                // class ocaml_fn_36
        1554: dup
        1555: invokespecial #177                // Method ocaml_fn_36."<init>":()V
        1558: astore        93
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        76
        1570: aload         93
        1572: aastore
        1573: new           #179                // class ocaml_fn_37
        1576: dup
        1577: invokespecial #180                // Method ocaml_fn_37."<init>":()V
        1580: astore        94
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        80
        1592: aload         94
        1594: aastore
        1595: new           #182                // class ocaml_fn_38
        1598: dup
        1599: aload         94
        1601: invokespecial #183                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1604: astore        95
        1606: aload         18
        1608: checkcast     #2                  // class Block
        1611: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1614: bipush        78
        1616: aload         95
        1618: aastore
        1619: new           #185                // class ocaml_fn_39
        1622: dup
        1623: aload         94
        1625: invokespecial #186                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1628: astore        96
        1630: aload         18
        1632: checkcast     #2                  // class Block
        1635: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1638: bipush        79
        1640: aload         96
        1642: aastore
        1643: new           #188                // class ocaml_fn_40
        1646: dup
        1647: aload         20
        1649: invokespecial #189                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1652: astore        97
        1654: aload         18
        1656: checkcast     #2                  // class Block
        1659: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1662: bipush        83
        1664: aload         97
        1666: aastore
        1667: new           #191                // class ocaml_fn_41
        1670: dup
        1671: aload         34
        1673: invokespecial #192                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1676: astore        98
        1678: aload         18
        1680: checkcast     #2                  // class Block
        1683: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1686: bipush        101
        1688: aload         98
        1690: aastore
        1691: new           #194                // class ocaml_fn_42
        1694: dup
        1695: aload         20
        1697: aload         98
        1699: invokespecial #197                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1702: astore        99
        1704: aload         18
        1706: checkcast     #2                  // class Block
        1709: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1712: bipush        84
        1714: aload         99
        1716: aastore
        1717: new           #199                // class ocaml_fn_43
        1720: dup
        1721: aload         99
        1723: invokespecial #200                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1726: astore        100
        1728: aload         18
        1730: checkcast     #2                  // class Block
        1733: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1736: bipush        85
        1738: aload         100
        1740: aastore
        1741: new           #202                // class ocaml_fn_44
        1744: dup
        1745: aload         34
        1747: invokespecial #203                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1750: astore        101
        1752: aload         18
        1754: checkcast     #2                  // class Block
        1757: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1760: bipush        82
        1762: aload         101
        1764: aastore
        1765: new           #205                // class ocaml_fn_45
        1768: dup
        1769: invokespecial #206                // Method ocaml_fn_45."<init>":()V
        1772: astore        102
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        93
        1784: aload         102
        1786: aastore
        1787: new           #208                // class ocaml_fn_46
        1790: dup
        1791: aload         79
        1793: invokespecial #209                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1796: astore        103
        1798: aload         18
        1800: checkcast     #2                  // class Block
        1803: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1806: bipush        40
        1808: aload         103
        1810: aastore
        1811: new           #211                // class ocaml_fn_47
        1814: dup
        1815: aload         79
        1817: aload         88
        1819: invokespecial #212                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1822: astore        104
        1824: aload         18
        1826: checkcast     #2                  // class Block
        1829: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1832: bipush        41
        1834: aload         104
        1836: aastore
        1837: new           #214                // class ocaml_fn_48
        1840: dup
        1841: aload         79
        1843: aload         87
        1845: invokespecial #215                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1848: astore        105
        1850: aload         18
        1852: checkcast     #2                  // class Block
        1855: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1858: bipush        42
        1860: aload         105
        1862: aastore
        1863: new           #217                // class ocaml_fn_49
        1866: dup
        1867: aload         63
        1869: aload         79
        1871: aload         88
        1873: invokespecial #220                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1876: astore        106
        1878: aload         18
        1880: checkcast     #2                  // class Block
        1883: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1886: bipush        43
        1888: aload         106
        1890: aastore
        1891: new           #222                // class ocaml_fn_50
        1894: dup
        1895: aload         66
        1897: aload         79
        1899: aload         88
        1901: invokespecial #223                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1904: astore        107
        1906: aload         18
        1908: checkcast     #2                  // class Block
        1911: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1914: bipush        44
        1916: aload         107
        1918: aastore
        1919: new           #225                // class ocaml_fn_51
        1922: dup
        1923: aload         79
        1925: aload         88
        1927: invokespecial #226                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1930: astore        108
        1932: aload         18
        1934: checkcast     #2                  // class Block
        1937: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1940: bipush        45
        1942: aload         108
        1944: aastore
        1945: new           #228                // class ocaml_fn_52
        1948: dup
        1949: aload         79
        1951: invokespecial #229                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1954: astore        109
        1956: aload         18
        1958: checkcast     #2                  // class Block
        1961: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1964: bipush        46
        1966: aload         109
        1968: aastore
        1969: new           #231                // class ocaml_fn_53
        1972: dup
        1973: aload         82
        1975: invokespecial #232                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1978: astore        110
        1980: aload         18
        1982: checkcast     #2                  // class Block
        1985: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1988: bipush        47
        1990: aload         110
        1992: aastore
        1993: new           #234                // class ocaml_fn_54
        1996: dup
        1997: aload         82
        1999: aload         88
        2001: invokespecial #235                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2004: astore        111
        2006: aload         18
        2008: checkcast     #2                  // class Block
        2011: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2014: bipush        48
        2016: aload         111
        2018: aastore
        2019: new           #237                // class ocaml_fn_55
        2022: dup
        2023: aload         82
        2025: aload         87
        2027: invokespecial #238                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        112
        2032: aload         18
        2034: checkcast     #2                  // class Block
        2037: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2040: bipush        49
        2042: aload         112
        2044: aastore
        2045: new           #240                // class ocaml_fn_56
        2048: dup
        2049: aload         63
        2051: aload         82
        2053: aload         88
        2055: invokespecial #241                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2058: astore        113
        2060: aload         18
        2062: checkcast     #2                  // class Block
        2065: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2068: bipush        50
        2070: aload         113
        2072: aastore
        2073: new           #243                // class ocaml_fn_57
        2076: dup
        2077: aload         66
        2079: aload         82
        2081: aload         88
        2083: invokespecial #244                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2086: astore        114
        2088: aload         18
        2090: checkcast     #2                  // class Block
        2093: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2096: bipush        51
        2098: aload         114
        2100: aastore
        2101: new           #246                // class ocaml_fn_58
        2104: dup
        2105: aload         82
        2107: aload         88
        2109: invokespecial #247                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2112: astore        115
        2114: aload         18
        2116: checkcast     #2                  // class Block
        2119: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2122: bipush        52
        2124: aload         115
        2126: aastore
        2127: new           #249                // class ocaml_fn_59
        2130: dup
        2131: aload         82
        2133: invokespecial #250                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2136: astore        116
        2138: aload         18
        2140: checkcast     #2                  // class Block
        2143: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2146: bipush        53
        2148: aload         116
        2150: aastore
        2151: new           #252                // class ocaml_fn_60
        2154: dup
        2155: aload         76
        2157: aload         79
        2159: aload         101
        2161: invokespecial #253                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2164: astore        117
        2166: aload         18
        2168: checkcast     #2                  // class Block
        2171: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2174: bipush        54
        2176: aload         117
        2178: aastore
        2179: new           #255                // class ocaml_fn_61
        2182: dup
        2183: aload         117
        2185: invokespecial #256                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2188: astore        118
        2190: aload         18
        2192: checkcast     #2                  // class Block
        2195: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2198: bipush        56
        2200: aload         118
        2202: aastore
        2203: new           #258                // class ocaml_fn_62
        2206: dup
        2207: aload         64
        2209: aload         117
        2211: invokespecial #259                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2214: astore        119
        2216: aload         18
        2218: checkcast     #2                  // class Block
        2221: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2224: bipush        55
        2226: aload         119
        2228: aastore
        2229: new           #261                // class ocaml_fn_63
        2232: dup
        2233: aload         117
        2235: invokespecial #262                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2238: astore        120
        2240: aload         18
        2242: checkcast     #2                  // class Block
        2245: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2248: bipush        58
        2250: aload         120
        2252: aastore
        2253: new           #264                // class ocaml_fn_64
        2256: dup
        2257: aload         67
        2259: aload         117
        2261: invokespecial #265                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2264: astore        121
        2266: aload         18
        2268: checkcast     #2                  // class Block
        2271: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2274: bipush        57
        2276: aload         121
        2278: aastore
        2279: new           #267                // class ocaml_fn_65
        2282: dup
        2283: invokespecial #268                // Method ocaml_fn_65."<init>":()V
        2286: astore        122
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        96
        2298: aload         122
        2300: aastore
        2301: new           #270                // class ocaml_fn_66
        2304: dup
        2305: aload         58
        2307: invokespecial #271                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2310: astore        123
        2312: aload         18
        2314: checkcast     #2                  // class Block
        2317: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2320: bipush        97
        2322: aload         123
        2324: aastore
        2325: new           #2                  // class Block
        2328: dup
        2329: iconst_0
        2330: iconst_1
        2331: anewarray     #4                  // class java/lang/Object
        2334: dup
        2335: iconst_0
        2336: aload         86
        2338: aastore
        2339: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2342: astore        124
        2344: new           #273                // class ocaml_fn_67
        2347: dup
        2348: aload         124
        2350: invokespecial #274                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2353: astore        125
        2355: aload         18
        2357: checkcast     #2                  // class Block
        2360: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2363: bipush        99
        2365: aload         125
        2367: aastore
        2368: new           #276                // class ocaml_fn_68
        2371: dup
        2372: invokespecial #277                // Method ocaml_fn_68."<init>":()V
        2375: astore        126
        2377: new           #2                  // class Block
        2380: dup
        2381: iconst_0
        2382: iconst_1
        2383: anewarray     #4                  // class java/lang/Object
        2386: dup
        2387: iconst_0
        2388: aload         126
        2390: aastore
        2391: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2394: astore        127
        2396: aload         18
        2398: checkcast     #2                  // class Block
        2401: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2404: bipush        103
        2406: aload         127
        2408: aastore
        2409: new           #279                // class ocaml_fn_69
        2412: dup
        2413: aload         124
        2415: aload         127
        2417: invokespecial #280                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2420: astore        128
        2422: aload         18
        2424: checkcast     #2                  // class Block
        2427: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2430: bipush        102
        2432: aload         128
        2434: aastore
        2435: new           #282                // class ocaml_fn_70
        2438: dup
        2439: aload         128
        2441: invokespecial #283                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2444: astore        129
        2446: aload         18
        2448: checkcast     #2                  // class Block
        2451: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2454: bipush        98
        2456: aload         129
        2458: aastore
        2459: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2462: bipush        44
        2464: aaload
        2465: astore        130
        2467: iconst_0
        2468: i2l
        2469: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2472: astore        131
        2474: new           #2                  // class Block
        2477: dup
        2478: iconst_0
        2479: bipush        6
        2481: anewarray     #4                  // class java/lang/Object
        2484: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2487: astore        132
        2489: new           #285                // class ocaml_fn_71
        2492: dup
        2493: invokespecial #286                // Method ocaml_fn_71."<init>":()V
        2496: astore        133
        2498: aload         132
        2500: checkcast     #2                  // class Block
        2503: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2506: iconst_5
        2507: aload         133
        2509: aastore
        2510: new           #288                // class ocaml_fn_72
        2513: dup
        2514: invokespecial #289                // Method ocaml_fn_72."<init>":()V
        2517: astore        134
        2519: aload         132
        2521: checkcast     #2                  // class Block
        2524: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2527: iconst_4
        2528: aload         134
        2530: aastore
        2531: new           #291                // class ocaml_fn_73
        2534: dup
        2535: invokespecial #292                // Method ocaml_fn_73."<init>":()V
        2538: astore        135
        2540: aload         132
        2542: checkcast     #2                  // class Block
        2545: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2548: iconst_3
        2549: aload         135
        2551: aastore
        2552: new           #294                // class ocaml_fn_74
        2555: dup
        2556: invokespecial #295                // Method ocaml_fn_74."<init>":()V
        2559: astore        136
        2561: aload         132
        2563: checkcast     #2                  // class Block
        2566: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2569: iconst_2
        2570: aload         136
        2572: aastore
        2573: new           #297                // class ocaml_fn_75
        2576: dup
        2577: invokespecial #298                // Method ocaml_fn_75."<init>":()V
        2580: astore        137
        2582: aload         132
        2584: checkcast     #2                  // class Block
        2587: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2590: iconst_1
        2591: aload         137
        2593: aastore
        2594: new           #300                // class ocaml_fn_76
        2597: dup
        2598: invokespecial #301                // Method ocaml_fn_76."<init>":()V
        2601: astore        138
        2603: aload         132
        2605: checkcast     #2                  // class Block
        2608: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2611: iconst_0
        2612: aload         138
        2614: aastore
        2615: aload         18
        2617: checkcast     #2                  // class Block
        2620: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2623: bipush        95
        2625: aload         132
        2627: aastore
        2628: new           #303                // class ocaml_fn_77
        2631: dup
        2632: invokespecial #304                // Method ocaml_fn_77."<init>":()V
        2635: astore        139
        2637: aload         18
        2639: checkcast     #2                  // class Block
        2642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2645: bipush        94
        2647: aload         139
        2649: aastore
        2650: new           #306                // class ocaml_fn_78
        2653: dup
        2654: invokespecial #307                // Method ocaml_fn_78."<init>":()V
        2657: astore        140
        2659: aload         18
        2661: checkcast     #2                  // class Block
        2664: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2667: bipush        92
        2669: aload         140
        2671: aastore
        2672: new           #309                // class ocaml_fn_79
        2675: dup
        2676: invokespecial #310                // Method ocaml_fn_79."<init>":()V
        2679: astore        141
        2681: aload         18
        2683: checkcast     #2                  // class Block
        2686: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2689: bipush        91
        2691: aload         141
        2693: aastore
        2694: new           #312                // class ocaml_fn_80
        2697: dup
        2698: invokespecial #313                // Method ocaml_fn_80."<init>":()V
        2701: astore        142
        2703: aload         18
        2705: checkcast     #2                  // class Block
        2708: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2711: bipush        90
        2713: aload         142
        2715: aastore
        2716: new           #315                // class ocaml_fn_81
        2719: dup
        2720: invokespecial #316                // Method ocaml_fn_81."<init>":()V
        2723: astore        143
        2725: aload         18
        2727: checkcast     #2                  // class Block
        2730: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2733: bipush        89
        2735: aload         143
        2737: aastore
        2738: new           #318                // class ocaml_fn_82
        2741: dup
        2742: invokespecial #319                // Method ocaml_fn_82."<init>":()V
        2745: astore        144
        2747: aload         18
        2749: checkcast     #2                  // class Block
        2752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2755: bipush        88
        2757: aload         144
        2759: aastore
        2760: new           #321                // class ocaml_fn_83
        2763: dup
        2764: invokespecial #322                // Method ocaml_fn_83."<init>":()V
        2767: astore        145
        2769: aload         18
        2771: checkcast     #2                  // class Block
        2774: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2777: bipush        87
        2779: aload         145
        2781: aastore
        2782: new           #324                // class ocaml_fn_84
        2785: dup
        2786: invokespecial #325                // Method ocaml_fn_84."<init>":()V
        2789: astore        146
        2791: aload         18
        2793: checkcast     #2                  // class Block
        2796: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2799: bipush        86
        2801: aload         146
        2803: aastore
        2804: new           #327                // class ocaml_fn_85
        2807: dup
        2808: invokespecial #328                // Method ocaml_fn_85."<init>":()V
        2811: astore        147
        2813: aload         18
        2815: checkcast     #2                  // class Block
        2818: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2821: bipush        81
        2823: aload         147
        2825: aastore
        2826: new           #330                // class ocaml_fn_86
        2829: dup
        2830: invokespecial #331                // Method ocaml_fn_86."<init>":()V
        2833: astore        148
        2835: aload         18
        2837: checkcast     #2                  // class Block
        2840: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2843: bipush        77
        2845: aload         148
        2847: aastore
        2848: new           #333                // class ocaml_fn_87
        2851: dup
        2852: invokespecial #334                // Method ocaml_fn_87."<init>":()V
        2855: astore        149
        2857: aload         18
        2859: checkcast     #2                  // class Block
        2862: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2865: bipush        74
        2867: aload         149
        2869: aastore
        2870: new           #336                // class ocaml_fn_88
        2873: dup
        2874: invokespecial #337                // Method ocaml_fn_88."<init>":()V
        2877: astore        150
        2879: aload         18
        2881: checkcast     #2                  // class Block
        2884: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2887: bipush        73
        2889: aload         150
        2891: aastore
        2892: new           #339                // class ocaml_fn_89
        2895: dup
        2896: invokespecial #340                // Method ocaml_fn_89."<init>":()V
        2899: astore        151
        2901: aload         18
        2903: checkcast     #2                  // class Block
        2906: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2909: bipush        72
        2911: aload         151
        2913: aastore
        2914: new           #342                // class ocaml_fn_90
        2917: dup
        2918: invokespecial #343                // Method ocaml_fn_90."<init>":()V
        2921: astore        152
        2923: aload         18
        2925: checkcast     #2                  // class Block
        2928: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2931: bipush        70
        2933: aload         152
        2935: aastore
        2936: new           #345                // class ocaml_fn_91
        2939: dup
        2940: invokespecial #346                // Method ocaml_fn_91."<init>":()V
        2943: astore        153
        2945: aload         18
        2947: checkcast     #2                  // class Block
        2950: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2953: bipush        69
        2955: aload         153
        2957: aastore
        2958: new           #348                // class ocaml_fn_92
        2961: dup
        2962: invokespecial #349                // Method ocaml_fn_92."<init>":()V
        2965: astore        154
        2967: aload         18
        2969: checkcast     #2                  // class Block
        2972: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2975: bipush        64
        2977: aload         154
        2979: aastore
        2980: new           #351                // class ocaml_fn_93
        2983: dup
        2984: invokespecial #352                // Method ocaml_fn_93."<init>":()V
        2987: astore        155
        2989: aload         18
        2991: checkcast     #2                  // class Block
        2994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2997: bipush        62
        2999: aload         155
        3001: aastore
        3002: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3005: bipush        45
        3007: aload         18
        3009: aastore
        3010: iconst_0
        3011: i2l
        3012: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3015: astore        156
        3017: iconst_1
        3018: i2l
        3019: lstore        157
        3021: iconst_0
        3022: i2l
        3023: lstore        159
        3025: lload         159
        3027: iconst_0
        3028: i2l
        3029: lcmp
        3030: ifeq          3045
        3033: lload         157
        3035: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3038: astore        161
        3040: goto_w        3074
        3045: lload         157
        3047: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3050: astore        162
        3052: goto_w        3057
        3057: bipush        10
        3059: i2l
        3060: lstore        163
        3062: lload         163
        3064: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3067: astore        165
        3069: goto_w        3091
        3074: bipush        20
        3076: i2l
        3077: lstore        166
        3079: lload         166
        3081: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3084: astore        165
        3086: goto_w        3091
        3091: getstatic     #356                // Field java/lang/System.out:Ljava/io/PrintStream;
        3094: aload         165
        3096: invokestatic  #82                 // Method Block.asLong:(Ljava/lang/Object;)J
        3099: l2i
        3100: invokevirtual #362                // Method java/io/PrintStream.println:(I)V
        3103: iconst_0
        3104: i2l
        3105: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3108: astore        168
        3110: new           #2                  // class Block
        3113: dup
        3114: iconst_0
        3115: iconst_0
        3116: anewarray     #4                  // class java/lang/Object
        3119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3122: astore        169
        3124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3127: bipush        46
        3129: aload         169
        3131: aastore
        3132: iconst_0
        3133: i2l
        3134: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3137: astore        170
        3139: iconst_0
        3140: i2l
        3141: lstore        171
        3143: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3146: bipush        45
        3148: aaload
        3149: checkcast     #2                  // class Block
        3152: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3155: bipush        102
        3157: aaload
        3158: astore        173
        3160: aload         173
        3162: checkcast     #131                // class Closure
        3165: lload         171
        3167: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3170: invokevirtual #366                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3173: astore        174
        3175: new           #2                  // class Block
        3178: dup
        3179: iconst_0
        3180: iconst_0
        3181: anewarray     #4                  // class java/lang/Object
        3184: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3187: astore        175
        3189: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3192: bipush        47
        3194: aload         175
        3196: aastore
        3197: iconst_0
        3198: i2l
        3199: invokestatic  #53                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3202: astore        176
        3204: return
    }
    |}]
