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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2231: bipush        46
        2233: aaload
        2234: astore        150
        2236: getstatic     #351                // Field java/lang/System.out:Ljava/io/PrintStream;
        2239: aload         150
        2241: checkcast     #353                // class java/lang/String
        2244: invokevirtual #359                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        2247: iconst_0
        2248: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2251: astore        151
        2253: new           #2                  // class Block
        2256: dup
        2257: iconst_0
        2258: iconst_0
        2259: anewarray     #4                  // class java/lang/Object
        2262: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2265: astore        152
        2267: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2270: bipush        47
        2272: aload         152
        2274: aastore
        2275: iconst_0
        2276: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2279: astore        153
        2281: iconst_0
        2282: istore        154
        2284: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2287: bipush        45
        2289: aaload
        2290: checkcast     #2                  // class Block
        2293: getfield      #362                // Field Block.fields:[Ljava/lang/Object;
        2296: bipush        102
        2298: aaload
        2299: astore        155
        2301: aload         155
        2303: checkcast     #126                // class Closure
        2306: iload         154
        2308: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2311: invokevirtual #366                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2314: astore        156
        2316: new           #2                  // class Block
        2319: dup
        2320: iconst_0
        2321: iconst_0
        2322: anewarray     #4                  // class java/lang/Object
        2325: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2328: astore        157
        2330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2333: bipush        48
        2335: aload         157
        2337: aastore
        2338: iconst_0
        2339: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2342: astore        158
        2344: return
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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: bipush        8
        2230: istore        150
        2232: getstatic     #351                // Field java/lang/System.out:Ljava/io/PrintStream;
        2235: iload         150
        2237: invokevirtual #357                // Method java/io/PrintStream.println:(I)V
        2240: iconst_0
        2241: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2244: astore        151
        2246: new           #2                  // class Block
        2249: dup
        2250: iconst_0
        2251: iconst_0
        2252: anewarray     #4                  // class java/lang/Object
        2255: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2258: astore        152
        2260: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2263: bipush        46
        2265: aload         152
        2267: aastore
        2268: iconst_0
        2269: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2272: astore        153
        2274: iconst_0
        2275: istore        154
        2277: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2280: bipush        45
        2282: aaload
        2283: checkcast     #2                  // class Block
        2286: getfield      #360                // Field Block.fields:[Ljava/lang/Object;
        2289: bipush        102
        2291: aaload
        2292: astore        155
        2294: aload         155
        2296: checkcast     #126                // class Closure
        2299: iload         154
        2301: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2304: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2307: astore        156
        2309: new           #2                  // class Block
        2312: dup
        2313: iconst_0
        2314: iconst_0
        2315: anewarray     #4                  // class java/lang/Object
        2318: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2321: astore        157
        2323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2326: bipush        47
        2328: aload         157
        2330: aastore
        2331: iconst_0
        2332: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2335: astore        158
        2337: return
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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: iconst_0
        2229: istore        150
        2231: iload         150
        2233: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2236: astore        151
        2238: goto_w        2243
        2243: new           #349                // class ocaml_fn_95
        2246: dup
        2247: invokespecial #350                // Method ocaml_fn_95."<init>":()V
        2250: astore        152
        2252: bipush        10
        2254: istore        153
        2256: aload         152
        2258: iload         153
        2260: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2263: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2266: astore        154
        2268: bipush        32
        2270: istore        155
        2272: aload         154
        2274: checkcast     #126                // class Closure
        2277: iload         155
        2279: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2282: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2285: astore        156
        2287: getstatic     #358                // Field java/lang/System.out:Ljava/io/PrintStream;
        2290: aload         156
        2292: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
        2295: l2i
        2296: invokevirtual #364                // Method java/io/PrintStream.println:(I)V
        2299: iconst_0
        2300: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2303: astore        157
        2305: new           #2                  // class Block
        2308: dup
        2309: iconst_0
        2310: iconst_1
        2311: anewarray     #4                  // class java/lang/Object
        2314: dup
        2315: iconst_0
        2316: aload         152
        2318: aastore
        2319: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2322: astore        158
        2324: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2327: bipush        46
        2329: aload         158
        2331: aastore
        2332: iconst_0
        2333: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2336: astore        159
        2338: iconst_0
        2339: istore        160
        2341: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2344: bipush        45
        2346: aaload
        2347: checkcast     #2                  // class Block
        2350: getfield      #367                // Field Block.fields:[Ljava/lang/Object;
        2353: bipush        102
        2355: aaload
        2356: astore        161
        2358: aload         161
        2360: checkcast     #126                // class Closure
        2363: iload         160
        2365: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2368: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2371: astore        162
        2373: new           #2                  // class Block
        2376: dup
        2377: iconst_0
        2378: iconst_0
        2379: anewarray     #4                  // class java/lang/Object
        2382: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2385: astore        163
        2387: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2390: bipush        47
        2392: aload         163
        2394: aastore
        2395: iconst_0
        2396: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2399: astore        164
        2401: return
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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: iconst_0
        2229: istore        150
        2231: iload         150
        2233: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2236: astore        151
        2238: goto_w        2243
        2243: new           #349                // class ocaml_fn_94
        2246: dup
        2247: invokespecial #350                // Method ocaml_fn_94."<init>":()V
        2250: astore        152
        2252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2255: bipush        46
        2257: aaload
        2258: astore        153
        2260: aload         152
        2262: aload         153
        2264: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2267: astore        154
        2269: getstatic     #358                // Field java/lang/System.out:Ljava/io/PrintStream;
        2272: aload         154
        2274: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
        2277: l2i
        2278: invokevirtual #364                // Method java/io/PrintStream.println:(I)V
        2281: iconst_0
        2282: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2285: astore        155
        2287: new           #2                  // class Block
        2290: dup
        2291: iconst_0
        2292: iconst_1
        2293: anewarray     #4                  // class java/lang/Object
        2296: dup
        2297: iconst_0
        2298: aload         152
        2300: aastore
        2301: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2304: astore        156
        2306: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2309: bipush        47
        2311: aload         156
        2313: aastore
        2314: iconst_0
        2315: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2318: astore        157
        2320: iconst_0
        2321: istore        158
        2323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2326: bipush        45
        2328: aaload
        2329: checkcast     #2                  // class Block
        2332: getfield      #367                // Field Block.fields:[Ljava/lang/Object;
        2335: bipush        102
        2337: aaload
        2338: astore        159
        2340: aload         159
        2342: checkcast     #126                // class Closure
        2345: iload         158
        2347: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2350: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2353: astore        160
        2355: new           #2                  // class Block
        2358: dup
        2359: iconst_0
        2360: iconst_0
        2361: anewarray     #4                  // class java/lang/Object
        2364: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2367: astore        161
        2369: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2372: bipush        48
        2374: aload         161
        2376: aastore
        2377: iconst_0
        2378: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2381: astore        162
        2383: return
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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: iconst_0
        2229: istore        150
        2231: iload         150
        2233: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2236: astore        151
        2238: goto_w        2243
        2243: iconst_0
        2244: istore        152
        2246: iconst_1
        2247: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2250: astore        153
        2252: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2255: bipush        46
        2257: aaload
        2258: astore        154
        2260: new           #2                  // class Block
        2263: dup
        2264: sipush        248
        2267: iconst_2
        2268: anewarray     #4                  // class java/lang/Object
        2271: dup
        2272: iconst_0
        2273: aload         154
        2275: aastore
        2276: dup
        2277: iconst_1
        2278: aload         153
        2280: aastore
        2281: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2284: astore        155
        2286: new           #349                // class ocaml_fn_94
        2289: dup
        2290: aload         155
        2292: invokespecial #350                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        2295: astore        156
        2297: iconst_0
        2298: istore        157
        2300: aload         156
        2302: iload         157
        2304: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2307: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2310: astore        158
        2312: getstatic     #358                // Field java/lang/System.out:Ljava/io/PrintStream;
        2315: aload         158
        2317: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
        2320: l2i
        2321: invokevirtual #364                // Method java/io/PrintStream.println:(I)V
        2324: iconst_0
        2325: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2328: astore        159
        2330: new           #2                  // class Block
        2333: dup
        2334: iconst_0
        2335: iconst_2
        2336: anewarray     #4                  // class java/lang/Object
        2339: dup
        2340: iconst_0
        2341: aload         155
        2343: aastore
        2344: dup
        2345: iconst_1
        2346: aload         156
        2348: aastore
        2349: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2352: astore        160
        2354: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2357: bipush        47
        2359: aload         160
        2361: aastore
        2362: iconst_0
        2363: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2366: astore        161
        2368: iconst_0
        2369: istore        162
        2371: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2374: bipush        45
        2376: aaload
        2377: checkcast     #2                  // class Block
        2380: getfield      #367                // Field Block.fields:[Ljava/lang/Object;
        2383: bipush        102
        2385: aaload
        2386: astore        163
        2388: aload         163
        2390: checkcast     #126                // class Closure
        2393: iload         162
        2395: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2398: invokevirtual #354                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2401: astore        164
        2403: new           #2                  // class Block
        2406: dup
        2407: iconst_0
        2408: iconst_0
        2409: anewarray     #4                  // class java/lang/Object
        2412: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2415: astore        165
        2417: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2420: bipush        48
        2422: aload         165
        2424: aastore
        2425: iconst_0
        2426: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2429: astore        166
        2431: return
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
         209: new           #55                 // class ocaml_fn_8
         212: dup
         213: invokespecial #56                 // Method ocaml_fn_8."<init>":()V
         216: astore        17
         218: new           #58                 // class ocaml_fn_9
         221: dup
         222: invokespecial #59                 // Method ocaml_fn_9."<init>":()V
         225: astore        18
         227: iconst_0
         228: istore        19
         230: iconst_0
         231: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         234: astore        20
         236: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         239: bipush        37
         241: aaload
         242: astore        21
         244: new           #2                  // class Block
         247: dup
         248: sipush        248
         251: iconst_2
         252: anewarray     #4                  // class java/lang/Object
         255: dup
         256: iconst_0
         257: aload         21
         259: aastore
         260: dup
         261: iconst_1
         262: aload         20
         264: aastore
         265: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         268: astore        22
         270: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         273: bipush        7
         275: aaload
         276: astore        23
         278: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         281: bipush        10
         283: aaload
         284: astore        24
         286: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         289: iconst_3
         290: aaload
         291: astore        25
         293: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         296: iconst_2
         297: aaload
         298: astore        26
         300: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         303: bipush        6
         305: aaload
         306: astore        27
         308: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         311: iconst_0
         312: aaload
         313: astore        28
         315: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         318: bipush        8
         320: aaload
         321: astore        29
         323: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         326: iconst_1
         327: aaload
         328: astore        30
         330: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         333: iconst_4
         334: aaload
         335: astore        31
         337: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         340: iconst_5
         341: aaload
         342: astore        32
         344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         347: bipush        9
         349: aaload
         350: astore        33
         352: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         355: bipush        11
         357: aaload
         358: astore        34
         360: new           #61                 // class ocaml_fn_10
         363: dup
         364: invokespecial #62                 // Method ocaml_fn_10."<init>":()V
         367: astore        35
         369: new           #64                 // class ocaml_fn_11
         372: dup
         373: invokespecial #65                 // Method ocaml_fn_11."<init>":()V
         376: astore        36
         378: new           #67                 // class ocaml_fn_12
         381: dup
         382: invokespecial #68                 // Method ocaml_fn_12."<init>":()V
         385: astore        37
         387: new           #70                 // class ocaml_fn_13
         390: dup
         391: invokespecial #71                 // Method ocaml_fn_13."<init>":()V
         394: astore        38
         396: ldc           #72                 // int 2147483647
         398: istore        39
         400: ldc           #73                 // int -2147483648
         402: istore        40
         404: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         407: bipush        38
         409: aaload
         410: astore        41
         412: aload         41
         414: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         417: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         420: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         423: astore        42
         425: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         428: bipush        39
         430: aaload
         431: astore        43
         433: aload         43
         435: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         438: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         441: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         444: astore        44
         446: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         449: bipush        40
         451: aaload
         452: astore        45
         454: aload         45
         456: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         459: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         462: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         465: astore        46
         467: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         470: bipush        41
         472: aaload
         473: astore        47
         475: aload         47
         477: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         480: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         483: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         486: astore        48
         488: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         491: bipush        42
         493: aaload
         494: astore        49
         496: aload         49
         498: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         501: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         504: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         507: astore        50
         509: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
         512: bipush        43
         514: aaload
         515: astore        51
         517: aload         51
         519: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
         522: invokestatic  #83                 // Method java/lang/Double.longBitsToDouble:(J)D
         525: invokestatic  #86                 // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
         528: astore        52
         530: new           #88                 // class ocaml_fn_14
         533: dup
         534: invokespecial #89                 // Method ocaml_fn_14."<init>":()V
         537: astore        53
         539: new           #91                 // class ocaml_fn_15
         542: dup
         543: aload         18
         545: invokespecial #94                 // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
         548: astore        54
         550: new           #96                 // class ocaml_fn_16
         553: dup
         554: invokespecial #97                 // Method ocaml_fn_16."<init>":()V
         557: astore        55
         559: new           #99                 // class ocaml_fn_17
         562: dup
         563: aload         18
         565: invokespecial #100                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
         568: astore        56
         570: new           #102                // class ocaml_fn_18
         573: dup
         574: invokespecial #103                // Method ocaml_fn_18."<init>":()V
         577: astore        57
         579: new           #105                // class ocaml_fn_19
         582: dup
         583: invokespecial #106                // Method ocaml_fn_19."<init>":()V
         586: astore        58
         588: new           #108                // class ocaml_fn_20
         591: dup
         592: aload         26
         594: invokespecial #109                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
         597: astore        59
         599: new           #111                // class ocaml_fn_21
         602: dup
         603: aload         53
         605: invokespecial #112                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
         608: astore        60
         610: new           #114                // class ocaml_fn_22
         613: dup
         614: aload         60
         616: invokespecial #115                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
         619: astore        61
         621: new           #117                // class ocaml_fn_23
         624: dup
         625: aload         26
         627: invokespecial #118                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
         630: astore        62
         632: new           #120                // class ocaml_fn_24
         635: dup
         636: invokespecial #121                // Method ocaml_fn_24."<init>":()V
         639: astore        63
         641: new           #123                // class ocaml_fn_25
         644: dup
         645: invokespecial #124                // Method ocaml_fn_25."<init>":()V
         648: astore        64
         650: aload         63
         652: checkcast     #120                // class ocaml_fn_24
         655: aload         63
         657: checkcast     #126                // class Closure
         660: putfield      #130                // Field ocaml_fn_24.sibling_0:LClosure;
         663: iconst_0
         664: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         667: astore        65
         669: aload         63
         671: checkcast     #120                // class ocaml_fn_24
         674: aload         64
         676: checkcast     #126                // class Closure
         679: putfield      #133                // Field ocaml_fn_24.sibling_1:LClosure;
         682: iconst_0
         683: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         686: astore        66
         688: aload         64
         690: checkcast     #123                // class ocaml_fn_25
         693: aload         63
         695: checkcast     #126                // class Closure
         698: putfield      #134                // Field ocaml_fn_25.sibling_0:LClosure;
         701: iconst_0
         702: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         705: astore        67
         707: aload         64
         709: checkcast     #123                // class ocaml_fn_25
         712: aload         64
         714: checkcast     #126                // class Closure
         717: putfield      #135                // Field ocaml_fn_25.sibling_1:LClosure;
         720: iconst_0
         721: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         724: astore        68
         726: iconst_0
         727: istore        69
         729: iload         69
         731: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         734: astore        70
         736: iconst_1
         737: istore        71
         739: iload         71
         741: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         744: astore        72
         746: iconst_2
         747: istore        73
         749: iload         73
         751: invokestatic  #139                // Method Channel.forDescriptor:(I)LChannel;
         754: astore        74
         756: new           #141                // class ocaml_fn_26
         759: dup
         760: invokespecial #142                // Method ocaml_fn_26."<init>":()V
         763: astore        75
         765: new           #144                // class ocaml_fn_27
         768: dup
         769: aload         75
         771: invokespecial #145                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
         774: astore        76
         776: new           #147                // class ocaml_fn_28
         779: dup
         780: aload         75
         782: invokespecial #148                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
         785: astore        77
         787: new           #150                // class ocaml_fn_29
         790: dup
         791: aload         30
         793: invokespecial #151                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
         796: astore        78
         798: new           #153                // class ocaml_fn_30
         801: dup
         802: invokespecial #154                // Method ocaml_fn_30."<init>":()V
         805: astore        79
         807: new           #156                // class ocaml_fn_31
         810: dup
         811: invokespecial #157                // Method ocaml_fn_31."<init>":()V
         814: astore        80
         816: new           #159                // class ocaml_fn_32
         819: dup
         820: aload         18
         822: invokespecial #160                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
         825: astore        81
         827: new           #162                // class ocaml_fn_33
         830: dup
         831: aload         18
         833: invokespecial #163                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
         836: astore        82
         838: new           #165                // class ocaml_fn_34
         841: dup
         842: invokespecial #166                // Method ocaml_fn_34."<init>":()V
         845: astore        83
         847: new           #168                // class ocaml_fn_35
         850: dup
         851: invokespecial #169                // Method ocaml_fn_35."<init>":()V
         854: astore        84
         856: new           #171                // class ocaml_fn_36
         859: dup
         860: invokespecial #172                // Method ocaml_fn_36."<init>":()V
         863: astore        85
         865: new           #174                // class ocaml_fn_37
         868: dup
         869: invokespecial #175                // Method ocaml_fn_37."<init>":()V
         872: astore        86
         874: new           #177                // class ocaml_fn_38
         877: dup
         878: aload         86
         880: invokespecial #178                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
         883: astore        87
         885: new           #180                // class ocaml_fn_39
         888: dup
         889: aload         86
         891: invokespecial #181                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
         894: astore        88
         896: new           #183                // class ocaml_fn_40
         899: dup
         900: aload         18
         902: invokespecial #184                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
         905: astore        89
         907: new           #186                // class ocaml_fn_41
         910: dup
         911: aload         31
         913: invokespecial #187                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
         916: astore        90
         918: new           #189                // class ocaml_fn_42
         921: dup
         922: aload         18
         924: aload         90
         926: invokespecial #192                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         929: astore        91
         931: new           #194                // class ocaml_fn_43
         934: dup
         935: aload         91
         937: invokespecial #195                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
         940: astore        92
         942: new           #197                // class ocaml_fn_44
         945: dup
         946: aload         31
         948: invokespecial #198                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
         951: astore        93
         953: new           #200                // class ocaml_fn_45
         956: dup
         957: invokespecial #201                // Method ocaml_fn_45."<init>":()V
         960: astore        94
         962: new           #203                // class ocaml_fn_46
         965: dup
         966: aload         72
         968: invokespecial #204                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
         971: astore        95
         973: new           #206                // class ocaml_fn_47
         976: dup
         977: aload         72
         979: aload         80
         981: invokespecial #207                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         984: astore        96
         986: new           #209                // class ocaml_fn_48
         989: dup
         990: aload         72
         992: aload         79
         994: invokespecial #210                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
         997: astore        97
         999: new           #212                // class ocaml_fn_49
        1002: dup
        1003: aload         58
        1005: aload         72
        1007: aload         80
        1009: invokespecial #215                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1012: astore        98
        1014: new           #217                // class ocaml_fn_50
        1017: dup
        1018: aload         61
        1020: aload         72
        1022: aload         80
        1024: invokespecial #218                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1027: astore        99
        1029: new           #220                // class ocaml_fn_51
        1032: dup
        1033: aload         72
        1035: aload         80
        1037: invokespecial #221                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1040: astore        100
        1042: new           #223                // class ocaml_fn_52
        1045: dup
        1046: aload         72
        1048: invokespecial #224                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1051: astore        101
        1053: new           #226                // class ocaml_fn_53
        1056: dup
        1057: aload         74
        1059: invokespecial #227                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1062: astore        102
        1064: new           #229                // class ocaml_fn_54
        1067: dup
        1068: aload         74
        1070: aload         80
        1072: invokespecial #230                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1075: astore        103
        1077: new           #232                // class ocaml_fn_55
        1080: dup
        1081: aload         74
        1083: aload         79
        1085: invokespecial #233                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1088: astore        104
        1090: new           #235                // class ocaml_fn_56
        1093: dup
        1094: aload         58
        1096: aload         74
        1098: aload         80
        1100: invokespecial #236                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1103: astore        105
        1105: new           #238                // class ocaml_fn_57
        1108: dup
        1109: aload         61
        1111: aload         74
        1113: aload         80
        1115: invokespecial #239                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1118: astore        106
        1120: new           #241                // class ocaml_fn_58
        1123: dup
        1124: aload         74
        1126: aload         80
        1128: invokespecial #242                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1131: astore        107
        1133: new           #244                // class ocaml_fn_59
        1136: dup
        1137: aload         74
        1139: invokespecial #245                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        1142: astore        108
        1144: new           #247                // class ocaml_fn_60
        1147: dup
        1148: aload         70
        1150: aload         72
        1152: aload         93
        1154: invokespecial #248                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1157: astore        109
        1159: new           #250                // class ocaml_fn_61
        1162: dup
        1163: aload         109
        1165: invokespecial #251                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        1168: astore        110
        1170: new           #253                // class ocaml_fn_62
        1173: dup
        1174: aload         59
        1176: aload         109
        1178: invokespecial #254                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1181: astore        111
        1183: new           #256                // class ocaml_fn_63
        1186: dup
        1187: aload         109
        1189: invokespecial #257                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        1192: astore        112
        1194: new           #259                // class ocaml_fn_64
        1197: dup
        1198: aload         62
        1200: aload         109
        1202: invokespecial #260                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1205: astore        113
        1207: new           #262                // class ocaml_fn_65
        1210: dup
        1211: invokespecial #263                // Method ocaml_fn_65."<init>":()V
        1214: astore        114
        1216: new           #265                // class ocaml_fn_66
        1219: dup
        1220: aload         53
        1222: invokespecial #266                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        1225: astore        115
        1227: new           #2                  // class Block
        1230: dup
        1231: iconst_0
        1232: iconst_1
        1233: anewarray     #4                  // class java/lang/Object
        1236: dup
        1237: iconst_0
        1238: aload         78
        1240: aastore
        1241: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        116
        1246: new           #268                // class ocaml_fn_67
        1249: dup
        1250: aload         116
        1252: invokespecial #269                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        1255: astore        117
        1257: new           #271                // class ocaml_fn_68
        1260: dup
        1261: invokespecial #272                // Method ocaml_fn_68."<init>":()V
        1264: astore        118
        1266: new           #2                  // class Block
        1269: dup
        1270: iconst_0
        1271: iconst_1
        1272: anewarray     #4                  // class java/lang/Object
        1275: dup
        1276: iconst_0
        1277: aload         118
        1279: aastore
        1280: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1283: astore        119
        1285: new           #274                // class ocaml_fn_69
        1288: dup
        1289: aload         116
        1291: aload         119
        1293: invokespecial #275                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1296: astore        120
        1298: new           #277                // class ocaml_fn_70
        1301: dup
        1302: aload         120
        1304: invokespecial #278                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        1307: astore        121
        1309: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        44
        1314: aaload
        1315: astore        122
        1317: iconst_0
        1318: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1321: astore        123
        1323: new           #280                // class ocaml_fn_71
        1326: dup
        1327: invokespecial #281                // Method ocaml_fn_71."<init>":()V
        1330: astore        124
        1332: new           #283                // class ocaml_fn_72
        1335: dup
        1336: invokespecial #284                // Method ocaml_fn_72."<init>":()V
        1339: astore        125
        1341: new           #286                // class ocaml_fn_73
        1344: dup
        1345: invokespecial #287                // Method ocaml_fn_73."<init>":()V
        1348: astore        126
        1350: new           #289                // class ocaml_fn_74
        1353: dup
        1354: invokespecial #290                // Method ocaml_fn_74."<init>":()V
        1357: astore        127
        1359: new           #292                // class ocaml_fn_75
        1362: dup
        1363: invokespecial #293                // Method ocaml_fn_75."<init>":()V
        1366: astore        128
        1368: new           #295                // class ocaml_fn_76
        1371: dup
        1372: invokespecial #296                // Method ocaml_fn_76."<init>":()V
        1375: astore        129
        1377: new           #2                  // class Block
        1380: dup
        1381: iconst_0
        1382: bipush        6
        1384: anewarray     #4                  // class java/lang/Object
        1387: dup
        1388: iconst_0
        1389: aload         129
        1391: aastore
        1392: dup
        1393: iconst_1
        1394: aload         128
        1396: aastore
        1397: dup
        1398: iconst_2
        1399: aload         127
        1401: aastore
        1402: dup
        1403: iconst_3
        1404: aload         126
        1406: aastore
        1407: dup
        1408: iconst_4
        1409: aload         125
        1411: aastore
        1412: dup
        1413: iconst_5
        1414: aload         124
        1416: aastore
        1417: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1420: astore        130
        1422: new           #298                // class ocaml_fn_77
        1425: dup
        1426: invokespecial #299                // Method ocaml_fn_77."<init>":()V
        1429: astore        131
        1431: new           #301                // class ocaml_fn_78
        1434: dup
        1435: invokespecial #302                // Method ocaml_fn_78."<init>":()V
        1438: astore        132
        1440: new           #304                // class ocaml_fn_79
        1443: dup
        1444: invokespecial #305                // Method ocaml_fn_79."<init>":()V
        1447: astore        133
        1449: new           #307                // class ocaml_fn_80
        1452: dup
        1453: invokespecial #308                // Method ocaml_fn_80."<init>":()V
        1456: astore        134
        1458: new           #310                // class ocaml_fn_81
        1461: dup
        1462: invokespecial #311                // Method ocaml_fn_81."<init>":()V
        1465: astore        135
        1467: new           #313                // class ocaml_fn_82
        1470: dup
        1471: invokespecial #314                // Method ocaml_fn_82."<init>":()V
        1474: astore        136
        1476: new           #316                // class ocaml_fn_83
        1479: dup
        1480: invokespecial #317                // Method ocaml_fn_83."<init>":()V
        1483: astore        137
        1485: new           #319                // class ocaml_fn_84
        1488: dup
        1489: invokespecial #320                // Method ocaml_fn_84."<init>":()V
        1492: astore        138
        1494: new           #322                // class ocaml_fn_85
        1497: dup
        1498: invokespecial #323                // Method ocaml_fn_85."<init>":()V
        1501: astore        139
        1503: new           #325                // class ocaml_fn_86
        1506: dup
        1507: invokespecial #326                // Method ocaml_fn_86."<init>":()V
        1510: astore        140
        1512: new           #328                // class ocaml_fn_87
        1515: dup
        1516: invokespecial #329                // Method ocaml_fn_87."<init>":()V
        1519: astore        141
        1521: new           #331                // class ocaml_fn_88
        1524: dup
        1525: invokespecial #332                // Method ocaml_fn_88."<init>":()V
        1528: astore        142
        1530: new           #334                // class ocaml_fn_89
        1533: dup
        1534: invokespecial #335                // Method ocaml_fn_89."<init>":()V
        1537: astore        143
        1539: new           #337                // class ocaml_fn_90
        1542: dup
        1543: invokespecial #338                // Method ocaml_fn_90."<init>":()V
        1546: astore        144
        1548: new           #340                // class ocaml_fn_91
        1551: dup
        1552: invokespecial #341                // Method ocaml_fn_91."<init>":()V
        1555: astore        145
        1557: new           #343                // class ocaml_fn_92
        1560: dup
        1561: invokespecial #344                // Method ocaml_fn_92."<init>":()V
        1564: astore        146
        1566: new           #346                // class ocaml_fn_93
        1569: dup
        1570: invokespecial #347                // Method ocaml_fn_93."<init>":()V
        1573: astore        147
        1575: new           #2                  // class Block
        1578: dup
        1579: iconst_0
        1580: bipush        104
        1582: anewarray     #4                  // class java/lang/Object
        1585: dup
        1586: iconst_0
        1587: aload         18
        1589: aastore
        1590: dup
        1591: iconst_1
        1592: aload         17
        1594: aastore
        1595: dup
        1596: iconst_2
        1597: aload         22
        1599: aastore
        1600: dup
        1601: iconst_3
        1602: aload         23
        1604: aastore
        1605: dup
        1606: iconst_4
        1607: aload         24
        1609: aastore
        1610: dup
        1611: iconst_5
        1612: aload         25
        1614: aastore
        1615: dup
        1616: bipush        6
        1618: aload         26
        1620: aastore
        1621: dup
        1622: bipush        7
        1624: aload         27
        1626: aastore
        1627: dup
        1628: bipush        8
        1630: aload         28
        1632: aastore
        1633: dup
        1634: bipush        9
        1636: aload         29
        1638: aastore
        1639: dup
        1640: bipush        10
        1642: aload         30
        1644: aastore
        1645: dup
        1646: bipush        11
        1648: aload         31
        1650: aastore
        1651: dup
        1652: bipush        12
        1654: aload         32
        1656: aastore
        1657: dup
        1658: bipush        13
        1660: aload         33
        1662: aastore
        1663: dup
        1664: bipush        14
        1666: aload         34
        1668: aastore
        1669: dup
        1670: bipush        15
        1672: aload         35
        1674: aastore
        1675: dup
        1676: bipush        16
        1678: aload         36
        1680: aastore
        1681: dup
        1682: bipush        17
        1684: aload         37
        1686: aastore
        1687: dup
        1688: bipush        18
        1690: iload         39
        1692: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1695: aastore
        1696: dup
        1697: bipush        19
        1699: iload         40
        1701: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1704: aastore
        1705: dup
        1706: bipush        20
        1708: aload         38
        1710: aastore
        1711: dup
        1712: bipush        21
        1714: aload         42
        1716: aastore
        1717: dup
        1718: bipush        22
        1720: aload         44
        1722: aastore
        1723: dup
        1724: bipush        23
        1726: aload         46
        1728: aastore
        1729: dup
        1730: bipush        24
        1732: aload         48
        1734: aastore
        1735: dup
        1736: bipush        25
        1738: aload         50
        1740: aastore
        1741: dup
        1742: bipush        26
        1744: aload         52
        1746: aastore
        1747: dup
        1748: bipush        27
        1750: aload         53
        1752: aastore
        1753: dup
        1754: bipush        28
        1756: aload         54
        1758: aastore
        1759: dup
        1760: bipush        29
        1762: aload         55
        1764: aastore
        1765: dup
        1766: bipush        30
        1768: aload         57
        1770: aastore
        1771: dup
        1772: bipush        31
        1774: aload         56
        1776: aastore
        1777: dup
        1778: bipush        32
        1780: aload         58
        1782: aastore
        1783: dup
        1784: bipush        33
        1786: aload         59
        1788: aastore
        1789: dup
        1790: bipush        34
        1792: aload         61
        1794: aastore
        1795: dup
        1796: bipush        35
        1798: aload         62
        1800: aastore
        1801: dup
        1802: bipush        36
        1804: aload         63
        1806: aastore
        1807: dup
        1808: bipush        37
        1810: aload         70
        1812: aastore
        1813: dup
        1814: bipush        38
        1816: aload         72
        1818: aastore
        1819: dup
        1820: bipush        39
        1822: aload         74
        1824: aastore
        1825: dup
        1826: bipush        40
        1828: aload         95
        1830: aastore
        1831: dup
        1832: bipush        41
        1834: aload         96
        1836: aastore
        1837: dup
        1838: bipush        42
        1840: aload         97
        1842: aastore
        1843: dup
        1844: bipush        43
        1846: aload         98
        1848: aastore
        1849: dup
        1850: bipush        44
        1852: aload         99
        1854: aastore
        1855: dup
        1856: bipush        45
        1858: aload         100
        1860: aastore
        1861: dup
        1862: bipush        46
        1864: aload         101
        1866: aastore
        1867: dup
        1868: bipush        47
        1870: aload         102
        1872: aastore
        1873: dup
        1874: bipush        48
        1876: aload         103
        1878: aastore
        1879: dup
        1880: bipush        49
        1882: aload         104
        1884: aastore
        1885: dup
        1886: bipush        50
        1888: aload         105
        1890: aastore
        1891: dup
        1892: bipush        51
        1894: aload         106
        1896: aastore
        1897: dup
        1898: bipush        52
        1900: aload         107
        1902: aastore
        1903: dup
        1904: bipush        53
        1906: aload         108
        1908: aastore
        1909: dup
        1910: bipush        54
        1912: aload         109
        1914: aastore
        1915: dup
        1916: bipush        55
        1918: aload         111
        1920: aastore
        1921: dup
        1922: bipush        56
        1924: aload         110
        1926: aastore
        1927: dup
        1928: bipush        57
        1930: aload         113
        1932: aastore
        1933: dup
        1934: bipush        58
        1936: aload         112
        1938: aastore
        1939: dup
        1940: bipush        59
        1942: aload         76
        1944: aastore
        1945: dup
        1946: bipush        60
        1948: aload         77
        1950: aastore
        1951: dup
        1952: bipush        61
        1954: aload         75
        1956: aastore
        1957: dup
        1958: bipush        62
        1960: aload         147
        1962: aastore
        1963: dup
        1964: bipush        63
        1966: aload         78
        1968: aastore
        1969: dup
        1970: bipush        64
        1972: aload         146
        1974: aastore
        1975: dup
        1976: bipush        65
        1978: aload         80
        1980: aastore
        1981: dup
        1982: bipush        66
        1984: aload         79
        1986: aastore
        1987: dup
        1988: bipush        67
        1990: aload         81
        1992: aastore
        1993: dup
        1994: bipush        68
        1996: aload         82
        1998: aastore
        1999: dup
        2000: bipush        69
        2002: aload         145
        2004: aastore
        2005: dup
        2006: bipush        70
        2008: aload         144
        2010: aastore
        2011: dup
        2012: bipush        71
        2014: aload         83
        2016: aastore
        2017: dup
        2018: bipush        72
        2020: aload         143
        2022: aastore
        2023: dup
        2024: bipush        73
        2026: aload         142
        2028: aastore
        2029: dup
        2030: bipush        74
        2032: aload         141
        2034: aastore
        2035: dup
        2036: bipush        75
        2038: aload         84
        2040: aastore
        2041: dup
        2042: bipush        76
        2044: aload         85
        2046: aastore
        2047: dup
        2048: bipush        77
        2050: aload         140
        2052: aastore
        2053: dup
        2054: bipush        78
        2056: aload         87
        2058: aastore
        2059: dup
        2060: bipush        79
        2062: aload         88
        2064: aastore
        2065: dup
        2066: bipush        80
        2068: aload         86
        2070: aastore
        2071: dup
        2072: bipush        81
        2074: aload         139
        2076: aastore
        2077: dup
        2078: bipush        82
        2080: aload         93
        2082: aastore
        2083: dup
        2084: bipush        83
        2086: aload         89
        2088: aastore
        2089: dup
        2090: bipush        84
        2092: aload         91
        2094: aastore
        2095: dup
        2096: bipush        85
        2098: aload         92
        2100: aastore
        2101: dup
        2102: bipush        86
        2104: aload         138
        2106: aastore
        2107: dup
        2108: bipush        87
        2110: aload         137
        2112: aastore
        2113: dup
        2114: bipush        88
        2116: aload         136
        2118: aastore
        2119: dup
        2120: bipush        89
        2122: aload         135
        2124: aastore
        2125: dup
        2126: bipush        90
        2128: aload         134
        2130: aastore
        2131: dup
        2132: bipush        91
        2134: aload         133
        2136: aastore
        2137: dup
        2138: bipush        92
        2140: aload         132
        2142: aastore
        2143: dup
        2144: bipush        93
        2146: aload         94
        2148: aastore
        2149: dup
        2150: bipush        94
        2152: aload         131
        2154: aastore
        2155: dup
        2156: bipush        95
        2158: aload         130
        2160: aastore
        2161: dup
        2162: bipush        96
        2164: aload         114
        2166: aastore
        2167: dup
        2168: bipush        97
        2170: aload         115
        2172: aastore
        2173: dup
        2174: bipush        98
        2176: aload         121
        2178: aastore
        2179: dup
        2180: bipush        99
        2182: aload         117
        2184: aastore
        2185: dup
        2186: bipush        100
        2188: aload         60
        2190: aastore
        2191: dup
        2192: bipush        101
        2194: aload         90
        2196: aastore
        2197: dup
        2198: bipush        102
        2200: aload         120
        2202: aastore
        2203: dup
        2204: bipush        103
        2206: aload         119
        2208: aastore
        2209: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2212: astore        148
        2214: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2217: bipush        45
        2219: aload         148
        2221: aastore
        2222: iconst_0
        2223: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2226: astore        149
        2228: iconst_1
        2229: istore        150
        2231: iconst_0
        2232: istore        151
        2234: iload         151
        2236: ifeq          2251
        2239: iload         150
        2241: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2244: astore        152
        2246: goto_w        2279
        2251: iload         150
        2253: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2256: astore        153
        2258: goto_w        2263
        2263: bipush        10
        2265: istore        154
        2267: iload         154
        2269: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2272: astore        155
        2274: goto_w        2295
        2279: bipush        20
        2281: istore        156
        2283: iload         156
        2285: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2288: astore        155
        2290: goto_w        2295
        2295: getstatic     #351                // Field java/lang/System.out:Ljava/io/PrintStream;
        2298: aload         155
        2300: invokestatic  #77                 // Method Block.asLong:(Ljava/lang/Object;)J
        2303: l2i
        2304: invokevirtual #357                // Method java/io/PrintStream.println:(I)V
        2307: iconst_0
        2308: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2311: astore        157
        2313: new           #2                  // class Block
        2316: dup
        2317: iconst_0
        2318: iconst_0
        2319: anewarray     #4                  // class java/lang/Object
        2322: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2325: astore        158
        2327: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2330: bipush        46
        2332: aload         158
        2334: aastore
        2335: iconst_0
        2336: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2339: astore        159
        2341: iconst_0
        2342: istore        160
        2344: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2347: bipush        45
        2349: aaload
        2350: checkcast     #2                  // class Block
        2353: getfield      #360                // Field Block.fields:[Ljava/lang/Object;
        2356: bipush        102
        2358: aaload
        2359: astore        161
        2361: aload         161
        2363: checkcast     #126                // class Closure
        2366: iload         160
        2368: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2371: invokevirtual #364                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        2374: astore        162
        2376: new           #2                  // class Block
        2379: dup
        2380: iconst_0
        2381: iconst_0
        2382: anewarray     #4                  // class java/lang/Object
        2385: invokespecial #16                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2388: astore        163
        2390: getstatic     #25                 // Field GLOBALS:[Ljava/lang/Object;
        2393: bipush        47
        2395: aload         163
        2397: aastore
        2398: iconst_0
        2399: invokestatic  #53                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2402: astore        164
        2404: return
    }
    |}]
