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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: ldc           #83                 // String hi
        1008: aastore
        1009: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1012: bipush        47
        1014: iconst_0
        1015: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1018: aastore
        1019: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1022: bipush        48
        1024: iconst_0
        1025: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1028: aastore
        1029: aconst_null
        1030: astore_1
        1031: aload_1
        1032: astore_2
        1033: goto_w        1038
        1038: new           #85                 // class ocaml_fn_0
        1041: dup
        1042: invokespecial #88                 // Method ocaml_fn_0."<init>":()V
        1045: astore_3
        1046: new           #90                 // class ocaml_fn_1
        1049: dup
        1050: invokespecial #91                 // Method ocaml_fn_1."<init>":()V
        1053: astore        4
        1055: new           #93                 // class ocaml_fn_2
        1058: dup
        1059: invokespecial #94                 // Method ocaml_fn_2."<init>":()V
        1062: astore        5
        1064: new           #10                 // class Block
        1067: dup
        1068: iconst_0
        1069: iconst_3
        1070: anewarray     #2                  // class java/lang/Object
        1073: dup
        1074: iconst_0
        1075: aload         4
        1077: aastore
        1078: dup
        1079: iconst_1
        1080: aload_3
        1081: aastore
        1082: dup
        1083: iconst_2
        1084: aload         5
        1086: aastore
        1087: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1090: astore        6
        1092: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1095: bipush        12
        1097: aload         6
        1099: aastore
        1100: iconst_0
        1101: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1104: astore        7
        1106: iconst_0
        1107: istore        8
        1109: iload         8
        1111: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1114: astore        9
        1116: goto_w        1121
        1121: sipush        199
        1124: istore        10
        1126: iconst_0
        1127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1130: astore        11
        1132: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1135: bipush        35
        1137: aaload
        1138: astore        12
        1140: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1143: iconst_3
        1144: aaload
        1145: astore        13
        1147: new           #10                 // class Block
        1150: dup
        1151: iconst_0
        1152: iconst_2
        1153: anewarray     #2                  // class java/lang/Object
        1156: dup
        1157: iconst_0
        1158: aload         13
        1160: aastore
        1161: dup
        1162: iconst_1
        1163: aload         12
        1165: aastore
        1166: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1169: astore        14
        1171: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1174: bipush        36
        1176: aaload
        1177: astore        15
        1179: iconst_0
        1180: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1183: astore        16
        1185: new           #96                 // class ocaml_fn_8
        1188: dup
        1189: invokespecial #97                 // Method ocaml_fn_8."<init>":()V
        1192: astore        17
        1194: new           #99                 // class ocaml_fn_9
        1197: dup
        1198: invokespecial #100                // Method ocaml_fn_9."<init>":()V
        1201: astore        18
        1203: iconst_0
        1204: istore        19
        1206: iconst_0
        1207: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1210: astore        20
        1212: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1215: bipush        37
        1217: aaload
        1218: astore        21
        1220: new           #10                 // class Block
        1223: dup
        1224: sipush        248
        1227: iconst_2
        1228: anewarray     #2                  // class java/lang/Object
        1231: dup
        1232: iconst_0
        1233: aload         21
        1235: aastore
        1236: dup
        1237: iconst_1
        1238: aload         20
        1240: aastore
        1241: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        22
        1246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        7
        1251: aaload
        1252: astore        23
        1254: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1257: bipush        10
        1259: aaload
        1260: astore        24
        1262: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1265: iconst_3
        1266: aaload
        1267: astore        25
        1269: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1272: iconst_2
        1273: aaload
        1274: astore        26
        1276: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1279: bipush        6
        1281: aaload
        1282: astore        27
        1284: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1287: iconst_0
        1288: aaload
        1289: astore        28
        1291: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1294: bipush        8
        1296: aaload
        1297: astore        29
        1299: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1302: iconst_1
        1303: aaload
        1304: astore        30
        1306: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1309: iconst_4
        1310: aaload
        1311: astore        31
        1313: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1316: iconst_5
        1317: aaload
        1318: astore        32
        1320: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        9
        1325: aaload
        1326: astore        33
        1328: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1331: bipush        11
        1333: aaload
        1334: astore        34
        1336: new           #102                // class ocaml_fn_10
        1339: dup
        1340: invokespecial #103                // Method ocaml_fn_10."<init>":()V
        1343: astore        35
        1345: new           #105                // class ocaml_fn_11
        1348: dup
        1349: invokespecial #106                // Method ocaml_fn_11."<init>":()V
        1352: astore        36
        1354: new           #108                // class ocaml_fn_12
        1357: dup
        1358: invokespecial #109                // Method ocaml_fn_12."<init>":()V
        1361: astore        37
        1363: new           #111                // class ocaml_fn_13
        1366: dup
        1367: invokespecial #112                // Method ocaml_fn_13."<init>":()V
        1370: astore        38
        1372: ldc           #113                // int 2147483647
        1374: istore        39
        1376: ldc           #114                // int -2147483648
        1378: istore        40
        1380: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1383: bipush        38
        1385: aaload
        1386: astore        41
        1388: ldc2_w        #115                // double 0.0d
        1391: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1394: astore        42
        1396: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1399: bipush        39
        1401: aaload
        1402: astore        43
        1404: ldc2_w        #115                // double 0.0d
        1407: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1410: astore        44
        1412: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1415: bipush        40
        1417: aaload
        1418: astore        45
        1420: ldc2_w        #115                // double 0.0d
        1423: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1426: astore        46
        1428: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1431: bipush        41
        1433: aaload
        1434: astore        47
        1436: ldc2_w        #115                // double 0.0d
        1439: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        48
        1444: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        42
        1449: aaload
        1450: astore        49
        1452: ldc2_w        #115                // double 0.0d
        1455: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1458: astore        50
        1460: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1463: bipush        43
        1465: aaload
        1466: astore        51
        1468: ldc2_w        #115                // double 0.0d
        1471: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1474: astore        52
        1476: new           #123                // class ocaml_fn_14
        1479: dup
        1480: invokespecial #124                // Method ocaml_fn_14."<init>":()V
        1483: astore        53
        1485: new           #126                // class ocaml_fn_15
        1488: dup
        1489: aload         18
        1491: invokespecial #129                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1494: astore        54
        1496: new           #131                // class ocaml_fn_16
        1499: dup
        1500: invokespecial #132                // Method ocaml_fn_16."<init>":()V
        1503: astore        55
        1505: new           #134                // class ocaml_fn_17
        1508: dup
        1509: aload         18
        1511: invokespecial #135                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1514: astore        56
        1516: new           #137                // class ocaml_fn_18
        1519: dup
        1520: invokespecial #138                // Method ocaml_fn_18."<init>":()V
        1523: astore        57
        1525: new           #140                // class ocaml_fn_19
        1528: dup
        1529: invokespecial #141                // Method ocaml_fn_19."<init>":()V
        1532: astore        58
        1534: new           #143                // class ocaml_fn_20
        1537: dup
        1538: aload         26
        1540: invokespecial #144                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1543: astore        59
        1545: new           #146                // class ocaml_fn_21
        1548: dup
        1549: aload         53
        1551: invokespecial #147                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1554: astore        60
        1556: new           #149                // class ocaml_fn_22
        1559: dup
        1560: aload         60
        1562: invokespecial #150                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1565: astore        61
        1567: new           #152                // class ocaml_fn_23
        1570: dup
        1571: aload         26
        1573: invokespecial #153                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1576: astore        62
        1578: new           #155                // class ocaml_fn_24
        1581: dup
        1582: invokespecial #156                // Method ocaml_fn_24."<init>":()V
        1585: astore        63
        1587: new           #158                // class ocaml_fn_25
        1590: dup
        1591: invokespecial #159                // Method ocaml_fn_25."<init>":()V
        1594: astore        64
        1596: aload         63
        1598: checkcast     #155                // class ocaml_fn_24
        1601: aload         63
        1603: checkcast     #161                // class Closure
        1606: putfield      #165                // Field ocaml_fn_24.sibling_0:LClosure;
        1609: iconst_0
        1610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1613: astore        65
        1615: aload         63
        1617: checkcast     #155                // class ocaml_fn_24
        1620: aload         64
        1622: checkcast     #161                // class Closure
        1625: putfield      #168                // Field ocaml_fn_24.sibling_1:LClosure;
        1628: iconst_0
        1629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1632: astore        66
        1634: aload         64
        1636: checkcast     #158                // class ocaml_fn_25
        1639: aload         63
        1641: checkcast     #161                // class Closure
        1644: putfield      #169                // Field ocaml_fn_25.sibling_0:LClosure;
        1647: iconst_0
        1648: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1651: astore        67
        1653: aload         64
        1655: checkcast     #158                // class ocaml_fn_25
        1658: aload         64
        1660: checkcast     #161                // class Closure
        1663: putfield      #170                // Field ocaml_fn_25.sibling_1:LClosure;
        1666: iconst_0
        1667: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1670: astore        68
        1672: iconst_0
        1673: istore        69
        1675: aconst_null
        1676: astore        70
        1678: iconst_1
        1679: istore        71
        1681: iload         71
        1683: invokestatic  #176                // Method Channel.forDescriptor:(I)LChannel;
        1686: astore        72
        1688: iconst_2
        1689: istore        73
        1691: iload         73
        1693: invokestatic  #176                // Method Channel.forDescriptor:(I)LChannel;
        1696: astore        74
        1698: new           #178                // class ocaml_fn_26
        1701: dup
        1702: invokespecial #179                // Method ocaml_fn_26."<init>":()V
        1705: astore        75
        1707: new           #181                // class ocaml_fn_27
        1710: dup
        1711: aload         75
        1713: invokespecial #182                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1716: astore        76
        1718: new           #184                // class ocaml_fn_28
        1721: dup
        1722: aload         75
        1724: invokespecial #185                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1727: astore        77
        1729: new           #187                // class ocaml_fn_29
        1732: dup
        1733: aload         30
        1735: invokespecial #188                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1738: astore        78
        1740: new           #190                // class ocaml_fn_30
        1743: dup
        1744: invokespecial #191                // Method ocaml_fn_30."<init>":()V
        1747: astore        79
        1749: new           #193                // class ocaml_fn_31
        1752: dup
        1753: invokespecial #194                // Method ocaml_fn_31."<init>":()V
        1756: astore        80
        1758: new           #196                // class ocaml_fn_32
        1761: dup
        1762: aload         18
        1764: invokespecial #197                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1767: astore        81
        1769: new           #199                // class ocaml_fn_33
        1772: dup
        1773: aload         18
        1775: invokespecial #200                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1778: astore        82
        1780: new           #202                // class ocaml_fn_34
        1783: dup
        1784: invokespecial #203                // Method ocaml_fn_34."<init>":()V
        1787: astore        83
        1789: new           #205                // class ocaml_fn_35
        1792: dup
        1793: invokespecial #206                // Method ocaml_fn_35."<init>":()V
        1796: astore        84
        1798: new           #208                // class ocaml_fn_36
        1801: dup
        1802: invokespecial #209                // Method ocaml_fn_36."<init>":()V
        1805: astore        85
        1807: new           #211                // class ocaml_fn_37
        1810: dup
        1811: invokespecial #212                // Method ocaml_fn_37."<init>":()V
        1814: astore        86
        1816: new           #214                // class ocaml_fn_38
        1819: dup
        1820: aload         86
        1822: invokespecial #215                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1825: astore        87
        1827: new           #217                // class ocaml_fn_39
        1830: dup
        1831: aload         86
        1833: invokespecial #218                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1836: astore        88
        1838: new           #220                // class ocaml_fn_40
        1841: dup
        1842: aload         18
        1844: invokespecial #221                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1847: astore        89
        1849: new           #223                // class ocaml_fn_41
        1852: dup
        1853: aload         31
        1855: invokespecial #224                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1858: astore        90
        1860: new           #226                // class ocaml_fn_42
        1863: dup
        1864: aload         18
        1866: aload         90
        1868: invokespecial #229                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        91
        1873: new           #231                // class ocaml_fn_43
        1876: dup
        1877: aload         91
        1879: invokespecial #232                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1882: astore        92
        1884: new           #234                // class ocaml_fn_44
        1887: dup
        1888: aload         31
        1890: invokespecial #235                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1893: astore        93
        1895: new           #237                // class ocaml_fn_45
        1898: dup
        1899: invokespecial #238                // Method ocaml_fn_45."<init>":()V
        1902: astore        94
        1904: new           #240                // class ocaml_fn_46
        1907: dup
        1908: aload         72
        1910: invokespecial #241                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1913: astore        95
        1915: new           #243                // class ocaml_fn_47
        1918: dup
        1919: aload         72
        1921: aload         80
        1923: invokespecial #244                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        96
        1928: new           #246                // class ocaml_fn_48
        1931: dup
        1932: aload         72
        1934: aload         79
        1936: invokespecial #247                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1939: astore        97
        1941: new           #249                // class ocaml_fn_49
        1944: dup
        1945: aload         58
        1947: aload         72
        1949: aload         80
        1951: invokespecial #252                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1954: astore        98
        1956: new           #254                // class ocaml_fn_50
        1959: dup
        1960: aload         61
        1962: aload         72
        1964: aload         80
        1966: invokespecial #255                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1969: astore        99
        1971: new           #257                // class ocaml_fn_51
        1974: dup
        1975: aload         72
        1977: aload         80
        1979: invokespecial #258                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1982: astore        100
        1984: new           #260                // class ocaml_fn_52
        1987: dup
        1988: aload         72
        1990: invokespecial #261                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1993: astore        101
        1995: new           #263                // class ocaml_fn_53
        1998: dup
        1999: aload         74
        2001: invokespecial #264                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2004: astore        102
        2006: new           #266                // class ocaml_fn_54
        2009: dup
        2010: aload         74
        2012: aload         80
        2014: invokespecial #267                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2017: astore        103
        2019: new           #269                // class ocaml_fn_55
        2022: dup
        2023: aload         74
        2025: aload         79
        2027: invokespecial #270                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        104
        2032: new           #272                // class ocaml_fn_56
        2035: dup
        2036: aload         58
        2038: aload         74
        2040: aload         80
        2042: invokespecial #273                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2045: astore        105
        2047: new           #275                // class ocaml_fn_57
        2050: dup
        2051: aload         61
        2053: aload         74
        2055: aload         80
        2057: invokespecial #276                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        106
        2062: new           #278                // class ocaml_fn_58
        2065: dup
        2066: aload         74
        2068: aload         80
        2070: invokespecial #279                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        107
        2075: new           #281                // class ocaml_fn_59
        2078: dup
        2079: aload         74
        2081: invokespecial #282                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2084: astore        108
        2086: new           #284                // class ocaml_fn_60
        2089: dup
        2090: aload         70
        2092: aload         72
        2094: aload         93
        2096: invokespecial #285                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        109
        2101: new           #287                // class ocaml_fn_61
        2104: dup
        2105: aload         109
        2107: invokespecial #288                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2110: astore        110
        2112: new           #290                // class ocaml_fn_62
        2115: dup
        2116: aload         59
        2118: aload         109
        2120: invokespecial #291                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2123: astore        111
        2125: new           #293                // class ocaml_fn_63
        2128: dup
        2129: aload         109
        2131: invokespecial #294                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2134: astore        112
        2136: new           #296                // class ocaml_fn_64
        2139: dup
        2140: aload         62
        2142: aload         109
        2144: invokespecial #297                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        113
        2149: new           #299                // class ocaml_fn_65
        2152: dup
        2153: invokespecial #300                // Method ocaml_fn_65."<init>":()V
        2156: astore        114
        2158: new           #302                // class ocaml_fn_66
        2161: dup
        2162: aload         53
        2164: invokespecial #303                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2167: astore        115
        2169: new           #10                 // class Block
        2172: dup
        2173: iconst_0
        2174: iconst_1
        2175: anewarray     #2                  // class java/lang/Object
        2178: dup
        2179: iconst_0
        2180: aload         78
        2182: aastore
        2183: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2186: astore        116
        2188: new           #305                // class ocaml_fn_67
        2191: dup
        2192: aload         116
        2194: invokespecial #306                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2197: astore        117
        2199: new           #308                // class ocaml_fn_68
        2202: dup
        2203: invokespecial #309                // Method ocaml_fn_68."<init>":()V
        2206: astore        118
        2208: new           #10                 // class Block
        2211: dup
        2212: iconst_0
        2213: iconst_1
        2214: anewarray     #2                  // class java/lang/Object
        2217: dup
        2218: iconst_0
        2219: aload         118
        2221: aastore
        2222: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2225: astore        119
        2227: new           #311                // class ocaml_fn_69
        2230: dup
        2231: aload         116
        2233: aload         119
        2235: invokespecial #312                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2238: astore        120
        2240: new           #314                // class ocaml_fn_70
        2243: dup
        2244: aload         120
        2246: invokespecial #315                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2249: astore        121
        2251: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2254: bipush        44
        2256: aaload
        2257: astore        122
        2259: iconst_0
        2260: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2263: astore        123
        2265: new           #317                // class ocaml_fn_71
        2268: dup
        2269: invokespecial #318                // Method ocaml_fn_71."<init>":()V
        2272: astore        124
        2274: new           #320                // class ocaml_fn_72
        2277: dup
        2278: invokespecial #321                // Method ocaml_fn_72."<init>":()V
        2281: astore        125
        2283: new           #323                // class ocaml_fn_73
        2286: dup
        2287: invokespecial #324                // Method ocaml_fn_73."<init>":()V
        2290: astore        126
        2292: new           #326                // class ocaml_fn_74
        2295: dup
        2296: invokespecial #327                // Method ocaml_fn_74."<init>":()V
        2299: astore        127
        2301: new           #329                // class ocaml_fn_75
        2304: dup
        2305: invokespecial #330                // Method ocaml_fn_75."<init>":()V
        2308: astore        128
        2310: new           #332                // class ocaml_fn_76
        2313: dup
        2314: invokespecial #333                // Method ocaml_fn_76."<init>":()V
        2317: astore        129
        2319: new           #10                 // class Block
        2322: dup
        2323: iconst_0
        2324: bipush        6
        2326: anewarray     #2                  // class java/lang/Object
        2329: dup
        2330: iconst_0
        2331: aload         129
        2333: aastore
        2334: dup
        2335: iconst_1
        2336: aload         128
        2338: aastore
        2339: dup
        2340: iconst_2
        2341: aload         127
        2343: aastore
        2344: dup
        2345: iconst_3
        2346: aload         126
        2348: aastore
        2349: dup
        2350: iconst_4
        2351: aload         125
        2353: aastore
        2354: dup
        2355: iconst_5
        2356: aload         124
        2358: aastore
        2359: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2362: astore        130
        2364: new           #335                // class ocaml_fn_77
        2367: dup
        2368: invokespecial #336                // Method ocaml_fn_77."<init>":()V
        2371: astore        131
        2373: new           #338                // class ocaml_fn_78
        2376: dup
        2377: invokespecial #339                // Method ocaml_fn_78."<init>":()V
        2380: astore        132
        2382: new           #341                // class ocaml_fn_79
        2385: dup
        2386: invokespecial #342                // Method ocaml_fn_79."<init>":()V
        2389: astore        133
        2391: new           #344                // class ocaml_fn_80
        2394: dup
        2395: invokespecial #345                // Method ocaml_fn_80."<init>":()V
        2398: astore        134
        2400: new           #347                // class ocaml_fn_81
        2403: dup
        2404: invokespecial #348                // Method ocaml_fn_81."<init>":()V
        2407: astore        135
        2409: new           #350                // class ocaml_fn_82
        2412: dup
        2413: invokespecial #351                // Method ocaml_fn_82."<init>":()V
        2416: astore        136
        2418: new           #353                // class ocaml_fn_83
        2421: dup
        2422: invokespecial #354                // Method ocaml_fn_83."<init>":()V
        2425: astore        137
        2427: new           #356                // class ocaml_fn_84
        2430: dup
        2431: invokespecial #357                // Method ocaml_fn_84."<init>":()V
        2434: astore        138
        2436: new           #359                // class ocaml_fn_85
        2439: dup
        2440: invokespecial #360                // Method ocaml_fn_85."<init>":()V
        2443: astore        139
        2445: new           #362                // class ocaml_fn_86
        2448: dup
        2449: invokespecial #363                // Method ocaml_fn_86."<init>":()V
        2452: astore        140
        2454: new           #365                // class ocaml_fn_87
        2457: dup
        2458: invokespecial #366                // Method ocaml_fn_87."<init>":()V
        2461: astore        141
        2463: new           #368                // class ocaml_fn_88
        2466: dup
        2467: invokespecial #369                // Method ocaml_fn_88."<init>":()V
        2470: astore        142
        2472: new           #371                // class ocaml_fn_89
        2475: dup
        2476: invokespecial #372                // Method ocaml_fn_89."<init>":()V
        2479: astore        143
        2481: new           #374                // class ocaml_fn_90
        2484: dup
        2485: invokespecial #375                // Method ocaml_fn_90."<init>":()V
        2488: astore        144
        2490: new           #377                // class ocaml_fn_91
        2493: dup
        2494: invokespecial #378                // Method ocaml_fn_91."<init>":()V
        2497: astore        145
        2499: new           #380                // class ocaml_fn_92
        2502: dup
        2503: invokespecial #381                // Method ocaml_fn_92."<init>":()V
        2506: astore        146
        2508: new           #383                // class ocaml_fn_93
        2511: dup
        2512: invokespecial #384                // Method ocaml_fn_93."<init>":()V
        2515: astore        147
        2517: new           #10                 // class Block
        2520: dup
        2521: iconst_0
        2522: bipush        104
        2524: anewarray     #2                  // class java/lang/Object
        2527: dup
        2528: iconst_0
        2529: aload         18
        2531: aastore
        2532: dup
        2533: iconst_1
        2534: aload         17
        2536: aastore
        2537: dup
        2538: iconst_2
        2539: aload         22
        2541: aastore
        2542: dup
        2543: iconst_3
        2544: aload         23
        2546: aastore
        2547: dup
        2548: iconst_4
        2549: aload         24
        2551: aastore
        2552: dup
        2553: iconst_5
        2554: aload         25
        2556: aastore
        2557: dup
        2558: bipush        6
        2560: aload         26
        2562: aastore
        2563: dup
        2564: bipush        7
        2566: aload         27
        2568: aastore
        2569: dup
        2570: bipush        8
        2572: aload         28
        2574: aastore
        2575: dup
        2576: bipush        9
        2578: aload         29
        2580: aastore
        2581: dup
        2582: bipush        10
        2584: aload         30
        2586: aastore
        2587: dup
        2588: bipush        11
        2590: aload         31
        2592: aastore
        2593: dup
        2594: bipush        12
        2596: aload         32
        2598: aastore
        2599: dup
        2600: bipush        13
        2602: aload         33
        2604: aastore
        2605: dup
        2606: bipush        14
        2608: aload         34
        2610: aastore
        2611: dup
        2612: bipush        15
        2614: aload         35
        2616: aastore
        2617: dup
        2618: bipush        16
        2620: aload         36
        2622: aastore
        2623: dup
        2624: bipush        17
        2626: aload         37
        2628: aastore
        2629: dup
        2630: bipush        18
        2632: iload         39
        2634: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2637: aastore
        2638: dup
        2639: bipush        19
        2641: iload         40
        2643: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2646: aastore
        2647: dup
        2648: bipush        20
        2650: aload         38
        2652: aastore
        2653: dup
        2654: bipush        21
        2656: aload         42
        2658: aastore
        2659: dup
        2660: bipush        22
        2662: aload         44
        2664: aastore
        2665: dup
        2666: bipush        23
        2668: aload         46
        2670: aastore
        2671: dup
        2672: bipush        24
        2674: aload         48
        2676: aastore
        2677: dup
        2678: bipush        25
        2680: aload         50
        2682: aastore
        2683: dup
        2684: bipush        26
        2686: aload         52
        2688: aastore
        2689: dup
        2690: bipush        27
        2692: aload         53
        2694: aastore
        2695: dup
        2696: bipush        28
        2698: aload         54
        2700: aastore
        2701: dup
        2702: bipush        29
        2704: aload         55
        2706: aastore
        2707: dup
        2708: bipush        30
        2710: aload         57
        2712: aastore
        2713: dup
        2714: bipush        31
        2716: aload         56
        2718: aastore
        2719: dup
        2720: bipush        32
        2722: aload         58
        2724: aastore
        2725: dup
        2726: bipush        33
        2728: aload         59
        2730: aastore
        2731: dup
        2732: bipush        34
        2734: aload         61
        2736: aastore
        2737: dup
        2738: bipush        35
        2740: aload         62
        2742: aastore
        2743: dup
        2744: bipush        36
        2746: aload         63
        2748: aastore
        2749: dup
        2750: bipush        37
        2752: aload         70
        2754: aastore
        2755: dup
        2756: bipush        38
        2758: aload         72
        2760: aastore
        2761: dup
        2762: bipush        39
        2764: aload         74
        2766: aastore
        2767: dup
        2768: bipush        40
        2770: aload         95
        2772: aastore
        2773: dup
        2774: bipush        41
        2776: aload         96
        2778: aastore
        2779: dup
        2780: bipush        42
        2782: aload         97
        2784: aastore
        2785: dup
        2786: bipush        43
        2788: aload         98
        2790: aastore
        2791: dup
        2792: bipush        44
        2794: aload         99
        2796: aastore
        2797: dup
        2798: bipush        45
        2800: aload         100
        2802: aastore
        2803: dup
        2804: bipush        46
        2806: aload         101
        2808: aastore
        2809: dup
        2810: bipush        47
        2812: aload         102
        2814: aastore
        2815: dup
        2816: bipush        48
        2818: aload         103
        2820: aastore
        2821: dup
        2822: bipush        49
        2824: aload         104
        2826: aastore
        2827: dup
        2828: bipush        50
        2830: aload         105
        2832: aastore
        2833: dup
        2834: bipush        51
        2836: aload         106
        2838: aastore
        2839: dup
        2840: bipush        52
        2842: aload         107
        2844: aastore
        2845: dup
        2846: bipush        53
        2848: aload         108
        2850: aastore
        2851: dup
        2852: bipush        54
        2854: aload         109
        2856: aastore
        2857: dup
        2858: bipush        55
        2860: aload         111
        2862: aastore
        2863: dup
        2864: bipush        56
        2866: aload         110
        2868: aastore
        2869: dup
        2870: bipush        57
        2872: aload         113
        2874: aastore
        2875: dup
        2876: bipush        58
        2878: aload         112
        2880: aastore
        2881: dup
        2882: bipush        59
        2884: aload         76
        2886: aastore
        2887: dup
        2888: bipush        60
        2890: aload         77
        2892: aastore
        2893: dup
        2894: bipush        61
        2896: aload         75
        2898: aastore
        2899: dup
        2900: bipush        62
        2902: aload         147
        2904: aastore
        2905: dup
        2906: bipush        63
        2908: aload         78
        2910: aastore
        2911: dup
        2912: bipush        64
        2914: aload         146
        2916: aastore
        2917: dup
        2918: bipush        65
        2920: aload         80
        2922: aastore
        2923: dup
        2924: bipush        66
        2926: aload         79
        2928: aastore
        2929: dup
        2930: bipush        67
        2932: aload         81
        2934: aastore
        2935: dup
        2936: bipush        68
        2938: aload         82
        2940: aastore
        2941: dup
        2942: bipush        69
        2944: aload         145
        2946: aastore
        2947: dup
        2948: bipush        70
        2950: aload         144
        2952: aastore
        2953: dup
        2954: bipush        71
        2956: aload         83
        2958: aastore
        2959: dup
        2960: bipush        72
        2962: aload         143
        2964: aastore
        2965: dup
        2966: bipush        73
        2968: aload         142
        2970: aastore
        2971: dup
        2972: bipush        74
        2974: aload         141
        2976: aastore
        2977: dup
        2978: bipush        75
        2980: aload         84
        2982: aastore
        2983: dup
        2984: bipush        76
        2986: aload         85
        2988: aastore
        2989: dup
        2990: bipush        77
        2992: aload         140
        2994: aastore
        2995: dup
        2996: bipush        78
        2998: aload         87
        3000: aastore
        3001: dup
        3002: bipush        79
        3004: aload         88
        3006: aastore
        3007: dup
        3008: bipush        80
        3010: aload         86
        3012: aastore
        3013: dup
        3014: bipush        81
        3016: aload         139
        3018: aastore
        3019: dup
        3020: bipush        82
        3022: aload         93
        3024: aastore
        3025: dup
        3026: bipush        83
        3028: aload         89
        3030: aastore
        3031: dup
        3032: bipush        84
        3034: aload         91
        3036: aastore
        3037: dup
        3038: bipush        85
        3040: aload         92
        3042: aastore
        3043: dup
        3044: bipush        86
        3046: aload         138
        3048: aastore
        3049: dup
        3050: bipush        87
        3052: aload         137
        3054: aastore
        3055: dup
        3056: bipush        88
        3058: aload         136
        3060: aastore
        3061: dup
        3062: bipush        89
        3064: aload         135
        3066: aastore
        3067: dup
        3068: bipush        90
        3070: aload         134
        3072: aastore
        3073: dup
        3074: bipush        91
        3076: aload         133
        3078: aastore
        3079: dup
        3080: bipush        92
        3082: aload         132
        3084: aastore
        3085: dup
        3086: bipush        93
        3088: aload         94
        3090: aastore
        3091: dup
        3092: bipush        94
        3094: aload         131
        3096: aastore
        3097: dup
        3098: bipush        95
        3100: aload         130
        3102: aastore
        3103: dup
        3104: bipush        96
        3106: aload         114
        3108: aastore
        3109: dup
        3110: bipush        97
        3112: aload         115
        3114: aastore
        3115: dup
        3116: bipush        98
        3118: aload         121
        3120: aastore
        3121: dup
        3122: bipush        99
        3124: aload         117
        3126: aastore
        3127: dup
        3128: bipush        100
        3130: aload         60
        3132: aastore
        3133: dup
        3134: bipush        101
        3136: aload         90
        3138: aastore
        3139: dup
        3140: bipush        102
        3142: aload         120
        3144: aastore
        3145: dup
        3146: bipush        103
        3148: aload         119
        3150: aastore
        3151: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3154: astore        148
        3156: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        45
        3161: aload         148
        3163: aastore
        3164: iconst_0
        3165: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3168: astore        149
        3170: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3173: bipush        46
        3175: aaload
        3176: astore        150
        3178: getstatic     #390                // Field java/lang/System.out:Ljava/io/PrintStream;
        3181: aload         150
        3183: checkcast     #392                // class java/lang/String
        3186: invokevirtual #398                // Method java/io/PrintStream.println:(Ljava/lang/String;)V
        3189: iconst_0
        3190: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3193: astore        151
        3195: new           #10                 // class Block
        3198: dup
        3199: iconst_0
        3200: iconst_0
        3201: anewarray     #2                  // class java/lang/Object
        3204: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3207: astore        152
        3209: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3212: bipush        47
        3214: aload         152
        3216: aastore
        3217: iconst_0
        3218: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3221: astore        153
        3223: iconst_0
        3224: istore        154
        3226: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3229: bipush        45
        3231: aaload
        3232: checkcast     #10                 // class Block
        3235: getfield      #401                // Field Block.fields:[Ljava/lang/Object;
        3238: bipush        102
        3240: aaload
        3241: astore        155
        3243: aload         155
        3245: checkcast     #161                // class Closure
        3248: iload         154
        3250: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3253: invokevirtual #405                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3256: astore        156
        3258: new           #10                 // class Block
        3261: dup
        3262: iconst_0
        3263: iconst_0
        3264: anewarray     #2                  // class java/lang/Object
        3267: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3270: astore        157
        3272: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3275: bipush        48
        3277: aload         157
        3279: aastore
        3280: iconst_0
        3281: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3284: astore        158
        3286: return
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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: iconst_0
        1007: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1010: aastore
        1011: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        47
        1016: iconst_0
        1017: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1020: aastore
        1021: aconst_null
        1022: astore_1
        1023: aload_1
        1024: astore_2
        1025: goto_w        1030
        1030: new           #83                 // class ocaml_fn_0
        1033: dup
        1034: invokespecial #86                 // Method ocaml_fn_0."<init>":()V
        1037: astore_3
        1038: new           #88                 // class ocaml_fn_1
        1041: dup
        1042: invokespecial #89                 // Method ocaml_fn_1."<init>":()V
        1045: astore        4
        1047: new           #91                 // class ocaml_fn_2
        1050: dup
        1051: invokespecial #92                 // Method ocaml_fn_2."<init>":()V
        1054: astore        5
        1056: new           #10                 // class Block
        1059: dup
        1060: iconst_0
        1061: iconst_3
        1062: anewarray     #2                  // class java/lang/Object
        1065: dup
        1066: iconst_0
        1067: aload         4
        1069: aastore
        1070: dup
        1071: iconst_1
        1072: aload_3
        1073: aastore
        1074: dup
        1075: iconst_2
        1076: aload         5
        1078: aastore
        1079: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1082: astore        6
        1084: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1087: bipush        12
        1089: aload         6
        1091: aastore
        1092: iconst_0
        1093: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1096: astore        7
        1098: iconst_0
        1099: istore        8
        1101: iload         8
        1103: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1106: astore        9
        1108: goto_w        1113
        1113: sipush        199
        1116: istore        10
        1118: iconst_0
        1119: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1122: astore        11
        1124: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        35
        1129: aaload
        1130: astore        12
        1132: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1135: iconst_3
        1136: aaload
        1137: astore        13
        1139: new           #10                 // class Block
        1142: dup
        1143: iconst_0
        1144: iconst_2
        1145: anewarray     #2                  // class java/lang/Object
        1148: dup
        1149: iconst_0
        1150: aload         13
        1152: aastore
        1153: dup
        1154: iconst_1
        1155: aload         12
        1157: aastore
        1158: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1161: astore        14
        1163: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1166: bipush        36
        1168: aaload
        1169: astore        15
        1171: iconst_0
        1172: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1175: astore        16
        1177: new           #94                 // class ocaml_fn_8
        1180: dup
        1181: invokespecial #95                 // Method ocaml_fn_8."<init>":()V
        1184: astore        17
        1186: new           #97                 // class ocaml_fn_9
        1189: dup
        1190: invokespecial #98                 // Method ocaml_fn_9."<init>":()V
        1193: astore        18
        1195: iconst_0
        1196: istore        19
        1198: iconst_0
        1199: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1202: astore        20
        1204: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1207: bipush        37
        1209: aaload
        1210: astore        21
        1212: new           #10                 // class Block
        1215: dup
        1216: sipush        248
        1219: iconst_2
        1220: anewarray     #2                  // class java/lang/Object
        1223: dup
        1224: iconst_0
        1225: aload         21
        1227: aastore
        1228: dup
        1229: iconst_1
        1230: aload         20
        1232: aastore
        1233: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1236: astore        22
        1238: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        7
        1243: aaload
        1244: astore        23
        1246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        10
        1251: aaload
        1252: astore        24
        1254: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1257: iconst_3
        1258: aaload
        1259: astore        25
        1261: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1264: iconst_2
        1265: aaload
        1266: astore        26
        1268: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1271: bipush        6
        1273: aaload
        1274: astore        27
        1276: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1279: iconst_0
        1280: aaload
        1281: astore        28
        1283: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1286: bipush        8
        1288: aaload
        1289: astore        29
        1291: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1294: iconst_1
        1295: aaload
        1296: astore        30
        1298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1301: iconst_4
        1302: aaload
        1303: astore        31
        1305: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1308: iconst_5
        1309: aaload
        1310: astore        32
        1312: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1315: bipush        9
        1317: aaload
        1318: astore        33
        1320: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        11
        1325: aaload
        1326: astore        34
        1328: new           #100                // class ocaml_fn_10
        1331: dup
        1332: invokespecial #101                // Method ocaml_fn_10."<init>":()V
        1335: astore        35
        1337: new           #103                // class ocaml_fn_11
        1340: dup
        1341: invokespecial #104                // Method ocaml_fn_11."<init>":()V
        1344: astore        36
        1346: new           #106                // class ocaml_fn_12
        1349: dup
        1350: invokespecial #107                // Method ocaml_fn_12."<init>":()V
        1353: astore        37
        1355: new           #109                // class ocaml_fn_13
        1358: dup
        1359: invokespecial #110                // Method ocaml_fn_13."<init>":()V
        1362: astore        38
        1364: ldc           #111                // int 2147483647
        1366: istore        39
        1368: ldc           #112                // int -2147483648
        1370: istore        40
        1372: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1375: bipush        38
        1377: aaload
        1378: astore        41
        1380: ldc2_w        #113                // double 0.0d
        1383: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1386: astore        42
        1388: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1391: bipush        39
        1393: aaload
        1394: astore        43
        1396: ldc2_w        #113                // double 0.0d
        1399: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1402: astore        44
        1404: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1407: bipush        40
        1409: aaload
        1410: astore        45
        1412: ldc2_w        #113                // double 0.0d
        1415: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1418: astore        46
        1420: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        41
        1425: aaload
        1426: astore        47
        1428: ldc2_w        #113                // double 0.0d
        1431: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        48
        1436: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        42
        1441: aaload
        1442: astore        49
        1444: ldc2_w        #113                // double 0.0d
        1447: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        50
        1452: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        43
        1457: aaload
        1458: astore        51
        1460: ldc2_w        #113                // double 0.0d
        1463: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        52
        1468: new           #121                // class ocaml_fn_14
        1471: dup
        1472: invokespecial #122                // Method ocaml_fn_14."<init>":()V
        1475: astore        53
        1477: new           #124                // class ocaml_fn_15
        1480: dup
        1481: aload         18
        1483: invokespecial #127                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1486: astore        54
        1488: new           #129                // class ocaml_fn_16
        1491: dup
        1492: invokespecial #130                // Method ocaml_fn_16."<init>":()V
        1495: astore        55
        1497: new           #132                // class ocaml_fn_17
        1500: dup
        1501: aload         18
        1503: invokespecial #133                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1506: astore        56
        1508: new           #135                // class ocaml_fn_18
        1511: dup
        1512: invokespecial #136                // Method ocaml_fn_18."<init>":()V
        1515: astore        57
        1517: new           #138                // class ocaml_fn_19
        1520: dup
        1521: invokespecial #139                // Method ocaml_fn_19."<init>":()V
        1524: astore        58
        1526: new           #141                // class ocaml_fn_20
        1529: dup
        1530: aload         26
        1532: invokespecial #142                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1535: astore        59
        1537: new           #144                // class ocaml_fn_21
        1540: dup
        1541: aload         53
        1543: invokespecial #145                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1546: astore        60
        1548: new           #147                // class ocaml_fn_22
        1551: dup
        1552: aload         60
        1554: invokespecial #148                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1557: astore        61
        1559: new           #150                // class ocaml_fn_23
        1562: dup
        1563: aload         26
        1565: invokespecial #151                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1568: astore        62
        1570: new           #153                // class ocaml_fn_24
        1573: dup
        1574: invokespecial #154                // Method ocaml_fn_24."<init>":()V
        1577: astore        63
        1579: new           #156                // class ocaml_fn_25
        1582: dup
        1583: invokespecial #157                // Method ocaml_fn_25."<init>":()V
        1586: astore        64
        1588: aload         63
        1590: checkcast     #153                // class ocaml_fn_24
        1593: aload         63
        1595: checkcast     #159                // class Closure
        1598: putfield      #163                // Field ocaml_fn_24.sibling_0:LClosure;
        1601: iconst_0
        1602: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1605: astore        65
        1607: aload         63
        1609: checkcast     #153                // class ocaml_fn_24
        1612: aload         64
        1614: checkcast     #159                // class Closure
        1617: putfield      #166                // Field ocaml_fn_24.sibling_1:LClosure;
        1620: iconst_0
        1621: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1624: astore        66
        1626: aload         64
        1628: checkcast     #156                // class ocaml_fn_25
        1631: aload         63
        1633: checkcast     #159                // class Closure
        1636: putfield      #167                // Field ocaml_fn_25.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        67
        1645: aload         64
        1647: checkcast     #156                // class ocaml_fn_25
        1650: aload         64
        1652: checkcast     #159                // class Closure
        1655: putfield      #168                // Field ocaml_fn_25.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        68
        1664: iconst_0
        1665: istore        69
        1667: aconst_null
        1668: astore        70
        1670: iconst_1
        1671: istore        71
        1673: iload         71
        1675: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1678: astore        72
        1680: iconst_2
        1681: istore        73
        1683: iload         73
        1685: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1688: astore        74
        1690: new           #176                // class ocaml_fn_26
        1693: dup
        1694: invokespecial #177                // Method ocaml_fn_26."<init>":()V
        1697: astore        75
        1699: new           #179                // class ocaml_fn_27
        1702: dup
        1703: aload         75
        1705: invokespecial #180                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1708: astore        76
        1710: new           #182                // class ocaml_fn_28
        1713: dup
        1714: aload         75
        1716: invokespecial #183                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1719: astore        77
        1721: new           #185                // class ocaml_fn_29
        1724: dup
        1725: aload         30
        1727: invokespecial #186                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1730: astore        78
        1732: new           #188                // class ocaml_fn_30
        1735: dup
        1736: invokespecial #189                // Method ocaml_fn_30."<init>":()V
        1739: astore        79
        1741: new           #191                // class ocaml_fn_31
        1744: dup
        1745: invokespecial #192                // Method ocaml_fn_31."<init>":()V
        1748: astore        80
        1750: new           #194                // class ocaml_fn_32
        1753: dup
        1754: aload         18
        1756: invokespecial #195                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1759: astore        81
        1761: new           #197                // class ocaml_fn_33
        1764: dup
        1765: aload         18
        1767: invokespecial #198                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1770: astore        82
        1772: new           #200                // class ocaml_fn_34
        1775: dup
        1776: invokespecial #201                // Method ocaml_fn_34."<init>":()V
        1779: astore        83
        1781: new           #203                // class ocaml_fn_35
        1784: dup
        1785: invokespecial #204                // Method ocaml_fn_35."<init>":()V
        1788: astore        84
        1790: new           #206                // class ocaml_fn_36
        1793: dup
        1794: invokespecial #207                // Method ocaml_fn_36."<init>":()V
        1797: astore        85
        1799: new           #209                // class ocaml_fn_37
        1802: dup
        1803: invokespecial #210                // Method ocaml_fn_37."<init>":()V
        1806: astore        86
        1808: new           #212                // class ocaml_fn_38
        1811: dup
        1812: aload         86
        1814: invokespecial #213                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1817: astore        87
        1819: new           #215                // class ocaml_fn_39
        1822: dup
        1823: aload         86
        1825: invokespecial #216                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1828: astore        88
        1830: new           #218                // class ocaml_fn_40
        1833: dup
        1834: aload         18
        1836: invokespecial #219                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1839: astore        89
        1841: new           #221                // class ocaml_fn_41
        1844: dup
        1845: aload         31
        1847: invokespecial #222                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1850: astore        90
        1852: new           #224                // class ocaml_fn_42
        1855: dup
        1856: aload         18
        1858: aload         90
        1860: invokespecial #227                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1863: astore        91
        1865: new           #229                // class ocaml_fn_43
        1868: dup
        1869: aload         91
        1871: invokespecial #230                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1874: astore        92
        1876: new           #232                // class ocaml_fn_44
        1879: dup
        1880: aload         31
        1882: invokespecial #233                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1885: astore        93
        1887: new           #235                // class ocaml_fn_45
        1890: dup
        1891: invokespecial #236                // Method ocaml_fn_45."<init>":()V
        1894: astore        94
        1896: new           #238                // class ocaml_fn_46
        1899: dup
        1900: aload         72
        1902: invokespecial #239                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1905: astore        95
        1907: new           #241                // class ocaml_fn_47
        1910: dup
        1911: aload         72
        1913: aload         80
        1915: invokespecial #242                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1918: astore        96
        1920: new           #244                // class ocaml_fn_48
        1923: dup
        1924: aload         72
        1926: aload         79
        1928: invokespecial #245                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1931: astore        97
        1933: new           #247                // class ocaml_fn_49
        1936: dup
        1937: aload         58
        1939: aload         72
        1941: aload         80
        1943: invokespecial #250                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1946: astore        98
        1948: new           #252                // class ocaml_fn_50
        1951: dup
        1952: aload         61
        1954: aload         72
        1956: aload         80
        1958: invokespecial #253                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1961: astore        99
        1963: new           #255                // class ocaml_fn_51
        1966: dup
        1967: aload         72
        1969: aload         80
        1971: invokespecial #256                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1974: astore        100
        1976: new           #258                // class ocaml_fn_52
        1979: dup
        1980: aload         72
        1982: invokespecial #259                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1985: astore        101
        1987: new           #261                // class ocaml_fn_53
        1990: dup
        1991: aload         74
        1993: invokespecial #262                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1996: astore        102
        1998: new           #264                // class ocaml_fn_54
        2001: dup
        2002: aload         74
        2004: aload         80
        2006: invokespecial #265                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2009: astore        103
        2011: new           #267                // class ocaml_fn_55
        2014: dup
        2015: aload         74
        2017: aload         79
        2019: invokespecial #268                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2022: astore        104
        2024: new           #270                // class ocaml_fn_56
        2027: dup
        2028: aload         58
        2030: aload         74
        2032: aload         80
        2034: invokespecial #271                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2037: astore        105
        2039: new           #273                // class ocaml_fn_57
        2042: dup
        2043: aload         61
        2045: aload         74
        2047: aload         80
        2049: invokespecial #274                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        106
        2054: new           #276                // class ocaml_fn_58
        2057: dup
        2058: aload         74
        2060: aload         80
        2062: invokespecial #277                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2065: astore        107
        2067: new           #279                // class ocaml_fn_59
        2070: dup
        2071: aload         74
        2073: invokespecial #280                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2076: astore        108
        2078: new           #282                // class ocaml_fn_60
        2081: dup
        2082: aload         70
        2084: aload         72
        2086: aload         93
        2088: invokespecial #283                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        109
        2093: new           #285                // class ocaml_fn_61
        2096: dup
        2097: aload         109
        2099: invokespecial #286                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2102: astore        110
        2104: new           #288                // class ocaml_fn_62
        2107: dup
        2108: aload         59
        2110: aload         109
        2112: invokespecial #289                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2115: astore        111
        2117: new           #291                // class ocaml_fn_63
        2120: dup
        2121: aload         109
        2123: invokespecial #292                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2126: astore        112
        2128: new           #294                // class ocaml_fn_64
        2131: dup
        2132: aload         62
        2134: aload         109
        2136: invokespecial #295                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2139: astore        113
        2141: new           #297                // class ocaml_fn_65
        2144: dup
        2145: invokespecial #298                // Method ocaml_fn_65."<init>":()V
        2148: astore        114
        2150: new           #300                // class ocaml_fn_66
        2153: dup
        2154: aload         53
        2156: invokespecial #301                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2159: astore        115
        2161: new           #10                 // class Block
        2164: dup
        2165: iconst_0
        2166: iconst_1
        2167: anewarray     #2                  // class java/lang/Object
        2170: dup
        2171: iconst_0
        2172: aload         78
        2174: aastore
        2175: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2178: astore        116
        2180: new           #303                // class ocaml_fn_67
        2183: dup
        2184: aload         116
        2186: invokespecial #304                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2189: astore        117
        2191: new           #306                // class ocaml_fn_68
        2194: dup
        2195: invokespecial #307                // Method ocaml_fn_68."<init>":()V
        2198: astore        118
        2200: new           #10                 // class Block
        2203: dup
        2204: iconst_0
        2205: iconst_1
        2206: anewarray     #2                  // class java/lang/Object
        2209: dup
        2210: iconst_0
        2211: aload         118
        2213: aastore
        2214: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2217: astore        119
        2219: new           #309                // class ocaml_fn_69
        2222: dup
        2223: aload         116
        2225: aload         119
        2227: invokespecial #310                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2230: astore        120
        2232: new           #312                // class ocaml_fn_70
        2235: dup
        2236: aload         120
        2238: invokespecial #313                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2241: astore        121
        2243: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2246: bipush        44
        2248: aaload
        2249: astore        122
        2251: iconst_0
        2252: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2255: astore        123
        2257: new           #315                // class ocaml_fn_71
        2260: dup
        2261: invokespecial #316                // Method ocaml_fn_71."<init>":()V
        2264: astore        124
        2266: new           #318                // class ocaml_fn_72
        2269: dup
        2270: invokespecial #319                // Method ocaml_fn_72."<init>":()V
        2273: astore        125
        2275: new           #321                // class ocaml_fn_73
        2278: dup
        2279: invokespecial #322                // Method ocaml_fn_73."<init>":()V
        2282: astore        126
        2284: new           #324                // class ocaml_fn_74
        2287: dup
        2288: invokespecial #325                // Method ocaml_fn_74."<init>":()V
        2291: astore        127
        2293: new           #327                // class ocaml_fn_75
        2296: dup
        2297: invokespecial #328                // Method ocaml_fn_75."<init>":()V
        2300: astore        128
        2302: new           #330                // class ocaml_fn_76
        2305: dup
        2306: invokespecial #331                // Method ocaml_fn_76."<init>":()V
        2309: astore        129
        2311: new           #10                 // class Block
        2314: dup
        2315: iconst_0
        2316: bipush        6
        2318: anewarray     #2                  // class java/lang/Object
        2321: dup
        2322: iconst_0
        2323: aload         129
        2325: aastore
        2326: dup
        2327: iconst_1
        2328: aload         128
        2330: aastore
        2331: dup
        2332: iconst_2
        2333: aload         127
        2335: aastore
        2336: dup
        2337: iconst_3
        2338: aload         126
        2340: aastore
        2341: dup
        2342: iconst_4
        2343: aload         125
        2345: aastore
        2346: dup
        2347: iconst_5
        2348: aload         124
        2350: aastore
        2351: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2354: astore        130
        2356: new           #333                // class ocaml_fn_77
        2359: dup
        2360: invokespecial #334                // Method ocaml_fn_77."<init>":()V
        2363: astore        131
        2365: new           #336                // class ocaml_fn_78
        2368: dup
        2369: invokespecial #337                // Method ocaml_fn_78."<init>":()V
        2372: astore        132
        2374: new           #339                // class ocaml_fn_79
        2377: dup
        2378: invokespecial #340                // Method ocaml_fn_79."<init>":()V
        2381: astore        133
        2383: new           #342                // class ocaml_fn_80
        2386: dup
        2387: invokespecial #343                // Method ocaml_fn_80."<init>":()V
        2390: astore        134
        2392: new           #345                // class ocaml_fn_81
        2395: dup
        2396: invokespecial #346                // Method ocaml_fn_81."<init>":()V
        2399: astore        135
        2401: new           #348                // class ocaml_fn_82
        2404: dup
        2405: invokespecial #349                // Method ocaml_fn_82."<init>":()V
        2408: astore        136
        2410: new           #351                // class ocaml_fn_83
        2413: dup
        2414: invokespecial #352                // Method ocaml_fn_83."<init>":()V
        2417: astore        137
        2419: new           #354                // class ocaml_fn_84
        2422: dup
        2423: invokespecial #355                // Method ocaml_fn_84."<init>":()V
        2426: astore        138
        2428: new           #357                // class ocaml_fn_85
        2431: dup
        2432: invokespecial #358                // Method ocaml_fn_85."<init>":()V
        2435: astore        139
        2437: new           #360                // class ocaml_fn_86
        2440: dup
        2441: invokespecial #361                // Method ocaml_fn_86."<init>":()V
        2444: astore        140
        2446: new           #363                // class ocaml_fn_87
        2449: dup
        2450: invokespecial #364                // Method ocaml_fn_87."<init>":()V
        2453: astore        141
        2455: new           #366                // class ocaml_fn_88
        2458: dup
        2459: invokespecial #367                // Method ocaml_fn_88."<init>":()V
        2462: astore        142
        2464: new           #369                // class ocaml_fn_89
        2467: dup
        2468: invokespecial #370                // Method ocaml_fn_89."<init>":()V
        2471: astore        143
        2473: new           #372                // class ocaml_fn_90
        2476: dup
        2477: invokespecial #373                // Method ocaml_fn_90."<init>":()V
        2480: astore        144
        2482: new           #375                // class ocaml_fn_91
        2485: dup
        2486: invokespecial #376                // Method ocaml_fn_91."<init>":()V
        2489: astore        145
        2491: new           #378                // class ocaml_fn_92
        2494: dup
        2495: invokespecial #379                // Method ocaml_fn_92."<init>":()V
        2498: astore        146
        2500: new           #381                // class ocaml_fn_93
        2503: dup
        2504: invokespecial #382                // Method ocaml_fn_93."<init>":()V
        2507: astore        147
        2509: new           #10                 // class Block
        2512: dup
        2513: iconst_0
        2514: bipush        104
        2516: anewarray     #2                  // class java/lang/Object
        2519: dup
        2520: iconst_0
        2521: aload         18
        2523: aastore
        2524: dup
        2525: iconst_1
        2526: aload         17
        2528: aastore
        2529: dup
        2530: iconst_2
        2531: aload         22
        2533: aastore
        2534: dup
        2535: iconst_3
        2536: aload         23
        2538: aastore
        2539: dup
        2540: iconst_4
        2541: aload         24
        2543: aastore
        2544: dup
        2545: iconst_5
        2546: aload         25
        2548: aastore
        2549: dup
        2550: bipush        6
        2552: aload         26
        2554: aastore
        2555: dup
        2556: bipush        7
        2558: aload         27
        2560: aastore
        2561: dup
        2562: bipush        8
        2564: aload         28
        2566: aastore
        2567: dup
        2568: bipush        9
        2570: aload         29
        2572: aastore
        2573: dup
        2574: bipush        10
        2576: aload         30
        2578: aastore
        2579: dup
        2580: bipush        11
        2582: aload         31
        2584: aastore
        2585: dup
        2586: bipush        12
        2588: aload         32
        2590: aastore
        2591: dup
        2592: bipush        13
        2594: aload         33
        2596: aastore
        2597: dup
        2598: bipush        14
        2600: aload         34
        2602: aastore
        2603: dup
        2604: bipush        15
        2606: aload         35
        2608: aastore
        2609: dup
        2610: bipush        16
        2612: aload         36
        2614: aastore
        2615: dup
        2616: bipush        17
        2618: aload         37
        2620: aastore
        2621: dup
        2622: bipush        18
        2624: iload         39
        2626: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2629: aastore
        2630: dup
        2631: bipush        19
        2633: iload         40
        2635: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2638: aastore
        2639: dup
        2640: bipush        20
        2642: aload         38
        2644: aastore
        2645: dup
        2646: bipush        21
        2648: aload         42
        2650: aastore
        2651: dup
        2652: bipush        22
        2654: aload         44
        2656: aastore
        2657: dup
        2658: bipush        23
        2660: aload         46
        2662: aastore
        2663: dup
        2664: bipush        24
        2666: aload         48
        2668: aastore
        2669: dup
        2670: bipush        25
        2672: aload         50
        2674: aastore
        2675: dup
        2676: bipush        26
        2678: aload         52
        2680: aastore
        2681: dup
        2682: bipush        27
        2684: aload         53
        2686: aastore
        2687: dup
        2688: bipush        28
        2690: aload         54
        2692: aastore
        2693: dup
        2694: bipush        29
        2696: aload         55
        2698: aastore
        2699: dup
        2700: bipush        30
        2702: aload         57
        2704: aastore
        2705: dup
        2706: bipush        31
        2708: aload         56
        2710: aastore
        2711: dup
        2712: bipush        32
        2714: aload         58
        2716: aastore
        2717: dup
        2718: bipush        33
        2720: aload         59
        2722: aastore
        2723: dup
        2724: bipush        34
        2726: aload         61
        2728: aastore
        2729: dup
        2730: bipush        35
        2732: aload         62
        2734: aastore
        2735: dup
        2736: bipush        36
        2738: aload         63
        2740: aastore
        2741: dup
        2742: bipush        37
        2744: aload         70
        2746: aastore
        2747: dup
        2748: bipush        38
        2750: aload         72
        2752: aastore
        2753: dup
        2754: bipush        39
        2756: aload         74
        2758: aastore
        2759: dup
        2760: bipush        40
        2762: aload         95
        2764: aastore
        2765: dup
        2766: bipush        41
        2768: aload         96
        2770: aastore
        2771: dup
        2772: bipush        42
        2774: aload         97
        2776: aastore
        2777: dup
        2778: bipush        43
        2780: aload         98
        2782: aastore
        2783: dup
        2784: bipush        44
        2786: aload         99
        2788: aastore
        2789: dup
        2790: bipush        45
        2792: aload         100
        2794: aastore
        2795: dup
        2796: bipush        46
        2798: aload         101
        2800: aastore
        2801: dup
        2802: bipush        47
        2804: aload         102
        2806: aastore
        2807: dup
        2808: bipush        48
        2810: aload         103
        2812: aastore
        2813: dup
        2814: bipush        49
        2816: aload         104
        2818: aastore
        2819: dup
        2820: bipush        50
        2822: aload         105
        2824: aastore
        2825: dup
        2826: bipush        51
        2828: aload         106
        2830: aastore
        2831: dup
        2832: bipush        52
        2834: aload         107
        2836: aastore
        2837: dup
        2838: bipush        53
        2840: aload         108
        2842: aastore
        2843: dup
        2844: bipush        54
        2846: aload         109
        2848: aastore
        2849: dup
        2850: bipush        55
        2852: aload         111
        2854: aastore
        2855: dup
        2856: bipush        56
        2858: aload         110
        2860: aastore
        2861: dup
        2862: bipush        57
        2864: aload         113
        2866: aastore
        2867: dup
        2868: bipush        58
        2870: aload         112
        2872: aastore
        2873: dup
        2874: bipush        59
        2876: aload         76
        2878: aastore
        2879: dup
        2880: bipush        60
        2882: aload         77
        2884: aastore
        2885: dup
        2886: bipush        61
        2888: aload         75
        2890: aastore
        2891: dup
        2892: bipush        62
        2894: aload         147
        2896: aastore
        2897: dup
        2898: bipush        63
        2900: aload         78
        2902: aastore
        2903: dup
        2904: bipush        64
        2906: aload         146
        2908: aastore
        2909: dup
        2910: bipush        65
        2912: aload         80
        2914: aastore
        2915: dup
        2916: bipush        66
        2918: aload         79
        2920: aastore
        2921: dup
        2922: bipush        67
        2924: aload         81
        2926: aastore
        2927: dup
        2928: bipush        68
        2930: aload         82
        2932: aastore
        2933: dup
        2934: bipush        69
        2936: aload         145
        2938: aastore
        2939: dup
        2940: bipush        70
        2942: aload         144
        2944: aastore
        2945: dup
        2946: bipush        71
        2948: aload         83
        2950: aastore
        2951: dup
        2952: bipush        72
        2954: aload         143
        2956: aastore
        2957: dup
        2958: bipush        73
        2960: aload         142
        2962: aastore
        2963: dup
        2964: bipush        74
        2966: aload         141
        2968: aastore
        2969: dup
        2970: bipush        75
        2972: aload         84
        2974: aastore
        2975: dup
        2976: bipush        76
        2978: aload         85
        2980: aastore
        2981: dup
        2982: bipush        77
        2984: aload         140
        2986: aastore
        2987: dup
        2988: bipush        78
        2990: aload         87
        2992: aastore
        2993: dup
        2994: bipush        79
        2996: aload         88
        2998: aastore
        2999: dup
        3000: bipush        80
        3002: aload         86
        3004: aastore
        3005: dup
        3006: bipush        81
        3008: aload         139
        3010: aastore
        3011: dup
        3012: bipush        82
        3014: aload         93
        3016: aastore
        3017: dup
        3018: bipush        83
        3020: aload         89
        3022: aastore
        3023: dup
        3024: bipush        84
        3026: aload         91
        3028: aastore
        3029: dup
        3030: bipush        85
        3032: aload         92
        3034: aastore
        3035: dup
        3036: bipush        86
        3038: aload         138
        3040: aastore
        3041: dup
        3042: bipush        87
        3044: aload         137
        3046: aastore
        3047: dup
        3048: bipush        88
        3050: aload         136
        3052: aastore
        3053: dup
        3054: bipush        89
        3056: aload         135
        3058: aastore
        3059: dup
        3060: bipush        90
        3062: aload         134
        3064: aastore
        3065: dup
        3066: bipush        91
        3068: aload         133
        3070: aastore
        3071: dup
        3072: bipush        92
        3074: aload         132
        3076: aastore
        3077: dup
        3078: bipush        93
        3080: aload         94
        3082: aastore
        3083: dup
        3084: bipush        94
        3086: aload         131
        3088: aastore
        3089: dup
        3090: bipush        95
        3092: aload         130
        3094: aastore
        3095: dup
        3096: bipush        96
        3098: aload         114
        3100: aastore
        3101: dup
        3102: bipush        97
        3104: aload         115
        3106: aastore
        3107: dup
        3108: bipush        98
        3110: aload         121
        3112: aastore
        3113: dup
        3114: bipush        99
        3116: aload         117
        3118: aastore
        3119: dup
        3120: bipush        100
        3122: aload         60
        3124: aastore
        3125: dup
        3126: bipush        101
        3128: aload         90
        3130: aastore
        3131: dup
        3132: bipush        102
        3134: aload         120
        3136: aastore
        3137: dup
        3138: bipush        103
        3140: aload         119
        3142: aastore
        3143: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3146: astore        148
        3148: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3151: bipush        45
        3153: aload         148
        3155: aastore
        3156: iconst_0
        3157: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3160: astore        149
        3162: bipush        8
        3164: istore        150
        3166: getstatic     #388                // Field java/lang/System.out:Ljava/io/PrintStream;
        3169: iload         150
        3171: invokevirtual #394                // Method java/io/PrintStream.println:(I)V
        3174: iconst_0
        3175: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3178: astore        151
        3180: new           #10                 // class Block
        3183: dup
        3184: iconst_0
        3185: iconst_0
        3186: anewarray     #2                  // class java/lang/Object
        3189: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3192: astore        152
        3194: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3197: bipush        46
        3199: aload         152
        3201: aastore
        3202: iconst_0
        3203: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3206: astore        153
        3208: iconst_0
        3209: istore        154
        3211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3214: bipush        45
        3216: aaload
        3217: checkcast     #10                 // class Block
        3220: getfield      #397                // Field Block.fields:[Ljava/lang/Object;
        3223: bipush        102
        3225: aaload
        3226: astore        155
        3228: aload         155
        3230: checkcast     #159                // class Closure
        3233: iload         154
        3235: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3238: invokevirtual #401                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3241: astore        156
        3243: new           #10                 // class Block
        3246: dup
        3247: iconst_0
        3248: iconst_0
        3249: anewarray     #2                  // class java/lang/Object
        3252: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3255: astore        157
        3257: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3260: bipush        47
        3262: aload         157
        3264: aastore
        3265: iconst_0
        3266: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3269: astore        158
        3271: return
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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: iconst_0
        1007: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1010: aastore
        1011: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        47
        1016: iconst_0
        1017: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1020: aastore
        1021: aconst_null
        1022: astore_1
        1023: aload_1
        1024: astore_2
        1025: goto_w        1030
        1030: new           #83                 // class ocaml_fn_0
        1033: dup
        1034: invokespecial #86                 // Method ocaml_fn_0."<init>":()V
        1037: astore_3
        1038: new           #88                 // class ocaml_fn_1
        1041: dup
        1042: invokespecial #89                 // Method ocaml_fn_1."<init>":()V
        1045: astore        4
        1047: new           #91                 // class ocaml_fn_2
        1050: dup
        1051: invokespecial #92                 // Method ocaml_fn_2."<init>":()V
        1054: astore        5
        1056: new           #10                 // class Block
        1059: dup
        1060: iconst_0
        1061: iconst_3
        1062: anewarray     #2                  // class java/lang/Object
        1065: dup
        1066: iconst_0
        1067: aload         4
        1069: aastore
        1070: dup
        1071: iconst_1
        1072: aload_3
        1073: aastore
        1074: dup
        1075: iconst_2
        1076: aload         5
        1078: aastore
        1079: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1082: astore        6
        1084: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1087: bipush        12
        1089: aload         6
        1091: aastore
        1092: iconst_0
        1093: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1096: astore        7
        1098: iconst_0
        1099: istore        8
        1101: iload         8
        1103: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1106: astore        9
        1108: goto_w        1113
        1113: sipush        199
        1116: istore        10
        1118: iconst_0
        1119: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1122: astore        11
        1124: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        35
        1129: aaload
        1130: astore        12
        1132: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1135: iconst_3
        1136: aaload
        1137: astore        13
        1139: new           #10                 // class Block
        1142: dup
        1143: iconst_0
        1144: iconst_2
        1145: anewarray     #2                  // class java/lang/Object
        1148: dup
        1149: iconst_0
        1150: aload         13
        1152: aastore
        1153: dup
        1154: iconst_1
        1155: aload         12
        1157: aastore
        1158: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1161: astore        14
        1163: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1166: bipush        36
        1168: aaload
        1169: astore        15
        1171: iconst_0
        1172: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1175: astore        16
        1177: new           #94                 // class ocaml_fn_8
        1180: dup
        1181: invokespecial #95                 // Method ocaml_fn_8."<init>":()V
        1184: astore        17
        1186: new           #97                 // class ocaml_fn_9
        1189: dup
        1190: invokespecial #98                 // Method ocaml_fn_9."<init>":()V
        1193: astore        18
        1195: iconst_0
        1196: istore        19
        1198: iconst_0
        1199: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1202: astore        20
        1204: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1207: bipush        37
        1209: aaload
        1210: astore        21
        1212: new           #10                 // class Block
        1215: dup
        1216: sipush        248
        1219: iconst_2
        1220: anewarray     #2                  // class java/lang/Object
        1223: dup
        1224: iconst_0
        1225: aload         21
        1227: aastore
        1228: dup
        1229: iconst_1
        1230: aload         20
        1232: aastore
        1233: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1236: astore        22
        1238: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        7
        1243: aaload
        1244: astore        23
        1246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        10
        1251: aaload
        1252: astore        24
        1254: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1257: iconst_3
        1258: aaload
        1259: astore        25
        1261: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1264: iconst_2
        1265: aaload
        1266: astore        26
        1268: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1271: bipush        6
        1273: aaload
        1274: astore        27
        1276: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1279: iconst_0
        1280: aaload
        1281: astore        28
        1283: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1286: bipush        8
        1288: aaload
        1289: astore        29
        1291: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1294: iconst_1
        1295: aaload
        1296: astore        30
        1298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1301: iconst_4
        1302: aaload
        1303: astore        31
        1305: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1308: iconst_5
        1309: aaload
        1310: astore        32
        1312: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1315: bipush        9
        1317: aaload
        1318: astore        33
        1320: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        11
        1325: aaload
        1326: astore        34
        1328: new           #100                // class ocaml_fn_10
        1331: dup
        1332: invokespecial #101                // Method ocaml_fn_10."<init>":()V
        1335: astore        35
        1337: new           #103                // class ocaml_fn_11
        1340: dup
        1341: invokespecial #104                // Method ocaml_fn_11."<init>":()V
        1344: astore        36
        1346: new           #106                // class ocaml_fn_12
        1349: dup
        1350: invokespecial #107                // Method ocaml_fn_12."<init>":()V
        1353: astore        37
        1355: new           #109                // class ocaml_fn_13
        1358: dup
        1359: invokespecial #110                // Method ocaml_fn_13."<init>":()V
        1362: astore        38
        1364: ldc           #111                // int 2147483647
        1366: istore        39
        1368: ldc           #112                // int -2147483648
        1370: istore        40
        1372: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1375: bipush        38
        1377: aaload
        1378: astore        41
        1380: ldc2_w        #113                // double 0.0d
        1383: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1386: astore        42
        1388: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1391: bipush        39
        1393: aaload
        1394: astore        43
        1396: ldc2_w        #113                // double 0.0d
        1399: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1402: astore        44
        1404: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1407: bipush        40
        1409: aaload
        1410: astore        45
        1412: ldc2_w        #113                // double 0.0d
        1415: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1418: astore        46
        1420: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        41
        1425: aaload
        1426: astore        47
        1428: ldc2_w        #113                // double 0.0d
        1431: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        48
        1436: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        42
        1441: aaload
        1442: astore        49
        1444: ldc2_w        #113                // double 0.0d
        1447: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        50
        1452: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        43
        1457: aaload
        1458: astore        51
        1460: ldc2_w        #113                // double 0.0d
        1463: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        52
        1468: new           #121                // class ocaml_fn_14
        1471: dup
        1472: invokespecial #122                // Method ocaml_fn_14."<init>":()V
        1475: astore        53
        1477: new           #124                // class ocaml_fn_15
        1480: dup
        1481: aload         18
        1483: invokespecial #127                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1486: astore        54
        1488: new           #129                // class ocaml_fn_16
        1491: dup
        1492: invokespecial #130                // Method ocaml_fn_16."<init>":()V
        1495: astore        55
        1497: new           #132                // class ocaml_fn_17
        1500: dup
        1501: aload         18
        1503: invokespecial #133                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1506: astore        56
        1508: new           #135                // class ocaml_fn_18
        1511: dup
        1512: invokespecial #136                // Method ocaml_fn_18."<init>":()V
        1515: astore        57
        1517: new           #138                // class ocaml_fn_19
        1520: dup
        1521: invokespecial #139                // Method ocaml_fn_19."<init>":()V
        1524: astore        58
        1526: new           #141                // class ocaml_fn_20
        1529: dup
        1530: aload         26
        1532: invokespecial #142                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1535: astore        59
        1537: new           #144                // class ocaml_fn_21
        1540: dup
        1541: aload         53
        1543: invokespecial #145                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1546: astore        60
        1548: new           #147                // class ocaml_fn_22
        1551: dup
        1552: aload         60
        1554: invokespecial #148                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1557: astore        61
        1559: new           #150                // class ocaml_fn_23
        1562: dup
        1563: aload         26
        1565: invokespecial #151                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1568: astore        62
        1570: new           #153                // class ocaml_fn_24
        1573: dup
        1574: invokespecial #154                // Method ocaml_fn_24."<init>":()V
        1577: astore        63
        1579: new           #156                // class ocaml_fn_25
        1582: dup
        1583: invokespecial #157                // Method ocaml_fn_25."<init>":()V
        1586: astore        64
        1588: aload         63
        1590: checkcast     #153                // class ocaml_fn_24
        1593: aload         63
        1595: checkcast     #159                // class Closure
        1598: putfield      #163                // Field ocaml_fn_24.sibling_0:LClosure;
        1601: iconst_0
        1602: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1605: astore        65
        1607: aload         63
        1609: checkcast     #153                // class ocaml_fn_24
        1612: aload         64
        1614: checkcast     #159                // class Closure
        1617: putfield      #166                // Field ocaml_fn_24.sibling_1:LClosure;
        1620: iconst_0
        1621: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1624: astore        66
        1626: aload         64
        1628: checkcast     #156                // class ocaml_fn_25
        1631: aload         63
        1633: checkcast     #159                // class Closure
        1636: putfield      #167                // Field ocaml_fn_25.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        67
        1645: aload         64
        1647: checkcast     #156                // class ocaml_fn_25
        1650: aload         64
        1652: checkcast     #159                // class Closure
        1655: putfield      #168                // Field ocaml_fn_25.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        68
        1664: iconst_0
        1665: istore        69
        1667: aconst_null
        1668: astore        70
        1670: iconst_1
        1671: istore        71
        1673: iload         71
        1675: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1678: astore        72
        1680: iconst_2
        1681: istore        73
        1683: iload         73
        1685: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1688: astore        74
        1690: new           #176                // class ocaml_fn_26
        1693: dup
        1694: invokespecial #177                // Method ocaml_fn_26."<init>":()V
        1697: astore        75
        1699: new           #179                // class ocaml_fn_27
        1702: dup
        1703: aload         75
        1705: invokespecial #180                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1708: astore        76
        1710: new           #182                // class ocaml_fn_28
        1713: dup
        1714: aload         75
        1716: invokespecial #183                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1719: astore        77
        1721: new           #185                // class ocaml_fn_29
        1724: dup
        1725: aload         30
        1727: invokespecial #186                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1730: astore        78
        1732: new           #188                // class ocaml_fn_30
        1735: dup
        1736: invokespecial #189                // Method ocaml_fn_30."<init>":()V
        1739: astore        79
        1741: new           #191                // class ocaml_fn_31
        1744: dup
        1745: invokespecial #192                // Method ocaml_fn_31."<init>":()V
        1748: astore        80
        1750: new           #194                // class ocaml_fn_32
        1753: dup
        1754: aload         18
        1756: invokespecial #195                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1759: astore        81
        1761: new           #197                // class ocaml_fn_33
        1764: dup
        1765: aload         18
        1767: invokespecial #198                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1770: astore        82
        1772: new           #200                // class ocaml_fn_34
        1775: dup
        1776: invokespecial #201                // Method ocaml_fn_34."<init>":()V
        1779: astore        83
        1781: new           #203                // class ocaml_fn_35
        1784: dup
        1785: invokespecial #204                // Method ocaml_fn_35."<init>":()V
        1788: astore        84
        1790: new           #206                // class ocaml_fn_36
        1793: dup
        1794: invokespecial #207                // Method ocaml_fn_36."<init>":()V
        1797: astore        85
        1799: new           #209                // class ocaml_fn_37
        1802: dup
        1803: invokespecial #210                // Method ocaml_fn_37."<init>":()V
        1806: astore        86
        1808: new           #212                // class ocaml_fn_38
        1811: dup
        1812: aload         86
        1814: invokespecial #213                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1817: astore        87
        1819: new           #215                // class ocaml_fn_39
        1822: dup
        1823: aload         86
        1825: invokespecial #216                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1828: astore        88
        1830: new           #218                // class ocaml_fn_40
        1833: dup
        1834: aload         18
        1836: invokespecial #219                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1839: astore        89
        1841: new           #221                // class ocaml_fn_41
        1844: dup
        1845: aload         31
        1847: invokespecial #222                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1850: astore        90
        1852: new           #224                // class ocaml_fn_42
        1855: dup
        1856: aload         18
        1858: aload         90
        1860: invokespecial #227                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1863: astore        91
        1865: new           #229                // class ocaml_fn_43
        1868: dup
        1869: aload         91
        1871: invokespecial #230                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1874: astore        92
        1876: new           #232                // class ocaml_fn_44
        1879: dup
        1880: aload         31
        1882: invokespecial #233                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1885: astore        93
        1887: new           #235                // class ocaml_fn_45
        1890: dup
        1891: invokespecial #236                // Method ocaml_fn_45."<init>":()V
        1894: astore        94
        1896: new           #238                // class ocaml_fn_46
        1899: dup
        1900: aload         72
        1902: invokespecial #239                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1905: astore        95
        1907: new           #241                // class ocaml_fn_47
        1910: dup
        1911: aload         72
        1913: aload         80
        1915: invokespecial #242                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1918: astore        96
        1920: new           #244                // class ocaml_fn_48
        1923: dup
        1924: aload         72
        1926: aload         79
        1928: invokespecial #245                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1931: astore        97
        1933: new           #247                // class ocaml_fn_49
        1936: dup
        1937: aload         58
        1939: aload         72
        1941: aload         80
        1943: invokespecial #250                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1946: astore        98
        1948: new           #252                // class ocaml_fn_50
        1951: dup
        1952: aload         61
        1954: aload         72
        1956: aload         80
        1958: invokespecial #253                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1961: astore        99
        1963: new           #255                // class ocaml_fn_51
        1966: dup
        1967: aload         72
        1969: aload         80
        1971: invokespecial #256                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1974: astore        100
        1976: new           #258                // class ocaml_fn_52
        1979: dup
        1980: aload         72
        1982: invokespecial #259                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1985: astore        101
        1987: new           #261                // class ocaml_fn_53
        1990: dup
        1991: aload         74
        1993: invokespecial #262                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1996: astore        102
        1998: new           #264                // class ocaml_fn_54
        2001: dup
        2002: aload         74
        2004: aload         80
        2006: invokespecial #265                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2009: astore        103
        2011: new           #267                // class ocaml_fn_55
        2014: dup
        2015: aload         74
        2017: aload         79
        2019: invokespecial #268                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2022: astore        104
        2024: new           #270                // class ocaml_fn_56
        2027: dup
        2028: aload         58
        2030: aload         74
        2032: aload         80
        2034: invokespecial #271                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2037: astore        105
        2039: new           #273                // class ocaml_fn_57
        2042: dup
        2043: aload         61
        2045: aload         74
        2047: aload         80
        2049: invokespecial #274                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        106
        2054: new           #276                // class ocaml_fn_58
        2057: dup
        2058: aload         74
        2060: aload         80
        2062: invokespecial #277                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2065: astore        107
        2067: new           #279                // class ocaml_fn_59
        2070: dup
        2071: aload         74
        2073: invokespecial #280                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2076: astore        108
        2078: new           #282                // class ocaml_fn_60
        2081: dup
        2082: aload         70
        2084: aload         72
        2086: aload         93
        2088: invokespecial #283                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        109
        2093: new           #285                // class ocaml_fn_61
        2096: dup
        2097: aload         109
        2099: invokespecial #286                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2102: astore        110
        2104: new           #288                // class ocaml_fn_62
        2107: dup
        2108: aload         59
        2110: aload         109
        2112: invokespecial #289                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2115: astore        111
        2117: new           #291                // class ocaml_fn_63
        2120: dup
        2121: aload         109
        2123: invokespecial #292                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2126: astore        112
        2128: new           #294                // class ocaml_fn_64
        2131: dup
        2132: aload         62
        2134: aload         109
        2136: invokespecial #295                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2139: astore        113
        2141: new           #297                // class ocaml_fn_65
        2144: dup
        2145: invokespecial #298                // Method ocaml_fn_65."<init>":()V
        2148: astore        114
        2150: new           #300                // class ocaml_fn_66
        2153: dup
        2154: aload         53
        2156: invokespecial #301                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2159: astore        115
        2161: new           #10                 // class Block
        2164: dup
        2165: iconst_0
        2166: iconst_1
        2167: anewarray     #2                  // class java/lang/Object
        2170: dup
        2171: iconst_0
        2172: aload         78
        2174: aastore
        2175: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2178: astore        116
        2180: new           #303                // class ocaml_fn_67
        2183: dup
        2184: aload         116
        2186: invokespecial #304                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2189: astore        117
        2191: new           #306                // class ocaml_fn_68
        2194: dup
        2195: invokespecial #307                // Method ocaml_fn_68."<init>":()V
        2198: astore        118
        2200: new           #10                 // class Block
        2203: dup
        2204: iconst_0
        2205: iconst_1
        2206: anewarray     #2                  // class java/lang/Object
        2209: dup
        2210: iconst_0
        2211: aload         118
        2213: aastore
        2214: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2217: astore        119
        2219: new           #309                // class ocaml_fn_69
        2222: dup
        2223: aload         116
        2225: aload         119
        2227: invokespecial #310                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2230: astore        120
        2232: new           #312                // class ocaml_fn_70
        2235: dup
        2236: aload         120
        2238: invokespecial #313                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2241: astore        121
        2243: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2246: bipush        44
        2248: aaload
        2249: astore        122
        2251: iconst_0
        2252: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2255: astore        123
        2257: new           #315                // class ocaml_fn_71
        2260: dup
        2261: invokespecial #316                // Method ocaml_fn_71."<init>":()V
        2264: astore        124
        2266: new           #318                // class ocaml_fn_72
        2269: dup
        2270: invokespecial #319                // Method ocaml_fn_72."<init>":()V
        2273: astore        125
        2275: new           #321                // class ocaml_fn_73
        2278: dup
        2279: invokespecial #322                // Method ocaml_fn_73."<init>":()V
        2282: astore        126
        2284: new           #324                // class ocaml_fn_74
        2287: dup
        2288: invokespecial #325                // Method ocaml_fn_74."<init>":()V
        2291: astore        127
        2293: new           #327                // class ocaml_fn_75
        2296: dup
        2297: invokespecial #328                // Method ocaml_fn_75."<init>":()V
        2300: astore        128
        2302: new           #330                // class ocaml_fn_76
        2305: dup
        2306: invokespecial #331                // Method ocaml_fn_76."<init>":()V
        2309: astore        129
        2311: new           #10                 // class Block
        2314: dup
        2315: iconst_0
        2316: bipush        6
        2318: anewarray     #2                  // class java/lang/Object
        2321: dup
        2322: iconst_0
        2323: aload         129
        2325: aastore
        2326: dup
        2327: iconst_1
        2328: aload         128
        2330: aastore
        2331: dup
        2332: iconst_2
        2333: aload         127
        2335: aastore
        2336: dup
        2337: iconst_3
        2338: aload         126
        2340: aastore
        2341: dup
        2342: iconst_4
        2343: aload         125
        2345: aastore
        2346: dup
        2347: iconst_5
        2348: aload         124
        2350: aastore
        2351: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2354: astore        130
        2356: new           #333                // class ocaml_fn_77
        2359: dup
        2360: invokespecial #334                // Method ocaml_fn_77."<init>":()V
        2363: astore        131
        2365: new           #336                // class ocaml_fn_78
        2368: dup
        2369: invokespecial #337                // Method ocaml_fn_78."<init>":()V
        2372: astore        132
        2374: new           #339                // class ocaml_fn_79
        2377: dup
        2378: invokespecial #340                // Method ocaml_fn_79."<init>":()V
        2381: astore        133
        2383: new           #342                // class ocaml_fn_80
        2386: dup
        2387: invokespecial #343                // Method ocaml_fn_80."<init>":()V
        2390: astore        134
        2392: new           #345                // class ocaml_fn_81
        2395: dup
        2396: invokespecial #346                // Method ocaml_fn_81."<init>":()V
        2399: astore        135
        2401: new           #348                // class ocaml_fn_82
        2404: dup
        2405: invokespecial #349                // Method ocaml_fn_82."<init>":()V
        2408: astore        136
        2410: new           #351                // class ocaml_fn_83
        2413: dup
        2414: invokespecial #352                // Method ocaml_fn_83."<init>":()V
        2417: astore        137
        2419: new           #354                // class ocaml_fn_84
        2422: dup
        2423: invokespecial #355                // Method ocaml_fn_84."<init>":()V
        2426: astore        138
        2428: new           #357                // class ocaml_fn_85
        2431: dup
        2432: invokespecial #358                // Method ocaml_fn_85."<init>":()V
        2435: astore        139
        2437: new           #360                // class ocaml_fn_86
        2440: dup
        2441: invokespecial #361                // Method ocaml_fn_86."<init>":()V
        2444: astore        140
        2446: new           #363                // class ocaml_fn_87
        2449: dup
        2450: invokespecial #364                // Method ocaml_fn_87."<init>":()V
        2453: astore        141
        2455: new           #366                // class ocaml_fn_88
        2458: dup
        2459: invokespecial #367                // Method ocaml_fn_88."<init>":()V
        2462: astore        142
        2464: new           #369                // class ocaml_fn_89
        2467: dup
        2468: invokespecial #370                // Method ocaml_fn_89."<init>":()V
        2471: astore        143
        2473: new           #372                // class ocaml_fn_90
        2476: dup
        2477: invokespecial #373                // Method ocaml_fn_90."<init>":()V
        2480: astore        144
        2482: new           #375                // class ocaml_fn_91
        2485: dup
        2486: invokespecial #376                // Method ocaml_fn_91."<init>":()V
        2489: astore        145
        2491: new           #378                // class ocaml_fn_92
        2494: dup
        2495: invokespecial #379                // Method ocaml_fn_92."<init>":()V
        2498: astore        146
        2500: new           #381                // class ocaml_fn_93
        2503: dup
        2504: invokespecial #382                // Method ocaml_fn_93."<init>":()V
        2507: astore        147
        2509: new           #10                 // class Block
        2512: dup
        2513: iconst_0
        2514: bipush        104
        2516: anewarray     #2                  // class java/lang/Object
        2519: dup
        2520: iconst_0
        2521: aload         18
        2523: aastore
        2524: dup
        2525: iconst_1
        2526: aload         17
        2528: aastore
        2529: dup
        2530: iconst_2
        2531: aload         22
        2533: aastore
        2534: dup
        2535: iconst_3
        2536: aload         23
        2538: aastore
        2539: dup
        2540: iconst_4
        2541: aload         24
        2543: aastore
        2544: dup
        2545: iconst_5
        2546: aload         25
        2548: aastore
        2549: dup
        2550: bipush        6
        2552: aload         26
        2554: aastore
        2555: dup
        2556: bipush        7
        2558: aload         27
        2560: aastore
        2561: dup
        2562: bipush        8
        2564: aload         28
        2566: aastore
        2567: dup
        2568: bipush        9
        2570: aload         29
        2572: aastore
        2573: dup
        2574: bipush        10
        2576: aload         30
        2578: aastore
        2579: dup
        2580: bipush        11
        2582: aload         31
        2584: aastore
        2585: dup
        2586: bipush        12
        2588: aload         32
        2590: aastore
        2591: dup
        2592: bipush        13
        2594: aload         33
        2596: aastore
        2597: dup
        2598: bipush        14
        2600: aload         34
        2602: aastore
        2603: dup
        2604: bipush        15
        2606: aload         35
        2608: aastore
        2609: dup
        2610: bipush        16
        2612: aload         36
        2614: aastore
        2615: dup
        2616: bipush        17
        2618: aload         37
        2620: aastore
        2621: dup
        2622: bipush        18
        2624: iload         39
        2626: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2629: aastore
        2630: dup
        2631: bipush        19
        2633: iload         40
        2635: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2638: aastore
        2639: dup
        2640: bipush        20
        2642: aload         38
        2644: aastore
        2645: dup
        2646: bipush        21
        2648: aload         42
        2650: aastore
        2651: dup
        2652: bipush        22
        2654: aload         44
        2656: aastore
        2657: dup
        2658: bipush        23
        2660: aload         46
        2662: aastore
        2663: dup
        2664: bipush        24
        2666: aload         48
        2668: aastore
        2669: dup
        2670: bipush        25
        2672: aload         50
        2674: aastore
        2675: dup
        2676: bipush        26
        2678: aload         52
        2680: aastore
        2681: dup
        2682: bipush        27
        2684: aload         53
        2686: aastore
        2687: dup
        2688: bipush        28
        2690: aload         54
        2692: aastore
        2693: dup
        2694: bipush        29
        2696: aload         55
        2698: aastore
        2699: dup
        2700: bipush        30
        2702: aload         57
        2704: aastore
        2705: dup
        2706: bipush        31
        2708: aload         56
        2710: aastore
        2711: dup
        2712: bipush        32
        2714: aload         58
        2716: aastore
        2717: dup
        2718: bipush        33
        2720: aload         59
        2722: aastore
        2723: dup
        2724: bipush        34
        2726: aload         61
        2728: aastore
        2729: dup
        2730: bipush        35
        2732: aload         62
        2734: aastore
        2735: dup
        2736: bipush        36
        2738: aload         63
        2740: aastore
        2741: dup
        2742: bipush        37
        2744: aload         70
        2746: aastore
        2747: dup
        2748: bipush        38
        2750: aload         72
        2752: aastore
        2753: dup
        2754: bipush        39
        2756: aload         74
        2758: aastore
        2759: dup
        2760: bipush        40
        2762: aload         95
        2764: aastore
        2765: dup
        2766: bipush        41
        2768: aload         96
        2770: aastore
        2771: dup
        2772: bipush        42
        2774: aload         97
        2776: aastore
        2777: dup
        2778: bipush        43
        2780: aload         98
        2782: aastore
        2783: dup
        2784: bipush        44
        2786: aload         99
        2788: aastore
        2789: dup
        2790: bipush        45
        2792: aload         100
        2794: aastore
        2795: dup
        2796: bipush        46
        2798: aload         101
        2800: aastore
        2801: dup
        2802: bipush        47
        2804: aload         102
        2806: aastore
        2807: dup
        2808: bipush        48
        2810: aload         103
        2812: aastore
        2813: dup
        2814: bipush        49
        2816: aload         104
        2818: aastore
        2819: dup
        2820: bipush        50
        2822: aload         105
        2824: aastore
        2825: dup
        2826: bipush        51
        2828: aload         106
        2830: aastore
        2831: dup
        2832: bipush        52
        2834: aload         107
        2836: aastore
        2837: dup
        2838: bipush        53
        2840: aload         108
        2842: aastore
        2843: dup
        2844: bipush        54
        2846: aload         109
        2848: aastore
        2849: dup
        2850: bipush        55
        2852: aload         111
        2854: aastore
        2855: dup
        2856: bipush        56
        2858: aload         110
        2860: aastore
        2861: dup
        2862: bipush        57
        2864: aload         113
        2866: aastore
        2867: dup
        2868: bipush        58
        2870: aload         112
        2872: aastore
        2873: dup
        2874: bipush        59
        2876: aload         76
        2878: aastore
        2879: dup
        2880: bipush        60
        2882: aload         77
        2884: aastore
        2885: dup
        2886: bipush        61
        2888: aload         75
        2890: aastore
        2891: dup
        2892: bipush        62
        2894: aload         147
        2896: aastore
        2897: dup
        2898: bipush        63
        2900: aload         78
        2902: aastore
        2903: dup
        2904: bipush        64
        2906: aload         146
        2908: aastore
        2909: dup
        2910: bipush        65
        2912: aload         80
        2914: aastore
        2915: dup
        2916: bipush        66
        2918: aload         79
        2920: aastore
        2921: dup
        2922: bipush        67
        2924: aload         81
        2926: aastore
        2927: dup
        2928: bipush        68
        2930: aload         82
        2932: aastore
        2933: dup
        2934: bipush        69
        2936: aload         145
        2938: aastore
        2939: dup
        2940: bipush        70
        2942: aload         144
        2944: aastore
        2945: dup
        2946: bipush        71
        2948: aload         83
        2950: aastore
        2951: dup
        2952: bipush        72
        2954: aload         143
        2956: aastore
        2957: dup
        2958: bipush        73
        2960: aload         142
        2962: aastore
        2963: dup
        2964: bipush        74
        2966: aload         141
        2968: aastore
        2969: dup
        2970: bipush        75
        2972: aload         84
        2974: aastore
        2975: dup
        2976: bipush        76
        2978: aload         85
        2980: aastore
        2981: dup
        2982: bipush        77
        2984: aload         140
        2986: aastore
        2987: dup
        2988: bipush        78
        2990: aload         87
        2992: aastore
        2993: dup
        2994: bipush        79
        2996: aload         88
        2998: aastore
        2999: dup
        3000: bipush        80
        3002: aload         86
        3004: aastore
        3005: dup
        3006: bipush        81
        3008: aload         139
        3010: aastore
        3011: dup
        3012: bipush        82
        3014: aload         93
        3016: aastore
        3017: dup
        3018: bipush        83
        3020: aload         89
        3022: aastore
        3023: dup
        3024: bipush        84
        3026: aload         91
        3028: aastore
        3029: dup
        3030: bipush        85
        3032: aload         92
        3034: aastore
        3035: dup
        3036: bipush        86
        3038: aload         138
        3040: aastore
        3041: dup
        3042: bipush        87
        3044: aload         137
        3046: aastore
        3047: dup
        3048: bipush        88
        3050: aload         136
        3052: aastore
        3053: dup
        3054: bipush        89
        3056: aload         135
        3058: aastore
        3059: dup
        3060: bipush        90
        3062: aload         134
        3064: aastore
        3065: dup
        3066: bipush        91
        3068: aload         133
        3070: aastore
        3071: dup
        3072: bipush        92
        3074: aload         132
        3076: aastore
        3077: dup
        3078: bipush        93
        3080: aload         94
        3082: aastore
        3083: dup
        3084: bipush        94
        3086: aload         131
        3088: aastore
        3089: dup
        3090: bipush        95
        3092: aload         130
        3094: aastore
        3095: dup
        3096: bipush        96
        3098: aload         114
        3100: aastore
        3101: dup
        3102: bipush        97
        3104: aload         115
        3106: aastore
        3107: dup
        3108: bipush        98
        3110: aload         121
        3112: aastore
        3113: dup
        3114: bipush        99
        3116: aload         117
        3118: aastore
        3119: dup
        3120: bipush        100
        3122: aload         60
        3124: aastore
        3125: dup
        3126: bipush        101
        3128: aload         90
        3130: aastore
        3131: dup
        3132: bipush        102
        3134: aload         120
        3136: aastore
        3137: dup
        3138: bipush        103
        3140: aload         119
        3142: aastore
        3143: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3146: astore        148
        3148: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3151: bipush        45
        3153: aload         148
        3155: aastore
        3156: iconst_0
        3157: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3160: astore        149
        3162: iconst_0
        3163: istore        150
        3165: iload         150
        3167: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3170: astore        151
        3172: goto_w        3177
        3177: new           #384                // class ocaml_fn_95
        3180: dup
        3181: invokespecial #385                // Method ocaml_fn_95."<init>":()V
        3184: astore        152
        3186: bipush        10
        3188: istore        153
        3190: aload         152
        3192: iload         153
        3194: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3197: invokevirtual #389                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3200: astore        154
        3202: bipush        32
        3204: istore        155
        3206: aload         154
        3208: checkcast     #159                // class Closure
        3211: iload         155
        3213: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3216: invokevirtual #389                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3219: astore        156
        3221: getstatic     #395                // Field java/lang/System.out:Ljava/io/PrintStream;
        3224: aload         156
        3226: checkcast     #14                 // class java/lang/Integer
        3229: invokevirtual #399                // Method java/lang/Integer.intValue:()I
        3232: invokevirtual #405                // Method java/io/PrintStream.println:(I)V
        3235: iconst_0
        3236: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3239: astore        157
        3241: new           #10                 // class Block
        3244: dup
        3245: iconst_0
        3246: iconst_1
        3247: anewarray     #2                  // class java/lang/Object
        3250: dup
        3251: iconst_0
        3252: aload         152
        3254: aastore
        3255: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3258: astore        158
        3260: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3263: bipush        46
        3265: aload         158
        3267: aastore
        3268: iconst_0
        3269: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3272: astore        159
        3274: iconst_0
        3275: istore        160
        3277: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3280: bipush        45
        3282: aaload
        3283: checkcast     #10                 // class Block
        3286: getfield      #408                // Field Block.fields:[Ljava/lang/Object;
        3289: bipush        102
        3291: aaload
        3292: astore        161
        3294: aload         161
        3296: checkcast     #159                // class Closure
        3299: iload         160
        3301: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3304: invokevirtual #389                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3307: astore        162
        3309: new           #10                 // class Block
        3312: dup
        3313: iconst_0
        3314: iconst_0
        3315: anewarray     #2                  // class java/lang/Object
        3318: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3321: astore        163
        3323: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3326: bipush        47
        3328: aload         163
        3330: aastore
        3331: iconst_0
        3332: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3335: astore        164
        3337: return
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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: new           #10                 // class Block
        1009: dup
        1010: iconst_0
        1011: iconst_1
        1012: anewarray     #2                  // class java/lang/Object
        1015: dup
        1016: iconst_0
        1017: bipush        42
        1019: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1022: aastore
        1023: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1026: aastore
        1027: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1030: bipush        47
        1032: iconst_0
        1033: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1036: aastore
        1037: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1040: bipush        48
        1042: iconst_0
        1043: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1046: aastore
        1047: aconst_null
        1048: astore_1
        1049: aload_1
        1050: astore_2
        1051: goto_w        1056
        1056: new           #83                 // class ocaml_fn_0
        1059: dup
        1060: invokespecial #86                 // Method ocaml_fn_0."<init>":()V
        1063: astore_3
        1064: new           #88                 // class ocaml_fn_1
        1067: dup
        1068: invokespecial #89                 // Method ocaml_fn_1."<init>":()V
        1071: astore        4
        1073: new           #91                 // class ocaml_fn_2
        1076: dup
        1077: invokespecial #92                 // Method ocaml_fn_2."<init>":()V
        1080: astore        5
        1082: new           #10                 // class Block
        1085: dup
        1086: iconst_0
        1087: iconst_3
        1088: anewarray     #2                  // class java/lang/Object
        1091: dup
        1092: iconst_0
        1093: aload         4
        1095: aastore
        1096: dup
        1097: iconst_1
        1098: aload_3
        1099: aastore
        1100: dup
        1101: iconst_2
        1102: aload         5
        1104: aastore
        1105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1108: astore        6
        1110: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1113: bipush        12
        1115: aload         6
        1117: aastore
        1118: iconst_0
        1119: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1122: astore        7
        1124: iconst_0
        1125: istore        8
        1127: iload         8
        1129: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1132: astore        9
        1134: goto_w        1139
        1139: sipush        199
        1142: istore        10
        1144: iconst_0
        1145: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1148: astore        11
        1150: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1153: bipush        35
        1155: aaload
        1156: astore        12
        1158: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1161: iconst_3
        1162: aaload
        1163: astore        13
        1165: new           #10                 // class Block
        1168: dup
        1169: iconst_0
        1170: iconst_2
        1171: anewarray     #2                  // class java/lang/Object
        1174: dup
        1175: iconst_0
        1176: aload         13
        1178: aastore
        1179: dup
        1180: iconst_1
        1181: aload         12
        1183: aastore
        1184: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1187: astore        14
        1189: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1192: bipush        36
        1194: aaload
        1195: astore        15
        1197: iconst_0
        1198: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1201: astore        16
        1203: new           #94                 // class ocaml_fn_8
        1206: dup
        1207: invokespecial #95                 // Method ocaml_fn_8."<init>":()V
        1210: astore        17
        1212: new           #97                 // class ocaml_fn_9
        1215: dup
        1216: invokespecial #98                 // Method ocaml_fn_9."<init>":()V
        1219: astore        18
        1221: iconst_0
        1222: istore        19
        1224: iconst_0
        1225: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1228: astore        20
        1230: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1233: bipush        37
        1235: aaload
        1236: astore        21
        1238: new           #10                 // class Block
        1241: dup
        1242: sipush        248
        1245: iconst_2
        1246: anewarray     #2                  // class java/lang/Object
        1249: dup
        1250: iconst_0
        1251: aload         21
        1253: aastore
        1254: dup
        1255: iconst_1
        1256: aload         20
        1258: aastore
        1259: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1262: astore        22
        1264: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1267: bipush        7
        1269: aaload
        1270: astore        23
        1272: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1275: bipush        10
        1277: aaload
        1278: astore        24
        1280: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1283: iconst_3
        1284: aaload
        1285: astore        25
        1287: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1290: iconst_2
        1291: aaload
        1292: astore        26
        1294: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1297: bipush        6
        1299: aaload
        1300: astore        27
        1302: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1305: iconst_0
        1306: aaload
        1307: astore        28
        1309: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1312: bipush        8
        1314: aaload
        1315: astore        29
        1317: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1320: iconst_1
        1321: aaload
        1322: astore        30
        1324: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1327: iconst_4
        1328: aaload
        1329: astore        31
        1331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1334: iconst_5
        1335: aaload
        1336: astore        32
        1338: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1341: bipush        9
        1343: aaload
        1344: astore        33
        1346: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1349: bipush        11
        1351: aaload
        1352: astore        34
        1354: new           #100                // class ocaml_fn_10
        1357: dup
        1358: invokespecial #101                // Method ocaml_fn_10."<init>":()V
        1361: astore        35
        1363: new           #103                // class ocaml_fn_11
        1366: dup
        1367: invokespecial #104                // Method ocaml_fn_11."<init>":()V
        1370: astore        36
        1372: new           #106                // class ocaml_fn_12
        1375: dup
        1376: invokespecial #107                // Method ocaml_fn_12."<init>":()V
        1379: astore        37
        1381: new           #109                // class ocaml_fn_13
        1384: dup
        1385: invokespecial #110                // Method ocaml_fn_13."<init>":()V
        1388: astore        38
        1390: ldc           #111                // int 2147483647
        1392: istore        39
        1394: ldc           #112                // int -2147483648
        1396: istore        40
        1398: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1401: bipush        38
        1403: aaload
        1404: astore        41
        1406: ldc2_w        #113                // double 0.0d
        1409: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1412: astore        42
        1414: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1417: bipush        39
        1419: aaload
        1420: astore        43
        1422: ldc2_w        #113                // double 0.0d
        1425: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1428: astore        44
        1430: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1433: bipush        40
        1435: aaload
        1436: astore        45
        1438: ldc2_w        #113                // double 0.0d
        1441: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1444: astore        46
        1446: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1449: bipush        41
        1451: aaload
        1452: astore        47
        1454: ldc2_w        #113                // double 0.0d
        1457: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1460: astore        48
        1462: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1465: bipush        42
        1467: aaload
        1468: astore        49
        1470: ldc2_w        #113                // double 0.0d
        1473: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1476: astore        50
        1478: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1481: bipush        43
        1483: aaload
        1484: astore        51
        1486: ldc2_w        #113                // double 0.0d
        1489: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1492: astore        52
        1494: new           #121                // class ocaml_fn_14
        1497: dup
        1498: invokespecial #122                // Method ocaml_fn_14."<init>":()V
        1501: astore        53
        1503: new           #124                // class ocaml_fn_15
        1506: dup
        1507: aload         18
        1509: invokespecial #127                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1512: astore        54
        1514: new           #129                // class ocaml_fn_16
        1517: dup
        1518: invokespecial #130                // Method ocaml_fn_16."<init>":()V
        1521: astore        55
        1523: new           #132                // class ocaml_fn_17
        1526: dup
        1527: aload         18
        1529: invokespecial #133                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1532: astore        56
        1534: new           #135                // class ocaml_fn_18
        1537: dup
        1538: invokespecial #136                // Method ocaml_fn_18."<init>":()V
        1541: astore        57
        1543: new           #138                // class ocaml_fn_19
        1546: dup
        1547: invokespecial #139                // Method ocaml_fn_19."<init>":()V
        1550: astore        58
        1552: new           #141                // class ocaml_fn_20
        1555: dup
        1556: aload         26
        1558: invokespecial #142                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1561: astore        59
        1563: new           #144                // class ocaml_fn_21
        1566: dup
        1567: aload         53
        1569: invokespecial #145                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1572: astore        60
        1574: new           #147                // class ocaml_fn_22
        1577: dup
        1578: aload         60
        1580: invokespecial #148                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1583: astore        61
        1585: new           #150                // class ocaml_fn_23
        1588: dup
        1589: aload         26
        1591: invokespecial #151                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1594: astore        62
        1596: new           #153                // class ocaml_fn_24
        1599: dup
        1600: invokespecial #154                // Method ocaml_fn_24."<init>":()V
        1603: astore        63
        1605: new           #156                // class ocaml_fn_25
        1608: dup
        1609: invokespecial #157                // Method ocaml_fn_25."<init>":()V
        1612: astore        64
        1614: aload         63
        1616: checkcast     #153                // class ocaml_fn_24
        1619: aload         63
        1621: checkcast     #159                // class Closure
        1624: putfield      #163                // Field ocaml_fn_24.sibling_0:LClosure;
        1627: iconst_0
        1628: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1631: astore        65
        1633: aload         63
        1635: checkcast     #153                // class ocaml_fn_24
        1638: aload         64
        1640: checkcast     #159                // class Closure
        1643: putfield      #166                // Field ocaml_fn_24.sibling_1:LClosure;
        1646: iconst_0
        1647: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1650: astore        66
        1652: aload         64
        1654: checkcast     #156                // class ocaml_fn_25
        1657: aload         63
        1659: checkcast     #159                // class Closure
        1662: putfield      #167                // Field ocaml_fn_25.sibling_0:LClosure;
        1665: iconst_0
        1666: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1669: astore        67
        1671: aload         64
        1673: checkcast     #156                // class ocaml_fn_25
        1676: aload         64
        1678: checkcast     #159                // class Closure
        1681: putfield      #168                // Field ocaml_fn_25.sibling_1:LClosure;
        1684: iconst_0
        1685: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1688: astore        68
        1690: iconst_0
        1691: istore        69
        1693: aconst_null
        1694: astore        70
        1696: iconst_1
        1697: istore        71
        1699: iload         71
        1701: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1704: astore        72
        1706: iconst_2
        1707: istore        73
        1709: iload         73
        1711: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1714: astore        74
        1716: new           #176                // class ocaml_fn_26
        1719: dup
        1720: invokespecial #177                // Method ocaml_fn_26."<init>":()V
        1723: astore        75
        1725: new           #179                // class ocaml_fn_27
        1728: dup
        1729: aload         75
        1731: invokespecial #180                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1734: astore        76
        1736: new           #182                // class ocaml_fn_28
        1739: dup
        1740: aload         75
        1742: invokespecial #183                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1745: astore        77
        1747: new           #185                // class ocaml_fn_29
        1750: dup
        1751: aload         30
        1753: invokespecial #186                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1756: astore        78
        1758: new           #188                // class ocaml_fn_30
        1761: dup
        1762: invokespecial #189                // Method ocaml_fn_30."<init>":()V
        1765: astore        79
        1767: new           #191                // class ocaml_fn_31
        1770: dup
        1771: invokespecial #192                // Method ocaml_fn_31."<init>":()V
        1774: astore        80
        1776: new           #194                // class ocaml_fn_32
        1779: dup
        1780: aload         18
        1782: invokespecial #195                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1785: astore        81
        1787: new           #197                // class ocaml_fn_33
        1790: dup
        1791: aload         18
        1793: invokespecial #198                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1796: astore        82
        1798: new           #200                // class ocaml_fn_34
        1801: dup
        1802: invokespecial #201                // Method ocaml_fn_34."<init>":()V
        1805: astore        83
        1807: new           #203                // class ocaml_fn_35
        1810: dup
        1811: invokespecial #204                // Method ocaml_fn_35."<init>":()V
        1814: astore        84
        1816: new           #206                // class ocaml_fn_36
        1819: dup
        1820: invokespecial #207                // Method ocaml_fn_36."<init>":()V
        1823: astore        85
        1825: new           #209                // class ocaml_fn_37
        1828: dup
        1829: invokespecial #210                // Method ocaml_fn_37."<init>":()V
        1832: astore        86
        1834: new           #212                // class ocaml_fn_38
        1837: dup
        1838: aload         86
        1840: invokespecial #213                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1843: astore        87
        1845: new           #215                // class ocaml_fn_39
        1848: dup
        1849: aload         86
        1851: invokespecial #216                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1854: astore        88
        1856: new           #218                // class ocaml_fn_40
        1859: dup
        1860: aload         18
        1862: invokespecial #219                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1865: astore        89
        1867: new           #221                // class ocaml_fn_41
        1870: dup
        1871: aload         31
        1873: invokespecial #222                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1876: astore        90
        1878: new           #224                // class ocaml_fn_42
        1881: dup
        1882: aload         18
        1884: aload         90
        1886: invokespecial #227                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1889: astore        91
        1891: new           #229                // class ocaml_fn_43
        1894: dup
        1895: aload         91
        1897: invokespecial #230                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1900: astore        92
        1902: new           #232                // class ocaml_fn_44
        1905: dup
        1906: aload         31
        1908: invokespecial #233                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1911: astore        93
        1913: new           #235                // class ocaml_fn_45
        1916: dup
        1917: invokespecial #236                // Method ocaml_fn_45."<init>":()V
        1920: astore        94
        1922: new           #238                // class ocaml_fn_46
        1925: dup
        1926: aload         72
        1928: invokespecial #239                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1931: astore        95
        1933: new           #241                // class ocaml_fn_47
        1936: dup
        1937: aload         72
        1939: aload         80
        1941: invokespecial #242                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1944: astore        96
        1946: new           #244                // class ocaml_fn_48
        1949: dup
        1950: aload         72
        1952: aload         79
        1954: invokespecial #245                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1957: astore        97
        1959: new           #247                // class ocaml_fn_49
        1962: dup
        1963: aload         58
        1965: aload         72
        1967: aload         80
        1969: invokespecial #250                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1972: astore        98
        1974: new           #252                // class ocaml_fn_50
        1977: dup
        1978: aload         61
        1980: aload         72
        1982: aload         80
        1984: invokespecial #253                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1987: astore        99
        1989: new           #255                // class ocaml_fn_51
        1992: dup
        1993: aload         72
        1995: aload         80
        1997: invokespecial #256                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2000: astore        100
        2002: new           #258                // class ocaml_fn_52
        2005: dup
        2006: aload         72
        2008: invokespecial #259                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        2011: astore        101
        2013: new           #261                // class ocaml_fn_53
        2016: dup
        2017: aload         74
        2019: invokespecial #262                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2022: astore        102
        2024: new           #264                // class ocaml_fn_54
        2027: dup
        2028: aload         74
        2030: aload         80
        2032: invokespecial #265                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2035: astore        103
        2037: new           #267                // class ocaml_fn_55
        2040: dup
        2041: aload         74
        2043: aload         79
        2045: invokespecial #268                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2048: astore        104
        2050: new           #270                // class ocaml_fn_56
        2053: dup
        2054: aload         58
        2056: aload         74
        2058: aload         80
        2060: invokespecial #271                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2063: astore        105
        2065: new           #273                // class ocaml_fn_57
        2068: dup
        2069: aload         61
        2071: aload         74
        2073: aload         80
        2075: invokespecial #274                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2078: astore        106
        2080: new           #276                // class ocaml_fn_58
        2083: dup
        2084: aload         74
        2086: aload         80
        2088: invokespecial #277                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        107
        2093: new           #279                // class ocaml_fn_59
        2096: dup
        2097: aload         74
        2099: invokespecial #280                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2102: astore        108
        2104: new           #282                // class ocaml_fn_60
        2107: dup
        2108: aload         70
        2110: aload         72
        2112: aload         93
        2114: invokespecial #283                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2117: astore        109
        2119: new           #285                // class ocaml_fn_61
        2122: dup
        2123: aload         109
        2125: invokespecial #286                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2128: astore        110
        2130: new           #288                // class ocaml_fn_62
        2133: dup
        2134: aload         59
        2136: aload         109
        2138: invokespecial #289                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2141: astore        111
        2143: new           #291                // class ocaml_fn_63
        2146: dup
        2147: aload         109
        2149: invokespecial #292                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2152: astore        112
        2154: new           #294                // class ocaml_fn_64
        2157: dup
        2158: aload         62
        2160: aload         109
        2162: invokespecial #295                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2165: astore        113
        2167: new           #297                // class ocaml_fn_65
        2170: dup
        2171: invokespecial #298                // Method ocaml_fn_65."<init>":()V
        2174: astore        114
        2176: new           #300                // class ocaml_fn_66
        2179: dup
        2180: aload         53
        2182: invokespecial #301                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2185: astore        115
        2187: new           #10                 // class Block
        2190: dup
        2191: iconst_0
        2192: iconst_1
        2193: anewarray     #2                  // class java/lang/Object
        2196: dup
        2197: iconst_0
        2198: aload         78
        2200: aastore
        2201: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2204: astore        116
        2206: new           #303                // class ocaml_fn_67
        2209: dup
        2210: aload         116
        2212: invokespecial #304                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2215: astore        117
        2217: new           #306                // class ocaml_fn_68
        2220: dup
        2221: invokespecial #307                // Method ocaml_fn_68."<init>":()V
        2224: astore        118
        2226: new           #10                 // class Block
        2229: dup
        2230: iconst_0
        2231: iconst_1
        2232: anewarray     #2                  // class java/lang/Object
        2235: dup
        2236: iconst_0
        2237: aload         118
        2239: aastore
        2240: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2243: astore        119
        2245: new           #309                // class ocaml_fn_69
        2248: dup
        2249: aload         116
        2251: aload         119
        2253: invokespecial #310                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2256: astore        120
        2258: new           #312                // class ocaml_fn_70
        2261: dup
        2262: aload         120
        2264: invokespecial #313                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2267: astore        121
        2269: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2272: bipush        44
        2274: aaload
        2275: astore        122
        2277: iconst_0
        2278: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2281: astore        123
        2283: new           #315                // class ocaml_fn_71
        2286: dup
        2287: invokespecial #316                // Method ocaml_fn_71."<init>":()V
        2290: astore        124
        2292: new           #318                // class ocaml_fn_72
        2295: dup
        2296: invokespecial #319                // Method ocaml_fn_72."<init>":()V
        2299: astore        125
        2301: new           #321                // class ocaml_fn_73
        2304: dup
        2305: invokespecial #322                // Method ocaml_fn_73."<init>":()V
        2308: astore        126
        2310: new           #324                // class ocaml_fn_74
        2313: dup
        2314: invokespecial #325                // Method ocaml_fn_74."<init>":()V
        2317: astore        127
        2319: new           #327                // class ocaml_fn_75
        2322: dup
        2323: invokespecial #328                // Method ocaml_fn_75."<init>":()V
        2326: astore        128
        2328: new           #330                // class ocaml_fn_76
        2331: dup
        2332: invokespecial #331                // Method ocaml_fn_76."<init>":()V
        2335: astore        129
        2337: new           #10                 // class Block
        2340: dup
        2341: iconst_0
        2342: bipush        6
        2344: anewarray     #2                  // class java/lang/Object
        2347: dup
        2348: iconst_0
        2349: aload         129
        2351: aastore
        2352: dup
        2353: iconst_1
        2354: aload         128
        2356: aastore
        2357: dup
        2358: iconst_2
        2359: aload         127
        2361: aastore
        2362: dup
        2363: iconst_3
        2364: aload         126
        2366: aastore
        2367: dup
        2368: iconst_4
        2369: aload         125
        2371: aastore
        2372: dup
        2373: iconst_5
        2374: aload         124
        2376: aastore
        2377: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2380: astore        130
        2382: new           #333                // class ocaml_fn_77
        2385: dup
        2386: invokespecial #334                // Method ocaml_fn_77."<init>":()V
        2389: astore        131
        2391: new           #336                // class ocaml_fn_78
        2394: dup
        2395: invokespecial #337                // Method ocaml_fn_78."<init>":()V
        2398: astore        132
        2400: new           #339                // class ocaml_fn_79
        2403: dup
        2404: invokespecial #340                // Method ocaml_fn_79."<init>":()V
        2407: astore        133
        2409: new           #342                // class ocaml_fn_80
        2412: dup
        2413: invokespecial #343                // Method ocaml_fn_80."<init>":()V
        2416: astore        134
        2418: new           #345                // class ocaml_fn_81
        2421: dup
        2422: invokespecial #346                // Method ocaml_fn_81."<init>":()V
        2425: astore        135
        2427: new           #348                // class ocaml_fn_82
        2430: dup
        2431: invokespecial #349                // Method ocaml_fn_82."<init>":()V
        2434: astore        136
        2436: new           #351                // class ocaml_fn_83
        2439: dup
        2440: invokespecial #352                // Method ocaml_fn_83."<init>":()V
        2443: astore        137
        2445: new           #354                // class ocaml_fn_84
        2448: dup
        2449: invokespecial #355                // Method ocaml_fn_84."<init>":()V
        2452: astore        138
        2454: new           #357                // class ocaml_fn_85
        2457: dup
        2458: invokespecial #358                // Method ocaml_fn_85."<init>":()V
        2461: astore        139
        2463: new           #360                // class ocaml_fn_86
        2466: dup
        2467: invokespecial #361                // Method ocaml_fn_86."<init>":()V
        2470: astore        140
        2472: new           #363                // class ocaml_fn_87
        2475: dup
        2476: invokespecial #364                // Method ocaml_fn_87."<init>":()V
        2479: astore        141
        2481: new           #366                // class ocaml_fn_88
        2484: dup
        2485: invokespecial #367                // Method ocaml_fn_88."<init>":()V
        2488: astore        142
        2490: new           #369                // class ocaml_fn_89
        2493: dup
        2494: invokespecial #370                // Method ocaml_fn_89."<init>":()V
        2497: astore        143
        2499: new           #372                // class ocaml_fn_90
        2502: dup
        2503: invokespecial #373                // Method ocaml_fn_90."<init>":()V
        2506: astore        144
        2508: new           #375                // class ocaml_fn_91
        2511: dup
        2512: invokespecial #376                // Method ocaml_fn_91."<init>":()V
        2515: astore        145
        2517: new           #378                // class ocaml_fn_92
        2520: dup
        2521: invokespecial #379                // Method ocaml_fn_92."<init>":()V
        2524: astore        146
        2526: new           #381                // class ocaml_fn_93
        2529: dup
        2530: invokespecial #382                // Method ocaml_fn_93."<init>":()V
        2533: astore        147
        2535: new           #10                 // class Block
        2538: dup
        2539: iconst_0
        2540: bipush        104
        2542: anewarray     #2                  // class java/lang/Object
        2545: dup
        2546: iconst_0
        2547: aload         18
        2549: aastore
        2550: dup
        2551: iconst_1
        2552: aload         17
        2554: aastore
        2555: dup
        2556: iconst_2
        2557: aload         22
        2559: aastore
        2560: dup
        2561: iconst_3
        2562: aload         23
        2564: aastore
        2565: dup
        2566: iconst_4
        2567: aload         24
        2569: aastore
        2570: dup
        2571: iconst_5
        2572: aload         25
        2574: aastore
        2575: dup
        2576: bipush        6
        2578: aload         26
        2580: aastore
        2581: dup
        2582: bipush        7
        2584: aload         27
        2586: aastore
        2587: dup
        2588: bipush        8
        2590: aload         28
        2592: aastore
        2593: dup
        2594: bipush        9
        2596: aload         29
        2598: aastore
        2599: dup
        2600: bipush        10
        2602: aload         30
        2604: aastore
        2605: dup
        2606: bipush        11
        2608: aload         31
        2610: aastore
        2611: dup
        2612: bipush        12
        2614: aload         32
        2616: aastore
        2617: dup
        2618: bipush        13
        2620: aload         33
        2622: aastore
        2623: dup
        2624: bipush        14
        2626: aload         34
        2628: aastore
        2629: dup
        2630: bipush        15
        2632: aload         35
        2634: aastore
        2635: dup
        2636: bipush        16
        2638: aload         36
        2640: aastore
        2641: dup
        2642: bipush        17
        2644: aload         37
        2646: aastore
        2647: dup
        2648: bipush        18
        2650: iload         39
        2652: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2655: aastore
        2656: dup
        2657: bipush        19
        2659: iload         40
        2661: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2664: aastore
        2665: dup
        2666: bipush        20
        2668: aload         38
        2670: aastore
        2671: dup
        2672: bipush        21
        2674: aload         42
        2676: aastore
        2677: dup
        2678: bipush        22
        2680: aload         44
        2682: aastore
        2683: dup
        2684: bipush        23
        2686: aload         46
        2688: aastore
        2689: dup
        2690: bipush        24
        2692: aload         48
        2694: aastore
        2695: dup
        2696: bipush        25
        2698: aload         50
        2700: aastore
        2701: dup
        2702: bipush        26
        2704: aload         52
        2706: aastore
        2707: dup
        2708: bipush        27
        2710: aload         53
        2712: aastore
        2713: dup
        2714: bipush        28
        2716: aload         54
        2718: aastore
        2719: dup
        2720: bipush        29
        2722: aload         55
        2724: aastore
        2725: dup
        2726: bipush        30
        2728: aload         57
        2730: aastore
        2731: dup
        2732: bipush        31
        2734: aload         56
        2736: aastore
        2737: dup
        2738: bipush        32
        2740: aload         58
        2742: aastore
        2743: dup
        2744: bipush        33
        2746: aload         59
        2748: aastore
        2749: dup
        2750: bipush        34
        2752: aload         61
        2754: aastore
        2755: dup
        2756: bipush        35
        2758: aload         62
        2760: aastore
        2761: dup
        2762: bipush        36
        2764: aload         63
        2766: aastore
        2767: dup
        2768: bipush        37
        2770: aload         70
        2772: aastore
        2773: dup
        2774: bipush        38
        2776: aload         72
        2778: aastore
        2779: dup
        2780: bipush        39
        2782: aload         74
        2784: aastore
        2785: dup
        2786: bipush        40
        2788: aload         95
        2790: aastore
        2791: dup
        2792: bipush        41
        2794: aload         96
        2796: aastore
        2797: dup
        2798: bipush        42
        2800: aload         97
        2802: aastore
        2803: dup
        2804: bipush        43
        2806: aload         98
        2808: aastore
        2809: dup
        2810: bipush        44
        2812: aload         99
        2814: aastore
        2815: dup
        2816: bipush        45
        2818: aload         100
        2820: aastore
        2821: dup
        2822: bipush        46
        2824: aload         101
        2826: aastore
        2827: dup
        2828: bipush        47
        2830: aload         102
        2832: aastore
        2833: dup
        2834: bipush        48
        2836: aload         103
        2838: aastore
        2839: dup
        2840: bipush        49
        2842: aload         104
        2844: aastore
        2845: dup
        2846: bipush        50
        2848: aload         105
        2850: aastore
        2851: dup
        2852: bipush        51
        2854: aload         106
        2856: aastore
        2857: dup
        2858: bipush        52
        2860: aload         107
        2862: aastore
        2863: dup
        2864: bipush        53
        2866: aload         108
        2868: aastore
        2869: dup
        2870: bipush        54
        2872: aload         109
        2874: aastore
        2875: dup
        2876: bipush        55
        2878: aload         111
        2880: aastore
        2881: dup
        2882: bipush        56
        2884: aload         110
        2886: aastore
        2887: dup
        2888: bipush        57
        2890: aload         113
        2892: aastore
        2893: dup
        2894: bipush        58
        2896: aload         112
        2898: aastore
        2899: dup
        2900: bipush        59
        2902: aload         76
        2904: aastore
        2905: dup
        2906: bipush        60
        2908: aload         77
        2910: aastore
        2911: dup
        2912: bipush        61
        2914: aload         75
        2916: aastore
        2917: dup
        2918: bipush        62
        2920: aload         147
        2922: aastore
        2923: dup
        2924: bipush        63
        2926: aload         78
        2928: aastore
        2929: dup
        2930: bipush        64
        2932: aload         146
        2934: aastore
        2935: dup
        2936: bipush        65
        2938: aload         80
        2940: aastore
        2941: dup
        2942: bipush        66
        2944: aload         79
        2946: aastore
        2947: dup
        2948: bipush        67
        2950: aload         81
        2952: aastore
        2953: dup
        2954: bipush        68
        2956: aload         82
        2958: aastore
        2959: dup
        2960: bipush        69
        2962: aload         145
        2964: aastore
        2965: dup
        2966: bipush        70
        2968: aload         144
        2970: aastore
        2971: dup
        2972: bipush        71
        2974: aload         83
        2976: aastore
        2977: dup
        2978: bipush        72
        2980: aload         143
        2982: aastore
        2983: dup
        2984: bipush        73
        2986: aload         142
        2988: aastore
        2989: dup
        2990: bipush        74
        2992: aload         141
        2994: aastore
        2995: dup
        2996: bipush        75
        2998: aload         84
        3000: aastore
        3001: dup
        3002: bipush        76
        3004: aload         85
        3006: aastore
        3007: dup
        3008: bipush        77
        3010: aload         140
        3012: aastore
        3013: dup
        3014: bipush        78
        3016: aload         87
        3018: aastore
        3019: dup
        3020: bipush        79
        3022: aload         88
        3024: aastore
        3025: dup
        3026: bipush        80
        3028: aload         86
        3030: aastore
        3031: dup
        3032: bipush        81
        3034: aload         139
        3036: aastore
        3037: dup
        3038: bipush        82
        3040: aload         93
        3042: aastore
        3043: dup
        3044: bipush        83
        3046: aload         89
        3048: aastore
        3049: dup
        3050: bipush        84
        3052: aload         91
        3054: aastore
        3055: dup
        3056: bipush        85
        3058: aload         92
        3060: aastore
        3061: dup
        3062: bipush        86
        3064: aload         138
        3066: aastore
        3067: dup
        3068: bipush        87
        3070: aload         137
        3072: aastore
        3073: dup
        3074: bipush        88
        3076: aload         136
        3078: aastore
        3079: dup
        3080: bipush        89
        3082: aload         135
        3084: aastore
        3085: dup
        3086: bipush        90
        3088: aload         134
        3090: aastore
        3091: dup
        3092: bipush        91
        3094: aload         133
        3096: aastore
        3097: dup
        3098: bipush        92
        3100: aload         132
        3102: aastore
        3103: dup
        3104: bipush        93
        3106: aload         94
        3108: aastore
        3109: dup
        3110: bipush        94
        3112: aload         131
        3114: aastore
        3115: dup
        3116: bipush        95
        3118: aload         130
        3120: aastore
        3121: dup
        3122: bipush        96
        3124: aload         114
        3126: aastore
        3127: dup
        3128: bipush        97
        3130: aload         115
        3132: aastore
        3133: dup
        3134: bipush        98
        3136: aload         121
        3138: aastore
        3139: dup
        3140: bipush        99
        3142: aload         117
        3144: aastore
        3145: dup
        3146: bipush        100
        3148: aload         60
        3150: aastore
        3151: dup
        3152: bipush        101
        3154: aload         90
        3156: aastore
        3157: dup
        3158: bipush        102
        3160: aload         120
        3162: aastore
        3163: dup
        3164: bipush        103
        3166: aload         119
        3168: aastore
        3169: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3172: astore        148
        3174: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3177: bipush        45
        3179: aload         148
        3181: aastore
        3182: iconst_0
        3183: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3186: astore        149
        3188: iconst_0
        3189: istore        150
        3191: iload         150
        3193: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3196: astore        151
        3198: goto_w        3203
        3203: new           #384                // class ocaml_fn_94
        3206: dup
        3207: invokespecial #385                // Method ocaml_fn_94."<init>":()V
        3210: astore        152
        3212: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3215: bipush        46
        3217: aaload
        3218: astore        153
        3220: aload         152
        3222: aload         153
        3224: invokevirtual #389                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3227: astore        154
        3229: getstatic     #395                // Field java/lang/System.out:Ljava/io/PrintStream;
        3232: aload         154
        3234: checkcast     #14                 // class java/lang/Integer
        3237: invokevirtual #399                // Method java/lang/Integer.intValue:()I
        3240: invokevirtual #405                // Method java/io/PrintStream.println:(I)V
        3243: iconst_0
        3244: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3247: astore        155
        3249: new           #10                 // class Block
        3252: dup
        3253: iconst_0
        3254: iconst_1
        3255: anewarray     #2                  // class java/lang/Object
        3258: dup
        3259: iconst_0
        3260: aload         152
        3262: aastore
        3263: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3266: astore        156
        3268: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3271: bipush        47
        3273: aload         156
        3275: aastore
        3276: iconst_0
        3277: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3280: astore        157
        3282: iconst_0
        3283: istore        158
        3285: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3288: bipush        45
        3290: aaload
        3291: checkcast     #10                 // class Block
        3294: getfield      #408                // Field Block.fields:[Ljava/lang/Object;
        3297: bipush        102
        3299: aaload
        3300: astore        159
        3302: aload         159
        3304: checkcast     #159                // class Closure
        3307: iload         158
        3309: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3312: invokevirtual #389                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3315: astore        160
        3317: new           #10                 // class Block
        3320: dup
        3321: iconst_0
        3322: iconst_0
        3323: anewarray     #2                  // class java/lang/Object
        3326: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3329: astore        161
        3331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3334: bipush        48
        3336: aload         161
        3338: aastore
        3339: iconst_0
        3340: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3343: astore        162
        3345: return
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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: ldc           #83                 // String Test.Oops
        1008: aastore
        1009: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1012: bipush        47
        1014: iconst_0
        1015: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1018: aastore
        1019: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1022: bipush        48
        1024: iconst_0
        1025: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1028: aastore
        1029: aconst_null
        1030: astore_1
        1031: aload_1
        1032: astore_2
        1033: goto_w        1038
        1038: new           #85                 // class ocaml_fn_0
        1041: dup
        1042: invokespecial #88                 // Method ocaml_fn_0."<init>":()V
        1045: astore_3
        1046: new           #90                 // class ocaml_fn_1
        1049: dup
        1050: invokespecial #91                 // Method ocaml_fn_1."<init>":()V
        1053: astore        4
        1055: new           #93                 // class ocaml_fn_2
        1058: dup
        1059: invokespecial #94                 // Method ocaml_fn_2."<init>":()V
        1062: astore        5
        1064: new           #10                 // class Block
        1067: dup
        1068: iconst_0
        1069: iconst_3
        1070: anewarray     #2                  // class java/lang/Object
        1073: dup
        1074: iconst_0
        1075: aload         4
        1077: aastore
        1078: dup
        1079: iconst_1
        1080: aload_3
        1081: aastore
        1082: dup
        1083: iconst_2
        1084: aload         5
        1086: aastore
        1087: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1090: astore        6
        1092: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1095: bipush        12
        1097: aload         6
        1099: aastore
        1100: iconst_0
        1101: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1104: astore        7
        1106: iconst_0
        1107: istore        8
        1109: iload         8
        1111: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1114: astore        9
        1116: goto_w        1121
        1121: sipush        199
        1124: istore        10
        1126: iconst_0
        1127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1130: astore        11
        1132: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1135: bipush        35
        1137: aaload
        1138: astore        12
        1140: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1143: iconst_3
        1144: aaload
        1145: astore        13
        1147: new           #10                 // class Block
        1150: dup
        1151: iconst_0
        1152: iconst_2
        1153: anewarray     #2                  // class java/lang/Object
        1156: dup
        1157: iconst_0
        1158: aload         13
        1160: aastore
        1161: dup
        1162: iconst_1
        1163: aload         12
        1165: aastore
        1166: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1169: astore        14
        1171: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1174: bipush        36
        1176: aaload
        1177: astore        15
        1179: iconst_0
        1180: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1183: astore        16
        1185: new           #96                 // class ocaml_fn_8
        1188: dup
        1189: invokespecial #97                 // Method ocaml_fn_8."<init>":()V
        1192: astore        17
        1194: new           #99                 // class ocaml_fn_9
        1197: dup
        1198: invokespecial #100                // Method ocaml_fn_9."<init>":()V
        1201: astore        18
        1203: iconst_0
        1204: istore        19
        1206: iconst_0
        1207: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1210: astore        20
        1212: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1215: bipush        37
        1217: aaload
        1218: astore        21
        1220: new           #10                 // class Block
        1223: dup
        1224: sipush        248
        1227: iconst_2
        1228: anewarray     #2                  // class java/lang/Object
        1231: dup
        1232: iconst_0
        1233: aload         21
        1235: aastore
        1236: dup
        1237: iconst_1
        1238: aload         20
        1240: aastore
        1241: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1244: astore        22
        1246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        7
        1251: aaload
        1252: astore        23
        1254: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1257: bipush        10
        1259: aaload
        1260: astore        24
        1262: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1265: iconst_3
        1266: aaload
        1267: astore        25
        1269: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1272: iconst_2
        1273: aaload
        1274: astore        26
        1276: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1279: bipush        6
        1281: aaload
        1282: astore        27
        1284: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1287: iconst_0
        1288: aaload
        1289: astore        28
        1291: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1294: bipush        8
        1296: aaload
        1297: astore        29
        1299: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1302: iconst_1
        1303: aaload
        1304: astore        30
        1306: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1309: iconst_4
        1310: aaload
        1311: astore        31
        1313: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1316: iconst_5
        1317: aaload
        1318: astore        32
        1320: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        9
        1325: aaload
        1326: astore        33
        1328: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1331: bipush        11
        1333: aaload
        1334: astore        34
        1336: new           #102                // class ocaml_fn_10
        1339: dup
        1340: invokespecial #103                // Method ocaml_fn_10."<init>":()V
        1343: astore        35
        1345: new           #105                // class ocaml_fn_11
        1348: dup
        1349: invokespecial #106                // Method ocaml_fn_11."<init>":()V
        1352: astore        36
        1354: new           #108                // class ocaml_fn_12
        1357: dup
        1358: invokespecial #109                // Method ocaml_fn_12."<init>":()V
        1361: astore        37
        1363: new           #111                // class ocaml_fn_13
        1366: dup
        1367: invokespecial #112                // Method ocaml_fn_13."<init>":()V
        1370: astore        38
        1372: ldc           #113                // int 2147483647
        1374: istore        39
        1376: ldc           #114                // int -2147483648
        1378: istore        40
        1380: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1383: bipush        38
        1385: aaload
        1386: astore        41
        1388: ldc2_w        #115                // double 0.0d
        1391: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1394: astore        42
        1396: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1399: bipush        39
        1401: aaload
        1402: astore        43
        1404: ldc2_w        #115                // double 0.0d
        1407: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1410: astore        44
        1412: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1415: bipush        40
        1417: aaload
        1418: astore        45
        1420: ldc2_w        #115                // double 0.0d
        1423: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1426: astore        46
        1428: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1431: bipush        41
        1433: aaload
        1434: astore        47
        1436: ldc2_w        #115                // double 0.0d
        1439: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1442: astore        48
        1444: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1447: bipush        42
        1449: aaload
        1450: astore        49
        1452: ldc2_w        #115                // double 0.0d
        1455: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1458: astore        50
        1460: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1463: bipush        43
        1465: aaload
        1466: astore        51
        1468: ldc2_w        #115                // double 0.0d
        1471: invokestatic  #121                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1474: astore        52
        1476: new           #123                // class ocaml_fn_14
        1479: dup
        1480: invokespecial #124                // Method ocaml_fn_14."<init>":()V
        1483: astore        53
        1485: new           #126                // class ocaml_fn_15
        1488: dup
        1489: aload         18
        1491: invokespecial #129                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1494: astore        54
        1496: new           #131                // class ocaml_fn_16
        1499: dup
        1500: invokespecial #132                // Method ocaml_fn_16."<init>":()V
        1503: astore        55
        1505: new           #134                // class ocaml_fn_17
        1508: dup
        1509: aload         18
        1511: invokespecial #135                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1514: astore        56
        1516: new           #137                // class ocaml_fn_18
        1519: dup
        1520: invokespecial #138                // Method ocaml_fn_18."<init>":()V
        1523: astore        57
        1525: new           #140                // class ocaml_fn_19
        1528: dup
        1529: invokespecial #141                // Method ocaml_fn_19."<init>":()V
        1532: astore        58
        1534: new           #143                // class ocaml_fn_20
        1537: dup
        1538: aload         26
        1540: invokespecial #144                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1543: astore        59
        1545: new           #146                // class ocaml_fn_21
        1548: dup
        1549: aload         53
        1551: invokespecial #147                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1554: astore        60
        1556: new           #149                // class ocaml_fn_22
        1559: dup
        1560: aload         60
        1562: invokespecial #150                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1565: astore        61
        1567: new           #152                // class ocaml_fn_23
        1570: dup
        1571: aload         26
        1573: invokespecial #153                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1576: astore        62
        1578: new           #155                // class ocaml_fn_24
        1581: dup
        1582: invokespecial #156                // Method ocaml_fn_24."<init>":()V
        1585: astore        63
        1587: new           #158                // class ocaml_fn_25
        1590: dup
        1591: invokespecial #159                // Method ocaml_fn_25."<init>":()V
        1594: astore        64
        1596: aload         63
        1598: checkcast     #155                // class ocaml_fn_24
        1601: aload         63
        1603: checkcast     #161                // class Closure
        1606: putfield      #165                // Field ocaml_fn_24.sibling_0:LClosure;
        1609: iconst_0
        1610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1613: astore        65
        1615: aload         63
        1617: checkcast     #155                // class ocaml_fn_24
        1620: aload         64
        1622: checkcast     #161                // class Closure
        1625: putfield      #168                // Field ocaml_fn_24.sibling_1:LClosure;
        1628: iconst_0
        1629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1632: astore        66
        1634: aload         64
        1636: checkcast     #158                // class ocaml_fn_25
        1639: aload         63
        1641: checkcast     #161                // class Closure
        1644: putfield      #169                // Field ocaml_fn_25.sibling_0:LClosure;
        1647: iconst_0
        1648: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1651: astore        67
        1653: aload         64
        1655: checkcast     #158                // class ocaml_fn_25
        1658: aload         64
        1660: checkcast     #161                // class Closure
        1663: putfield      #170                // Field ocaml_fn_25.sibling_1:LClosure;
        1666: iconst_0
        1667: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1670: astore        68
        1672: iconst_0
        1673: istore        69
        1675: aconst_null
        1676: astore        70
        1678: iconst_1
        1679: istore        71
        1681: iload         71
        1683: invokestatic  #176                // Method Channel.forDescriptor:(I)LChannel;
        1686: astore        72
        1688: iconst_2
        1689: istore        73
        1691: iload         73
        1693: invokestatic  #176                // Method Channel.forDescriptor:(I)LChannel;
        1696: astore        74
        1698: new           #178                // class ocaml_fn_26
        1701: dup
        1702: invokespecial #179                // Method ocaml_fn_26."<init>":()V
        1705: astore        75
        1707: new           #181                // class ocaml_fn_27
        1710: dup
        1711: aload         75
        1713: invokespecial #182                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1716: astore        76
        1718: new           #184                // class ocaml_fn_28
        1721: dup
        1722: aload         75
        1724: invokespecial #185                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1727: astore        77
        1729: new           #187                // class ocaml_fn_29
        1732: dup
        1733: aload         30
        1735: invokespecial #188                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1738: astore        78
        1740: new           #190                // class ocaml_fn_30
        1743: dup
        1744: invokespecial #191                // Method ocaml_fn_30."<init>":()V
        1747: astore        79
        1749: new           #193                // class ocaml_fn_31
        1752: dup
        1753: invokespecial #194                // Method ocaml_fn_31."<init>":()V
        1756: astore        80
        1758: new           #196                // class ocaml_fn_32
        1761: dup
        1762: aload         18
        1764: invokespecial #197                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1767: astore        81
        1769: new           #199                // class ocaml_fn_33
        1772: dup
        1773: aload         18
        1775: invokespecial #200                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1778: astore        82
        1780: new           #202                // class ocaml_fn_34
        1783: dup
        1784: invokespecial #203                // Method ocaml_fn_34."<init>":()V
        1787: astore        83
        1789: new           #205                // class ocaml_fn_35
        1792: dup
        1793: invokespecial #206                // Method ocaml_fn_35."<init>":()V
        1796: astore        84
        1798: new           #208                // class ocaml_fn_36
        1801: dup
        1802: invokespecial #209                // Method ocaml_fn_36."<init>":()V
        1805: astore        85
        1807: new           #211                // class ocaml_fn_37
        1810: dup
        1811: invokespecial #212                // Method ocaml_fn_37."<init>":()V
        1814: astore        86
        1816: new           #214                // class ocaml_fn_38
        1819: dup
        1820: aload         86
        1822: invokespecial #215                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1825: astore        87
        1827: new           #217                // class ocaml_fn_39
        1830: dup
        1831: aload         86
        1833: invokespecial #218                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1836: astore        88
        1838: new           #220                // class ocaml_fn_40
        1841: dup
        1842: aload         18
        1844: invokespecial #221                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1847: astore        89
        1849: new           #223                // class ocaml_fn_41
        1852: dup
        1853: aload         31
        1855: invokespecial #224                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1858: astore        90
        1860: new           #226                // class ocaml_fn_42
        1863: dup
        1864: aload         18
        1866: aload         90
        1868: invokespecial #229                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1871: astore        91
        1873: new           #231                // class ocaml_fn_43
        1876: dup
        1877: aload         91
        1879: invokespecial #232                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1882: astore        92
        1884: new           #234                // class ocaml_fn_44
        1887: dup
        1888: aload         31
        1890: invokespecial #235                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1893: astore        93
        1895: new           #237                // class ocaml_fn_45
        1898: dup
        1899: invokespecial #238                // Method ocaml_fn_45."<init>":()V
        1902: astore        94
        1904: new           #240                // class ocaml_fn_46
        1907: dup
        1908: aload         72
        1910: invokespecial #241                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1913: astore        95
        1915: new           #243                // class ocaml_fn_47
        1918: dup
        1919: aload         72
        1921: aload         80
        1923: invokespecial #244                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1926: astore        96
        1928: new           #246                // class ocaml_fn_48
        1931: dup
        1932: aload         72
        1934: aload         79
        1936: invokespecial #247                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1939: astore        97
        1941: new           #249                // class ocaml_fn_49
        1944: dup
        1945: aload         58
        1947: aload         72
        1949: aload         80
        1951: invokespecial #252                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1954: astore        98
        1956: new           #254                // class ocaml_fn_50
        1959: dup
        1960: aload         61
        1962: aload         72
        1964: aload         80
        1966: invokespecial #255                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1969: astore        99
        1971: new           #257                // class ocaml_fn_51
        1974: dup
        1975: aload         72
        1977: aload         80
        1979: invokespecial #258                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1982: astore        100
        1984: new           #260                // class ocaml_fn_52
        1987: dup
        1988: aload         72
        1990: invokespecial #261                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1993: astore        101
        1995: new           #263                // class ocaml_fn_53
        1998: dup
        1999: aload         74
        2001: invokespecial #264                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        2004: astore        102
        2006: new           #266                // class ocaml_fn_54
        2009: dup
        2010: aload         74
        2012: aload         80
        2014: invokespecial #267                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2017: astore        103
        2019: new           #269                // class ocaml_fn_55
        2022: dup
        2023: aload         74
        2025: aload         79
        2027: invokespecial #270                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2030: astore        104
        2032: new           #272                // class ocaml_fn_56
        2035: dup
        2036: aload         58
        2038: aload         74
        2040: aload         80
        2042: invokespecial #273                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2045: astore        105
        2047: new           #275                // class ocaml_fn_57
        2050: dup
        2051: aload         61
        2053: aload         74
        2055: aload         80
        2057: invokespecial #276                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2060: astore        106
        2062: new           #278                // class ocaml_fn_58
        2065: dup
        2066: aload         74
        2068: aload         80
        2070: invokespecial #279                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2073: astore        107
        2075: new           #281                // class ocaml_fn_59
        2078: dup
        2079: aload         74
        2081: invokespecial #282                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2084: astore        108
        2086: new           #284                // class ocaml_fn_60
        2089: dup
        2090: aload         70
        2092: aload         72
        2094: aload         93
        2096: invokespecial #285                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2099: astore        109
        2101: new           #287                // class ocaml_fn_61
        2104: dup
        2105: aload         109
        2107: invokespecial #288                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2110: astore        110
        2112: new           #290                // class ocaml_fn_62
        2115: dup
        2116: aload         59
        2118: aload         109
        2120: invokespecial #291                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2123: astore        111
        2125: new           #293                // class ocaml_fn_63
        2128: dup
        2129: aload         109
        2131: invokespecial #294                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2134: astore        112
        2136: new           #296                // class ocaml_fn_64
        2139: dup
        2140: aload         62
        2142: aload         109
        2144: invokespecial #297                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2147: astore        113
        2149: new           #299                // class ocaml_fn_65
        2152: dup
        2153: invokespecial #300                // Method ocaml_fn_65."<init>":()V
        2156: astore        114
        2158: new           #302                // class ocaml_fn_66
        2161: dup
        2162: aload         53
        2164: invokespecial #303                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2167: astore        115
        2169: new           #10                 // class Block
        2172: dup
        2173: iconst_0
        2174: iconst_1
        2175: anewarray     #2                  // class java/lang/Object
        2178: dup
        2179: iconst_0
        2180: aload         78
        2182: aastore
        2183: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2186: astore        116
        2188: new           #305                // class ocaml_fn_67
        2191: dup
        2192: aload         116
        2194: invokespecial #306                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2197: astore        117
        2199: new           #308                // class ocaml_fn_68
        2202: dup
        2203: invokespecial #309                // Method ocaml_fn_68."<init>":()V
        2206: astore        118
        2208: new           #10                 // class Block
        2211: dup
        2212: iconst_0
        2213: iconst_1
        2214: anewarray     #2                  // class java/lang/Object
        2217: dup
        2218: iconst_0
        2219: aload         118
        2221: aastore
        2222: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2225: astore        119
        2227: new           #311                // class ocaml_fn_69
        2230: dup
        2231: aload         116
        2233: aload         119
        2235: invokespecial #312                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2238: astore        120
        2240: new           #314                // class ocaml_fn_70
        2243: dup
        2244: aload         120
        2246: invokespecial #315                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2249: astore        121
        2251: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2254: bipush        44
        2256: aaload
        2257: astore        122
        2259: iconst_0
        2260: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2263: astore        123
        2265: new           #317                // class ocaml_fn_71
        2268: dup
        2269: invokespecial #318                // Method ocaml_fn_71."<init>":()V
        2272: astore        124
        2274: new           #320                // class ocaml_fn_72
        2277: dup
        2278: invokespecial #321                // Method ocaml_fn_72."<init>":()V
        2281: astore        125
        2283: new           #323                // class ocaml_fn_73
        2286: dup
        2287: invokespecial #324                // Method ocaml_fn_73."<init>":()V
        2290: astore        126
        2292: new           #326                // class ocaml_fn_74
        2295: dup
        2296: invokespecial #327                // Method ocaml_fn_74."<init>":()V
        2299: astore        127
        2301: new           #329                // class ocaml_fn_75
        2304: dup
        2305: invokespecial #330                // Method ocaml_fn_75."<init>":()V
        2308: astore        128
        2310: new           #332                // class ocaml_fn_76
        2313: dup
        2314: invokespecial #333                // Method ocaml_fn_76."<init>":()V
        2317: astore        129
        2319: new           #10                 // class Block
        2322: dup
        2323: iconst_0
        2324: bipush        6
        2326: anewarray     #2                  // class java/lang/Object
        2329: dup
        2330: iconst_0
        2331: aload         129
        2333: aastore
        2334: dup
        2335: iconst_1
        2336: aload         128
        2338: aastore
        2339: dup
        2340: iconst_2
        2341: aload         127
        2343: aastore
        2344: dup
        2345: iconst_3
        2346: aload         126
        2348: aastore
        2349: dup
        2350: iconst_4
        2351: aload         125
        2353: aastore
        2354: dup
        2355: iconst_5
        2356: aload         124
        2358: aastore
        2359: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2362: astore        130
        2364: new           #335                // class ocaml_fn_77
        2367: dup
        2368: invokespecial #336                // Method ocaml_fn_77."<init>":()V
        2371: astore        131
        2373: new           #338                // class ocaml_fn_78
        2376: dup
        2377: invokespecial #339                // Method ocaml_fn_78."<init>":()V
        2380: astore        132
        2382: new           #341                // class ocaml_fn_79
        2385: dup
        2386: invokespecial #342                // Method ocaml_fn_79."<init>":()V
        2389: astore        133
        2391: new           #344                // class ocaml_fn_80
        2394: dup
        2395: invokespecial #345                // Method ocaml_fn_80."<init>":()V
        2398: astore        134
        2400: new           #347                // class ocaml_fn_81
        2403: dup
        2404: invokespecial #348                // Method ocaml_fn_81."<init>":()V
        2407: astore        135
        2409: new           #350                // class ocaml_fn_82
        2412: dup
        2413: invokespecial #351                // Method ocaml_fn_82."<init>":()V
        2416: astore        136
        2418: new           #353                // class ocaml_fn_83
        2421: dup
        2422: invokespecial #354                // Method ocaml_fn_83."<init>":()V
        2425: astore        137
        2427: new           #356                // class ocaml_fn_84
        2430: dup
        2431: invokespecial #357                // Method ocaml_fn_84."<init>":()V
        2434: astore        138
        2436: new           #359                // class ocaml_fn_85
        2439: dup
        2440: invokespecial #360                // Method ocaml_fn_85."<init>":()V
        2443: astore        139
        2445: new           #362                // class ocaml_fn_86
        2448: dup
        2449: invokespecial #363                // Method ocaml_fn_86."<init>":()V
        2452: astore        140
        2454: new           #365                // class ocaml_fn_87
        2457: dup
        2458: invokespecial #366                // Method ocaml_fn_87."<init>":()V
        2461: astore        141
        2463: new           #368                // class ocaml_fn_88
        2466: dup
        2467: invokespecial #369                // Method ocaml_fn_88."<init>":()V
        2470: astore        142
        2472: new           #371                // class ocaml_fn_89
        2475: dup
        2476: invokespecial #372                // Method ocaml_fn_89."<init>":()V
        2479: astore        143
        2481: new           #374                // class ocaml_fn_90
        2484: dup
        2485: invokespecial #375                // Method ocaml_fn_90."<init>":()V
        2488: astore        144
        2490: new           #377                // class ocaml_fn_91
        2493: dup
        2494: invokespecial #378                // Method ocaml_fn_91."<init>":()V
        2497: astore        145
        2499: new           #380                // class ocaml_fn_92
        2502: dup
        2503: invokespecial #381                // Method ocaml_fn_92."<init>":()V
        2506: astore        146
        2508: new           #383                // class ocaml_fn_93
        2511: dup
        2512: invokespecial #384                // Method ocaml_fn_93."<init>":()V
        2515: astore        147
        2517: new           #10                 // class Block
        2520: dup
        2521: iconst_0
        2522: bipush        104
        2524: anewarray     #2                  // class java/lang/Object
        2527: dup
        2528: iconst_0
        2529: aload         18
        2531: aastore
        2532: dup
        2533: iconst_1
        2534: aload         17
        2536: aastore
        2537: dup
        2538: iconst_2
        2539: aload         22
        2541: aastore
        2542: dup
        2543: iconst_3
        2544: aload         23
        2546: aastore
        2547: dup
        2548: iconst_4
        2549: aload         24
        2551: aastore
        2552: dup
        2553: iconst_5
        2554: aload         25
        2556: aastore
        2557: dup
        2558: bipush        6
        2560: aload         26
        2562: aastore
        2563: dup
        2564: bipush        7
        2566: aload         27
        2568: aastore
        2569: dup
        2570: bipush        8
        2572: aload         28
        2574: aastore
        2575: dup
        2576: bipush        9
        2578: aload         29
        2580: aastore
        2581: dup
        2582: bipush        10
        2584: aload         30
        2586: aastore
        2587: dup
        2588: bipush        11
        2590: aload         31
        2592: aastore
        2593: dup
        2594: bipush        12
        2596: aload         32
        2598: aastore
        2599: dup
        2600: bipush        13
        2602: aload         33
        2604: aastore
        2605: dup
        2606: bipush        14
        2608: aload         34
        2610: aastore
        2611: dup
        2612: bipush        15
        2614: aload         35
        2616: aastore
        2617: dup
        2618: bipush        16
        2620: aload         36
        2622: aastore
        2623: dup
        2624: bipush        17
        2626: aload         37
        2628: aastore
        2629: dup
        2630: bipush        18
        2632: iload         39
        2634: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2637: aastore
        2638: dup
        2639: bipush        19
        2641: iload         40
        2643: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2646: aastore
        2647: dup
        2648: bipush        20
        2650: aload         38
        2652: aastore
        2653: dup
        2654: bipush        21
        2656: aload         42
        2658: aastore
        2659: dup
        2660: bipush        22
        2662: aload         44
        2664: aastore
        2665: dup
        2666: bipush        23
        2668: aload         46
        2670: aastore
        2671: dup
        2672: bipush        24
        2674: aload         48
        2676: aastore
        2677: dup
        2678: bipush        25
        2680: aload         50
        2682: aastore
        2683: dup
        2684: bipush        26
        2686: aload         52
        2688: aastore
        2689: dup
        2690: bipush        27
        2692: aload         53
        2694: aastore
        2695: dup
        2696: bipush        28
        2698: aload         54
        2700: aastore
        2701: dup
        2702: bipush        29
        2704: aload         55
        2706: aastore
        2707: dup
        2708: bipush        30
        2710: aload         57
        2712: aastore
        2713: dup
        2714: bipush        31
        2716: aload         56
        2718: aastore
        2719: dup
        2720: bipush        32
        2722: aload         58
        2724: aastore
        2725: dup
        2726: bipush        33
        2728: aload         59
        2730: aastore
        2731: dup
        2732: bipush        34
        2734: aload         61
        2736: aastore
        2737: dup
        2738: bipush        35
        2740: aload         62
        2742: aastore
        2743: dup
        2744: bipush        36
        2746: aload         63
        2748: aastore
        2749: dup
        2750: bipush        37
        2752: aload         70
        2754: aastore
        2755: dup
        2756: bipush        38
        2758: aload         72
        2760: aastore
        2761: dup
        2762: bipush        39
        2764: aload         74
        2766: aastore
        2767: dup
        2768: bipush        40
        2770: aload         95
        2772: aastore
        2773: dup
        2774: bipush        41
        2776: aload         96
        2778: aastore
        2779: dup
        2780: bipush        42
        2782: aload         97
        2784: aastore
        2785: dup
        2786: bipush        43
        2788: aload         98
        2790: aastore
        2791: dup
        2792: bipush        44
        2794: aload         99
        2796: aastore
        2797: dup
        2798: bipush        45
        2800: aload         100
        2802: aastore
        2803: dup
        2804: bipush        46
        2806: aload         101
        2808: aastore
        2809: dup
        2810: bipush        47
        2812: aload         102
        2814: aastore
        2815: dup
        2816: bipush        48
        2818: aload         103
        2820: aastore
        2821: dup
        2822: bipush        49
        2824: aload         104
        2826: aastore
        2827: dup
        2828: bipush        50
        2830: aload         105
        2832: aastore
        2833: dup
        2834: bipush        51
        2836: aload         106
        2838: aastore
        2839: dup
        2840: bipush        52
        2842: aload         107
        2844: aastore
        2845: dup
        2846: bipush        53
        2848: aload         108
        2850: aastore
        2851: dup
        2852: bipush        54
        2854: aload         109
        2856: aastore
        2857: dup
        2858: bipush        55
        2860: aload         111
        2862: aastore
        2863: dup
        2864: bipush        56
        2866: aload         110
        2868: aastore
        2869: dup
        2870: bipush        57
        2872: aload         113
        2874: aastore
        2875: dup
        2876: bipush        58
        2878: aload         112
        2880: aastore
        2881: dup
        2882: bipush        59
        2884: aload         76
        2886: aastore
        2887: dup
        2888: bipush        60
        2890: aload         77
        2892: aastore
        2893: dup
        2894: bipush        61
        2896: aload         75
        2898: aastore
        2899: dup
        2900: bipush        62
        2902: aload         147
        2904: aastore
        2905: dup
        2906: bipush        63
        2908: aload         78
        2910: aastore
        2911: dup
        2912: bipush        64
        2914: aload         146
        2916: aastore
        2917: dup
        2918: bipush        65
        2920: aload         80
        2922: aastore
        2923: dup
        2924: bipush        66
        2926: aload         79
        2928: aastore
        2929: dup
        2930: bipush        67
        2932: aload         81
        2934: aastore
        2935: dup
        2936: bipush        68
        2938: aload         82
        2940: aastore
        2941: dup
        2942: bipush        69
        2944: aload         145
        2946: aastore
        2947: dup
        2948: bipush        70
        2950: aload         144
        2952: aastore
        2953: dup
        2954: bipush        71
        2956: aload         83
        2958: aastore
        2959: dup
        2960: bipush        72
        2962: aload         143
        2964: aastore
        2965: dup
        2966: bipush        73
        2968: aload         142
        2970: aastore
        2971: dup
        2972: bipush        74
        2974: aload         141
        2976: aastore
        2977: dup
        2978: bipush        75
        2980: aload         84
        2982: aastore
        2983: dup
        2984: bipush        76
        2986: aload         85
        2988: aastore
        2989: dup
        2990: bipush        77
        2992: aload         140
        2994: aastore
        2995: dup
        2996: bipush        78
        2998: aload         87
        3000: aastore
        3001: dup
        3002: bipush        79
        3004: aload         88
        3006: aastore
        3007: dup
        3008: bipush        80
        3010: aload         86
        3012: aastore
        3013: dup
        3014: bipush        81
        3016: aload         139
        3018: aastore
        3019: dup
        3020: bipush        82
        3022: aload         93
        3024: aastore
        3025: dup
        3026: bipush        83
        3028: aload         89
        3030: aastore
        3031: dup
        3032: bipush        84
        3034: aload         91
        3036: aastore
        3037: dup
        3038: bipush        85
        3040: aload         92
        3042: aastore
        3043: dup
        3044: bipush        86
        3046: aload         138
        3048: aastore
        3049: dup
        3050: bipush        87
        3052: aload         137
        3054: aastore
        3055: dup
        3056: bipush        88
        3058: aload         136
        3060: aastore
        3061: dup
        3062: bipush        89
        3064: aload         135
        3066: aastore
        3067: dup
        3068: bipush        90
        3070: aload         134
        3072: aastore
        3073: dup
        3074: bipush        91
        3076: aload         133
        3078: aastore
        3079: dup
        3080: bipush        92
        3082: aload         132
        3084: aastore
        3085: dup
        3086: bipush        93
        3088: aload         94
        3090: aastore
        3091: dup
        3092: bipush        94
        3094: aload         131
        3096: aastore
        3097: dup
        3098: bipush        95
        3100: aload         130
        3102: aastore
        3103: dup
        3104: bipush        96
        3106: aload         114
        3108: aastore
        3109: dup
        3110: bipush        97
        3112: aload         115
        3114: aastore
        3115: dup
        3116: bipush        98
        3118: aload         121
        3120: aastore
        3121: dup
        3122: bipush        99
        3124: aload         117
        3126: aastore
        3127: dup
        3128: bipush        100
        3130: aload         60
        3132: aastore
        3133: dup
        3134: bipush        101
        3136: aload         90
        3138: aastore
        3139: dup
        3140: bipush        102
        3142: aload         120
        3144: aastore
        3145: dup
        3146: bipush        103
        3148: aload         119
        3150: aastore
        3151: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3154: astore        148
        3156: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3159: bipush        45
        3161: aload         148
        3163: aastore
        3164: iconst_0
        3165: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3168: astore        149
        3170: iconst_0
        3171: istore        150
        3173: iload         150
        3175: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3178: astore        151
        3180: goto_w        3185
        3185: iconst_0
        3186: istore        152
        3188: iconst_1
        3189: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3192: astore        153
        3194: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3197: bipush        46
        3199: aaload
        3200: astore        154
        3202: new           #10                 // class Block
        3205: dup
        3206: sipush        248
        3209: iconst_2
        3210: anewarray     #2                  // class java/lang/Object
        3213: dup
        3214: iconst_0
        3215: aload         154
        3217: aastore
        3218: dup
        3219: iconst_1
        3220: aload         153
        3222: aastore
        3223: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3226: astore        155
        3228: new           #386                // class ocaml_fn_94
        3231: dup
        3232: aload         155
        3234: invokespecial #387                // Method ocaml_fn_94."<init>":(Ljava/lang/Object;)V
        3237: astore        156
        3239: iconst_0
        3240: istore        157
        3242: aload         156
        3244: iload         157
        3246: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3249: invokevirtual #391                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3252: astore        158
        3254: getstatic     #397                // Field java/lang/System.out:Ljava/io/PrintStream;
        3257: aload         158
        3259: checkcast     #14                 // class java/lang/Integer
        3262: invokevirtual #401                // Method java/lang/Integer.intValue:()I
        3265: invokevirtual #407                // Method java/io/PrintStream.println:(I)V
        3268: iconst_0
        3269: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3272: astore        159
        3274: new           #10                 // class Block
        3277: dup
        3278: iconst_0
        3279: iconst_2
        3280: anewarray     #2                  // class java/lang/Object
        3283: dup
        3284: iconst_0
        3285: aload         155
        3287: aastore
        3288: dup
        3289: iconst_1
        3290: aload         156
        3292: aastore
        3293: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3296: astore        160
        3298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3301: bipush        47
        3303: aload         160
        3305: aastore
        3306: iconst_0
        3307: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3310: astore        161
        3312: iconst_0
        3313: istore        162
        3315: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3318: bipush        45
        3320: aaload
        3321: checkcast     #10                 // class Block
        3324: getfield      #410                // Field Block.fields:[Ljava/lang/Object;
        3327: bipush        102
        3329: aaload
        3330: astore        163
        3332: aload         163
        3334: checkcast     #161                // class Closure
        3337: iload         162
        3339: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3342: invokevirtual #391                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3345: astore        164
        3347: new           #10                 // class Block
        3350: dup
        3351: iconst_0
        3352: iconst_0
        3353: anewarray     #2                  // class java/lang/Object
        3356: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3359: astore        165
        3361: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3364: bipush        48
        3366: aload         165
        3368: aastore
        3369: iconst_0
        3370: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3373: astore        166
        3375: return
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
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: new           #10                 // class Block
          15: dup
          16: sipush        248
          19: iconst_2
          20: anewarray     #2                  // class java/lang/Object
          23: dup
          24: iconst_0
          25: ldc           #12                 // String Out_of_memory
          27: aastore
          28: dup
          29: iconst_1
          30: iconst_m1
          31: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          34: aastore
          35: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          38: aastore
          39: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          42: iconst_1
          43: new           #10                 // class Block
          46: dup
          47: sipush        248
          50: iconst_2
          51: anewarray     #2                  // class java/lang/Object
          54: dup
          55: iconst_0
          56: ldc           #24                 // String Sys_error
          58: aastore
          59: dup
          60: iconst_1
          61: bipush        -2
          63: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          66: aastore
          67: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          70: aastore
          71: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          74: iconst_2
          75: new           #10                 // class Block
          78: dup
          79: sipush        248
          82: iconst_2
          83: anewarray     #2                  // class java/lang/Object
          86: dup
          87: iconst_0
          88: ldc           #26                 // String Failure
          90: aastore
          91: dup
          92: iconst_1
          93: bipush        -3
          95: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          98: aastore
          99: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         102: aastore
         103: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         106: iconst_3
         107: new           #10                 // class Block
         110: dup
         111: sipush        248
         114: iconst_2
         115: anewarray     #2                  // class java/lang/Object
         118: dup
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: dup
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         134: aastore
         135: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         138: iconst_4
         139: new           #10                 // class Block
         142: dup
         143: sipush        248
         146: iconst_2
         147: anewarray     #2                  // class java/lang/Object
         150: dup
         151: iconst_0
         152: ldc           #30                 // String End_of_file
         154: aastore
         155: dup
         156: iconst_1
         157: bipush        -5
         159: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         162: aastore
         163: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         166: aastore
         167: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         170: iconst_5
         171: new           #10                 // class Block
         174: dup
         175: sipush        248
         178: iconst_2
         179: anewarray     #2                  // class java/lang/Object
         182: dup
         183: iconst_0
         184: ldc           #32                 // String Division_by_zero
         186: aastore
         187: dup
         188: iconst_1
         189: bipush        -6
         191: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         194: aastore
         195: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         198: aastore
         199: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         202: bipush        6
         204: new           #10                 // class Block
         207: dup
         208: sipush        248
         211: iconst_2
         212: anewarray     #2                  // class java/lang/Object
         215: dup
         216: iconst_0
         217: ldc           #34                 // String Not_found
         219: aastore
         220: dup
         221: iconst_1
         222: bipush        -7
         224: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         227: aastore
         228: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         231: aastore
         232: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         235: bipush        7
         237: new           #10                 // class Block
         240: dup
         241: sipush        248
         244: iconst_2
         245: anewarray     #2                  // class java/lang/Object
         248: dup
         249: iconst_0
         250: ldc           #36                 // String Match_failure
         252: aastore
         253: dup
         254: iconst_1
         255: bipush        -8
         257: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         260: aastore
         261: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         264: aastore
         265: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         268: bipush        8
         270: new           #10                 // class Block
         273: dup
         274: sipush        248
         277: iconst_2
         278: anewarray     #2                  // class java/lang/Object
         281: dup
         282: iconst_0
         283: ldc           #38                 // String Stack_overflow
         285: aastore
         286: dup
         287: iconst_1
         288: bipush        -9
         290: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         293: aastore
         294: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         297: aastore
         298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         301: bipush        9
         303: new           #10                 // class Block
         306: dup
         307: sipush        248
         310: iconst_2
         311: anewarray     #2                  // class java/lang/Object
         314: dup
         315: iconst_0
         316: ldc           #40                 // String Sys_blocked_io
         318: aastore
         319: dup
         320: iconst_1
         321: bipush        -10
         323: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         326: aastore
         327: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         330: aastore
         331: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         334: bipush        10
         336: new           #10                 // class Block
         339: dup
         340: sipush        248
         343: iconst_2
         344: anewarray     #2                  // class java/lang/Object
         347: dup
         348: iconst_0
         349: ldc           #42                 // String Assert_failure
         351: aastore
         352: dup
         353: iconst_1
         354: bipush        -11
         356: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         359: aastore
         360: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         363: aastore
         364: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         367: bipush        11
         369: new           #10                 // class Block
         372: dup
         373: sipush        248
         376: iconst_2
         377: anewarray     #2                  // class java/lang/Object
         380: dup
         381: iconst_0
         382: ldc           #44                 // String Undefined_recursive_module
         384: aastore
         385: dup
         386: iconst_1
         387: bipush        -12
         389: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         392: aastore
         393: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         396: aastore
         397: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         400: bipush        12
         402: iconst_0
         403: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         406: aastore
         407: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         410: bipush        13
         412: ldc           #46                 // String %,
         414: aastore
         415: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         418: bipush        14
         420: ldc           #48                 // String really_input
         422: aastore
         423: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         426: bipush        15
         428: ldc           #50                 // String input
         430: aastore
         431: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         434: bipush        16
         436: new           #10                 // class Block
         439: dup
         440: iconst_0
         441: iconst_2
         442: anewarray     #2                  // class java/lang/Object
         445: dup
         446: iconst_0
         447: iconst_0
         448: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         451: aastore
         452: dup
         453: iconst_1
         454: new           #10                 // class Block
         457: dup
         458: iconst_0
         459: iconst_2
         460: anewarray     #2                  // class java/lang/Object
         463: dup
         464: iconst_0
         465: bipush        6
         467: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         470: aastore
         471: dup
         472: iconst_1
         473: iconst_0
         474: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         477: aastore
         478: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         481: aastore
         482: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         485: aastore
         486: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         489: bipush        17
         491: new           #10                 // class Block
         494: dup
         495: iconst_0
         496: iconst_2
         497: anewarray     #2                  // class java/lang/Object
         500: dup
         501: iconst_0
         502: iconst_0
         503: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         506: aastore
         507: dup
         508: iconst_1
         509: new           #10                 // class Block
         512: dup
         513: iconst_0
         514: iconst_2
         515: anewarray     #2                  // class java/lang/Object
         518: dup
         519: iconst_0
         520: bipush        7
         522: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         525: aastore
         526: dup
         527: iconst_1
         528: iconst_0
         529: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         532: aastore
         533: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         536: aastore
         537: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         540: aastore
         541: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         544: bipush        18
         546: ldc           #52                 // String output_substring
         548: aastore
         549: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         552: bipush        19
         554: ldc           #54                 // String output
         556: aastore
         557: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         560: bipush        20
         562: new           #10                 // class Block
         565: dup
         566: iconst_0
         567: iconst_2
         568: anewarray     #2                  // class java/lang/Object
         571: dup
         572: iconst_0
         573: iconst_1
         574: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         577: aastore
         578: dup
         579: iconst_1
         580: new           #10                 // class Block
         583: dup
         584: iconst_0
         585: iconst_2
         586: anewarray     #2                  // class java/lang/Object
         589: dup
         590: iconst_0
         591: iconst_3
         592: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: dup
         597: iconst_1
         598: new           #10                 // class Block
         601: dup
         602: iconst_0
         603: iconst_2
         604: anewarray     #2                  // class java/lang/Object
         607: dup
         608: iconst_0
         609: iconst_4
         610: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         613: aastore
         614: dup
         615: iconst_1
         616: new           #10                 // class Block
         619: dup
         620: iconst_0
         621: iconst_2
         622: anewarray     #2                  // class java/lang/Object
         625: dup
         626: iconst_0
         627: bipush        6
         629: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         632: aastore
         633: dup
         634: iconst_1
         635: iconst_0
         636: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         639: aastore
         640: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         643: aastore
         644: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         647: aastore
         648: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         651: aastore
         652: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         655: aastore
         656: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         659: bipush        21
         661: new           #10                 // class Block
         664: dup
         665: iconst_0
         666: iconst_2
         667: anewarray     #2                  // class java/lang/Object
         670: dup
         671: iconst_0
         672: iconst_1
         673: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         676: aastore
         677: dup
         678: iconst_1
         679: new           #10                 // class Block
         682: dup
         683: iconst_0
         684: iconst_2
         685: anewarray     #2                  // class java/lang/Object
         688: dup
         689: iconst_0
         690: iconst_3
         691: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         694: aastore
         695: dup
         696: iconst_1
         697: new           #10                 // class Block
         700: dup
         701: iconst_0
         702: iconst_2
         703: anewarray     #2                  // class java/lang/Object
         706: dup
         707: iconst_0
         708: iconst_4
         709: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         712: aastore
         713: dup
         714: iconst_1
         715: new           #10                 // class Block
         718: dup
         719: iconst_0
         720: iconst_2
         721: anewarray     #2                  // class java/lang/Object
         724: dup
         725: iconst_0
         726: bipush        7
         728: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         731: aastore
         732: dup
         733: iconst_1
         734: iconst_0
         735: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         738: aastore
         739: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         742: aastore
         743: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         746: aastore
         747: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         750: aastore
         751: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         754: aastore
         755: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         758: bipush        22
         760: ldc           #56                 // String %.12g
         762: aastore
         763: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         766: bipush        23
         768: ldc           #58                 // String .
         770: aastore
         771: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         774: bipush        24
         776: ldc           #60                 // String %d
         778: aastore
         779: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         782: bipush        25
         784: ldc           #62                 // String false
         786: aastore
         787: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         790: bipush        26
         792: ldc           #64                 // String true
         794: aastore
         795: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         798: bipush        27
         800: new           #10                 // class Block
         803: dup
         804: iconst_0
         805: iconst_1
         806: anewarray     #2                  // class java/lang/Object
         809: dup
         810: iconst_0
         811: iconst_1
         812: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         815: aastore
         816: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         819: aastore
         820: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         823: bipush        28
         825: new           #10                 // class Block
         828: dup
         829: iconst_0
         830: iconst_1
         831: anewarray     #2                  // class java/lang/Object
         834: dup
         835: iconst_0
         836: iconst_0
         837: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         840: aastore
         841: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         844: aastore
         845: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         848: bipush        29
         850: ldc           #62                 // String false
         852: aastore
         853: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         856: bipush        30
         858: ldc           #64                 // String true
         860: aastore
         861: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         864: bipush        31
         866: ldc           #66                 // String bool_of_string
         868: aastore
         869: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         872: bipush        32
         874: ldc           #64                 // String true
         876: aastore
         877: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         880: bipush        33
         882: ldc           #62                 // String false
         884: aastore
         885: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         888: bipush        34
         890: ldc           #68                 // String char_of_int
         892: aastore
         893: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         896: bipush        35
         898: ldc           #70                 // String index out of bounds
         900: aastore
         901: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         904: bipush        36
         906: ldc           #72                 // String Pervasives.array_bound_error
         908: aastore
         909: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         912: bipush        37
         914: ldc           #74                 // String Stdlib.Exit
         916: aastore
         917: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         920: bipush        38
         922: ldc           #75                 // int 0
         924: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         927: aastore
         928: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         931: bipush        39
         933: ldc           #75                 // int 0
         935: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         938: aastore
         939: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         942: bipush        40
         944: ldc           #76                 // int 1
         946: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         949: aastore
         950: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         953: bipush        41
         955: ldc           #77                 // int -1
         957: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         960: aastore
         961: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         964: bipush        42
         966: ldc           #78                 // int 0
         968: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         971: aastore
         972: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         975: bipush        43
         977: ldc           #79                 // int 0
         979: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         982: aastore
         983: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         986: bipush        44
         988: ldc           #81                 // String Pervasives.do_at_exit
         990: aastore
         991: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         994: bipush        45
         996: iconst_0
         997: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1000: aastore
        1001: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1004: bipush        46
        1006: iconst_0
        1007: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1010: aastore
        1011: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1014: bipush        47
        1016: iconst_0
        1017: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1020: aastore
        1021: aconst_null
        1022: astore_1
        1023: aload_1
        1024: astore_2
        1025: goto_w        1030
        1030: new           #83                 // class ocaml_fn_0
        1033: dup
        1034: invokespecial #86                 // Method ocaml_fn_0."<init>":()V
        1037: astore_3
        1038: new           #88                 // class ocaml_fn_1
        1041: dup
        1042: invokespecial #89                 // Method ocaml_fn_1."<init>":()V
        1045: astore        4
        1047: new           #91                 // class ocaml_fn_2
        1050: dup
        1051: invokespecial #92                 // Method ocaml_fn_2."<init>":()V
        1054: astore        5
        1056: new           #10                 // class Block
        1059: dup
        1060: iconst_0
        1061: iconst_3
        1062: anewarray     #2                  // class java/lang/Object
        1065: dup
        1066: iconst_0
        1067: aload         4
        1069: aastore
        1070: dup
        1071: iconst_1
        1072: aload_3
        1073: aastore
        1074: dup
        1075: iconst_2
        1076: aload         5
        1078: aastore
        1079: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1082: astore        6
        1084: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1087: bipush        12
        1089: aload         6
        1091: aastore
        1092: iconst_0
        1093: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1096: astore        7
        1098: iconst_0
        1099: istore        8
        1101: iload         8
        1103: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1106: astore        9
        1108: goto_w        1113
        1113: sipush        199
        1116: istore        10
        1118: iconst_0
        1119: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1122: astore        11
        1124: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1127: bipush        35
        1129: aaload
        1130: astore        12
        1132: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1135: iconst_3
        1136: aaload
        1137: astore        13
        1139: new           #10                 // class Block
        1142: dup
        1143: iconst_0
        1144: iconst_2
        1145: anewarray     #2                  // class java/lang/Object
        1148: dup
        1149: iconst_0
        1150: aload         13
        1152: aastore
        1153: dup
        1154: iconst_1
        1155: aload         12
        1157: aastore
        1158: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1161: astore        14
        1163: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1166: bipush        36
        1168: aaload
        1169: astore        15
        1171: iconst_0
        1172: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1175: astore        16
        1177: new           #94                 // class ocaml_fn_8
        1180: dup
        1181: invokespecial #95                 // Method ocaml_fn_8."<init>":()V
        1184: astore        17
        1186: new           #97                 // class ocaml_fn_9
        1189: dup
        1190: invokespecial #98                 // Method ocaml_fn_9."<init>":()V
        1193: astore        18
        1195: iconst_0
        1196: istore        19
        1198: iconst_0
        1199: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1202: astore        20
        1204: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1207: bipush        37
        1209: aaload
        1210: astore        21
        1212: new           #10                 // class Block
        1215: dup
        1216: sipush        248
        1219: iconst_2
        1220: anewarray     #2                  // class java/lang/Object
        1223: dup
        1224: iconst_0
        1225: aload         21
        1227: aastore
        1228: dup
        1229: iconst_1
        1230: aload         20
        1232: aastore
        1233: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1236: astore        22
        1238: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1241: bipush        7
        1243: aaload
        1244: astore        23
        1246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1249: bipush        10
        1251: aaload
        1252: astore        24
        1254: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1257: iconst_3
        1258: aaload
        1259: astore        25
        1261: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1264: iconst_2
        1265: aaload
        1266: astore        26
        1268: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1271: bipush        6
        1273: aaload
        1274: astore        27
        1276: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1279: iconst_0
        1280: aaload
        1281: astore        28
        1283: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1286: bipush        8
        1288: aaload
        1289: astore        29
        1291: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1294: iconst_1
        1295: aaload
        1296: astore        30
        1298: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1301: iconst_4
        1302: aaload
        1303: astore        31
        1305: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1308: iconst_5
        1309: aaload
        1310: astore        32
        1312: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1315: bipush        9
        1317: aaload
        1318: astore        33
        1320: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1323: bipush        11
        1325: aaload
        1326: astore        34
        1328: new           #100                // class ocaml_fn_10
        1331: dup
        1332: invokespecial #101                // Method ocaml_fn_10."<init>":()V
        1335: astore        35
        1337: new           #103                // class ocaml_fn_11
        1340: dup
        1341: invokespecial #104                // Method ocaml_fn_11."<init>":()V
        1344: astore        36
        1346: new           #106                // class ocaml_fn_12
        1349: dup
        1350: invokespecial #107                // Method ocaml_fn_12."<init>":()V
        1353: astore        37
        1355: new           #109                // class ocaml_fn_13
        1358: dup
        1359: invokespecial #110                // Method ocaml_fn_13."<init>":()V
        1362: astore        38
        1364: ldc           #111                // int 2147483647
        1366: istore        39
        1368: ldc           #112                // int -2147483648
        1370: istore        40
        1372: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1375: bipush        38
        1377: aaload
        1378: astore        41
        1380: ldc2_w        #113                // double 0.0d
        1383: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1386: astore        42
        1388: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1391: bipush        39
        1393: aaload
        1394: astore        43
        1396: ldc2_w        #113                // double 0.0d
        1399: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1402: astore        44
        1404: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1407: bipush        40
        1409: aaload
        1410: astore        45
        1412: ldc2_w        #113                // double 0.0d
        1415: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1418: astore        46
        1420: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1423: bipush        41
        1425: aaload
        1426: astore        47
        1428: ldc2_w        #113                // double 0.0d
        1431: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1434: astore        48
        1436: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1439: bipush        42
        1441: aaload
        1442: astore        49
        1444: ldc2_w        #113                // double 0.0d
        1447: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1450: astore        50
        1452: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        1455: bipush        43
        1457: aaload
        1458: astore        51
        1460: ldc2_w        #113                // double 0.0d
        1463: invokestatic  #119                // Method java/lang/Double.valueOf:(D)Ljava/lang/Double;
        1466: astore        52
        1468: new           #121                // class ocaml_fn_14
        1471: dup
        1472: invokespecial #122                // Method ocaml_fn_14."<init>":()V
        1475: astore        53
        1477: new           #124                // class ocaml_fn_15
        1480: dup
        1481: aload         18
        1483: invokespecial #127                // Method ocaml_fn_15."<init>":(Ljava/lang/Object;)V
        1486: astore        54
        1488: new           #129                // class ocaml_fn_16
        1491: dup
        1492: invokespecial #130                // Method ocaml_fn_16."<init>":()V
        1495: astore        55
        1497: new           #132                // class ocaml_fn_17
        1500: dup
        1501: aload         18
        1503: invokespecial #133                // Method ocaml_fn_17."<init>":(Ljava/lang/Object;)V
        1506: astore        56
        1508: new           #135                // class ocaml_fn_18
        1511: dup
        1512: invokespecial #136                // Method ocaml_fn_18."<init>":()V
        1515: astore        57
        1517: new           #138                // class ocaml_fn_19
        1520: dup
        1521: invokespecial #139                // Method ocaml_fn_19."<init>":()V
        1524: astore        58
        1526: new           #141                // class ocaml_fn_20
        1529: dup
        1530: aload         26
        1532: invokespecial #142                // Method ocaml_fn_20."<init>":(Ljava/lang/Object;)V
        1535: astore        59
        1537: new           #144                // class ocaml_fn_21
        1540: dup
        1541: aload         53
        1543: invokespecial #145                // Method ocaml_fn_21."<init>":(Ljava/lang/Object;)V
        1546: astore        60
        1548: new           #147                // class ocaml_fn_22
        1551: dup
        1552: aload         60
        1554: invokespecial #148                // Method ocaml_fn_22."<init>":(Ljava/lang/Object;)V
        1557: astore        61
        1559: new           #150                // class ocaml_fn_23
        1562: dup
        1563: aload         26
        1565: invokespecial #151                // Method ocaml_fn_23."<init>":(Ljava/lang/Object;)V
        1568: astore        62
        1570: new           #153                // class ocaml_fn_24
        1573: dup
        1574: invokespecial #154                // Method ocaml_fn_24."<init>":()V
        1577: astore        63
        1579: new           #156                // class ocaml_fn_25
        1582: dup
        1583: invokespecial #157                // Method ocaml_fn_25."<init>":()V
        1586: astore        64
        1588: aload         63
        1590: checkcast     #153                // class ocaml_fn_24
        1593: aload         63
        1595: checkcast     #159                // class Closure
        1598: putfield      #163                // Field ocaml_fn_24.sibling_0:LClosure;
        1601: iconst_0
        1602: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1605: astore        65
        1607: aload         63
        1609: checkcast     #153                // class ocaml_fn_24
        1612: aload         64
        1614: checkcast     #159                // class Closure
        1617: putfield      #166                // Field ocaml_fn_24.sibling_1:LClosure;
        1620: iconst_0
        1621: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1624: astore        66
        1626: aload         64
        1628: checkcast     #156                // class ocaml_fn_25
        1631: aload         63
        1633: checkcast     #159                // class Closure
        1636: putfield      #167                // Field ocaml_fn_25.sibling_0:LClosure;
        1639: iconst_0
        1640: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1643: astore        67
        1645: aload         64
        1647: checkcast     #156                // class ocaml_fn_25
        1650: aload         64
        1652: checkcast     #159                // class Closure
        1655: putfield      #168                // Field ocaml_fn_25.sibling_1:LClosure;
        1658: iconst_0
        1659: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1662: astore        68
        1664: iconst_0
        1665: istore        69
        1667: aconst_null
        1668: astore        70
        1670: iconst_1
        1671: istore        71
        1673: iload         71
        1675: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1678: astore        72
        1680: iconst_2
        1681: istore        73
        1683: iload         73
        1685: invokestatic  #174                // Method Channel.forDescriptor:(I)LChannel;
        1688: astore        74
        1690: new           #176                // class ocaml_fn_26
        1693: dup
        1694: invokespecial #177                // Method ocaml_fn_26."<init>":()V
        1697: astore        75
        1699: new           #179                // class ocaml_fn_27
        1702: dup
        1703: aload         75
        1705: invokespecial #180                // Method ocaml_fn_27."<init>":(Ljava/lang/Object;)V
        1708: astore        76
        1710: new           #182                // class ocaml_fn_28
        1713: dup
        1714: aload         75
        1716: invokespecial #183                // Method ocaml_fn_28."<init>":(Ljava/lang/Object;)V
        1719: astore        77
        1721: new           #185                // class ocaml_fn_29
        1724: dup
        1725: aload         30
        1727: invokespecial #186                // Method ocaml_fn_29."<init>":(Ljava/lang/Object;)V
        1730: astore        78
        1732: new           #188                // class ocaml_fn_30
        1735: dup
        1736: invokespecial #189                // Method ocaml_fn_30."<init>":()V
        1739: astore        79
        1741: new           #191                // class ocaml_fn_31
        1744: dup
        1745: invokespecial #192                // Method ocaml_fn_31."<init>":()V
        1748: astore        80
        1750: new           #194                // class ocaml_fn_32
        1753: dup
        1754: aload         18
        1756: invokespecial #195                // Method ocaml_fn_32."<init>":(Ljava/lang/Object;)V
        1759: astore        81
        1761: new           #197                // class ocaml_fn_33
        1764: dup
        1765: aload         18
        1767: invokespecial #198                // Method ocaml_fn_33."<init>":(Ljava/lang/Object;)V
        1770: astore        82
        1772: new           #200                // class ocaml_fn_34
        1775: dup
        1776: invokespecial #201                // Method ocaml_fn_34."<init>":()V
        1779: astore        83
        1781: new           #203                // class ocaml_fn_35
        1784: dup
        1785: invokespecial #204                // Method ocaml_fn_35."<init>":()V
        1788: astore        84
        1790: new           #206                // class ocaml_fn_36
        1793: dup
        1794: invokespecial #207                // Method ocaml_fn_36."<init>":()V
        1797: astore        85
        1799: new           #209                // class ocaml_fn_37
        1802: dup
        1803: invokespecial #210                // Method ocaml_fn_37."<init>":()V
        1806: astore        86
        1808: new           #212                // class ocaml_fn_38
        1811: dup
        1812: aload         86
        1814: invokespecial #213                // Method ocaml_fn_38."<init>":(Ljava/lang/Object;)V
        1817: astore        87
        1819: new           #215                // class ocaml_fn_39
        1822: dup
        1823: aload         86
        1825: invokespecial #216                // Method ocaml_fn_39."<init>":(Ljava/lang/Object;)V
        1828: astore        88
        1830: new           #218                // class ocaml_fn_40
        1833: dup
        1834: aload         18
        1836: invokespecial #219                // Method ocaml_fn_40."<init>":(Ljava/lang/Object;)V
        1839: astore        89
        1841: new           #221                // class ocaml_fn_41
        1844: dup
        1845: aload         31
        1847: invokespecial #222                // Method ocaml_fn_41."<init>":(Ljava/lang/Object;)V
        1850: astore        90
        1852: new           #224                // class ocaml_fn_42
        1855: dup
        1856: aload         18
        1858: aload         90
        1860: invokespecial #227                // Method ocaml_fn_42."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1863: astore        91
        1865: new           #229                // class ocaml_fn_43
        1868: dup
        1869: aload         91
        1871: invokespecial #230                // Method ocaml_fn_43."<init>":(Ljava/lang/Object;)V
        1874: astore        92
        1876: new           #232                // class ocaml_fn_44
        1879: dup
        1880: aload         31
        1882: invokespecial #233                // Method ocaml_fn_44."<init>":(Ljava/lang/Object;)V
        1885: astore        93
        1887: new           #235                // class ocaml_fn_45
        1890: dup
        1891: invokespecial #236                // Method ocaml_fn_45."<init>":()V
        1894: astore        94
        1896: new           #238                // class ocaml_fn_46
        1899: dup
        1900: aload         72
        1902: invokespecial #239                // Method ocaml_fn_46."<init>":(Ljava/lang/Object;)V
        1905: astore        95
        1907: new           #241                // class ocaml_fn_47
        1910: dup
        1911: aload         72
        1913: aload         80
        1915: invokespecial #242                // Method ocaml_fn_47."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1918: astore        96
        1920: new           #244                // class ocaml_fn_48
        1923: dup
        1924: aload         72
        1926: aload         79
        1928: invokespecial #245                // Method ocaml_fn_48."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1931: astore        97
        1933: new           #247                // class ocaml_fn_49
        1936: dup
        1937: aload         58
        1939: aload         72
        1941: aload         80
        1943: invokespecial #250                // Method ocaml_fn_49."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1946: astore        98
        1948: new           #252                // class ocaml_fn_50
        1951: dup
        1952: aload         61
        1954: aload         72
        1956: aload         80
        1958: invokespecial #253                // Method ocaml_fn_50."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        1961: astore        99
        1963: new           #255                // class ocaml_fn_51
        1966: dup
        1967: aload         72
        1969: aload         80
        1971: invokespecial #256                // Method ocaml_fn_51."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        1974: astore        100
        1976: new           #258                // class ocaml_fn_52
        1979: dup
        1980: aload         72
        1982: invokespecial #259                // Method ocaml_fn_52."<init>":(Ljava/lang/Object;)V
        1985: astore        101
        1987: new           #261                // class ocaml_fn_53
        1990: dup
        1991: aload         74
        1993: invokespecial #262                // Method ocaml_fn_53."<init>":(Ljava/lang/Object;)V
        1996: astore        102
        1998: new           #264                // class ocaml_fn_54
        2001: dup
        2002: aload         74
        2004: aload         80
        2006: invokespecial #265                // Method ocaml_fn_54."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2009: astore        103
        2011: new           #267                // class ocaml_fn_55
        2014: dup
        2015: aload         74
        2017: aload         79
        2019: invokespecial #268                // Method ocaml_fn_55."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2022: astore        104
        2024: new           #270                // class ocaml_fn_56
        2027: dup
        2028: aload         58
        2030: aload         74
        2032: aload         80
        2034: invokespecial #271                // Method ocaml_fn_56."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2037: astore        105
        2039: new           #273                // class ocaml_fn_57
        2042: dup
        2043: aload         61
        2045: aload         74
        2047: aload         80
        2049: invokespecial #274                // Method ocaml_fn_57."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2052: astore        106
        2054: new           #276                // class ocaml_fn_58
        2057: dup
        2058: aload         74
        2060: aload         80
        2062: invokespecial #277                // Method ocaml_fn_58."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2065: astore        107
        2067: new           #279                // class ocaml_fn_59
        2070: dup
        2071: aload         74
        2073: invokespecial #280                // Method ocaml_fn_59."<init>":(Ljava/lang/Object;)V
        2076: astore        108
        2078: new           #282                // class ocaml_fn_60
        2081: dup
        2082: aload         70
        2084: aload         72
        2086: aload         93
        2088: invokespecial #283                // Method ocaml_fn_60."<init>":(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)V
        2091: astore        109
        2093: new           #285                // class ocaml_fn_61
        2096: dup
        2097: aload         109
        2099: invokespecial #286                // Method ocaml_fn_61."<init>":(Ljava/lang/Object;)V
        2102: astore        110
        2104: new           #288                // class ocaml_fn_62
        2107: dup
        2108: aload         59
        2110: aload         109
        2112: invokespecial #289                // Method ocaml_fn_62."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2115: astore        111
        2117: new           #291                // class ocaml_fn_63
        2120: dup
        2121: aload         109
        2123: invokespecial #292                // Method ocaml_fn_63."<init>":(Ljava/lang/Object;)V
        2126: astore        112
        2128: new           #294                // class ocaml_fn_64
        2131: dup
        2132: aload         62
        2134: aload         109
        2136: invokespecial #295                // Method ocaml_fn_64."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2139: astore        113
        2141: new           #297                // class ocaml_fn_65
        2144: dup
        2145: invokespecial #298                // Method ocaml_fn_65."<init>":()V
        2148: astore        114
        2150: new           #300                // class ocaml_fn_66
        2153: dup
        2154: aload         53
        2156: invokespecial #301                // Method ocaml_fn_66."<init>":(Ljava/lang/Object;)V
        2159: astore        115
        2161: new           #10                 // class Block
        2164: dup
        2165: iconst_0
        2166: iconst_1
        2167: anewarray     #2                  // class java/lang/Object
        2170: dup
        2171: iconst_0
        2172: aload         78
        2174: aastore
        2175: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2178: astore        116
        2180: new           #303                // class ocaml_fn_67
        2183: dup
        2184: aload         116
        2186: invokespecial #304                // Method ocaml_fn_67."<init>":(Ljava/lang/Object;)V
        2189: astore        117
        2191: new           #306                // class ocaml_fn_68
        2194: dup
        2195: invokespecial #307                // Method ocaml_fn_68."<init>":()V
        2198: astore        118
        2200: new           #10                 // class Block
        2203: dup
        2204: iconst_0
        2205: iconst_1
        2206: anewarray     #2                  // class java/lang/Object
        2209: dup
        2210: iconst_0
        2211: aload         118
        2213: aastore
        2214: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2217: astore        119
        2219: new           #309                // class ocaml_fn_69
        2222: dup
        2223: aload         116
        2225: aload         119
        2227: invokespecial #310                // Method ocaml_fn_69."<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
        2230: astore        120
        2232: new           #312                // class ocaml_fn_70
        2235: dup
        2236: aload         120
        2238: invokespecial #313                // Method ocaml_fn_70."<init>":(Ljava/lang/Object;)V
        2241: astore        121
        2243: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        2246: bipush        44
        2248: aaload
        2249: astore        122
        2251: iconst_0
        2252: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2255: astore        123
        2257: new           #315                // class ocaml_fn_71
        2260: dup
        2261: invokespecial #316                // Method ocaml_fn_71."<init>":()V
        2264: astore        124
        2266: new           #318                // class ocaml_fn_72
        2269: dup
        2270: invokespecial #319                // Method ocaml_fn_72."<init>":()V
        2273: astore        125
        2275: new           #321                // class ocaml_fn_73
        2278: dup
        2279: invokespecial #322                // Method ocaml_fn_73."<init>":()V
        2282: astore        126
        2284: new           #324                // class ocaml_fn_74
        2287: dup
        2288: invokespecial #325                // Method ocaml_fn_74."<init>":()V
        2291: astore        127
        2293: new           #327                // class ocaml_fn_75
        2296: dup
        2297: invokespecial #328                // Method ocaml_fn_75."<init>":()V
        2300: astore        128
        2302: new           #330                // class ocaml_fn_76
        2305: dup
        2306: invokespecial #331                // Method ocaml_fn_76."<init>":()V
        2309: astore        129
        2311: new           #10                 // class Block
        2314: dup
        2315: iconst_0
        2316: bipush        6
        2318: anewarray     #2                  // class java/lang/Object
        2321: dup
        2322: iconst_0
        2323: aload         129
        2325: aastore
        2326: dup
        2327: iconst_1
        2328: aload         128
        2330: aastore
        2331: dup
        2332: iconst_2
        2333: aload         127
        2335: aastore
        2336: dup
        2337: iconst_3
        2338: aload         126
        2340: aastore
        2341: dup
        2342: iconst_4
        2343: aload         125
        2345: aastore
        2346: dup
        2347: iconst_5
        2348: aload         124
        2350: aastore
        2351: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        2354: astore        130
        2356: new           #333                // class ocaml_fn_77
        2359: dup
        2360: invokespecial #334                // Method ocaml_fn_77."<init>":()V
        2363: astore        131
        2365: new           #336                // class ocaml_fn_78
        2368: dup
        2369: invokespecial #337                // Method ocaml_fn_78."<init>":()V
        2372: astore        132
        2374: new           #339                // class ocaml_fn_79
        2377: dup
        2378: invokespecial #340                // Method ocaml_fn_79."<init>":()V
        2381: astore        133
        2383: new           #342                // class ocaml_fn_80
        2386: dup
        2387: invokespecial #343                // Method ocaml_fn_80."<init>":()V
        2390: astore        134
        2392: new           #345                // class ocaml_fn_81
        2395: dup
        2396: invokespecial #346                // Method ocaml_fn_81."<init>":()V
        2399: astore        135
        2401: new           #348                // class ocaml_fn_82
        2404: dup
        2405: invokespecial #349                // Method ocaml_fn_82."<init>":()V
        2408: astore        136
        2410: new           #351                // class ocaml_fn_83
        2413: dup
        2414: invokespecial #352                // Method ocaml_fn_83."<init>":()V
        2417: astore        137
        2419: new           #354                // class ocaml_fn_84
        2422: dup
        2423: invokespecial #355                // Method ocaml_fn_84."<init>":()V
        2426: astore        138
        2428: new           #357                // class ocaml_fn_85
        2431: dup
        2432: invokespecial #358                // Method ocaml_fn_85."<init>":()V
        2435: astore        139
        2437: new           #360                // class ocaml_fn_86
        2440: dup
        2441: invokespecial #361                // Method ocaml_fn_86."<init>":()V
        2444: astore        140
        2446: new           #363                // class ocaml_fn_87
        2449: dup
        2450: invokespecial #364                // Method ocaml_fn_87."<init>":()V
        2453: astore        141
        2455: new           #366                // class ocaml_fn_88
        2458: dup
        2459: invokespecial #367                // Method ocaml_fn_88."<init>":()V
        2462: astore        142
        2464: new           #369                // class ocaml_fn_89
        2467: dup
        2468: invokespecial #370                // Method ocaml_fn_89."<init>":()V
        2471: astore        143
        2473: new           #372                // class ocaml_fn_90
        2476: dup
        2477: invokespecial #373                // Method ocaml_fn_90."<init>":()V
        2480: astore        144
        2482: new           #375                // class ocaml_fn_91
        2485: dup
        2486: invokespecial #376                // Method ocaml_fn_91."<init>":()V
        2489: astore        145
        2491: new           #378                // class ocaml_fn_92
        2494: dup
        2495: invokespecial #379                // Method ocaml_fn_92."<init>":()V
        2498: astore        146
        2500: new           #381                // class ocaml_fn_93
        2503: dup
        2504: invokespecial #382                // Method ocaml_fn_93."<init>":()V
        2507: astore        147
        2509: new           #10                 // class Block
        2512: dup
        2513: iconst_0
        2514: bipush        104
        2516: anewarray     #2                  // class java/lang/Object
        2519: dup
        2520: iconst_0
        2521: aload         18
        2523: aastore
        2524: dup
        2525: iconst_1
        2526: aload         17
        2528: aastore
        2529: dup
        2530: iconst_2
        2531: aload         22
        2533: aastore
        2534: dup
        2535: iconst_3
        2536: aload         23
        2538: aastore
        2539: dup
        2540: iconst_4
        2541: aload         24
        2543: aastore
        2544: dup
        2545: iconst_5
        2546: aload         25
        2548: aastore
        2549: dup
        2550: bipush        6
        2552: aload         26
        2554: aastore
        2555: dup
        2556: bipush        7
        2558: aload         27
        2560: aastore
        2561: dup
        2562: bipush        8
        2564: aload         28
        2566: aastore
        2567: dup
        2568: bipush        9
        2570: aload         29
        2572: aastore
        2573: dup
        2574: bipush        10
        2576: aload         30
        2578: aastore
        2579: dup
        2580: bipush        11
        2582: aload         31
        2584: aastore
        2585: dup
        2586: bipush        12
        2588: aload         32
        2590: aastore
        2591: dup
        2592: bipush        13
        2594: aload         33
        2596: aastore
        2597: dup
        2598: bipush        14
        2600: aload         34
        2602: aastore
        2603: dup
        2604: bipush        15
        2606: aload         35
        2608: aastore
        2609: dup
        2610: bipush        16
        2612: aload         36
        2614: aastore
        2615: dup
        2616: bipush        17
        2618: aload         37
        2620: aastore
        2621: dup
        2622: bipush        18
        2624: iload         39
        2626: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2629: aastore
        2630: dup
        2631: bipush        19
        2633: iload         40
        2635: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        2638: aastore
        2639: dup
        2640: bipush        20
        2642: aload         38
        2644: aastore
        2645: dup
        2646: bipush        21
        2648: aload         42
        2650: aastore
        2651: dup
        2652: bipush        22
        2654: aload         44
        2656: aastore
        2657: dup
        2658: bipush        23
        2660: aload         46
        2662: aastore
        2663: dup
        2664: bipush        24
        2666: aload         48
        2668: aastore
        2669: dup
        2670: bipush        25
        2672: aload         50
        2674: aastore
        2675: dup
        2676: bipush        26
        2678: aload         52
        2680: aastore
        2681: dup
        2682: bipush        27
        2684: aload         53
        2686: aastore
        2687: dup
        2688: bipush        28
        2690: aload         54
        2692: aastore
        2693: dup
        2694: bipush        29
        2696: aload         55
        2698: aastore
        2699: dup
        2700: bipush        30
        2702: aload         57
        2704: aastore
        2705: dup
        2706: bipush        31
        2708: aload         56
        2710: aastore
        2711: dup
        2712: bipush        32
        2714: aload         58
        2716: aastore
        2717: dup
        2718: bipush        33
        2720: aload         59
        2722: aastore
        2723: dup
        2724: bipush        34
        2726: aload         61
        2728: aastore
        2729: dup
        2730: bipush        35
        2732: aload         62
        2734: aastore
        2735: dup
        2736: bipush        36
        2738: aload         63
        2740: aastore
        2741: dup
        2742: bipush        37
        2744: aload         70
        2746: aastore
        2747: dup
        2748: bipush        38
        2750: aload         72
        2752: aastore
        2753: dup
        2754: bipush        39
        2756: aload         74
        2758: aastore
        2759: dup
        2760: bipush        40
        2762: aload         95
        2764: aastore
        2765: dup
        2766: bipush        41
        2768: aload         96
        2770: aastore
        2771: dup
        2772: bipush        42
        2774: aload         97
        2776: aastore
        2777: dup
        2778: bipush        43
        2780: aload         98
        2782: aastore
        2783: dup
        2784: bipush        44
        2786: aload         99
        2788: aastore
        2789: dup
        2790: bipush        45
        2792: aload         100
        2794: aastore
        2795: dup
        2796: bipush        46
        2798: aload         101
        2800: aastore
        2801: dup
        2802: bipush        47
        2804: aload         102
        2806: aastore
        2807: dup
        2808: bipush        48
        2810: aload         103
        2812: aastore
        2813: dup
        2814: bipush        49
        2816: aload         104
        2818: aastore
        2819: dup
        2820: bipush        50
        2822: aload         105
        2824: aastore
        2825: dup
        2826: bipush        51
        2828: aload         106
        2830: aastore
        2831: dup
        2832: bipush        52
        2834: aload         107
        2836: aastore
        2837: dup
        2838: bipush        53
        2840: aload         108
        2842: aastore
        2843: dup
        2844: bipush        54
        2846: aload         109
        2848: aastore
        2849: dup
        2850: bipush        55
        2852: aload         111
        2854: aastore
        2855: dup
        2856: bipush        56
        2858: aload         110
        2860: aastore
        2861: dup
        2862: bipush        57
        2864: aload         113
        2866: aastore
        2867: dup
        2868: bipush        58
        2870: aload         112
        2872: aastore
        2873: dup
        2874: bipush        59
        2876: aload         76
        2878: aastore
        2879: dup
        2880: bipush        60
        2882: aload         77
        2884: aastore
        2885: dup
        2886: bipush        61
        2888: aload         75
        2890: aastore
        2891: dup
        2892: bipush        62
        2894: aload         147
        2896: aastore
        2897: dup
        2898: bipush        63
        2900: aload         78
        2902: aastore
        2903: dup
        2904: bipush        64
        2906: aload         146
        2908: aastore
        2909: dup
        2910: bipush        65
        2912: aload         80
        2914: aastore
        2915: dup
        2916: bipush        66
        2918: aload         79
        2920: aastore
        2921: dup
        2922: bipush        67
        2924: aload         81
        2926: aastore
        2927: dup
        2928: bipush        68
        2930: aload         82
        2932: aastore
        2933: dup
        2934: bipush        69
        2936: aload         145
        2938: aastore
        2939: dup
        2940: bipush        70
        2942: aload         144
        2944: aastore
        2945: dup
        2946: bipush        71
        2948: aload         83
        2950: aastore
        2951: dup
        2952: bipush        72
        2954: aload         143
        2956: aastore
        2957: dup
        2958: bipush        73
        2960: aload         142
        2962: aastore
        2963: dup
        2964: bipush        74
        2966: aload         141
        2968: aastore
        2969: dup
        2970: bipush        75
        2972: aload         84
        2974: aastore
        2975: dup
        2976: bipush        76
        2978: aload         85
        2980: aastore
        2981: dup
        2982: bipush        77
        2984: aload         140
        2986: aastore
        2987: dup
        2988: bipush        78
        2990: aload         87
        2992: aastore
        2993: dup
        2994: bipush        79
        2996: aload         88
        2998: aastore
        2999: dup
        3000: bipush        80
        3002: aload         86
        3004: aastore
        3005: dup
        3006: bipush        81
        3008: aload         139
        3010: aastore
        3011: dup
        3012: bipush        82
        3014: aload         93
        3016: aastore
        3017: dup
        3018: bipush        83
        3020: aload         89
        3022: aastore
        3023: dup
        3024: bipush        84
        3026: aload         91
        3028: aastore
        3029: dup
        3030: bipush        85
        3032: aload         92
        3034: aastore
        3035: dup
        3036: bipush        86
        3038: aload         138
        3040: aastore
        3041: dup
        3042: bipush        87
        3044: aload         137
        3046: aastore
        3047: dup
        3048: bipush        88
        3050: aload         136
        3052: aastore
        3053: dup
        3054: bipush        89
        3056: aload         135
        3058: aastore
        3059: dup
        3060: bipush        90
        3062: aload         134
        3064: aastore
        3065: dup
        3066: bipush        91
        3068: aload         133
        3070: aastore
        3071: dup
        3072: bipush        92
        3074: aload         132
        3076: aastore
        3077: dup
        3078: bipush        93
        3080: aload         94
        3082: aastore
        3083: dup
        3084: bipush        94
        3086: aload         131
        3088: aastore
        3089: dup
        3090: bipush        95
        3092: aload         130
        3094: aastore
        3095: dup
        3096: bipush        96
        3098: aload         114
        3100: aastore
        3101: dup
        3102: bipush        97
        3104: aload         115
        3106: aastore
        3107: dup
        3108: bipush        98
        3110: aload         121
        3112: aastore
        3113: dup
        3114: bipush        99
        3116: aload         117
        3118: aastore
        3119: dup
        3120: bipush        100
        3122: aload         60
        3124: aastore
        3125: dup
        3126: bipush        101
        3128: aload         90
        3130: aastore
        3131: dup
        3132: bipush        102
        3134: aload         120
        3136: aastore
        3137: dup
        3138: bipush        103
        3140: aload         119
        3142: aastore
        3143: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3146: astore        148
        3148: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3151: bipush        45
        3153: aload         148
        3155: aastore
        3156: iconst_0
        3157: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3160: astore        149
        3162: iconst_1
        3163: istore        150
        3165: iconst_0
        3166: istore        151
        3168: iload         151
        3170: ifeq          3185
        3173: iload         150
        3175: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3178: astore        152
        3180: goto_w        3213
        3185: iload         150
        3187: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3190: astore        153
        3192: goto_w        3197
        3197: bipush        10
        3199: istore        154
        3201: iload         154
        3203: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3206: astore        155
        3208: goto_w        3229
        3213: bipush        20
        3215: istore        156
        3217: iload         156
        3219: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3222: astore        155
        3224: goto_w        3229
        3229: getstatic     #388                // Field java/lang/System.out:Ljava/io/PrintStream;
        3232: aload         155
        3234: checkcast     #14                 // class java/lang/Integer
        3237: invokevirtual #392                // Method java/lang/Integer.intValue:()I
        3240: invokevirtual #398                // Method java/io/PrintStream.println:(I)V
        3243: iconst_0
        3244: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3247: astore        157
        3249: new           #10                 // class Block
        3252: dup
        3253: iconst_0
        3254: iconst_0
        3255: anewarray     #2                  // class java/lang/Object
        3258: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3261: astore        158
        3263: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3266: bipush        46
        3268: aload         158
        3270: aastore
        3271: iconst_0
        3272: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3275: astore        159
        3277: iconst_0
        3278: istore        160
        3280: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3283: bipush        45
        3285: aaload
        3286: checkcast     #10                 // class Block
        3289: getfield      #401                // Field Block.fields:[Ljava/lang/Object;
        3292: bipush        102
        3294: aaload
        3295: astore        161
        3297: aload         161
        3299: checkcast     #159                // class Closure
        3302: iload         160
        3304: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3307: invokevirtual #405                // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        3310: astore        162
        3312: new           #10                 // class Block
        3315: dup
        3316: iconst_0
        3317: iconst_0
        3318: anewarray     #2                  // class java/lang/Object
        3321: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        3324: astore        163
        3326: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
        3329: bipush        47
        3331: aload         163
        3333: aastore
        3334: iconst_0
        3335: invokestatic  #18                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        3338: astore        164
        3340: return
    }
    |}]
