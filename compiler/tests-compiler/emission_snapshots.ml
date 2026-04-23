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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3047: bipush        46
        3049: aaload
        3050: astore        157
        3052: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3055: aload         157
        3057: checkcast     #370                // class java/lang/String
        3060: invokevirtual #376                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3063: iconst_0
        3064: i2l
        3065: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3068: astore        158
        3070: new           #2                  // class Block
        3073: dup
        3074: iconst_0
        3075: iconst_0
        3076: anewarray     #4                  // class java/lang/Object
        3079: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3082: astore        159
        3084: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3087: bipush        47
        3089: aload         159
        3091: aastore
        3092: iconst_0
        3093: i2l
        3094: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3097: astore        160
        3099: iconst_0
        3100: i2l
        3101: lstore        161
        3103: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3106: bipush        45
        3108: aaload
        3109: checkcast     #2                  // class Block
        3112: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3115: bipush        102
        3117: aaload
        3118: astore        163
        3120: aload         163
        3122: checkcast     #143                // class Closure
        3125: lload         161
        3127: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3130: invokevirtual #380                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3133: astore        164
        3135: new           #2                  // class Block
        3138: dup
        3139: iconst_0
        3140: iconst_0
        3141: anewarray     #4                  // class java/lang/Object
        3144: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3147: astore        165
        3149: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3152: bipush        48
        3154: aload         165
        3156: aastore
        3157: iconst_0
        3158: i2l
        3159: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3162: astore        166
        3164: return
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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: bipush        8
        3046: i2l
        3047: lstore        157
        3049: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3052: lload         157
        3054: l2i
        3055: invokevirtual #374                // Method java/io/PrintStream.println:(I)V
        3058: iconst_0
        3059: i2l
        3060: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3063: astore        159
        3065: new           #2                  // class Block
        3068: dup
        3069: iconst_0
        3070: iconst_0
        3071: anewarray     #4                  // class java/lang/Object
        3074: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3077: astore        160
        3079: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3082: bipush        46
        3084: aload         160
        3086: aastore
        3087: iconst_0
        3088: i2l
        3089: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3092: astore        161
        3094: iconst_0
        3095: i2l
        3096: lstore        162
        3098: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3101: bipush        45
        3103: aaload
        3104: checkcast     #2                  // class Block
        3107: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3110: bipush        102
        3112: aaload
        3113: astore        164
        3115: aload         164
        3117: checkcast     #143                // class Closure
        3120: lload         162
        3122: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3125: invokevirtual #378                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3128: astore        165
        3130: new           #2                  // class Block
        3133: dup
        3134: iconst_0
        3135: iconst_0
        3136: anewarray     #4                  // class java/lang/Object
        3139: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3142: astore        166
        3144: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3147: bipush        47
        3149: aload         166
        3151: aastore
        3152: iconst_0
        3153: i2l
        3154: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3157: astore        167
        3159: return
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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: iconst_0
        3045: i2l
        3046: lstore        157
        3048: lload         157
        3050: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3053: astore        159
        3055: goto_w        3060
        3060: new           #366                // class ocaml_fn_95
        3063: dup
        3064: invokespecial #367                // Method ocaml_fn_95."<init>":()V
        3067: astore        160
        3069: bipush        10
        3071: i2l
        3072: lstore        161
        3074: aload         160
        3076: lload         161
        3078: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3081: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3084: astore        163
        3086: bipush        32
        3088: i2l
        3089: lstore        164
        3091: aload         163
        3093: checkcast     #143                // class Closure
        3096: lload         164
        3098: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3101: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3104: astore        166
        3106: getstatic     #375                // Field java/lang/System.out:Ljava/io/PrintStream;
        3109: aload         166
        3111: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
        3114: l2i
        3115: invokevirtual #381                // Method java/io/PrintStream.println:(I)V
        3118: iconst_0
        3119: i2l
        3120: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3123: astore        167
        3125: new           #2                  // class Block
        3128: dup
        3129: iconst_0
        3130: iconst_1
        3131: anewarray     #4                  // class java/lang/Object
        3134: dup
        3135: iconst_0
        3136: aload         160
        3138: aastore
        3139: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3142: astore        168
        3144: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3147: bipush        46
        3149: aload         168
        3151: aastore
        3152: iconst_0
        3153: i2l
        3154: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3157: astore        169
        3159: iconst_0
        3160: i2l
        3161: lstore        170
        3163: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3166: bipush        45
        3168: aaload
        3169: checkcast     #2                  // class Block
        3172: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3175: bipush        102
        3177: aaload
        3178: astore        172
        3180: aload         172
        3182: checkcast     #143                // class Closure
        3185: lload         170
        3187: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3190: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3193: astore        173
        3195: new           #2                  // class Block
        3198: dup
        3199: iconst_0
        3200: iconst_0
        3201: anewarray     #4                  // class java/lang/Object
        3204: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3207: astore        174
        3209: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3212: bipush        47
        3214: aload         174
        3216: aastore
        3217: iconst_0
        3218: i2l
        3219: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3222: astore        175
        3224: return
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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: iconst_0
        3045: i2l
        3046: lstore        157
        3048: lload         157
        3050: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3053: astore        159
        3055: goto_w        3060
        3060: new           #366                // class ocaml_fn_94
        3063: dup
        3064: invokespecial #367                // Method ocaml_fn_94."<init>":()V
        3067: astore        160
        3069: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3072: bipush        46
        3074: aaload
        3075: astore        161
        3077: aload         160
        3079: aload         161
        3081: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3084: astore        162
        3086: getstatic     #375                // Field java/lang/System.out:Ljava/io/PrintStream;
        3089: aload         162
        3091: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
        3094: l2i
        3095: invokevirtual #381                // Method java/io/PrintStream.println:(I)V
        3098: iconst_0
        3099: i2l
        3100: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3103: astore        163
        3105: new           #2                  // class Block
        3108: dup
        3109: iconst_0
        3110: iconst_1
        3111: anewarray     #4                  // class java/lang/Object
        3114: dup
        3115: iconst_0
        3116: aload         160
        3118: aastore
        3119: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3122: astore        164
        3124: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3127: bipush        47
        3129: aload         164
        3131: aastore
        3132: iconst_0
        3133: i2l
        3134: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3137: astore        165
        3139: iconst_0
        3140: i2l
        3141: lstore        166
        3143: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3146: bipush        45
        3148: aaload
        3149: checkcast     #2                  // class Block
        3152: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3155: bipush        102
        3157: aaload
        3158: astore        168
        3160: aload         168
        3162: checkcast     #143                // class Closure
        3165: lload         166
        3167: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3170: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3173: astore        169
        3175: new           #2                  // class Block
        3178: dup
        3179: iconst_0
        3180: iconst_0
        3181: anewarray     #4                  // class java/lang/Object
        3184: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3187: astore        170
        3189: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3192: bipush        48
        3194: aload         170
        3196: aastore
        3197: iconst_0
        3198: i2l
        3199: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3202: astore        171
        3204: return
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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: iconst_0
        3045: i2l
        3046: lstore        157
        3048: lload         157
        3050: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3053: astore        159
        3055: goto_w        3060
        3060: iconst_0
        3061: i2l
        3062: lstore        160
        3064: iconst_1
        3065: i2l
        3066: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3069: astore        162
        3071: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3074: bipush        46
        3076: aaload
        3077: astore        163
        3079: new           #2                  // class Block
        3082: dup
        3083: sipush        248
        3086: iconst_2
        3087: anewarray     #4                  // class java/lang/Object
        3090: dup
        3091: iconst_0
        3092: aload         163
        3094: aastore
        3095: dup
        3096: iconst_1
        3097: aload         162
        3099: aastore
        3100: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3103: astore        164
        3105: new           #366                // class ocaml_fn_94
        3108: dup
        3109: aload         164
        3111: invokespecial #367                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3114: astore        165
        3116: iconst_0
        3117: i2l
        3118: lstore        166
        3120: aload         165
        3122: lload         166
        3124: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3127: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3130: astore        168
        3132: getstatic     #375                // Field java/lang/System.out:Ljava/io/PrintStream;
        3135: aload         168
        3137: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
        3140: l2i
        3141: invokevirtual #381                // Method java/io/PrintStream.println:(I)V
        3144: iconst_0
        3145: i2l
        3146: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3149: astore        169
        3151: new           #2                  // class Block
        3154: dup
        3155: iconst_0
        3156: iconst_2
        3157: anewarray     #4                  // class java/lang/Object
        3160: dup
        3161: iconst_0
        3162: aload         164
        3164: aastore
        3165: dup
        3166: iconst_1
        3167: aload         165
        3169: aastore
        3170: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3173: astore        170
        3175: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3178: bipush        47
        3180: aload         170
        3182: aastore
        3183: iconst_0
        3184: i2l
        3185: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3188: astore        171
        3190: iconst_0
        3191: i2l
        3192: lstore        172
        3194: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3197: bipush        45
        3199: aaload
        3200: checkcast     #2                  // class Block
        3203: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3206: bipush        102
        3208: aaload
        3209: astore        174
        3211: aload         174
        3213: checkcast     #143                // class Closure
        3216: lload         172
        3218: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3221: invokevirtual #371                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3224: astore        175
        3226: new           #2                  // class Block
        3229: dup
        3230: iconst_0
        3231: iconst_0
        3232: anewarray     #4                  // class java/lang/Object
        3235: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3238: astore        176
        3240: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3243: bipush        48
        3245: aload         176
        3247: aastore
        3248: iconst_0
        3249: i2l
        3250: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3253: astore        177
        3255: return
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
         295: iconst_0
         296: i2l
         297: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         300: astore        23
         302: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         305: bipush        37
         307: aaload
         308: astore        24
         310: new           #2                  // class Block
         313: dup
         314: sipush        248
         317: iconst_2
         318: anewarray     #4                  // class java/lang/Object
         321: dup
         322: iconst_0
         323: aload         24
         325: aastore
         326: dup
         327: iconst_1
         328: aload         23
         330: aastore
         331: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         334: astore        25
         336: aload         18
         338: checkcast     #2                  // class Block
         341: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         344: iconst_2
         345: aload         25
         347: aastore
         348: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         351: bipush        7
         353: aaload
         354: astore        26
         356: aload         18
         358: checkcast     #2                  // class Block
         361: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         364: iconst_3
         365: aload         26
         367: aastore
         368: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         371: bipush        10
         373: aaload
         374: astore        27
         376: aload         18
         378: checkcast     #2                  // class Block
         381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         384: iconst_4
         385: aload         27
         387: aastore
         388: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         391: iconst_3
         392: aaload
         393: astore        28
         395: aload         18
         397: checkcast     #2                  // class Block
         400: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         403: iconst_5
         404: aload         28
         406: aastore
         407: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         410: iconst_2
         411: aaload
         412: astore        29
         414: aload         18
         416: checkcast     #2                  // class Block
         419: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         422: bipush        6
         424: aload         29
         426: aastore
         427: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         430: bipush        6
         432: aaload
         433: astore        30
         435: aload         18
         437: checkcast     #2                  // class Block
         440: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         443: bipush        7
         445: aload         30
         447: aastore
         448: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         451: iconst_0
         452: aaload
         453: astore        31
         455: aload         18
         457: checkcast     #2                  // class Block
         460: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         463: bipush        8
         465: aload         31
         467: aastore
         468: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         471: bipush        8
         473: aaload
         474: astore        32
         476: aload         18
         478: checkcast     #2                  // class Block
         481: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         484: bipush        9
         486: aload         32
         488: aastore
         489: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         492: iconst_1
         493: aaload
         494: astore        33
         496: aload         18
         498: checkcast     #2                  // class Block
         501: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         504: bipush        10
         506: aload         33
         508: aastore
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: iconst_4
         513: aaload
         514: astore        34
         516: aload         18
         518: checkcast     #2                  // class Block
         521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         524: bipush        11
         526: aload         34
         528: aastore
         529: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         532: iconst_5
         533: aaload
         534: astore        35
         536: aload         18
         538: checkcast     #2                  // class Block
         541: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         544: bipush        12
         546: aload         35
         548: aastore
         549: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        9
         554: aaload
         555: astore        36
         557: aload         18
         559: checkcast     #2                  // class Block
         562: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         565: bipush        13
         567: aload         36
         569: aastore
         570: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         573: bipush        11
         575: aaload
         576: astore        37
         578: aload         18
         580: checkcast     #2                  // class Block
         583: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         586: bipush        14
         588: aload         37
         590: aastore
         591: new           #76                 // class ocaml_fn_10
         594: dup
         595: invokespecial #77                 // Method ocaml_fn_10."<init>":()V
         598: astore        38
         600: aload         18
         602: checkcast     #2                  // class Block
         605: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         608: bipush        15
         610: aload         38
         612: aastore
         613: new           #79                 // class ocaml_fn_11
         616: dup
         617: invokespecial #80                 // Method ocaml_fn_11."<init>":()V
         620: astore        39
         622: aload         18
         624: checkcast     #2                  // class Block
         627: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         630: bipush        16
         632: aload         39
         634: aastore
         635: new           #82                 // class ocaml_fn_12
         638: dup
         639: invokespecial #83                 // Method ocaml_fn_12."<init>":()V
         642: astore        40
         644: aload         18
         646: checkcast     #2                  // class Block
         649: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         652: bipush        17
         654: aload         40
         656: aastore
         657: new           #85                 // class ocaml_fn_13
         660: dup
         661: invokespecial #86                 // Method ocaml_fn_13."<init>":()V
         664: astore        41
         666: aload         18
         668: checkcast     #2                  // class Block
         671: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         674: bipush        20
         676: aload         41
         678: aastore
         679: ldc2_w        #87                 // long 4611686018427387903l
         682: lstore        42
         684: aload         18
         686: checkcast     #2                  // class Block
         689: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         692: bipush        18
         694: lload         42
         696: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         699: aastore
         700: ldc2_w        #89                 // long -4611686018427387904l
         703: lstore        44
         705: aload         18
         707: checkcast     #2                  // class Block
         710: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         713: bipush        19
         715: lload         44
         717: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
         720: aastore
         721: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         724: bipush        38
         726: aaload
         727: astore        46
         729: aload         46
         731: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         734: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         737: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         740: astore        47
         742: aload         18
         744: checkcast     #2                  // class Block
         747: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         750: bipush        21
         752: aload         47
         754: aastore
         755: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        39
         760: aaload
         761: astore        48
         763: aload         48
         765: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         768: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         771: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         774: astore        49
         776: aload         18
         778: checkcast     #2                  // class Block
         781: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         784: bipush        22
         786: aload         49
         788: aastore
         789: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         792: bipush        40
         794: aaload
         795: astore        50
         797: aload         50
         799: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         802: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         805: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         808: astore        51
         810: aload         18
         812: checkcast     #2                  // class Block
         815: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         818: bipush        23
         820: aload         51
         822: aastore
         823: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         826: bipush        41
         828: aaload
         829: astore        52
         831: aload         52
         833: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         836: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         839: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         842: astore        53
         844: aload         18
         846: checkcast     #2                  // class Block
         849: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         852: bipush        24
         854: aload         53
         856: aastore
         857: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         860: bipush        42
         862: aaload
         863: astore        54
         865: aload         54
         867: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         870: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         873: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         876: astore        55
         878: aload         18
         880: checkcast     #2                  // class Block
         883: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         886: bipush        25
         888: aload         55
         890: aastore
         891: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         894: bipush        43
         896: aaload
         897: astore        56
         899: aload         56
         901: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
         904: invokestatic  #100                // Method java/lang/Double.longBitsToDouble:(J)D
         907: invokestatic  #103                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         910: astore        57
         912: aload         18
         914: checkcast     #2                  // class Block
         917: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         920: bipush        26
         922: aload         57
         924: aastore
         925: new           #105                // class ocaml_fn_14
         928: dup
         929: invokespecial #106                // Method ocaml_fn_14."<init>":()V
         932: astore        58
         934: aload         18
         936: checkcast     #2                  // class Block
         939: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         942: bipush        27
         944: aload         58
         946: aastore
         947: new           #108                // class ocaml_fn_15
         950: dup
         951: aload         20
         953: invokespecial #111                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         956: astore        59
         958: aload         18
         960: checkcast     #2                  // class Block
         963: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         966: bipush        28
         968: aload         59
         970: aastore
         971: new           #113                // class ocaml_fn_16
         974: dup
         975: invokespecial #114                // Method ocaml_fn_16."<init>":()V
         978: astore        60
         980: aload         18
         982: checkcast     #2                  // class Block
         985: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
         988: bipush        29
         990: aload         60
         992: aastore
         993: new           #116                // class ocaml_fn_17
         996: dup
         997: aload         20
         999: invokespecial #117                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1002: astore        61
        1004: aload         18
        1006: checkcast     #2                  // class Block
        1009: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1012: bipush        31
        1014: aload         61
        1016: aastore
        1017: new           #119                // class ocaml_fn_18
        1020: dup
        1021: invokespecial #120                // Method ocaml_fn_18."<init>":()V
        1024: astore        62
        1026: aload         18
        1028: checkcast     #2                  // class Block
        1031: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1034: bipush        30
        1036: aload         62
        1038: aastore
        1039: new           #122                // class ocaml_fn_19
        1042: dup
        1043: invokespecial #123                // Method ocaml_fn_19."<init>":()V
        1046: astore        63
        1048: aload         18
        1050: checkcast     #2                  // class Block
        1053: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1056: bipush        32
        1058: aload         63
        1060: aastore
        1061: new           #125                // class ocaml_fn_20
        1064: dup
        1065: aload         29
        1067: invokespecial #126                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1070: astore        64
        1072: aload         18
        1074: checkcast     #2                  // class Block
        1077: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1080: bipush        33
        1082: aload         64
        1084: aastore
        1085: new           #128                // class ocaml_fn_21
        1088: dup
        1089: aload         58
        1091: invokespecial #129                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1094: astore        65
        1096: aload         18
        1098: checkcast     #2                  // class Block
        1101: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1104: bipush        100
        1106: aload         65
        1108: aastore
        1109: new           #131                // class ocaml_fn_22
        1112: dup
        1113: aload         65
        1115: invokespecial #132                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1118: astore        66
        1120: aload         18
        1122: checkcast     #2                  // class Block
        1125: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1128: bipush        34
        1130: aload         66
        1132: aastore
        1133: new           #134                // class ocaml_fn_23
        1136: dup
        1137: aload         29
        1139: invokespecial #135                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1142: astore        67
        1144: aload         18
        1146: checkcast     #2                  // class Block
        1149: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1152: bipush        35
        1154: aload         67
        1156: aastore
        1157: new           #137                // class ocaml_fn_24
        1160: dup
        1161: invokespecial #138                // Method ocaml_fn_24."<init>":()V
        1164: astore        68
        1166: aload         18
        1168: checkcast     #2                  // class Block
        1171: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1174: bipush        36
        1176: aload         68
        1178: aastore
        1179: new           #140                // class ocaml_fn_25
        1182: dup
        1183: invokespecial #141                // Method ocaml_fn_25."<init>":()V
        1186: astore        69
        1188: aload         68
        1190: checkcast     #137                // class ocaml_fn_24
        1193: aload         68
        1195: checkcast     #143                // class Closure
        1198: putfield      #147                // Field ocaml_fn_24.sibling_0:LClosure;
        1201: iconst_0
        1202: i2l
        1203: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1206: astore        70
        1208: aload         68
        1210: checkcast     #137                // class ocaml_fn_24
        1213: aload         69
        1215: checkcast     #143                // class Closure
        1218: putfield      #150                // Field ocaml_fn_24.sibling_1:LClosure;
        1221: iconst_0
        1222: i2l
        1223: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1226: astore        71
        1228: aload         69
        1230: checkcast     #140                // class ocaml_fn_25
        1233: aload         68
        1235: checkcast     #143                // class Closure
        1238: putfield      #151                // Field ocaml_fn_25.sibling_0:LClosure;
        1241: iconst_0
        1242: i2l
        1243: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1246: astore        72
        1248: aload         69
        1250: checkcast     #140                // class ocaml_fn_25
        1253: aload         69
        1255: checkcast     #143                // class Closure
        1258: putfield      #152                // Field ocaml_fn_25.sibling_1:LClosure;
        1261: iconst_0
        1262: i2l
        1263: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        1266: astore        73
        1268: iconst_0
        1269: i2l
        1270: lstore        74
        1272: lload         74
        1274: l2i
        1275: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1278: astore        76
        1280: aload         18
        1282: checkcast     #2                  // class Block
        1285: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1288: bipush        37
        1290: aload         76
        1292: aastore
        1293: iconst_1
        1294: i2l
        1295: lstore        77
        1297: lload         77
        1299: l2i
        1300: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1303: astore        79
        1305: aload         18
        1307: checkcast     #2                  // class Block
        1310: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1313: bipush        38
        1315: aload         79
        1317: aastore
        1318: iconst_2
        1319: i2l
        1320: lstore        80
        1322: lload         80
        1324: l2i
        1325: invokestatic  #156                // Method Channel.forDescriptor:(I)LChannel;
        1328: astore        82
        1330: aload         18
        1332: checkcast     #2                  // class Block
        1335: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1338: bipush        39
        1340: aload         82
        1342: aastore
        1343: new           #158                // class ocaml_fn_26
        1346: dup
        1347: invokespecial #159                // Method ocaml_fn_26."<init>":()V
        1350: astore        83
        1352: aload         18
        1354: checkcast     #2                  // class Block
        1357: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1360: bipush        61
        1362: aload         83
        1364: aastore
        1365: new           #161                // class ocaml_fn_27
        1368: dup
        1369: aload         83
        1371: invokespecial #162                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1374: astore        84
        1376: aload         18
        1378: checkcast     #2                  // class Block
        1381: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1384: bipush        59
        1386: aload         84
        1388: aastore
        1389: new           #164                // class ocaml_fn_28
        1392: dup
        1393: aload         83
        1395: invokespecial #165                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1398: astore        85
        1400: aload         18
        1402: checkcast     #2                  // class Block
        1405: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1408: bipush        60
        1410: aload         85
        1412: aastore
        1413: new           #167                // class ocaml_fn_29
        1416: dup
        1417: aload         33
        1419: invokespecial #168                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1422: astore        86
        1424: aload         18
        1426: checkcast     #2                  // class Block
        1429: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1432: bipush        63
        1434: aload         86
        1436: aastore
        1437: new           #170                // class ocaml_fn_30
        1440: dup
        1441: invokespecial #171                // Method ocaml_fn_30."<init>":()V
        1444: astore        87
        1446: aload         18
        1448: checkcast     #2                  // class Block
        1451: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1454: bipush        66
        1456: aload         87
        1458: aastore
        1459: new           #173                // class ocaml_fn_31
        1462: dup
        1463: invokespecial #174                // Method ocaml_fn_31."<init>":()V
        1466: astore        88
        1468: aload         18
        1470: checkcast     #2                  // class Block
        1473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1476: bipush        65
        1478: aload         88
        1480: aastore
        1481: new           #176                // class ocaml_fn_32
        1484: dup
        1485: aload         20
        1487: invokespecial #177                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1490: astore        89
        1492: aload         18
        1494: checkcast     #2                  // class Block
        1497: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1500: bipush        67
        1502: aload         89
        1504: aastore
        1505: new           #179                // class ocaml_fn_33
        1508: dup
        1509: aload         20
        1511: invokespecial #180                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1514: astore        90
        1516: aload         18
        1518: checkcast     #2                  // class Block
        1521: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1524: bipush        68
        1526: aload         90
        1528: aastore
        1529: new           #182                // class ocaml_fn_34
        1532: dup
        1533: invokespecial #183                // Method ocaml_fn_34."<init>":()V
        1536: astore        91
        1538: aload         18
        1540: checkcast     #2                  // class Block
        1543: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1546: bipush        71
        1548: aload         91
        1550: aastore
        1551: new           #185                // class ocaml_fn_35
        1554: dup
        1555: invokespecial #186                // Method ocaml_fn_35."<init>":()V
        1558: astore        92
        1560: aload         18
        1562: checkcast     #2                  // class Block
        1565: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1568: bipush        75
        1570: aload         92
        1572: aastore
        1573: new           #188                // class ocaml_fn_36
        1576: dup
        1577: invokespecial #189                // Method ocaml_fn_36."<init>":()V
        1580: astore        93
        1582: aload         18
        1584: checkcast     #2                  // class Block
        1587: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1590: bipush        76
        1592: aload         93
        1594: aastore
        1595: new           #191                // class ocaml_fn_37
        1598: dup
        1599: invokespecial #192                // Method ocaml_fn_37."<init>":()V
        1602: astore        94
        1604: aload         18
        1606: checkcast     #2                  // class Block
        1609: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1612: bipush        80
        1614: aload         94
        1616: aastore
        1617: new           #194                // class ocaml_fn_38
        1620: dup
        1621: aload         94
        1623: invokespecial #195                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1626: astore        95
        1628: aload         18
        1630: checkcast     #2                  // class Block
        1633: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1636: bipush        78
        1638: aload         95
        1640: aastore
        1641: new           #197                // class ocaml_fn_39
        1644: dup
        1645: aload         94
        1647: invokespecial #198                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1650: astore        96
        1652: aload         18
        1654: checkcast     #2                  // class Block
        1657: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1660: bipush        79
        1662: aload         96
        1664: aastore
        1665: new           #200                // class ocaml_fn_40
        1668: dup
        1669: aload         20
        1671: invokespecial #201                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1674: astore        97
        1676: aload         18
        1678: checkcast     #2                  // class Block
        1681: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1684: bipush        83
        1686: aload         97
        1688: aastore
        1689: new           #203                // class ocaml_fn_41
        1692: dup
        1693: aload         34
        1695: invokespecial #204                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1698: astore        98
        1700: aload         18
        1702: checkcast     #2                  // class Block
        1705: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1708: bipush        101
        1710: aload         98
        1712: aastore
        1713: new           #206                // class ocaml_fn_42
        1716: dup
        1717: aload         20
        1719: aload         98
        1721: invokespecial #209                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1724: astore        99
        1726: aload         18
        1728: checkcast     #2                  // class Block
        1731: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1734: bipush        84
        1736: aload         99
        1738: aastore
        1739: new           #211                // class ocaml_fn_43
        1742: dup
        1743: aload         99
        1745: invokespecial #212                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1748: astore        100
        1750: aload         18
        1752: checkcast     #2                  // class Block
        1755: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1758: bipush        85
        1760: aload         100
        1762: aastore
        1763: new           #214                // class ocaml_fn_44
        1766: dup
        1767: aload         34
        1769: invokespecial #215                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1772: astore        101
        1774: aload         18
        1776: checkcast     #2                  // class Block
        1779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1782: bipush        82
        1784: aload         101
        1786: aastore
        1787: new           #217                // class ocaml_fn_45
        1790: dup
        1791: invokespecial #218                // Method ocaml_fn_45."<init>":()V
        1794: astore        102
        1796: aload         18
        1798: checkcast     #2                  // class Block
        1801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1804: bipush        93
        1806: aload         102
        1808: aastore
        1809: new           #220                // class ocaml_fn_46
        1812: dup
        1813: aload         79
        1815: invokespecial #221                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1818: astore        103
        1820: aload         18
        1822: checkcast     #2                  // class Block
        1825: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1828: bipush        40
        1830: aload         103
        1832: aastore
        1833: new           #223                // class ocaml_fn_47
        1836: dup
        1837: aload         79
        1839: aload         88
        1841: invokespecial #224                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1844: astore        104
        1846: aload         18
        1848: checkcast     #2                  // class Block
        1851: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1854: bipush        41
        1856: aload         104
        1858: aastore
        1859: new           #226                // class ocaml_fn_48
        1862: dup
        1863: aload         79
        1865: aload         87
        1867: invokespecial #227                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1870: astore        105
        1872: aload         18
        1874: checkcast     #2                  // class Block
        1877: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1880: bipush        42
        1882: aload         105
        1884: aastore
        1885: new           #229                // class ocaml_fn_49
        1888: dup
        1889: aload         63
        1891: aload         79
        1893: aload         88
        1895: invokespecial #232                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1898: astore        106
        1900: aload         18
        1902: checkcast     #2                  // class Block
        1905: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1908: bipush        43
        1910: aload         106
        1912: aastore
        1913: new           #234                // class ocaml_fn_50
        1916: dup
        1917: aload         66
        1919: aload         79
        1921: aload         88
        1923: invokespecial #235                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        107
        1928: aload         18
        1930: checkcast     #2                  // class Block
        1933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1936: bipush        44
        1938: aload         107
        1940: aastore
        1941: new           #237                // class ocaml_fn_51
        1944: dup
        1945: aload         79
        1947: aload         88
        1949: invokespecial #238                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1952: astore        108
        1954: aload         18
        1956: checkcast     #2                  // class Block
        1959: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1962: bipush        45
        1964: aload         108
        1966: aastore
        1967: new           #240                // class ocaml_fn_52
        1970: dup
        1971: aload         79
        1973: invokespecial #241                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1976: astore        109
        1978: aload         18
        1980: checkcast     #2                  // class Block
        1983: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        1986: bipush        46
        1988: aload         109
        1990: aastore
        1991: new           #243                // class ocaml_fn_53
        1994: dup
        1995: aload         82
        1997: invokespecial #244                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2000: astore        110
        2002: aload         18
        2004: checkcast     #2                  // class Block
        2007: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2010: bipush        47
        2012: aload         110
        2014: aastore
        2015: new           #246                // class ocaml_fn_54
        2018: dup
        2019: aload         82
        2021: aload         88
        2023: invokespecial #247                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2026: astore        111
        2028: aload         18
        2030: checkcast     #2                  // class Block
        2033: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2036: bipush        48
        2038: aload         111
        2040: aastore
        2041: new           #249                // class ocaml_fn_55
        2044: dup
        2045: aload         82
        2047: aload         87
        2049: invokespecial #250                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        112
        2054: aload         18
        2056: checkcast     #2                  // class Block
        2059: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2062: bipush        49
        2064: aload         112
        2066: aastore
        2067: new           #252                // class ocaml_fn_56
        2070: dup
        2071: aload         63
        2073: aload         82
        2075: aload         88
        2077: invokespecial #253                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2080: astore        113
        2082: aload         18
        2084: checkcast     #2                  // class Block
        2087: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2090: bipush        50
        2092: aload         113
        2094: aastore
        2095: new           #255                // class ocaml_fn_57
        2098: dup
        2099: aload         66
        2101: aload         82
        2103: aload         88
        2105: invokespecial #256                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2108: astore        114
        2110: aload         18
        2112: checkcast     #2                  // class Block
        2115: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2118: bipush        51
        2120: aload         114
        2122: aastore
        2123: new           #258                // class ocaml_fn_58
        2126: dup
        2127: aload         82
        2129: aload         88
        2131: invokespecial #259                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2134: astore        115
        2136: aload         18
        2138: checkcast     #2                  // class Block
        2141: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2144: bipush        52
        2146: aload         115
        2148: aastore
        2149: new           #261                // class ocaml_fn_59
        2152: dup
        2153: aload         82
        2155: invokespecial #262                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2158: astore        116
        2160: aload         18
        2162: checkcast     #2                  // class Block
        2165: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2168: bipush        53
        2170: aload         116
        2172: aastore
        2173: new           #264                // class ocaml_fn_60
        2176: dup
        2177: aload         76
        2179: aload         79
        2181: aload         101
        2183: invokespecial #265                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2186: astore        117
        2188: aload         18
        2190: checkcast     #2                  // class Block
        2193: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2196: bipush        54
        2198: aload         117
        2200: aastore
        2201: new           #267                // class ocaml_fn_61
        2204: dup
        2205: aload         117
        2207: invokespecial #268                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2210: astore        118
        2212: aload         18
        2214: checkcast     #2                  // class Block
        2217: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2220: bipush        56
        2222: aload         118
        2224: aastore
        2225: new           #270                // class ocaml_fn_62
        2228: dup
        2229: aload         64
        2231: aload         117
        2233: invokespecial #271                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2236: astore        119
        2238: aload         18
        2240: checkcast     #2                  // class Block
        2243: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2246: bipush        55
        2248: aload         119
        2250: aastore
        2251: new           #273                // class ocaml_fn_63
        2254: dup
        2255: aload         117
        2257: invokespecial #274                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2260: astore        120
        2262: aload         18
        2264: checkcast     #2                  // class Block
        2267: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2270: bipush        58
        2272: aload         120
        2274: aastore
        2275: new           #276                // class ocaml_fn_64
        2278: dup
        2279: aload         67
        2281: aload         117
        2283: invokespecial #277                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2286: astore        121
        2288: aload         18
        2290: checkcast     #2                  // class Block
        2293: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        57
        2298: aload         121
        2300: aastore
        2301: new           #279                // class ocaml_fn_65
        2304: dup
        2305: invokespecial #280                // Method ocaml_fn_65."<init>":()V
        2308: astore        122
        2310: aload         18
        2312: checkcast     #2                  // class Block
        2315: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2318: bipush        96
        2320: aload         122
        2322: aastore
        2323: new           #282                // class ocaml_fn_66
        2326: dup
        2327: aload         58
        2329: invokespecial #283                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2332: astore        123
        2334: aload         18
        2336: checkcast     #2                  // class Block
        2339: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2342: bipush        97
        2344: aload         123
        2346: aastore
        2347: new           #2                  // class Block
        2350: dup
        2351: iconst_0
        2352: iconst_1
        2353: anewarray     #4                  // class java/lang/Object
        2356: dup
        2357: iconst_0
        2358: aload         86
        2360: aastore
        2361: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2364: astore        124
        2366: new           #285                // class ocaml_fn_67
        2369: dup
        2370: aload         124
        2372: invokespecial #286                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2375: astore        125
        2377: aload         18
        2379: checkcast     #2                  // class Block
        2382: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2385: bipush        99
        2387: aload         125
        2389: aastore
        2390: new           #288                // class ocaml_fn_68
        2393: dup
        2394: invokespecial #289                // Method ocaml_fn_68."<init>":()V
        2397: astore        126
        2399: new           #2                  // class Block
        2402: dup
        2403: iconst_0
        2404: iconst_1
        2405: anewarray     #4                  // class java/lang/Object
        2408: dup
        2409: iconst_0
        2410: aload         126
        2412: aastore
        2413: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2416: astore        127
        2418: aload         18
        2420: checkcast     #2                  // class Block
        2423: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2426: bipush        103
        2428: aload         127
        2430: aastore
        2431: new           #291                // class ocaml_fn_69
        2434: dup
        2435: aload         124
        2437: aload         127
        2439: invokespecial #292                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2442: astore        128
        2444: aload         18
        2446: checkcast     #2                  // class Block
        2449: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2452: bipush        102
        2454: aload         128
        2456: aastore
        2457: new           #294                // class ocaml_fn_70
        2460: dup
        2461: aload         128
        2463: invokespecial #295                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2466: astore        129
        2468: aload         18
        2470: checkcast     #2                  // class Block
        2473: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2476: bipush        98
        2478: aload         129
        2480: aastore
        2481: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2484: bipush        44
        2486: aaload
        2487: astore        130
        2489: aload         130
        2491: aload         128
        2493: invokestatic  #65                 // Method Ocaml.registerNamedValue:(Ljava/lang/Object;Ljava/lang/Object;)J
        2496: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        2499: astore        131
        2501: new           #2                  // class Block
        2504: dup
        2505: iconst_0
        2506: bipush        6
        2508: anewarray     #4                  // class java/lang/Object
        2511: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2514: astore        132
        2516: new           #297                // class ocaml_fn_71
        2519: dup
        2520: invokespecial #298                // Method ocaml_fn_71."<init>":()V
        2523: astore        133
        2525: aload         132
        2527: checkcast     #2                  // class Block
        2530: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2533: iconst_5
        2534: aload         133
        2536: aastore
        2537: new           #300                // class ocaml_fn_72
        2540: dup
        2541: invokespecial #301                // Method ocaml_fn_72."<init>":()V
        2544: astore        134
        2546: aload         132
        2548: checkcast     #2                  // class Block
        2551: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2554: iconst_4
        2555: aload         134
        2557: aastore
        2558: new           #303                // class ocaml_fn_73
        2561: dup
        2562: invokespecial #304                // Method ocaml_fn_73."<init>":()V
        2565: astore        135
        2567: aload         132
        2569: checkcast     #2                  // class Block
        2572: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2575: iconst_3
        2576: aload         135
        2578: aastore
        2579: new           #306                // class ocaml_fn_74
        2582: dup
        2583: invokespecial #307                // Method ocaml_fn_74."<init>":()V
        2586: astore        136
        2588: aload         132
        2590: checkcast     #2                  // class Block
        2593: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2596: iconst_2
        2597: aload         136
        2599: aastore
        2600: new           #309                // class ocaml_fn_75
        2603: dup
        2604: invokespecial #310                // Method ocaml_fn_75."<init>":()V
        2607: astore        137
        2609: aload         132
        2611: checkcast     #2                  // class Block
        2614: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2617: iconst_1
        2618: aload         137
        2620: aastore
        2621: new           #312                // class ocaml_fn_76
        2624: dup
        2625: invokespecial #313                // Method ocaml_fn_76."<init>":()V
        2628: astore        138
        2630: aload         132
        2632: checkcast     #2                  // class Block
        2635: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2638: iconst_0
        2639: aload         138
        2641: aastore
        2642: aload         18
        2644: checkcast     #2                  // class Block
        2647: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2650: bipush        95
        2652: aload         132
        2654: aastore
        2655: new           #315                // class ocaml_fn_77
        2658: dup
        2659: invokespecial #316                // Method ocaml_fn_77."<init>":()V
        2662: astore        139
        2664: aload         18
        2666: checkcast     #2                  // class Block
        2669: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2672: bipush        94
        2674: aload         139
        2676: aastore
        2677: new           #318                // class ocaml_fn_78
        2680: dup
        2681: invokespecial #319                // Method ocaml_fn_78."<init>":()V
        2684: astore        140
        2686: aload         18
        2688: checkcast     #2                  // class Block
        2691: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2694: bipush        92
        2696: aload         140
        2698: aastore
        2699: new           #321                // class ocaml_fn_79
        2702: dup
        2703: invokespecial #322                // Method ocaml_fn_79."<init>":()V
        2706: astore        141
        2708: aload         18
        2710: checkcast     #2                  // class Block
        2713: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2716: bipush        91
        2718: aload         141
        2720: aastore
        2721: new           #324                // class ocaml_fn_80
        2724: dup
        2725: invokespecial #325                // Method ocaml_fn_80."<init>":()V
        2728: astore        142
        2730: aload         18
        2732: checkcast     #2                  // class Block
        2735: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2738: bipush        90
        2740: aload         142
        2742: aastore
        2743: new           #327                // class ocaml_fn_81
        2746: dup
        2747: invokespecial #328                // Method ocaml_fn_81."<init>":()V
        2750: astore        143
        2752: aload         18
        2754: checkcast     #2                  // class Block
        2757: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2760: bipush        89
        2762: aload         143
        2764: aastore
        2765: new           #330                // class ocaml_fn_82
        2768: dup
        2769: invokespecial #331                // Method ocaml_fn_82."<init>":()V
        2772: astore        144
        2774: aload         18
        2776: checkcast     #2                  // class Block
        2779: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2782: bipush        88
        2784: aload         144
        2786: aastore
        2787: new           #333                // class ocaml_fn_83
        2790: dup
        2791: invokespecial #334                // Method ocaml_fn_83."<init>":()V
        2794: astore        145
        2796: aload         18
        2798: checkcast     #2                  // class Block
        2801: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2804: bipush        87
        2806: aload         145
        2808: aastore
        2809: new           #336                // class ocaml_fn_84
        2812: dup
        2813: invokespecial #337                // Method ocaml_fn_84."<init>":()V
        2816: astore        146
        2818: aload         18
        2820: checkcast     #2                  // class Block
        2823: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2826: bipush        86
        2828: aload         146
        2830: aastore
        2831: new           #339                // class ocaml_fn_85
        2834: dup
        2835: invokespecial #340                // Method ocaml_fn_85."<init>":()V
        2838: astore        147
        2840: aload         18
        2842: checkcast     #2                  // class Block
        2845: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2848: bipush        81
        2850: aload         147
        2852: aastore
        2853: new           #342                // class ocaml_fn_86
        2856: dup
        2857: invokespecial #343                // Method ocaml_fn_86."<init>":()V
        2860: astore        148
        2862: aload         18
        2864: checkcast     #2                  // class Block
        2867: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2870: bipush        77
        2872: aload         148
        2874: aastore
        2875: new           #345                // class ocaml_fn_87
        2878: dup
        2879: invokespecial #346                // Method ocaml_fn_87."<init>":()V
        2882: astore        149
        2884: aload         18
        2886: checkcast     #2                  // class Block
        2889: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2892: bipush        74
        2894: aload         149
        2896: aastore
        2897: new           #348                // class ocaml_fn_88
        2900: dup
        2901: invokespecial #349                // Method ocaml_fn_88."<init>":()V
        2904: astore        150
        2906: aload         18
        2908: checkcast     #2                  // class Block
        2911: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2914: bipush        73
        2916: aload         150
        2918: aastore
        2919: new           #351                // class ocaml_fn_89
        2922: dup
        2923: invokespecial #352                // Method ocaml_fn_89."<init>":()V
        2926: astore        151
        2928: aload         18
        2930: checkcast     #2                  // class Block
        2933: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2936: bipush        72
        2938: aload         151
        2940: aastore
        2941: new           #354                // class ocaml_fn_90
        2944: dup
        2945: invokespecial #355                // Method ocaml_fn_90."<init>":()V
        2948: astore        152
        2950: aload         18
        2952: checkcast     #2                  // class Block
        2955: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2958: bipush        70
        2960: aload         152
        2962: aastore
        2963: new           #357                // class ocaml_fn_91
        2966: dup
        2967: invokespecial #358                // Method ocaml_fn_91."<init>":()V
        2970: astore        153
        2972: aload         18
        2974: checkcast     #2                  // class Block
        2977: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        2980: bipush        69
        2982: aload         153
        2984: aastore
        2985: new           #360                // class ocaml_fn_92
        2988: dup
        2989: invokespecial #361                // Method ocaml_fn_92."<init>":()V
        2992: astore        154
        2994: aload         18
        2996: checkcast     #2                  // class Block
        2999: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3002: bipush        64
        3004: aload         154
        3006: aastore
        3007: new           #363                // class ocaml_fn_93
        3010: dup
        3011: invokespecial #364                // Method ocaml_fn_93."<init>":()V
        3014: astore        155
        3016: aload         18
        3018: checkcast     #2                  // class Block
        3021: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3024: bipush        62
        3026: aload         155
        3028: aastore
        3029: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3032: bipush        45
        3034: aload         18
        3036: aastore
        3037: iconst_0
        3038: i2l
        3039: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3042: astore        156
        3044: iconst_1
        3045: i2l
        3046: lstore        157
        3048: iconst_0
        3049: i2l
        3050: lstore        159
        3052: lload         159
        3054: iconst_0
        3055: i2l
        3056: lcmp
        3057: ifeq          3072
        3060: lload         157
        3062: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3065: astore        161
        3067: goto_w        3101
        3072: lload         157
        3074: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3077: astore        162
        3079: goto_w        3084
        3084: bipush        10
        3086: i2l
        3087: lstore        163
        3089: lload         163
        3091: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3094: astore        165
        3096: goto_w        3118
        3101: bipush        20
        3103: i2l
        3104: lstore        166
        3106: lload         166
        3108: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3111: astore        165
        3113: goto_w        3118
        3118: getstatic     #368                // Field java/lang/System.out:Ljava/io/PrintStream;
        3121: aload         165
        3123: invokestatic  #94                 // Method Block.asLong:(Ljava/lang/Object;)J
        3126: l2i
        3127: invokevirtual #374                // Method java/io/PrintStream.println:(I)V
        3130: iconst_0
        3131: i2l
        3132: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3135: astore        168
        3137: new           #2                  // class Block
        3140: dup
        3141: iconst_0
        3142: iconst_0
        3143: anewarray     #4                  // class java/lang/Object
        3146: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3149: astore        169
        3151: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3154: bipush        46
        3156: aload         169
        3158: aastore
        3159: iconst_0
        3160: i2l
        3161: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3164: astore        170
        3166: iconst_0
        3167: i2l
        3168: lstore        171
        3170: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3173: bipush        45
        3175: aaload
        3176: checkcast     #2                  // class Block
        3179: getfield      #71                 // Field Block.fields:[Ljava/lang/Object;
        3182: bipush        102
        3184: aaload
        3185: astore        173
        3187: aload         173
        3189: checkcast     #143                // class Closure
        3192: lload         171
        3194: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3197: invokevirtual #378                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3200: astore        174
        3202: new           #2                  // class Block
        3205: dup
        3206: iconst_0
        3207: iconst_0
        3208: anewarray     #4                  // class java/lang/Object
        3211: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3214: astore        175
        3216: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        3219: bipush        47
        3221: aload         175
        3223: aastore
        3224: iconst_0
        3225: i2l
        3226: invokestatic  #61                 // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
        3229: astore        176
        3231: return
    }
    |}]
