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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3001: bipush        46
        3003: aaload
        3004: astore        150
        3006: getstatic     #354                // Field java/lang/System.out:Ljava/io/PrintStream;
        3009: aload         150
        3011: checkcast     #356                // class java/lang/String
        3014: invokevirtual #362                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3017: iconst_0
        3018: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3021: astore        151
        3023: new           #2                  // class Block
        3026: dup
        3027: iconst_0
        3028: iconst_0
        3029: anewarray     #4                  // class java/lang/Object
        3032: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3035: astore        152
        3037: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3040: bipush        47
        3042: aload         152
        3044: aastore
        3045: iconst_0
        3046: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3049: astore        153
        3051: iconst_0
        3052: istore        154
        3054: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3057: bipush        45
        3059: aaload
        3060: checkcast     #2                  // class Block
        3063: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3066: bipush        102
        3068: aaload
        3069: astore        155
        3071: aload         155
        3073: checkcast     #129                // class Closure
        3076: iload         154
        3078: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3081: invokevirtual #366                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3084: astore        156
        3086: new           #2                  // class Block
        3089: dup
        3090: iconst_0
        3091: iconst_0
        3092: anewarray     #4                  // class java/lang/Object
        3095: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3098: astore        157
        3100: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3103: bipush        48
        3105: aload         157
        3107: aastore
        3108: iconst_0
        3109: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3112: astore        158
        3114: return
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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: bipush        8
        3000: istore        150
        3002: getstatic     #354                // Field java/lang/System.out:Ljava/io/PrintStream;
        3005: iload         150
        3007: invokevirtual #360                // Method java/io/PrintStream.println:(I)V
        3010: iconst_0
        3011: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3014: astore        151
        3016: new           #2                  // class Block
        3019: dup
        3020: iconst_0
        3021: iconst_0
        3022: anewarray     #4                  // class java/lang/Object
        3025: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3028: astore        152
        3030: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3033: bipush        46
        3035: aload         152
        3037: aastore
        3038: iconst_0
        3039: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3042: astore        153
        3044: iconst_0
        3045: istore        154
        3047: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3050: bipush        45
        3052: aaload
        3053: checkcast     #2                  // class Block
        3056: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3059: bipush        102
        3061: aaload
        3062: astore        155
        3064: aload         155
        3066: checkcast     #129                // class Closure
        3069: iload         154
        3071: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3074: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3077: astore        156
        3079: new           #2                  // class Block
        3082: dup
        3083: iconst_0
        3084: iconst_0
        3085: anewarray     #4                  // class java/lang/Object
        3088: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3091: astore        157
        3093: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3096: bipush        47
        3098: aload         157
        3100: aastore
        3101: iconst_0
        3102: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3105: astore        158
        3107: return
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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: iconst_0
        2999: istore        150
        3001: iload         150
        3003: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3006: astore        151
        3008: goto_w        3013
        3013: new           #352                // class ocaml_fn_95
        3016: dup
        3017: invokespecial #353                // Method ocaml_fn_95."<init>":()V
        3020: astore        152
        3022: bipush        10
        3024: istore        153
        3026: aload         152
        3028: iload         153
        3030: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3033: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3036: astore        154
        3038: bipush        32
        3040: istore        155
        3042: aload         154
        3044: checkcast     #129                // class Closure
        3047: iload         155
        3049: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3052: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3055: astore        156
        3057: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3060: aload         156
        3062: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
        3065: l2i
        3066: invokevirtual #367                // Method java/io/PrintStream.println:(I)V
        3069: iconst_0
        3070: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3073: astore        157
        3075: new           #2                  // class Block
        3078: dup
        3079: iconst_0
        3080: iconst_1
        3081: anewarray     #4                  // class java/lang/Object
        3084: dup
        3085: iconst_0
        3086: aload         152
        3088: aastore
        3089: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3092: astore        158
        3094: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3097: bipush        46
        3099: aload         158
        3101: aastore
        3102: iconst_0
        3103: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3106: astore        159
        3108: iconst_0
        3109: istore        160
        3111: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3114: bipush        45
        3116: aaload
        3117: checkcast     #2                  // class Block
        3120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3123: bipush        102
        3125: aaload
        3126: astore        161
        3128: aload         161
        3130: checkcast     #129                // class Closure
        3133: iload         160
        3135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3138: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3141: astore        162
        3143: new           #2                  // class Block
        3146: dup
        3147: iconst_0
        3148: iconst_0
        3149: anewarray     #4                  // class java/lang/Object
        3152: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3155: astore        163
        3157: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3160: bipush        47
        3162: aload         163
        3164: aastore
        3165: iconst_0
        3166: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3169: astore        164
        3171: return
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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: iconst_0
        2999: istore        150
        3001: iload         150
        3003: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3006: astore        151
        3008: goto_w        3013
        3013: new           #352                // class ocaml_fn_94
        3016: dup
        3017: invokespecial #353                // Method ocaml_fn_94."<init>":()V
        3020: astore        152
        3022: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3025: bipush        46
        3027: aaload
        3028: astore        153
        3030: aload         152
        3032: aload         153
        3034: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3037: astore        154
        3039: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3042: aload         154
        3044: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
        3047: l2i
        3048: invokevirtual #367                // Method java/io/PrintStream.println:(I)V
        3051: iconst_0
        3052: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3055: astore        155
        3057: new           #2                  // class Block
        3060: dup
        3061: iconst_0
        3062: iconst_1
        3063: anewarray     #4                  // class java/lang/Object
        3066: dup
        3067: iconst_0
        3068: aload         152
        3070: aastore
        3071: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3074: astore        156
        3076: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3079: bipush        47
        3081: aload         156
        3083: aastore
        3084: iconst_0
        3085: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3088: astore        157
        3090: iconst_0
        3091: istore        158
        3093: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3096: bipush        45
        3098: aaload
        3099: checkcast     #2                  // class Block
        3102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3105: bipush        102
        3107: aaload
        3108: astore        159
        3110: aload         159
        3112: checkcast     #129                // class Closure
        3115: iload         158
        3117: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3120: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3123: astore        160
        3125: new           #2                  // class Block
        3128: dup
        3129: iconst_0
        3130: iconst_0
        3131: anewarray     #4                  // class java/lang/Object
        3134: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3137: astore        161
        3139: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3142: bipush        48
        3144: aload         161
        3146: aastore
        3147: iconst_0
        3148: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3151: astore        162
        3153: return
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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: iconst_0
        2999: istore        150
        3001: iload         150
        3003: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3006: astore        151
        3008: goto_w        3013
        3013: iconst_0
        3014: istore        152
        3016: iconst_1
        3017: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3020: astore        153
        3022: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3025: bipush        46
        3027: aaload
        3028: astore        154
        3030: new           #2                  // class Block
        3033: dup
        3034: sipush        248
        3037: iconst_2
        3038: anewarray     #4                  // class java/lang/Object
        3041: dup
        3042: iconst_0
        3043: aload         154
        3045: aastore
        3046: dup
        3047: iconst_1
        3048: aload         153
        3050: aastore
        3051: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3054: astore        155
        3056: new           #352                // class ocaml_fn_94
        3059: dup
        3060: aload         155
        3062: invokespecial #353                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3065: astore        156
        3067: iconst_0
        3068: istore        157
        3070: aload         156
        3072: iload         157
        3074: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3077: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3080: astore        158
        3082: getstatic     #361                // Field java/lang/System.out:Ljava/io/PrintStream;
        3085: aload         158
        3087: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
        3090: l2i
        3091: invokevirtual #367                // Method java/io/PrintStream.println:(I)V
        3094: iconst_0
        3095: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3098: astore        159
        3100: new           #2                  // class Block
        3103: dup
        3104: iconst_0
        3105: iconst_2
        3106: anewarray     #4                  // class java/lang/Object
        3109: dup
        3110: iconst_0
        3111: aload         155
        3113: aastore
        3114: dup
        3115: iconst_1
        3116: aload         156
        3118: aastore
        3119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3122: astore        160
        3124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3127: bipush        47
        3129: aload         160
        3131: aastore
        3132: iconst_0
        3133: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3136: astore        161
        3138: iconst_0
        3139: istore        162
        3141: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3144: bipush        45
        3146: aaload
        3147: checkcast     #2                  // class Block
        3150: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3153: bipush        102
        3155: aaload
        3156: astore        163
        3158: aload         163
        3160: checkcast     #129                // class Closure
        3163: iload         162
        3165: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3168: invokevirtual #357                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3171: astore        164
        3173: new           #2                  // class Block
        3176: dup
        3177: iconst_0
        3178: iconst_0
        3179: anewarray     #4                  // class java/lang/Object
        3182: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3185: astore        165
        3187: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3190: bipush        48
        3192: aload         165
        3194: aastore
        3195: iconst_0
        3196: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3199: astore        166
        3201: return
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
          54: astore_1
          55: aload_1
          56: astore_2
          57: goto_w        62
          62: new           #39                 // class ocaml_fn_0
          65: dup
          66: invokespecial #41                 // Method ocaml_fn_0."<init>":()V
          69: astore_3
          70: new           #43                 // class ocaml_fn_1
          73: dup
          74: invokespecial #44                 // Method ocaml_fn_1."<init>":()V
          77: astore        4
          79: new           #46                 // class ocaml_fn_2
          82: dup
          83: invokespecial #47                 // Method ocaml_fn_2."<init>":()V
          86: astore        5
          88: new           #2                  // class Block
          91: dup
          92: iconst_0
          93: iconst_3
          94: anewarray     #4                  // class java/lang/Object
          97: dup
          98: iconst_0
          99: aload         4
         101: aastore
         102: dup
         103: iconst_1
         104: aload_3
         105: aastore
         106: dup
         107: iconst_2
         108: aload         5
         110: aastore
         111: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         114: astore        6
         116: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         119: bipush        12
         121: aload         6
         123: aastore
         124: iconst_0
         125: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         128: astore        7
         130: iconst_0
         131: istore        8
         133: iload         8
         135: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         138: astore        9
         140: goto_w        145
         145: sipush        199
         148: istore        10
         150: iconst_0
         151: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         154: astore        11
         156: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         159: bipush        35
         161: aaload
         162: astore        12
         164: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         167: iconst_3
         168: aaload
         169: astore        13
         171: new           #2                  // class Block
         174: dup
         175: iconst_0
         176: iconst_2
         177: anewarray     #4                  // class java/lang/Object
         180: dup
         181: iconst_0
         182: aload         13
         184: aastore
         185: dup
         186: iconst_1
         187: aload         12
         189: aastore
         190: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         193: astore        14
         195: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         198: bipush        36
         200: aaload
         201: astore        15
         203: iconst_0
         204: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         207: astore        16
         209: new           #2                  // class Block
         212: dup
         213: iconst_0
         214: bipush        104
         216: anewarray     #4                  // class java/lang/Object
         219: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         222: astore        17
         224: new           #55                 // class ocaml_fn_8
         227: dup
         228: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         231: astore        18
         233: aload         17
         235: checkcast     #2                  // class Block
         238: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         241: iconst_1
         242: aload         18
         244: aastore
         245: new           #61                 // class ocaml_fn_9
         248: dup
         249: invokespecial #62                 // Method ocaml_fn_9."<init>":()V
         252: astore        19
         254: aload         17
         256: checkcast     #2                  // class Block
         259: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         262: iconst_0
         263: aload         19
         265: aastore
         266: iconst_0
         267: istore        20
         269: iconst_0
         270: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         273: astore        21
         275: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         278: bipush        37
         280: aaload
         281: astore        22
         283: new           #2                  // class Block
         286: dup
         287: sipush        248
         290: iconst_2
         291: anewarray     #4                  // class java/lang/Object
         294: dup
         295: iconst_0
         296: aload         22
         298: aastore
         299: dup
         300: iconst_1
         301: aload         21
         303: aastore
         304: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         307: astore        23
         309: aload         17
         311: checkcast     #2                  // class Block
         314: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         317: iconst_2
         318: aload         23
         320: aastore
         321: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         324: bipush        7
         326: aaload
         327: astore        24
         329: aload         17
         331: checkcast     #2                  // class Block
         334: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         337: iconst_3
         338: aload         24
         340: aastore
         341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         344: bipush        10
         346: aaload
         347: astore        25
         349: aload         17
         351: checkcast     #2                  // class Block
         354: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         357: iconst_4
         358: aload         25
         360: aastore
         361: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         364: iconst_3
         365: aaload
         366: astore        26
         368: aload         17
         370: checkcast     #2                  // class Block
         373: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         376: iconst_5
         377: aload         26
         379: aastore
         380: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         383: iconst_2
         384: aaload
         385: astore        27
         387: aload         17
         389: checkcast     #2                  // class Block
         392: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         395: bipush        6
         397: aload         27
         399: aastore
         400: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         403: bipush        6
         405: aaload
         406: astore        28
         408: aload         17
         410: checkcast     #2                  // class Block
         413: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         416: bipush        7
         418: aload         28
         420: aastore
         421: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         424: iconst_0
         425: aaload
         426: astore        29
         428: aload         17
         430: checkcast     #2                  // class Block
         433: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         436: bipush        8
         438: aload         29
         440: aastore
         441: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         444: bipush        8
         446: aaload
         447: astore        30
         449: aload         17
         451: checkcast     #2                  // class Block
         454: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         457: bipush        9
         459: aload         30
         461: aastore
         462: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         465: iconst_1
         466: aaload
         467: astore        31
         469: aload         17
         471: checkcast     #2                  // class Block
         474: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         477: bipush        10
         479: aload         31
         481: aastore
         482: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         485: iconst_4
         486: aaload
         487: astore        32
         489: aload         17
         491: checkcast     #2                  // class Block
         494: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         497: bipush        11
         499: aload         32
         501: aastore
         502: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         505: iconst_5
         506: aaload
         507: astore        33
         509: aload         17
         511: checkcast     #2                  // class Block
         514: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         517: bipush        12
         519: aload         33
         521: aastore
         522: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         525: bipush        9
         527: aaload
         528: astore        34
         530: aload         17
         532: checkcast     #2                  // class Block
         535: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         538: bipush        13
         540: aload         34
         542: aastore
         543: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         546: bipush        11
         548: aaload
         549: astore        35
         551: aload         17
         553: checkcast     #2                  // class Block
         556: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         559: bipush        14
         561: aload         35
         563: aastore
         564: new           #64                 // class ocaml_fn_10
         567: dup
         568: invokespecial #65                 // Method ocaml_fn_10."<init>":()V
         571: astore        36
         573: aload         17
         575: checkcast     #2                  // class Block
         578: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         581: bipush        15
         583: aload         36
         585: aastore
         586: new           #67                 // class ocaml_fn_11
         589: dup
         590: invokespecial #68                 // Method ocaml_fn_11."<init>":()V
         593: astore        37
         595: aload         17
         597: checkcast     #2                  // class Block
         600: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         603: bipush        16
         605: aload         37
         607: aastore
         608: new           #70                 // class ocaml_fn_12
         611: dup
         612: invokespecial #71                 // Method ocaml_fn_12."<init>":()V
         615: astore        38
         617: aload         17
         619: checkcast     #2                  // class Block
         622: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         625: bipush        17
         627: aload         38
         629: aastore
         630: new           #73                 // class ocaml_fn_13
         633: dup
         634: invokespecial #74                 // Method ocaml_fn_13."<init>":()V
         637: astore        39
         639: aload         17
         641: checkcast     #2                  // class Block
         644: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         647: bipush        20
         649: aload         39
         651: aastore
         652: ldc           #75                 // int 2147483647
         654: istore        40
         656: aload         17
         658: checkcast     #2                  // class Block
         661: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         664: bipush        18
         666: iload         40
         668: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         671: aastore
         672: ldc           #76                 // int -2147483648
         674: istore        41
         676: aload         17
         678: checkcast     #2                  // class Block
         681: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         684: bipush        19
         686: iload         41
         688: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         691: aastore
         692: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         695: bipush        38
         697: aaload
         698: astore        42
         700: aload         42
         702: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         705: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         708: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         711: astore        43
         713: aload         17
         715: checkcast     #2                  // class Block
         718: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         721: bipush        21
         723: aload         43
         725: aastore
         726: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         729: bipush        39
         731: aaload
         732: astore        44
         734: aload         44
         736: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         739: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         742: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         745: astore        45
         747: aload         17
         749: checkcast     #2                  // class Block
         752: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         755: bipush        22
         757: aload         45
         759: aastore
         760: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         763: bipush        40
         765: aaload
         766: astore        46
         768: aload         46
         770: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         773: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         776: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         779: astore        47
         781: aload         17
         783: checkcast     #2                  // class Block
         786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         789: bipush        23
         791: aload         47
         793: aastore
         794: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         797: bipush        41
         799: aaload
         800: astore        48
         802: aload         48
         804: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         807: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         810: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         813: astore        49
         815: aload         17
         817: checkcast     #2                  // class Block
         820: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         823: bipush        24
         825: aload         49
         827: aastore
         828: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         831: bipush        42
         833: aaload
         834: astore        50
         836: aload         50
         838: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         841: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         844: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         847: astore        51
         849: aload         17
         851: checkcast     #2                  // class Block
         854: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         857: bipush        25
         859: aload         51
         861: aastore
         862: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         865: bipush        43
         867: aaload
         868: astore        52
         870: aload         52
         872: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
         875: invokestatic  #86                 // Method java/lang/Double.longBitsToDouble:(J)D
         878: invokestatic  #89                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         881: astore        53
         883: aload         17
         885: checkcast     #2                  // class Block
         888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         891: bipush        26
         893: aload         53
         895: aastore
         896: new           #91                 // class ocaml_fn_14
         899: dup
         900: invokespecial #92                 // Method ocaml_fn_14."<init>":()V
         903: astore        54
         905: aload         17
         907: checkcast     #2                  // class Block
         910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         913: bipush        27
         915: aload         54
         917: aastore
         918: new           #94                 // class ocaml_fn_15
         921: dup
         922: aload         19
         924: invokespecial #97                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         927: astore        55
         929: aload         17
         931: checkcast     #2                  // class Block
         934: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         937: bipush        28
         939: aload         55
         941: aastore
         942: new           #99                 // class ocaml_fn_16
         945: dup
         946: invokespecial #100                // Method ocaml_fn_16."<init>":()V
         949: astore        56
         951: aload         17
         953: checkcast     #2                  // class Block
         956: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         959: bipush        29
         961: aload         56
         963: aastore
         964: new           #102                // class ocaml_fn_17
         967: dup
         968: aload         19
         970: invokespecial #103                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         973: astore        57
         975: aload         17
         977: checkcast     #2                  // class Block
         980: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
         983: bipush        31
         985: aload         57
         987: aastore
         988: new           #105                // class ocaml_fn_18
         991: dup
         992: invokespecial #106                // Method ocaml_fn_18."<init>":()V
         995: astore        58
         997: aload         17
         999: checkcast     #2                  // class Block
        1002: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1005: bipush        30
        1007: aload         58
        1009: aastore
        1010: new           #108                // class ocaml_fn_19
        1013: dup
        1014: invokespecial #109                // Method ocaml_fn_19."<init>":()V
        1017: astore        59
        1019: aload         17
        1021: checkcast     #2                  // class Block
        1024: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1027: bipush        32
        1029: aload         59
        1031: aastore
        1032: new           #111                // class ocaml_fn_20
        1035: dup
        1036: aload         27
        1038: invokespecial #112                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1041: astore        60
        1043: aload         17
        1045: checkcast     #2                  // class Block
        1048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1051: bipush        33
        1053: aload         60
        1055: aastore
        1056: new           #114                // class ocaml_fn_21
        1059: dup
        1060: aload         54
        1062: invokespecial #115                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1065: astore        61
        1067: aload         17
        1069: checkcast     #2                  // class Block
        1072: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1075: bipush        100
        1077: aload         61
        1079: aastore
        1080: new           #117                // class ocaml_fn_22
        1083: dup
        1084: aload         61
        1086: invokespecial #118                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1089: astore        62
        1091: aload         17
        1093: checkcast     #2                  // class Block
        1096: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1099: bipush        34
        1101: aload         62
        1103: aastore
        1104: new           #120                // class ocaml_fn_23
        1107: dup
        1108: aload         27
        1110: invokespecial #121                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1113: astore        63
        1115: aload         17
        1117: checkcast     #2                  // class Block
        1120: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1123: bipush        35
        1125: aload         63
        1127: aastore
        1128: new           #123                // class ocaml_fn_24
        1131: dup
        1132: invokespecial #124                // Method ocaml_fn_24."<init>":()V
        1135: astore        64
        1137: aload         17
        1139: checkcast     #2                  // class Block
        1142: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1145: bipush        36
        1147: aload         64
        1149: aastore
        1150: new           #126                // class ocaml_fn_25
        1153: dup
        1154: invokespecial #127                // Method ocaml_fn_25."<init>":()V
        1157: astore        65
        1159: aload         64
        1161: checkcast     #123                // class ocaml_fn_24
        1164: aload         64
        1166: checkcast     #129                // class Closure
        1169: putfield      #133                // Field ocaml_fn_24.sibling_0:LClosure;
        1172: iconst_0
        1173: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1176: astore        66
        1178: aload         64
        1180: checkcast     #123                // class ocaml_fn_24
        1183: aload         65
        1185: checkcast     #129                // class Closure
        1188: putfield      #136                // Field ocaml_fn_24.sibling_1:LClosure;
        1191: iconst_0
        1192: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1195: astore        67
        1197: aload         65
        1199: checkcast     #126                // class ocaml_fn_25
        1202: aload         64
        1204: checkcast     #129                // class Closure
        1207: putfield      #137                // Field ocaml_fn_25.sibling_0:LClosure;
        1210: iconst_0
        1211: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1214: astore        68
        1216: aload         65
        1218: checkcast     #126                // class ocaml_fn_25
        1221: aload         65
        1223: checkcast     #129                // class Closure
        1226: putfield      #138                // Field ocaml_fn_25.sibling_1:LClosure;
        1229: iconst_0
        1230: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1233: astore        69
        1235: iconst_0
        1236: istore        70
        1238: iload         70
        1240: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1243: astore        71
        1245: aload         17
        1247: checkcast     #2                  // class Block
        1250: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1253: bipush        37
        1255: aload         71
        1257: aastore
        1258: iconst_1
        1259: istore        72
        1261: iload         72
        1263: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1266: astore        73
        1268: aload         17
        1270: checkcast     #2                  // class Block
        1273: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1276: bipush        38
        1278: aload         73
        1280: aastore
        1281: iconst_2
        1282: istore        74
        1284: iload         74
        1286: invokestatic  #142                // Method Channel.forDescriptor:(I)LChannel;
        1289: astore        75
        1291: aload         17
        1293: checkcast     #2                  // class Block
        1296: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1299: bipush        39
        1301: aload         75
        1303: aastore
        1304: new           #144                // class ocaml_fn_26
        1307: dup
        1308: invokespecial #145                // Method ocaml_fn_26."<init>":()V
        1311: astore        76
        1313: aload         17
        1315: checkcast     #2                  // class Block
        1318: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1321: bipush        61
        1323: aload         76
        1325: aastore
        1326: new           #147                // class ocaml_fn_27
        1329: dup
        1330: aload         76
        1332: invokespecial #148                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1335: astore        77
        1337: aload         17
        1339: checkcast     #2                  // class Block
        1342: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1345: bipush        59
        1347: aload         77
        1349: aastore
        1350: new           #150                // class ocaml_fn_28
        1353: dup
        1354: aload         76
        1356: invokespecial #151                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1359: astore        78
        1361: aload         17
        1363: checkcast     #2                  // class Block
        1366: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1369: bipush        60
        1371: aload         78
        1373: aastore
        1374: new           #153                // class ocaml_fn_29
        1377: dup
        1378: aload         31
        1380: invokespecial #154                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1383: astore        79
        1385: aload         17
        1387: checkcast     #2                  // class Block
        1390: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1393: bipush        63
        1395: aload         79
        1397: aastore
        1398: new           #156                // class ocaml_fn_30
        1401: dup
        1402: invokespecial #157                // Method ocaml_fn_30."<init>":()V
        1405: astore        80
        1407: aload         17
        1409: checkcast     #2                  // class Block
        1412: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1415: bipush        66
        1417: aload         80
        1419: aastore
        1420: new           #159                // class ocaml_fn_31
        1423: dup
        1424: invokespecial #160                // Method ocaml_fn_31."<init>":()V
        1427: astore        81
        1429: aload         17
        1431: checkcast     #2                  // class Block
        1434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1437: bipush        65
        1439: aload         81
        1441: aastore
        1442: new           #162                // class ocaml_fn_32
        1445: dup
        1446: aload         19
        1448: invokespecial #163                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1451: astore        82
        1453: aload         17
        1455: checkcast     #2                  // class Block
        1458: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1461: bipush        67
        1463: aload         82
        1465: aastore
        1466: new           #165                // class ocaml_fn_33
        1469: dup
        1470: aload         19
        1472: invokespecial #166                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1475: astore        83
        1477: aload         17
        1479: checkcast     #2                  // class Block
        1482: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1485: bipush        68
        1487: aload         83
        1489: aastore
        1490: new           #168                // class ocaml_fn_34
        1493: dup
        1494: invokespecial #169                // Method ocaml_fn_34."<init>":()V
        1497: astore        84
        1499: aload         17
        1501: checkcast     #2                  // class Block
        1504: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1507: bipush        71
        1509: aload         84
        1511: aastore
        1512: new           #171                // class ocaml_fn_35
        1515: dup
        1516: invokespecial #172                // Method ocaml_fn_35."<init>":()V
        1519: astore        85
        1521: aload         17
        1523: checkcast     #2                  // class Block
        1526: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1529: bipush        75
        1531: aload         85
        1533: aastore
        1534: new           #174                // class ocaml_fn_36
        1537: dup
        1538: invokespecial #175                // Method ocaml_fn_36."<init>":()V
        1541: astore        86
        1543: aload         17
        1545: checkcast     #2                  // class Block
        1548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1551: bipush        76
        1553: aload         86
        1555: aastore
        1556: new           #177                // class ocaml_fn_37
        1559: dup
        1560: invokespecial #178                // Method ocaml_fn_37."<init>":()V
        1563: astore        87
        1565: aload         17
        1567: checkcast     #2                  // class Block
        1570: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1573: bipush        80
        1575: aload         87
        1577: aastore
        1578: new           #180                // class ocaml_fn_38
        1581: dup
        1582: aload         87
        1584: invokespecial #181                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1587: astore        88
        1589: aload         17
        1591: checkcast     #2                  // class Block
        1594: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1597: bipush        78
        1599: aload         88
        1601: aastore
        1602: new           #183                // class ocaml_fn_39
        1605: dup
        1606: aload         87
        1608: invokespecial #184                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1611: astore        89
        1613: aload         17
        1615: checkcast     #2                  // class Block
        1618: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1621: bipush        79
        1623: aload         89
        1625: aastore
        1626: new           #186                // class ocaml_fn_40
        1629: dup
        1630: aload         19
        1632: invokespecial #187                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1635: astore        90
        1637: aload         17
        1639: checkcast     #2                  // class Block
        1642: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1645: bipush        83
        1647: aload         90
        1649: aastore
        1650: new           #189                // class ocaml_fn_41
        1653: dup
        1654: aload         32
        1656: invokespecial #190                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1659: astore        91
        1661: aload         17
        1663: checkcast     #2                  // class Block
        1666: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1669: bipush        101
        1671: aload         91
        1673: aastore
        1674: new           #192                // class ocaml_fn_42
        1677: dup
        1678: aload         19
        1680: aload         91
        1682: invokespecial #195                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1685: astore        92
        1687: aload         17
        1689: checkcast     #2                  // class Block
        1692: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1695: bipush        84
        1697: aload         92
        1699: aastore
        1700: new           #197                // class ocaml_fn_43
        1703: dup
        1704: aload         92
        1706: invokespecial #198                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1709: astore        93
        1711: aload         17
        1713: checkcast     #2                  // class Block
        1716: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1719: bipush        85
        1721: aload         93
        1723: aastore
        1724: new           #200                // class ocaml_fn_44
        1727: dup
        1728: aload         32
        1730: invokespecial #201                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1733: astore        94
        1735: aload         17
        1737: checkcast     #2                  // class Block
        1740: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1743: bipush        82
        1745: aload         94
        1747: aastore
        1748: new           #203                // class ocaml_fn_45
        1751: dup
        1752: invokespecial #204                // Method ocaml_fn_45."<init>":()V
        1755: astore        95
        1757: aload         17
        1759: checkcast     #2                  // class Block
        1762: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1765: bipush        93
        1767: aload         95
        1769: aastore
        1770: new           #206                // class ocaml_fn_46
        1773: dup
        1774: aload         73
        1776: invokespecial #207                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1779: astore        96
        1781: aload         17
        1783: checkcast     #2                  // class Block
        1786: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1789: bipush        40
        1791: aload         96
        1793: aastore
        1794: new           #209                // class ocaml_fn_47
        1797: dup
        1798: aload         73
        1800: aload         81
        1802: invokespecial #210                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1805: astore        97
        1807: aload         17
        1809: checkcast     #2                  // class Block
        1812: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1815: bipush        41
        1817: aload         97
        1819: aastore
        1820: new           #212                // class ocaml_fn_48
        1823: dup
        1824: aload         73
        1826: aload         80
        1828: invokespecial #213                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1831: astore        98
        1833: aload         17
        1835: checkcast     #2                  // class Block
        1838: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1841: bipush        42
        1843: aload         98
        1845: aastore
        1846: new           #215                // class ocaml_fn_49
        1849: dup
        1850: aload         59
        1852: aload         73
        1854: aload         81
        1856: invokespecial #218                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1859: astore        99
        1861: aload         17
        1863: checkcast     #2                  // class Block
        1866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1869: bipush        43
        1871: aload         99
        1873: aastore
        1874: new           #220                // class ocaml_fn_50
        1877: dup
        1878: aload         62
        1880: aload         73
        1882: aload         81
        1884: invokespecial #221                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1887: astore        100
        1889: aload         17
        1891: checkcast     #2                  // class Block
        1894: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1897: bipush        44
        1899: aload         100
        1901: aastore
        1902: new           #223                // class ocaml_fn_51
        1905: dup
        1906: aload         73
        1908: aload         81
        1910: invokespecial #224                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1913: astore        101
        1915: aload         17
        1917: checkcast     #2                  // class Block
        1920: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1923: bipush        45
        1925: aload         101
        1927: aastore
        1928: new           #226                // class ocaml_fn_52
        1931: dup
        1932: aload         73
        1934: invokespecial #227                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1937: astore        102
        1939: aload         17
        1941: checkcast     #2                  // class Block
        1944: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1947: bipush        46
        1949: aload         102
        1951: aastore
        1952: new           #229                // class ocaml_fn_53
        1955: dup
        1956: aload         75
        1958: invokespecial #230                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1961: astore        103
        1963: aload         17
        1965: checkcast     #2                  // class Block
        1968: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1971: bipush        47
        1973: aload         103
        1975: aastore
        1976: new           #232                // class ocaml_fn_54
        1979: dup
        1980: aload         75
        1982: aload         81
        1984: invokespecial #233                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        104
        1989: aload         17
        1991: checkcast     #2                  // class Block
        1994: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        1997: bipush        48
        1999: aload         104
        2001: aastore
        2002: new           #235                // class ocaml_fn_55
        2005: dup
        2006: aload         75
        2008: aload         80
        2010: invokespecial #236                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2013: astore        105
        2015: aload         17
        2017: checkcast     #2                  // class Block
        2020: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2023: bipush        49
        2025: aload         105
        2027: aastore
        2028: new           #238                // class ocaml_fn_56
        2031: dup
        2032: aload         59
        2034: aload         75
        2036: aload         81
        2038: invokespecial #239                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2041: astore        106
        2043: aload         17
        2045: checkcast     #2                  // class Block
        2048: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2051: bipush        50
        2053: aload         106
        2055: aastore
        2056: new           #241                // class ocaml_fn_57
        2059: dup
        2060: aload         62
        2062: aload         75
        2064: aload         81
        2066: invokespecial #242                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2069: astore        107
        2071: aload         17
        2073: checkcast     #2                  // class Block
        2076: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2079: bipush        51
        2081: aload         107
        2083: aastore
        2084: new           #244                // class ocaml_fn_58
        2087: dup
        2088: aload         75
        2090: aload         81
        2092: invokespecial #245                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2095: astore        108
        2097: aload         17
        2099: checkcast     #2                  // class Block
        2102: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2105: bipush        52
        2107: aload         108
        2109: aastore
        2110: new           #247                // class ocaml_fn_59
        2113: dup
        2114: aload         75
        2116: invokespecial #248                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2119: astore        109
        2121: aload         17
        2123: checkcast     #2                  // class Block
        2126: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2129: bipush        53
        2131: aload         109
        2133: aastore
        2134: new           #250                // class ocaml_fn_60
        2137: dup
        2138: aload         71
        2140: aload         73
        2142: aload         94
        2144: invokespecial #251                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        110
        2149: aload         17
        2151: checkcast     #2                  // class Block
        2154: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2157: bipush        54
        2159: aload         110
        2161: aastore
        2162: new           #253                // class ocaml_fn_61
        2165: dup
        2166: aload         110
        2168: invokespecial #254                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2171: astore        111
        2173: aload         17
        2175: checkcast     #2                  // class Block
        2178: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2181: bipush        56
        2183: aload         111
        2185: aastore
        2186: new           #256                // class ocaml_fn_62
        2189: dup
        2190: aload         60
        2192: aload         110
        2194: invokespecial #257                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2197: astore        112
        2199: aload         17
        2201: checkcast     #2                  // class Block
        2204: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2207: bipush        55
        2209: aload         112
        2211: aastore
        2212: new           #259                // class ocaml_fn_63
        2215: dup
        2216: aload         110
        2218: invokespecial #260                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2221: astore        113
        2223: aload         17
        2225: checkcast     #2                  // class Block
        2228: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2231: bipush        58
        2233: aload         113
        2235: aastore
        2236: new           #262                // class ocaml_fn_64
        2239: dup
        2240: aload         63
        2242: aload         110
        2244: invokespecial #263                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2247: astore        114
        2249: aload         17
        2251: checkcast     #2                  // class Block
        2254: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2257: bipush        57
        2259: aload         114
        2261: aastore
        2262: new           #265                // class ocaml_fn_65
        2265: dup
        2266: invokespecial #266                // Method ocaml_fn_65."<init>":()V
        2269: astore        115
        2271: aload         17
        2273: checkcast     #2                  // class Block
        2276: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2279: bipush        96
        2281: aload         115
        2283: aastore
        2284: new           #268                // class ocaml_fn_66
        2287: dup
        2288: aload         54
        2290: invokespecial #269                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2293: astore        116
        2295: aload         17
        2297: checkcast     #2                  // class Block
        2300: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2303: bipush        97
        2305: aload         116
        2307: aastore
        2308: new           #2                  // class Block
        2311: dup
        2312: iconst_0
        2313: iconst_1
        2314: anewarray     #4                  // class java/lang/Object
        2317: dup
        2318: iconst_0
        2319: aload         79
        2321: aastore
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        117
        2327: new           #271                // class ocaml_fn_67
        2330: dup
        2331: aload         117
        2333: invokespecial #272                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2336: astore        118
        2338: aload         17
        2340: checkcast     #2                  // class Block
        2343: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2346: bipush        99
        2348: aload         118
        2350: aastore
        2351: new           #274                // class ocaml_fn_68
        2354: dup
        2355: invokespecial #275                // Method ocaml_fn_68."<init>":()V
        2358: astore        119
        2360: new           #2                  // class Block
        2363: dup
        2364: iconst_0
        2365: iconst_1
        2366: anewarray     #4                  // class java/lang/Object
        2369: dup
        2370: iconst_0
        2371: aload         119
        2373: aastore
        2374: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2377: astore        120
        2379: aload         17
        2381: checkcast     #2                  // class Block
        2384: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2387: bipush        103
        2389: aload         120
        2391: aastore
        2392: new           #277                // class ocaml_fn_69
        2395: dup
        2396: aload         117
        2398: aload         120
        2400: invokespecial #278                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2403: astore        121
        2405: aload         17
        2407: checkcast     #2                  // class Block
        2410: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2413: bipush        102
        2415: aload         121
        2417: aastore
        2418: new           #280                // class ocaml_fn_70
        2421: dup
        2422: aload         121
        2424: invokespecial #281                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2427: astore        122
        2429: aload         17
        2431: checkcast     #2                  // class Block
        2434: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2437: bipush        98
        2439: aload         122
        2441: aastore
        2442: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2445: bipush        44
        2447: aaload
        2448: astore        123
        2450: iconst_0
        2451: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2454: astore        124
        2456: new           #2                  // class Block
        2459: dup
        2460: iconst_0
        2461: bipush        6
        2463: anewarray     #4                  // class java/lang/Object
        2466: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2469: astore        125
        2471: new           #283                // class ocaml_fn_71
        2474: dup
        2475: invokespecial #284                // Method ocaml_fn_71."<init>":()V
        2478: astore        126
        2480: aload         125
        2482: checkcast     #2                  // class Block
        2485: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2488: iconst_5
        2489: aload         126
        2491: aastore
        2492: new           #286                // class ocaml_fn_72
        2495: dup
        2496: invokespecial #287                // Method ocaml_fn_72."<init>":()V
        2499: astore        127
        2501: aload         125
        2503: checkcast     #2                  // class Block
        2506: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2509: iconst_4
        2510: aload         127
        2512: aastore
        2513: new           #289                // class ocaml_fn_73
        2516: dup
        2517: invokespecial #290                // Method ocaml_fn_73."<init>":()V
        2520: astore        128
        2522: aload         125
        2524: checkcast     #2                  // class Block
        2527: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2530: iconst_3
        2531: aload         128
        2533: aastore
        2534: new           #292                // class ocaml_fn_74
        2537: dup
        2538: invokespecial #293                // Method ocaml_fn_74."<init>":()V
        2541: astore        129
        2543: aload         125
        2545: checkcast     #2                  // class Block
        2548: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2551: iconst_2
        2552: aload         129
        2554: aastore
        2555: new           #295                // class ocaml_fn_75
        2558: dup
        2559: invokespecial #296                // Method ocaml_fn_75."<init>":()V
        2562: astore        130
        2564: aload         125
        2566: checkcast     #2                  // class Block
        2569: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2572: iconst_1
        2573: aload         130
        2575: aastore
        2576: new           #298                // class ocaml_fn_76
        2579: dup
        2580: invokespecial #299                // Method ocaml_fn_76."<init>":()V
        2583: astore        131
        2585: aload         125
        2587: checkcast     #2                  // class Block
        2590: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2593: iconst_0
        2594: aload         131
        2596: aastore
        2597: aload         17
        2599: checkcast     #2                  // class Block
        2602: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2605: bipush        95
        2607: aload         125
        2609: aastore
        2610: new           #301                // class ocaml_fn_77
        2613: dup
        2614: invokespecial #302                // Method ocaml_fn_77."<init>":()V
        2617: astore        132
        2619: aload         17
        2621: checkcast     #2                  // class Block
        2624: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2627: bipush        94
        2629: aload         132
        2631: aastore
        2632: new           #304                // class ocaml_fn_78
        2635: dup
        2636: invokespecial #305                // Method ocaml_fn_78."<init>":()V
        2639: astore        133
        2641: aload         17
        2643: checkcast     #2                  // class Block
        2646: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2649: bipush        92
        2651: aload         133
        2653: aastore
        2654: new           #307                // class ocaml_fn_79
        2657: dup
        2658: invokespecial #308                // Method ocaml_fn_79."<init>":()V
        2661: astore        134
        2663: aload         17
        2665: checkcast     #2                  // class Block
        2668: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2671: bipush        91
        2673: aload         134
        2675: aastore
        2676: new           #310                // class ocaml_fn_80
        2679: dup
        2680: invokespecial #311                // Method ocaml_fn_80."<init>":()V
        2683: astore        135
        2685: aload         17
        2687: checkcast     #2                  // class Block
        2690: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2693: bipush        90
        2695: aload         135
        2697: aastore
        2698: new           #313                // class ocaml_fn_81
        2701: dup
        2702: invokespecial #314                // Method ocaml_fn_81."<init>":()V
        2705: astore        136
        2707: aload         17
        2709: checkcast     #2                  // class Block
        2712: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2715: bipush        89
        2717: aload         136
        2719: aastore
        2720: new           #316                // class ocaml_fn_82
        2723: dup
        2724: invokespecial #317                // Method ocaml_fn_82."<init>":()V
        2727: astore        137
        2729: aload         17
        2731: checkcast     #2                  // class Block
        2734: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2737: bipush        88
        2739: aload         137
        2741: aastore
        2742: new           #319                // class ocaml_fn_83
        2745: dup
        2746: invokespecial #320                // Method ocaml_fn_83."<init>":()V
        2749: astore        138
        2751: aload         17
        2753: checkcast     #2                  // class Block
        2756: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2759: bipush        87
        2761: aload         138
        2763: aastore
        2764: new           #322                // class ocaml_fn_84
        2767: dup
        2768: invokespecial #323                // Method ocaml_fn_84."<init>":()V
        2771: astore        139
        2773: aload         17
        2775: checkcast     #2                  // class Block
        2778: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2781: bipush        86
        2783: aload         139
        2785: aastore
        2786: new           #325                // class ocaml_fn_85
        2789: dup
        2790: invokespecial #326                // Method ocaml_fn_85."<init>":()V
        2793: astore        140
        2795: aload         17
        2797: checkcast     #2                  // class Block
        2800: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2803: bipush        81
        2805: aload         140
        2807: aastore
        2808: new           #328                // class ocaml_fn_86
        2811: dup
        2812: invokespecial #329                // Method ocaml_fn_86."<init>":()V
        2815: astore        141
        2817: aload         17
        2819: checkcast     #2                  // class Block
        2822: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2825: bipush        77
        2827: aload         141
        2829: aastore
        2830: new           #331                // class ocaml_fn_87
        2833: dup
        2834: invokespecial #332                // Method ocaml_fn_87."<init>":()V
        2837: astore        142
        2839: aload         17
        2841: checkcast     #2                  // class Block
        2844: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2847: bipush        74
        2849: aload         142
        2851: aastore
        2852: new           #334                // class ocaml_fn_88
        2855: dup
        2856: invokespecial #335                // Method ocaml_fn_88."<init>":()V
        2859: astore        143
        2861: aload         17
        2863: checkcast     #2                  // class Block
        2866: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2869: bipush        73
        2871: aload         143
        2873: aastore
        2874: new           #337                // class ocaml_fn_89
        2877: dup
        2878: invokespecial #338                // Method ocaml_fn_89."<init>":()V
        2881: astore        144
        2883: aload         17
        2885: checkcast     #2                  // class Block
        2888: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2891: bipush        72
        2893: aload         144
        2895: aastore
        2896: new           #340                // class ocaml_fn_90
        2899: dup
        2900: invokespecial #341                // Method ocaml_fn_90."<init>":()V
        2903: astore        145
        2905: aload         17
        2907: checkcast     #2                  // class Block
        2910: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2913: bipush        70
        2915: aload         145
        2917: aastore
        2918: new           #343                // class ocaml_fn_91
        2921: dup
        2922: invokespecial #344                // Method ocaml_fn_91."<init>":()V
        2925: astore        146
        2927: aload         17
        2929: checkcast     #2                  // class Block
        2932: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2935: bipush        69
        2937: aload         146
        2939: aastore
        2940: new           #346                // class ocaml_fn_92
        2943: dup
        2944: invokespecial #347                // Method ocaml_fn_92."<init>":()V
        2947: astore        147
        2949: aload         17
        2951: checkcast     #2                  // class Block
        2954: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2957: bipush        64
        2959: aload         147
        2961: aastore
        2962: new           #349                // class ocaml_fn_93
        2965: dup
        2966: invokespecial #350                // Method ocaml_fn_93."<init>":()V
        2969: astore        148
        2971: aload         17
        2973: checkcast     #2                  // class Block
        2976: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        2979: bipush        62
        2981: aload         148
        2983: aastore
        2984: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2987: bipush        45
        2989: aload         17
        2991: aastore
        2992: iconst_0
        2993: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2996: astore        149
        2998: iconst_1
        2999: istore        150
        3001: iconst_0
        3002: istore        151
        3004: iload         151
        3006: ifeq          3021
        3009: iload         150
        3011: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3014: astore        152
        3016: goto_w        3049
        3021: iload         150
        3023: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3026: astore        153
        3028: goto_w        3033
        3033: bipush        10
        3035: istore        154
        3037: iload         154
        3039: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3042: astore        155
        3044: goto_w        3065
        3049: bipush        20
        3051: istore        156
        3053: iload         156
        3055: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3058: astore        155
        3060: goto_w        3065
        3065: getstatic     #354                // Field java/lang/System.out:Ljava/io/PrintStream;
        3068: aload         155
        3070: invokestatic  #80                 // Method Block.asLong:(Ljava/lang/Object;)J
        3073: l2i
        3074: invokevirtual #360                // Method java/io/PrintStream.println:(I)V
        3077: iconst_0
        3078: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3081: astore        157
        3083: new           #2                  // class Block
        3086: dup
        3087: iconst_0
        3088: iconst_0
        3089: anewarray     #4                  // class java/lang/Object
        3092: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3095: astore        158
        3097: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3100: bipush        46
        3102: aload         158
        3104: aastore
        3105: iconst_0
        3106: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3109: astore        159
        3111: iconst_0
        3112: istore        160
        3114: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3117: bipush        45
        3119: aaload
        3120: checkcast     #2                  // class Block
        3123: getfield      #59                 // Field Block.fields:[Ljava/lang/Object;
        3126: bipush        102
        3128: aaload
        3129: astore        161
        3131: aload         161
        3133: checkcast     #129                // class Closure
        3136: iload         160
        3138: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3141: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3144: astore        162
        3146: new           #2                  // class Block
        3149: dup
        3150: iconst_0
        3151: iconst_0
        3152: anewarray     #4                  // class java/lang/Object
        3155: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3158: astore        163
        3160: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3163: bipush        47
        3165: aload         163
        3167: aastore
        3168: iconst_0
        3169: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3172: astore        164
        3174: return
    }
    |}]
